--[[
    RobloxSpy — modules/remote-spy.lua
    Main Remote Spy module

    Wires Hooks → Session → GUI together.
    Provides the live feed of intercepted remote calls,
    plus a detail panel for each event (info, args, R2S code, actions).
]]

local Compat = require(script.Parent.Parent.core.compat)
local Serializer = require(script.Parent.Parent.core.serializer)
local Hooks = require(script.Parent.Parent.core.hooks)
local Session = require(script.Parent.Parent.core.session)
local Framework = require(script.Parent.Parent.gui.framework)
local Theme = require(script.Parent.Parent.gui.theme)
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
local _entries = {}     -- GUI entry frames
local _maxVisible = 500 -- max visible rows (older ones removed from GUI)
local _autoScroll = Config.get("autoScroll") ~= false
local _filterText = ""
local _filterType = nil -- nil = all, "fire", "invoke", "incoming", "block"
local _paused = false
local _entryCount = 0
local _startClock = os.clock() -- feed times are relative to spy start

-- Detail panel
local _detail = nil      -- { frame, scroll, ... }
local _detailData = nil  -- entry data currently shown
local _detail_refreshExpand = nil

-- ── HELPERS ─────────────────────────────────────────────────────

local function smallButton(parent, name, text, color, order)
    local btn = create("TextButton", {
        Name = name,
        Size = UDim2.new(0, 0, 0, 24),
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
    return btn
end

local function serializeArgs(args)
    local out = {}
    if not args then return out end
    local n = args.n or #args
    for i = 1, n do
        local v = args[i]
        local s = "nil"
        local ok, res = pcall(Serializer.serialize, v, 1)
        if ok then s = res else s = tostring(v) end
        table.insert(out, { index = i, type = typeof(v), value = s })
    end
    return out
end

-- Builds the code shown in the detail panel / copied by 📋
local function buildCode(event)
    if not event then return "-- no event" end
    if event.method == "OnClientEvent" then
        local lines = {
            T("code_incoming"),
            "-- Remote: " .. tostring(event.remotePath or "?"),
            T("code_replay"),
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
        local call = "firesignal(remote.OnClientEvent"
        if #names > 0 then call = call .. ", " .. table.concat(names, ", ") end
        table.insert(lines, call .. ")")
        return table.concat(lines, "\n")
    end
    local ok, code = pcall(Serializer.generateR2S, event.remote, event.method, event.args)
    if ok and code then return code end
    return "-- R2S generation failed: " .. tostring(code)
end

-- ── BUILD UI ────────────────────────────────────────────────────

function RemoteSpy.buildUI(tabContent)
    -- Top toolbar (horizontal scroll so it fits small/mobile windows)
    local toolbar = create("ScrollingFrame", {
        Name = "Toolbar",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
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

    -- Pause/Resume button
    local pauseBtn = smallButton(toolbar, "Pause", Hooks.isPaused() and T("resume") or T("pause"), Hooks.isPaused() and Theme.Colors.Success or Theme.Colors.Warning, 1)

    -- Clear button
    local clearBtn = smallButton(toolbar, "Clear", T("clear"), Theme.Colors.Error, 2)

    -- Filter type buttons
    local filters = {
        { "All", T("f_all") },
        { "Fire", T("f_fire") },
        { "Invoke", T("f_invoke") },
        { "Incoming", T("f_incoming") },
        { "Blocked", T("f_blocked") },
    }
    for i, f in ipairs(filters) do
        local name, text = f[1], f[2]
        local fb = smallButton(toolbar, "Filter_" .. name, text, Theme.Colors.BgTertiary, 10 + i)
        fb.TextColor3 = Theme.Colors.TextSecondary
        if name == "All" then
            fb.BackgroundColor3 = Theme.Colors.Accent
            fb.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        fb.Activated:Connect(function()
            if name == "All" then
                _filterType = nil
            elseif name == "Blocked" then
                _filterType = "block"
            else
                _filterType = name:lower()
            end
            RemoteSpy._refreshFilter()
            -- Visual update
            for _, c in ipairs(toolbar:GetChildren()) do
                if c:IsA("TextButton") and c.Name:match("^Filter_") then
                    local isActive = (c.Name == "Filter_" .. name)
                    c.BackgroundColor3 = isActive and Theme.Colors.Accent or Theme.Colors.BgTertiary
                    c.TextColor3 = isActive and Color3.fromRGB(255,255,255) or Theme.Colors.TextSecondary
                end
            end
        end)
    end

    -- Search bar
    local searchContainer = create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = tabContent,
    })
    applyPadding(searchContainer, 2, 6, 2, 6)

    SearchBar.new(searchContainer, {
        Placeholder = T("search_spy"),
        OnChange = function(text)
            _filterText = text:lower()
            RemoteSpy._refreshFilter()
        end,
    })

    -- Feed scroll area
    _feedScroll = Framework.createScrollFrame(tabContent, {
        Name = "Feed",
        Size = UDim2.new(1, 0, 1, -66),
        Position = UDim2.new(0, 0, 0, 66),
        Padding = 2,
        InnerPadding = 4,
    })

    -- Detail panel (overlay, hidden until a row is clicked)
    RemoteSpy._buildDetailPanel(tabContent)

    -- Button handlers
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

    -- UI rebuilt (e.g. language change): re-create rows for kept entries
    _paused = Hooks.isPaused()
    _detailData = nil
    _filterType = nil
    _filterText = ""
    for _, entry in ipairs(_entries) do
        entry.frame = nil
    end
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

    -- Header
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
        Size = UDim2.new(0, 60, 0, 24),
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
    -- Expand: maximizes the whole window so the event is easy to read
    local expandBtn = create("TextButton", {
        Name = "Expand",
        Size = UDim2.new(0, 30, 0, 24),
        Position = UDim2.new(1, -36, 0.5, -12),
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = 0.4,
        Text = "⛶",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = 14,
        ZIndex = 22,
        Parent = header,
    })
    applyCorner(expandBtn, Theme.CornerRadius.SM)

    local title = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -116, 1, 0),
        Position = UDim2.new(0, 72, 0, 0),
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

    -- Action bar (wraps into a horizontal scroll)
    local actions = create("ScrollingFrame", {
        Name = "Actions",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
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

    local btnCopyCode = smallButton(actions, "CopyCode", T("copy_code"), Theme.Colors.Accent, 1)
    local btnCopyPath = smallButton(actions, "CopyPath", T("copy_path"), Theme.Colors.BgTertiary, 2)
    local btnCopyArgs = smallButton(actions, "CopyArgs", T("copy_args"), Theme.Colors.BgTertiary, 3)
    local btnRefire   = smallButton(actions, "Refire", T("refire"), Theme.Colors.Success, 4)
    local btnIgnore   = smallButton(actions, "Ignore", T("ignore"), Theme.Colors.Warning, 5)
    local btnDrop     = smallButton(actions, "Drop", T("drop"), Theme.Colors.Error, 6)
    local btnDelete   = smallButton(actions, "Delete", T("delete"), Theme.Colors.Error, 7)
    for _, b in ipairs(actions:GetChildren()) do
        if b:IsA("GuiObject") then b.ZIndex = 22 end
    end

    -- Body
    local scroll = Framework.createScrollFrame(frame, {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -64),
        Position = UDim2.new(0, 0, 0, 64),
        Padding = 6,
        InnerPadding = 8,
    })
    scroll.ZIndex = 21

    _detail = {
        frame = frame, scroll = scroll, title = title,
        btnIgnore = btnIgnore, btnDrop = btnDrop, btnRefire = btnRefire,
    }

    backBtn.Activated:Connect(function() RemoteSpy.closeDetail() end)

    local function refreshExpandIcon()
        local w = Framework.getMainWindow and Framework.getMainWindow()
        expandBtn.Text = (w and w:isMaximized()) and "❐" or "⛶"
    end
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
    btnIgnore.Activated:Connect(function()
        local ev = _detailData and _detailData._event
        if not ev or not ev.remote then return end
        if Hooks.isBlocked(ev.remote) then
            Hooks.unblockRemote(ev.remote)
            Framework.notify(T("n_log_resumed", _detailData.remote), "info")
        else
            Hooks.blockRemote(ev.remote)
            Framework.notify(T("n_ignored", _detailData.remote), "warning")
        end
        RemoteSpy._refreshDetailButtons()
    end)
    btnDrop.Activated:Connect(function()
        local ev = _detailData and _detailData._event
        if not ev or not ev.remote then return end
        if ev.method == "OnClientEvent" then
            Framework.notify(T("n_cant_block_in"), "warning")
            return
        end
        if Hooks.isDropped(ev.remote) then
            Hooks.undropRemote(ev.remote)
            Framework.notify(T("n_allowed", _detailData.remote), "info")
        else
            Hooks.dropRemote(ev.remote)
            Framework.notify(T("n_blocked", _detailData.remote), "warning")
        end
        RemoteSpy._refreshDetailButtons()
    end)
    btnDelete.Activated:Connect(function()
        if not _detailData then return end
        RemoteSpy.deleteEntry(_detailData)
        RemoteSpy.closeDetail()
    end)
end

function RemoteSpy._refreshDetailButtons()
    if not _detail or not _detailData then return end
    local ev = _detailData._event
    local remote = ev and ev.remote
    _detail.btnIgnore.Text = (remote and Hooks.isBlocked(remote)) and T("unignore") or T("ignore")
    _detail.btnDrop.Text = (remote and Hooks.isDropped(remote)) and T("undrop") or T("drop")
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

local function infoRow(parent, order, key, value)
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
        Size = UDim2.new(0, 90, 0, 14),
        BackgroundTransparency = 1,
        Text = key,
        TextColor3 = Theme.Colors.TextSecondary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
        Parent = row,
    })
    create("TextBox", {
        Size = UDim2.new(1, -94, 0, 0),
        Position = UDim2.new(0, 94, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextEditable = false,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 23,
        Parent = row,
    })
end

local function codeBlock(parent, order, text)
    local box = create("TextBox", {
        Name = "Code_" .. order,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Colors.BgPrimary,
        BorderSizePixel = 0,
        Text = text,
        TextEditable = false,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        TextColor3 = Color3.fromRGB(190, 220, 255),
        Font = Theme.Fonts.Code,
        TextSize = Framework.IS_MOBILE and 13 or Theme.TextSizes.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = order,
        ZIndex = 22,
        Parent = parent,
    })
    applyCorner(box, Theme.CornerRadius.SM)
    applyPadding(box, 6, 8, 6, 8)
    return box
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

    local rows = {
        { T("k_remote"),   data.remote or "?" },
        { T("k_class"),    data.class ~= "" and data.class or (ev.remoteType or "?") },
        { T("k_method"),   ev.method or "?" },
        { T("k_direction"), ev.method == "OnClientEvent" and T("dir_in") or T("dir_out") },
        { T("k_path"),     data.path ~= "" and data.path or "?" },
        { T("k_caller"),   caller or T("caller_unknown") },
        { T("k_call"),   tostring(ev.id or data.index or "?") },
        { T("k_time"),     T("time_fmt", (tonumber(ev.timestamp) or _startClock) - _startClock) },
        { T("k_status"),   status },
    }
    for i, r in ipairs(rows) do
        infoRow(scroll, 1 + i, r[1], r[2])
    end

    -- Arguments
    local args = serializeArgs(ev.args)
    section(scroll, 20, T("sec_args", #args))
    if #args == 0 then
        infoRow(scroll, 21, "—", T("no_args"))
    else
        for i, a in ipairs(args) do
            infoRow(scroll, 20 + i, string.format("[%d] %s", a.index, a.type), a.value)
        end
    end

    -- Code
    section(scroll, 500, ev.method == "OnClientEvent" and T("sec_replay") or T("sec_r2s"))
    codeBlock(scroll, 501, buildCode(ev))

    RemoteSpy._refreshDetailButtons()
    if _detail_refreshExpand then _detail_refreshExpand() end
    _detail.frame.Visible = true
    scroll.CanvasPosition = Vector2.new(0, 0)
end

function RemoteSpy.closeDetail()
    if _detail then
        _detail.frame.Visible = false
        -- Window was enlarged from the detail panel → give the old size back
        if _detail.expandedByDetail then
            _detail.expandedByDetail = false
            local w = Framework.getMainWindow and Framework.getMainWindow()
            if w and w:isMaximized() then w:toggleMaximize(false) end
        end
    end
    _detailData = nil
end

-- ── FEED MANAGEMENT ─────────────────────────────────────────────

function RemoteSpy.addEntry(event)
    if not _feedScroll then return end

    _entryCount = _entryCount + 1

    local entryData = {
        t      = event.timestamp and math.floor((event.timestamp - _startClock) * 1000) or 0,
        type   = "fire",
        remote = "",
        class  = "",
        args   = "",
        path   = "",
        caller = nil,
        index  = _entryCount,
        _event = event, -- keep ref for R2S
    }

    -- Determine type
    if event.blocked then
        entryData.type = "block"
    elseif event.method == "InvokeServer" then
        entryData.type = "invoke"
    elseif event.method == "OnClientEvent" then
        entryData.type = "incoming"
    end

    pcall(function() entryData.remote = event.remote.Name end)
    pcall(function() entryData.class = event.remote.ClassName end)
    pcall(function() entryData.path = Serializer.getInstancePath(event.remote) end)
    if entryData.path == "" and event.remotePath then entryData.path = event.remotePath end
    pcall(function() entryData.args = Serializer.summarize(event.args, 120) end)
    pcall(function()
        local c = event.caller or event.callingScript
        if c then entryData.caller = c:GetFullName() end
    end)

    -- Check filter before creating GUI element
    if not RemoteSpy._matchesFilter(entryData) then
        -- Store data but don't create visible row
        table.insert(_entries, { data = entryData, frame = nil, hidden = true })
        return
    end

    local row = RemoteSpy._createRow(entryData)
    table.insert(_entries, { data = entryData, frame = row, hidden = false })

    -- Trim old visible entries
    while #_entries > _maxVisible do
        local oldest = table.remove(_entries, 1)
        if oldest.frame then
            oldest.frame:Destroy()
        end
    end

    -- Auto-scroll to bottom
    if _autoScroll and _feedScroll then
        task.defer(function()
            _feedScroll.CanvasPosition = Vector2.new(0, _feedScroll.AbsoluteCanvasSize.Y)
        end)
    end
end

function RemoteSpy._createRow(entryData)
    return LogEntry.new(_feedScroll, entryData, {
        onSelect = function(d)
            RemoteSpy.openDetail(d)
        end,
        onCopy = function(d)
            RemoteSpy._copyR2S(d)
        end,
        onBlock = function(d)
            if d._event and d._event.remote then
                if Hooks.isBlocked(d._event.remote) then
                    Hooks.unblockRemote(d._event.remote)
                    Framework.notify(T("n_log_resumed", d.remote), "info")
                else
                    Hooks.blockRemote(d._event.remote)
                    Framework.notify(T("n_ignored", d.remote), "warning")
                end
            end
        end,
        onDelete = function(d)
            RemoteSpy.deleteEntry(d)
        end,
    })
end

function RemoteSpy.deleteEntry(data)
    for i, entry in ipairs(_entries) do
        if entry.data == data then
            if entry.frame then entry.frame:Destroy() end
            table.remove(_entries, i)
            return true
        end
    end
    return false
end

function RemoteSpy.clearFeed()
    for _, entry in ipairs(_entries) do
        if entry.frame then
            entry.frame:Destroy()
        end
    end
    _entries = {}
    _entryCount = 0
    RemoteSpy.closeDetail()
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

-- Plain-text dump of the current feed (for export / clipboard)
function RemoteSpy.exportText()
    local lines = {
        T("log_export_title"),
        "Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "Executor: " .. tostring(Compat.ExecutorName or "Unknown"),
        string.rep("=", 60),
    }
    for _, entry in ipairs(_entries) do
        local d = entry.data
        table.insert(lines, string.format("[%s] %s  %s", Theme.getRemoteLabel(d.type), d.remote or "?", d.path or ""))
        table.insert(lines, "    args: " .. (d.args or ""))
        if d.caller then table.insert(lines, "    caller: " .. d.caller) end
        local okC, code = pcall(buildCode, d._event)
        if okC then
            for l in tostring(code):gmatch("[^\n]+") do
                table.insert(lines, "    | " .. l)
            end
        end
        table.insert(lines, "")
    end
    return table.concat(lines, "\n")
end

-- ── FILTERING ───────────────────────────────────────────────────

function RemoteSpy._matchesFilter(data)
    -- Type filter
    if _filterType then
        if data.type ~= _filterType then return false end
    end
    -- Text filter
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
            -- Row was filtered out at creation time: create it now
            entry.frame = RemoteSpy._createRow(entry.data)
            entry.hidden = false
        end
    end
end

-- ── R2S (REMOTE TO SCRIPT) ─────────────────────────────────────

function RemoteSpy._copyR2S(data)
    local event = data._event
    if not event then return end
    Framework.copy(buildCode(event), T("c_r2s"))
end

-- ── LIFECYCLE ───────────────────────────────────────────────────

function RemoteSpy.start()
    -- Start session first so the very first events are recorded
    pcall(Session.start)

    -- Subscribe to hooks
    Hooks.subscribe(function(event)
        -- Add to GUI feed (isolated: a session error must not hide the row)
        local okGui, errGui = pcall(RemoteSpy.addEntry, event)
        if not okGui then warn("[RobloxSpy] addEntry error: " .. tostring(errGui)) end
        -- Record in session
        pcall(Session.record, event)
    end)

    -- Start hooking
    Hooks.start()
end

function RemoteSpy.stop()
    Hooks.stop()
    Session.stop()
end

return RemoteSpy
