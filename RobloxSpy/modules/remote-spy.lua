--[[
    RobloxSpy — modules/remote-spy.lua
    Main Remote Spy module (v1.1.0)

    Wires Hooks → Session → GUI together.
    • Live feed with filters, search, grouping of identical calls (×N)
    • Detail panel: info, stats, arguments (+ diff with previous call),
      InvokeServer return values, R2S / replay code, actions
    • Keyword alerts, watchlist, per-game ignore / block lists
]]

local Compat = require(script.Parent.Parent.core.compat)
local Serializer = require(script.Parent.Parent.core.serializer)
local Hooks = require(script.Parent.Parent.core.hooks)
local Session = require(script.Parent.Parent.core.session)
local Errors = require(script.Parent.Parent.core.errors)
local Framework = require(script.Parent.Parent.gui.framework)
local Theme = require(script.Parent.Parent.gui.theme)
local Icons = require(script.Parent.Parent.gui.icons)
local LogEntry = require(script.Parent.Parent.gui.components["log-entry"])
local SearchBar = require(script.Parent.Parent.gui.components["search-bar"])
local I18n = require(script.Parent.Parent.core.i18n)
local Config = require(script.Parent.Parent.core.config)

local T = I18n.T

local create = Framework.create
local applyCorner = Framework.applyCorner
local applyPadding = Framework.applyPadding

local RemoteSpy = {}

local _feedScroll = nil
local _emptyState = nil
local _entries = {}     -- { data, frame, hidden }
local _maxVisible = 500 -- max rows kept (older ones removed)
local _autoScroll = Config.get("autoScroll") ~= false
local _filterText = ""
local _filterType = nil -- nil = all | fire | invoke | incoming | clientinvoke | bindable | block | watched
local _paused = false
local _entryCount = 0
local _serial = 0       -- never reset: used by incremental auto-save
local _startClock = os.clock()

local _lastData = nil   -- last created entry (grouping)
local _byCapture = {}   -- [captureId] = entry data (to attach InvokeServer results)
local _stats = {}       -- [remote] = { count, first, last, callers = {}, nCallers }
local _alertCooldown = {}
local _watched = {}     -- [fullName] = true
local _keywords = {}

-- Detail panel
local _detail = nil
local _detailData = nil
local _detail_refreshExpand = nil

-- ── HELPERS ─────────────────────────────────────────────────────

local function smallButton(parent, name, text, color, order, tip)
    local btn = create("TextButton", {
        Name = name,
        Size = UDim2.new(0, 0, 0, Framework.IS_MOBILE and 30 or 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = color or Theme.Colors.BgTertiary,
        BackgroundTransparency = 0.45,
        Text = text,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    applyCorner(btn, Theme.CornerRadius.SM)
    applyPadding(btn, 2, 8, 2, 8)
    if tip then Framework.tooltip(btn, tip) end
    return btn
end

local function serializeArgs(args)
    local ok, out = pcall(Serializer.serializeArgs, args or {})
    return ok and out or {}
end

local function loadKeywords()
    _keywords = {}
    for raw in tostring(Config.get("alertKeywords") or ""):gmatch("[^,]+") do
        local word = raw:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if word ~= "" then table.insert(_keywords, word) end
    end
end

local function loadWatched()
    _watched = {}
    for _, p in ipairs(Config.getGameList("watch")) do _watched[p] = true end
end

local function matchesKeyword(name)
    name = tostring(name or ""):lower()
    for _, k in ipairs(_keywords) do
        if name:find(k, 1, true) then return k end
    end
    return nil
end

-- Builds the code shown in the detail panel / copied by the copy button
local function buildCode(event)
    if not event then return "-- no event" end
    if event.method == "OnClientEvent" or event.type == "clientinvoke" then
        local isInvoke = event.type == "clientinvoke"
        local lines = {
            isInvoke and T("code_clientinvoke") or T("code_incoming"),
            "-- Remote: " .. tostring(event.remotePath or "?"),
            isInvoke and T("code_clientinvoke_note") or T("code_replay"),
            "",
        }
        local okPath, path = pcall(Serializer.serialize, event.remote)
        table.insert(lines, "local remote = " .. (okPath and path or "nil"))
        local names = {}
        for _, a in ipairs(serializeArgs(event.args)) do
            table.insert(lines, "local arg" .. a.index .. " = " .. a.value)
            table.insert(names, "arg" .. a.index)
        end
        table.insert(lines, "")
        if not isInvoke then
            local call = "firesignal(remote.OnClientEvent"
            if #names > 0 then call = call .. ", " .. table.concat(names, ", ") end
            table.insert(lines, call .. ")")
        end
        return table.concat(lines, "\n")
    end
    if event.r2s and event.r2s ~= "" then return event.r2s end
    local ok, code = pcall(Serializer.generateR2S, event.remote, event.method, event.args)
    if ok and code then return code end
    return "-- R2S generation failed: " .. tostring(code)
end

local function entryTypeOf(event)
    if event.blocked then return "block" end
    if event.type == "clientinvoke" then return "clientinvoke" end
    if event.type == "bindable" then return "bindable" end
    if event.method == "InvokeServer" then return "invoke" end
    if event.method == "OnClientEvent" then return "incoming" end
    return "fire"
end

local function updateEmptyState()
    if not _emptyState then return end
    local anyVisible = false
    for _, e in ipairs(_entries) do
        if e.frame and e.frame.Visible then anyVisible = true; break end
    end
    _emptyState.Visible = not anyVisible
    local txt = _emptyState:FindFirstChild("Text")
    if txt then
        txt.Text = (#_entries == 0) and T("empty_feed") or T("empty_filter")
    end
end

-- ── BUILD UI ────────────────────────────────────────────────────

function RemoteSpy.buildUI(tabContent)
    loadKeywords()
    loadWatched()

    local barH = Framework.IS_MOBILE and 40 or 34

    local toolbar = create("ScrollingFrame", {
        Name = "Toolbar",
        Size = UDim2.new(1, 0, 0, barH),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        ScrollBarThickness = Framework.IS_MOBILE and 4 or 2,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = tabContent,
    })
    applyPadding(toolbar, 4, 6, 4, 6)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = toolbar,
    })

    local pauseBtn = smallButton(toolbar, "Pause", Hooks.isPaused() and T("resume") or T("pause"),
        Hooks.isPaused() and Theme.Colors.Success or Theme.Colors.Warning, 1, T("tip_pause"))
    local clearBtn = smallButton(toolbar, "Clear", T("clear"), Theme.Colors.Error, 2, T("tip_clear"))

    local filters = {
        { "All", T("f_all"), nil },
        { "Fire", T("f_fire"), "fire" },
        { "Invoke", T("f_invoke"), "invoke" },
        { "Incoming", T("f_incoming"), "incoming" },
        { "ClientInvoke", T("f_clientinvoke"), "clientinvoke" },
        { "Bindable", T("f_bindable"), "bindable" },
        { "Blocked", T("f_blocked"), "block" },
        { "Watched", T("f_watched"), "watched" },
    }
    for i, f in ipairs(filters) do
        local name, text, ftype = f[1], f[2], f[3]
        local fb = smallButton(toolbar, "Filter_" .. name, text, Theme.Colors.BgTertiary, 10 + i)
        fb.TextColor3 = Theme.Colors.TextSecondary
        if name == "All" then
            fb.BackgroundColor3 = Theme.Colors.Accent
            fb.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        fb.Activated:Connect(function()
            _filterType = ftype
            RemoteSpy._refreshFilter()
            for _, c in ipairs(toolbar:GetChildren()) do
                if c:IsA("TextButton") and c.Name:match("^Filter_") then
                    local isActive = (c.Name == "Filter_" .. name)
                    c.BackgroundColor3 = isActive and Theme.Colors.Accent or Theme.Colors.BgTertiary
                    c.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.Colors.TextSecondary
                end
            end
        end)
    end

    local searchContainer = create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, barH),
        BackgroundTransparency = 1,
        Parent = tabContent,
    })
    applyPadding(searchContainer, 2, 6, 2, 6)

    local search = SearchBar.new(searchContainer, {
        Placeholder = T("search_spy"),
        OnChange = function(text)
            _filterText = text:lower()
            RemoteSpy._refreshFilter()
        end,
    })
    RemoteSpy._searchBar = search

    _feedScroll = Framework.createScrollFrame(tabContent, {
        Name = "Feed",
        Size = UDim2.new(1, 0, 1, -(barH + 32)),
        Position = UDim2.new(0, 0, 0, barH + 32),
        Padding = 2,
        InnerPadding = 4,
    })
    _emptyState = Framework.emptyState(_feedScroll, T("empty_feed"), "spy")

    RemoteSpy._buildDetailPanel(tabContent)

    pauseBtn.Activated:Connect(function()
        _paused = not _paused
        if _paused then
            Hooks.pause()
            pauseBtn.Text = T("resume")
            pauseBtn.BackgroundColor3 = Theme.Colors.Success
        else
            Hooks.resume()
            pauseBtn.Text = T("pause")
            pauseBtn.BackgroundColor3 = Theme.Colors.Warning
        end
    end)

    clearBtn.Activated:Connect(function()
        RemoteSpy.clearFeed()
        Framework.notify(T("feed_cleared"), "info", 1.5)
    end)

    -- UI rebuilt (language / theme change): re-create rows for kept entries
    _paused = Hooks.isPaused()
    _detailData = nil
    _filterType = nil
    _filterText = ""
    for _, entry in ipairs(_entries) do
        entry.frame = nil
    end
    RemoteSpy._refreshFilter()
end

-- Filters the feed on one remote (used by the Network tab)
function RemoteSpy.filterByRemote(name)
    _filterType = nil
    _filterText = tostring(name or ""):lower()
    pcall(function()
        if RemoteSpy._searchBar and RemoteSpy._searchBar.setText then
            RemoteSpy._searchBar:setText(name)
        end
    end)
    RemoteSpy._refreshFilter()
end

-- ── DETAIL PANEL ────────────────────────────────────────────────

function RemoteSpy._buildDetailPanel(tabContent)
    local frame = create("Frame", {
        Name = "DetailPanel",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        Parent = tabContent,
    })

    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = frame,
    })
    local backBtn = create("TextButton", {
        Name = "Back",
        Size = UDim2.new(0, 66, 0, 24),
        Position = UDim2.new(0, 6, 0.5, -12),
        BackgroundColor3 = Theme.Colors.BgTertiary,
        Text = T("back"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        ZIndex = 22,
        Parent = header,
    })
    applyCorner(backBtn, Theme.CornerRadius.SM)

    local expandBtn = create("TextButton", {
        Name = "Expand",
        Size = UDim2.new(0, 30, 0, 24),
        Position = UDim2.new(1, -36, 0.5, -12),
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = 0.4,
        Text = "",
        ZIndex = 22,
        Parent = header,
    })
    applyCorner(expandBtn, Theme.CornerRadius.SM)
    Framework.tooltip(expandBtn, T("tip_expand"))

    local title = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -122, 1, 0),
        Position = UDim2.new(0, 78, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Heading,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 22,
        Parent = header,
    })

    local actions = create("ScrollingFrame", {
        Name = "Actions",
        Size = UDim2.new(1, 0, 0, Framework.IS_MOBILE and 38 or 32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        BorderSizePixel = 0,
        ScrollBarThickness = Framework.IS_MOBILE and 4 or 2,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ZIndex = 21,
        Parent = frame,
    })
    applyPadding(actions, 4, 6, 4, 6)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actions,
    })

    local btnCopyCode = smallButton(actions, "CopyCode", T("copy_code"), Theme.Colors.Accent, 1, T("tip_copy_r2s"))
    local btnCopyPath = smallButton(actions, "CopyPath", T("copy_path"), Theme.Colors.BgTertiary, 2)
    local btnCopyArgs = smallButton(actions, "CopyArgs", T("copy_args"), Theme.Colors.BgTertiary, 3)
    local btnRefire   = smallButton(actions, "Refire", T("refire"), Theme.Colors.Success, 4, T("tip_refire"))
    local btnWatch    = smallButton(actions, "Watch", T("watch"), Theme.Colors.Warning, 5, T("tip_watch"))
    local btnIgnore   = smallButton(actions, "Ignore", T("ignore"), Theme.Colors.Warning, 6, T("tip_ignore"))
    local btnDrop     = smallButton(actions, "Drop", T("drop"), Theme.Colors.Error, 7, T("tip_drop"))
    local btnDelete   = smallButton(actions, "Delete", T("delete"), Theme.Colors.Error, 8, T("tip_delete"))
    for _, b in ipairs(actions:GetChildren()) do
        if b:IsA("GuiObject") then b.ZIndex = 22 end
    end

    local actionsH = Framework.IS_MOBILE and 38 or 32
    local scroll = Framework.createScrollFrame(frame, {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -(32 + actionsH)),
        Position = UDim2.new(0, 0, 0, 32 + actionsH),
        Padding = 6,
        InnerPadding = 8,
    })
    scroll.ZIndex = 21

    _detail = {
        frame = frame, scroll = scroll, title = title,
        btnIgnore = btnIgnore, btnDrop = btnDrop, btnRefire = btnRefire, btnWatch = btnWatch,
    }

    backBtn.Activated:Connect(function() RemoteSpy.closeDetail() end)

    local expandIcon = nil
    local function refreshExpandIcon()
        local w = Framework.getMainWindow and Framework.getMainWindow()
        if expandIcon then expandIcon:Destroy() end
        expandIcon = Icons.draw((w and w:isMaximized()) and "restore" or "maximize", expandBtn, 13,
            Color3.fromRGB(255, 255, 255), Theme.Colors.AccentDim)
        expandIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        expandIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        expandIcon.ZIndex = 23
    end
    refreshExpandIcon()
    expandBtn.Activated:Connect(function()
        local w = Framework.getMainWindow and Framework.getMainWindow()
        if not w then return end
        w:toggleMaximize()
        _detail.expandedByDetail = w:isMaximized()
        refreshExpandIcon()
    end)
    _detail_refreshExpand = refreshExpandIcon

    btnCopyCode.Activated:Connect(function()
        if _detailData then Framework.copy(buildCode(_detailData._event), T("c_code")) end
    end)
    btnCopyPath.Activated:Connect(function()
        if _detailData then Framework.copy(_detailData.path ~= "" and _detailData.path or _detailData.remote, T("c_path")) end
    end)
    btnCopyArgs.Activated:Connect(function()
        if not _detailData then return end
        local lines = {}
        for _, a in ipairs(serializeArgs(_detailData._event and _detailData._event.args)) do
            table.insert(lines, string.format("[%d] (%s) %s", a.index, a.type, a.value))
        end
        Framework.copy(#lines > 0 and table.concat(lines, "\n") or T("no_args"), T("c_args"))
    end)
    btnRefire.Activated:Connect(function()
        local ev = _detailData and _detailData._event
        if not ev or not ev.remote then return end
        if ev.method ~= "FireServer" and ev.method ~= "InvokeServer" then
            Framework.notify(T("n_refire_only_out"), "warning")
            return
        end
        task.spawn(function()
            local args = ev.args or {}
            local n = args.n or #args
            local ok, err = pcall(function()
                if ev.method == "FireServer" then
                    ev.remote:FireServer(table.unpack(args, 1, n))
                else
                    ev.remote:InvokeServer(table.unpack(args, 1, n))
                end
            end)
            if ok then
                Framework.notify(T("n_refired", tostring(_detailData and _detailData.remote or "")), "success")
            else
                Framework.notify(T("n_refire_fail", tostring(err)), "error")
            end
        end)
    end)
    btnWatch.Activated:Connect(function()
        if not _detailData then return end
        RemoteSpy.toggleWatch(_detailData)
        RemoteSpy._refreshDetailButtons()
    end)
    btnIgnore.Activated:Connect(function()
        if not _detailData then return end
        RemoteSpy.toggleIgnore(_detailData)
        RemoteSpy._refreshDetailButtons()
    end)
    btnDrop.Activated:Connect(function()
        local ev = _detailData and _detailData._event
        if not ev or not ev.remote then return end
        if ev.method ~= "FireServer" and ev.method ~= "InvokeServer" then
            Framework.notify(T("n_cant_block_in"), "warning")
            return
        end
        local name = Hooks.getFullName(ev.remote)
        if Hooks.isDropped(ev.remote) then
            Hooks.undropRemote(ev.remote)
            Config.setGameRule("drop", name, false)
            Framework.notify(T("n_allowed", _detailData.remote), "info")
        else
            Hooks.dropRemote(ev.remote)
            Config.setGameRule("drop", name, true)
            Framework.notify(T("n_blocked", _detailData.remote) .. " · " .. T("n_saved_game"), "warning")
        end
        RemoteSpy._refreshDetailButtons()
    end)
    btnDelete.Activated:Connect(function()
        if not _detailData then return end
        RemoteSpy.deleteEntry(_detailData)
        RemoteSpy.closeDetail()
    end)
end

function RemoteSpy.toggleIgnore(d)
    local remote = d._event and d._event.remote
    if not remote then return end
    local name = Hooks.getFullName(remote)
    if Hooks.isBlocked(remote) then
        Hooks.unblockRemote(remote)
        Config.setGameRule("ignore", name, false)
        Framework.notify(T("n_log_resumed", d.remote), "info")
    else
        Hooks.blockRemote(remote)
        Config.setGameRule("ignore", name, true)
        Framework.notify(T("n_ignored", d.remote) .. " · " .. T("n_saved_game"), "warning")
    end
end

function RemoteSpy.toggleWatch(d)
    local name = d._event and d._event.remoteFullName or d.path
    if not name then return end
    local on = not _watched[name]
    _watched[name] = on or nil
    Config.setGameRule("watch", name, on)
    for _, e in ipairs(_entries) do
        local en = e.data._event and e.data._event.remoteFullName
        if en == name then
            e.data.watched = on
            if e.frame then LogEntry.setWatched(e.frame, on) end
        end
    end
    Framework.notify(on and T("n_watch_on", d.remote) or T("n_watch_off", d.remote), on and "success" or "info", 2)
    if _filterType == "watched" then RemoteSpy._refreshFilter() end
end

function RemoteSpy._refreshDetailButtons()
    if not _detail or not _detailData then return end
    local ev = _detailData._event
    local remote = ev and ev.remote
    _detail.btnIgnore.Text = (remote and Hooks.isBlocked(remote)) and T("unignore") or T("ignore")
    _detail.btnDrop.Text = (remote and Hooks.isDropped(remote)) and T("undrop") or T("drop")
    _detail.btnWatch.Text = _detailData.watched and T("unwatch") or T("watch")
    local outgoing = ev and (ev.method == "FireServer" or ev.method == "InvokeServer")
    _detail.btnRefire.Visible = outgoing and true or false
    _detail.btnDrop.Visible = outgoing and true or false
end

local function section(parent, order, titleText)
    create("TextLabel", {
        Name = "Section_" .. order,
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Theme.Colors.TextAccent,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        ZIndex = 22,
        Parent = parent,
    })
end

local function infoRow(parent, order, key, value, valueColor, note)
    local row = create("Frame", {
        Name = "Info_" .. order,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 22,
        Parent = parent,
    })
    applyCorner(row, Theme.CornerRadius.SM)
    applyPadding(row, 4, 8, 4, 8)
    create("TextLabel", {
        Size = UDim2.new(0, 96, 0, 14),
        BackgroundTransparency = 1,
        Text = key,
        TextColor3 = Theme.Colors.TextSecondary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 23,
        Parent = row,
    })
    local text = tostring(value)
    if note then text = text .. "\n" .. note end
    create("TextBox", {
        Size = UDim2.new(1, -100, 0, 0),
        Position = UDim2.new(0, 100, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text,
        TextEditable = false,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextColor3 = valueColor or Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
        Parent = row,
    })
end

-- Code block styled like the Script Viewer: numbered lines, no wrapping,
-- its own horizontal scroll bar for long lines.
local TextService = game:GetService("TextService")
local function codeBlock(parent, order, text)
    text = tostring(text or "")
    local size = Framework.IS_MOBILE and 13 or Theme.TextSizes.Code
    local lines = {}
    for line in (text .. "\n"):gmatch("(.-)\n") do table.insert(lines, line) end
    if #lines > 1 and lines[#lines] == "" then table.remove(lines) end
    local width = #tostring(#lines)
    for i, l in ipairs(lines) do
        lines[i] = string.format("%" .. width .. "d │ %s", i, l)
    end
    local numbered = table.concat(lines, "\n")
    local okSz, bounds = pcall(function()
        return TextService:GetTextSize(numbered, size, Theme.Fonts.Code, Vector2.new(100000, 100000))
    end)
    local textW = (okSz and bounds) and bounds.X or (#numbered * size * 0.6)
    local textH = (okSz and bounds) and bounds.Y or (#lines * (size + 2))
    local barH = Framework.IS_MOBILE and 8 or 5

    local holder = create("Frame", {
        Name = "Code_" .. order,
        Size = UDim2.new(1, 0, 0, textH + 14 + barH),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        ZIndex = 22,
        Parent = parent,
    })
    applyCorner(holder, Theme.CornerRadius.SM)
    local sc = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollBarThickness = barH,
        ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110),
        CanvasSize = UDim2.new(0, textW + 20, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ZIndex = 22,
        Parent = holder,
    })
    create("TextBox", {
        Size = UDim2.new(0, textW + 4, 0, textH),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = numbered,
        TextEditable = false,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = false,
        TextColor3 = Color3.fromRGB(190, 220, 255),
        Font = Theme.Fonts.Code,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 23,
        Parent = sc,
    })
    return holder
end

-- Previous call of the same remote (for the argument diff)
local function findPrevious(data)
    local remote = data._event and data._event.remote
    if not remote then return nil end
    local found = false
    for i = #_entries, 1, -1 do
        local d = _entries[i].data
        if found and d._event and d._event.remote == remote and d.type == data.type then
            return d
        end
        if d == data then found = true end
    end
    return nil
end

local function fmtClock(c)
    return string.format("+%.1fs", (tonumber(c) or _startClock) - _startClock)
end

function RemoteSpy.openDetail(data)
    if not _detail then return end
    _detailData = data
    local ev = data._event or {}
    local scroll = _detail.scroll

    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    _detail.title.Text = string.format("%s  %s", Theme.getRemoteLabel(data.type), data.remote or "?")
    _detail.title.TextColor3 = Theme.getRemoteColor(data.type)

    -- Info
    section(scroll, 1, T("sec_info"))
    local caller = data.caller
    if not caller and ev.callingScript then
        pcall(function() caller = ev.callingScript:GetFullName() end)
    end
    local status = T("st_logged")
    if ev.remote and Hooks.isDropped(ev.remote) then status = T("st_dropped")
    elseif ev.remote and Hooks.isBlocked(ev.remote) then status = T("st_ignored") end
    if data.watched then status = status .. "  ·  " .. T("st_watched") end

    local direction = T("dir_out")
    if ev.method == "OnClientEvent" or ev.type == "clientinvoke" then direction = T("dir_in")
    elseif ev.type == "bindable" then direction = T("dir_local") end

    local rows = {
        { T("k_remote"),   data.remote or "?" },
        { T("k_class"),    data.class ~= "" and data.class or (ev.remoteType or "?") },
        { T("k_method"),   ev.method or "?" },
        { T("k_direction"), direction },
        { T("k_path"),     data.path ~= "" and data.path or "?" },
        { T("k_caller"),   caller or T("caller_unknown") },
        { T("k_call"),     tostring(ev.id or data.index or "?") },
        { T("k_time"),     T("time_fmt", (tonumber(ev.timestamp) or _startClock) - _startClock) },
        { T("k_status"),   status },
    }
    if (data.count or 1) > 1 then
        table.insert(rows, { T("k_grouped"), T("grouped_fmt", data.count) })
    end
    if (data.skipped or 0) > 0 then
        table.insert(rows, { T("k_flood"), T("flood_fmt", data.skipped) })
    end
    for i, r in ipairs(rows) do
        infoRow(scroll, 1 + i, r[1], r[2])
    end

    -- Stats for this remote
    local st = ev.remote and _stats[ev.remote]
    if st then
        section(scroll, 30, T("sec_stats"))
        local elapsed = math.max(1, os.clock() - st.first)
        local callers = {}
        for name in pairs(st.callers) do table.insert(callers, name) end
        table.sort(callers)
        infoRow(scroll, 31, T("k_total"), tostring(st.count))
        infoRow(scroll, 32, T("k_rate"), T("rate_fmt", st.count / elapsed * 60))
        infoRow(scroll, 33, T("k_first_last"), fmtClock(st.first) .. "  →  " .. fmtClock(st.last))
        infoRow(scroll, 34, T("k_callers"), #callers > 0 and table.concat(callers, "\n") or T("caller_unknown"))
    end

    -- Arguments (+ diff with the previous call of the same remote)
    local args = serializeArgs(ev.args)
    local prev = findPrevious(data)
    local prevArgs = prev and serializeArgs(prev._event and prev._event.args) or nil
    section(scroll, 40, T("sec_args", #args) .. (prevArgs and ("  ·  " .. T("diff_hint")) or ""))
    if #args == 0 then
        infoRow(scroll, 41, "—", T("no_args"))
    else
        for i, a in ipairs(args) do
            local color, note = nil, nil
            if prevArgs then
                local p = prevArgs[i]
                if not p or p.value ~= a.value then
                    color = Theme.Colors.Warning
                    note = T("diff_was", p and p.value or "—")
                end
            end
            infoRow(scroll, 40 + i, string.format("[%d] %s", a.index, a.type), a.value, color, note)
        end
    end

    -- InvokeServer return value
    if ev.method == "InvokeServer" then
        section(scroll, 300, T("sec_return"))
        if data.result then
            if #data.result == 0 then
                infoRow(scroll, 301, "—", T("ret_nothing"))
            else
                for i, r in ipairs(data.result) do
                    infoRow(scroll, 300 + i, string.format("[%d] %s", r.index, r.type), r.value, Theme.Colors.InvokeServer)
                end
            end
        else
            infoRow(scroll, 301, "—", Hooks.getCaptureReturns() and T("ret_waiting") or T("ret_disabled"))
        end
    end

    -- Code
    local isIn = ev.method == "OnClientEvent" or ev.type == "clientinvoke"
    section(scroll, 500, isIn and T("sec_replay") or T("sec_r2s"))
    codeBlock(scroll, 501, buildCode(ev))

    RemoteSpy._refreshDetailButtons()
    if _detail_refreshExpand then _detail_refreshExpand() end
    _detail.frame.Visible = true
    scroll.CanvasPosition = Vector2.new(0, 0)
end

function RemoteSpy.closeDetail()
    if _detail then
        _detail.frame.Visible = false
        if _detail.expandedByDetail then
            _detail.expandedByDetail = false
            local w = Framework.getMainWindow and Framework.getMainWindow()
            if w and w:isMaximized() then w:toggleMaximize(false) end
        end
    end
    _detailData = nil
end

-- ── FEED MANAGEMENT ─────────────────────────────────────────────

local function recordStats(event, data)
    local remote = event.remote
    if not remote then return end
    local st = _stats[remote]
    if not st then
        st = { count = 0, first = event.timestamp or os.clock(), last = 0, callers = {}, nCallers = 0 }
        _stats[remote] = st
    end
    st.count = st.count + 1
    st.last = event.timestamp or os.clock()
    if data.caller and not st.callers[data.caller] and st.nCallers < 20 then
        st.callers[data.caller] = true
        st.nCallers = st.nCallers + 1
    end
end

function RemoteSpy.getStats()
    return _stats
end

function RemoteSpy.addEntry(event)
    if not _feedScroll then return end

    local entryData = {
        t      = event.timestamp and math.floor((event.timestamp - _startClock) * 1000) or 0,
        type   = entryTypeOf(event),
        remote = "",
        class  = "",
        args   = "",
        path   = "",
        caller = nil,
        count  = 1,
        skipped = event.floodSkipped or 0,
        _event = event,
    }

    pcall(function() entryData.remote = event.remote.Name end)
    pcall(function() entryData.class = event.remote.ClassName end)
    pcall(function() entryData.path = Serializer.getInstancePath(event.remote) end)
    if entryData.path == "" and event.remotePath then entryData.path = event.remotePath end
    pcall(function() entryData.args = Serializer.summarize(event.args, 120) end)
    pcall(function()
        local c = event.callingScript or event.caller
        if c then entryData.caller = c:GetFullName() end
    end)
    entryData.watched = event.remoteFullName and _watched[event.remoteFullName] or false
    if entryData.skipped > 0 then
        entryData.args = T("skipped_prefix", entryData.skipped) .. " " .. entryData.args
    end

    recordStats(event, entryData)
    Framework.bumpUnread()

    -- Grouping: identical consecutive call within 3 s → "×N" on the same row
    local last = _lastData
    if Config.get("groupDuplicates") ~= false and last and last._event
        and last._event.remote == event.remote and last.type == entryData.type
        and last.args == entryData.args and (entryData.t - (last.lastT or last.t)) < 3000 then
        last.count = last.count + 1
        last.lastT = entryData.t
        last._event = event -- newest call wins (code, return value)
        if event.captureId then _byCapture[event.captureId] = last end
        for i = #_entries, math.max(1, #_entries - 3), -1 do
            if _entries[i].data == last then
                if _entries[i].frame then LogEntry.setCount(_entries[i].frame, last.count) end
                break
            end
        end
        if _detailData == last then RemoteSpy.openDetail(last) end
        return
    end

    _entryCount = _entryCount + 1
    _serial = _serial + 1
    entryData.index = _entryCount
    entryData.serial = _serial
    if event.captureId then _byCapture[event.captureId] = entryData end
    _lastData = entryData

    -- Keyword alert (throttled per remote)
    local kw = matchesKeyword(entryData.remote)
    if kw and Config.get("alertsEnabled") ~= false then
        entryData.alert = kw
        local key = event.remote
        if not _alertCooldown[key] or os.clock() - _alertCooldown[key] > 5 then
            _alertCooldown[key] = os.clock()
            Framework.notify(T("n_alert", entryData.remote, kw), "warning", 3)
        end
    end

    local entry = { data = entryData, frame = nil, hidden = true }
    table.insert(_entries, entry)
    if RemoteSpy._matchesFilter(entryData) then
        entry.frame = RemoteSpy._createRow(entryData)
        entry.hidden = false
    end

    -- Trim old entries
    while #_entries > _maxVisible do
        local oldest = table.remove(_entries, 1)
        if oldest.frame then oldest.frame:Destroy() end
        if oldest.data._event and oldest.data._event.captureId then
            _byCapture[oldest.data._event.captureId] = nil
        end
    end

    updateEmptyState()

    if _autoScroll and _feedScroll and entry.frame then
        task.defer(function()
            _feedScroll.CanvasPosition = Vector2.new(0, _feedScroll.AbsoluteCanvasSize.Y)
        end)
    end
end

-- InvokeServer returned: attach the values to the matching row
function RemoteSpy.attachResult(resultEvent)
    local data = resultEvent.captureId and _byCapture[resultEvent.captureId]
    if not data then return end
    data.result = serializeArgs(resultEvent.args)
    for i = #_entries, 1, -1 do
        if _entries[i].data == data then
            if _entries[i].frame then LogEntry.setReturned(_entries[i].frame, true) end
            break
        end
    end
    if _detailData == data then RemoteSpy.openDetail(data) end
end

function RemoteSpy._createRow(entryData)
    local row = LogEntry.new(_feedScroll, entryData, {
        onSelect = function(d) RemoteSpy.openDetail(d) end,
        onCopy = function(d) RemoteSpy._copyR2S(d) end,
        onBlock = function(d) RemoteSpy.toggleIgnore(d) end,
        onDelete = function(d) RemoteSpy.deleteEntry(d) end,
    })
    if (entryData.count or 1) > 1 then LogEntry.setCount(row, entryData.count) end
    if entryData.result then LogEntry.setReturned(row, true) end
    if entryData.watched then LogEntry.setWatched(row, true) end
    if entryData.alert then LogEntry.setAlert(row, true) end
    return row
end

function RemoteSpy.deleteEntry(data)
    for i, entry in ipairs(_entries) do
        if entry.data == data then
            if entry.frame then entry.frame:Destroy() end
            table.remove(_entries, i)
            if _lastData == data then _lastData = nil end
            updateEmptyState()
            return true
        end
    end
    return false
end

function RemoteSpy.clearFeed()
    for _, entry in ipairs(_entries) do
        if entry.frame then entry.frame:Destroy() end
    end
    _entries = {}
    _entryCount = 0
    _lastData = nil
    _byCapture = {}
    RemoteSpy.closeDetail()
    updateEmptyState()
end

function RemoteSpy.getEntries()
    return _entries
end

function RemoteSpy.setAutoScroll(enabled)
    _autoScroll = enabled and true or false
    Config.set("autoScroll", _autoScroll)
end

function RemoteSpy.getAutoScroll()
    return _autoScroll
end

function RemoteSpy.setMaxVisible(n)
    _maxVisible = math.max(50, tonumber(n) or 500)
end

function RemoteSpy.reloadKeywords()
    loadKeywords()
end

local function entryText(d, lines)
    local countStr = (d.count or 1) > 1 and ("  ×" .. d.count) or ""
    table.insert(lines, string.format("[%s] %s%s  %s", Theme.getRemoteLabel(d.type), d.remote or "?", countStr, d.path or ""))
    table.insert(lines, "    args: " .. (d.args or ""))
    if d.caller then table.insert(lines, "    caller: " .. d.caller) end
    if d.result then
        local parts = {}
        for _, r in ipairs(d.result) do table.insert(parts, r.value) end
        table.insert(lines, "    returned: " .. (#parts > 0 and table.concat(parts, ", ") or "nothing"))
    end
    local okC, code = pcall(buildCode, d._event)
    if okC then
        for l in tostring(code):gmatch("[^\n]+") do
            table.insert(lines, "    | " .. l)
        end
    end
    table.insert(lines, "")
end

-- Plain-text dump of the current feed (export / clipboard)
function RemoteSpy.exportText()
    local lines = {
        T("log_export_title"),
        "Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "Executor: " .. tostring(Compat.ExecutorName or "Unknown"),
        string.rep("=", 60),
    }
    for _, entry in ipairs(_entries) do
        entryText(entry.data, lines)
    end
    return table.concat(lines, "\n")
end

-- Only the entries created after `sinceSerial` (incremental auto-save).
-- Returns text, newestSerial.
function RemoteSpy.exportTextSince(sinceSerial)
    sinceSerial = sinceSerial or 0
    local lines = {}
    local newest = sinceSerial
    for _, entry in ipairs(_entries) do
        local d = entry.data
        if (d.serial or 0) > sinceSerial then
            entryText(d, lines)
            newest = math.max(newest, d.serial or 0)
        end
    end
    return table.concat(lines, "\n"), newest
end

-- ── FILTERING ───────────────────────────────────────────────────

function RemoteSpy._matchesFilter(data)
    if _filterType then
        if _filterType == "watched" then
            if not data.watched then return false end
        elseif data.type ~= _filterType then
            return false
        end
    end
    if _filterText ~= "" then
        local haystack = (data.remote or ""):lower()
            .. " " .. (data.args or ""):lower()
            .. " " .. (data.path or ""):lower()
            .. " " .. (data.caller or ""):lower()
        if not haystack:find(_filterText, 1, true) then
            return false
        end
    end
    return true
end

function RemoteSpy._refreshFilter()
    if not _feedScroll then return end
    for _, entry in ipairs(_entries) do
        local show = RemoteSpy._matchesFilter(entry.data)
        if entry.frame then
            entry.frame.Visible = show
        elseif show then
            entry.frame = RemoteSpy._createRow(entry.data)
            entry.hidden = false
        end
    end
    updateEmptyState()
end

-- ── R2S (REMOTE TO SCRIPT) ─────────────────────────────────────

function RemoteSpy._copyR2S(data)
    local event = data._event
    if not event then return end
    Framework.copy(buildCode(event), T("c_r2s"))
end

-- ── LIFECYCLE ───────────────────────────────────────────────────

local _subscribed = false

function RemoteSpy.start()
    pcall(Session.start)

    -- Saved per-game ignore / block rules
    Hooks.setPathRules(Config.getGameList("ignore"), Config.getGameList("drop"))

    if not _subscribed then
        _subscribed = true
        Hooks.subscribe(function(event)
            local okGui, errGui = pcall(RemoteSpy.addEntry, event)
            if not okGui then Errors.add("RemoteSpy.addEntry", errGui) end
            local okS, errS = pcall(Session.record, event)
            if not okS then Errors.add("Session.record", errS) end
        end)
        Hooks.onResult(function(ev)
            local ok, err = pcall(RemoteSpy.attachResult, ev)
            if not ok then Errors.add("RemoteSpy.attachResult", err) end
        end)
    end

    Hooks.start()
end

function RemoteSpy.stop()
    Hooks.stop()
    Session.stop()
end

return RemoteSpy
