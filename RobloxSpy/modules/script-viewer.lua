--[[
    RobloxSpy — modules/script-viewer.lua
    Script scanner / decompiler / source viewer

    • Async scan (never freezes the game) from several sources:
      game descendants, getnilinstances, getscripts, getloadedmodules,
      getrunningscripts — deduplicated
    • Search filter + type filter (All / Local / Module / Running)
    • Line-numbered viewer, split in chunks (no TextLabel size limit)
    • Decompile cache, copy, save to the export folder
]]

local Framework = require(script.Parent.Parent.gui.framework)
local Theme = require(script.Parent.Parent.gui.theme)
local Compat = require(script.Parent.Parent.core.compat)
local Config = require(script.Parent.Parent.core.config)
local I18n = require(script.Parent.Parent.core.i18n)
local Errors = require(script.Parent.Parent.core.errors)

local T = I18n.T
local create = Framework.create
local applyCorner = Framework.applyCorner
local applyPadding = Framework.applyPadding

local ScriptViewer = {}

local _listScroll = nil
local _codeScroll = nil
local _codeLabel = nil
local _countLabel = nil
local _scripts = {}          -- { inst, name, path, kind, running }
local _cache = {}            -- [inst] = source
local _failReason = setmetatable({}, { __mode = "k" })
local _current = nil         -- { inst, path, source }
local _filterText = ""
local _filterKind = "all"    -- all | local | module | running
local _scanning = false
local _view = {}             -- filtered scripts shown in the list
local _rowPool = {}          -- reusable row buttons (virtualized list)
local ROW_H = Framework.IS_MOBILE and 42 or 34

local LINES_PER_CHUNK = 150

-- ── HELPERS ─────────────────────────────────────────────────────

local function small(parent, text, color, order)
    local b = create("TextButton", {
        Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = color or Theme.Colors.BgTertiary,
        BackgroundTransparency = 0.45,
        Text = text,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Tiny,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    applyCorner(b, Theme.CornerRadius.SM)
    applyPadding(b, 2, 6, 2, 6)
    return b
end

local function getSource(scr)
    if _cache[scr] then return _cache[scr] end
    local source = nil

    -- Method 1: decompile
    if Compat.has("decompile") then
        pcall(function() source = Compat.decompile(scr) end)
        if source and #source < 200 then
            local low = source:lower()
            if source:match("^%-%- Decompil") or low:find("failed to", 1, true)
                or low:find("bytecode", 1, true) or low:find("unable to", 1, true) then
                _failReason[scr] = source
                source = nil
            end
        end
    end
    -- Method 2: getsourcecode (some executors)
    if not source then
        pcall(function()
            local fn = Compat.getGlobal("getsourcecode")
            if fn then source = fn(scr) end
        end)
    end
    -- Method 3: .Source (Studio / plugin identity only)
    if not source or source == "" then
        pcall(function()
            local s = scr.Source
            if s and s ~= "" then source = s end
        end)
    end

    if source and source ~= "" then
        _cache[scr] = source
        return source
    end
    return nil
end

-- ── BUILD UI ────────────────────────────────────────────────────

function ScriptViewer.buildUI(tabContent)
    -- Left: script list
    local leftPanel = create("Frame", {
        Name = "ScriptList",
        Size = UDim2.new(0.38, -2, 1, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Parent = tabContent,
    })

    -- Scan button
    local scanBtn = create("TextButton", {
        Name = "Scan",
        Size = UDim2.new(1, -8, 0, 26),
        Position = UDim2.new(0, 4, 0, 3),
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = 0.35,
        Text = T("sc_scan"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        Parent = leftPanel,
    })
    applyCorner(scanBtn, Theme.CornerRadius.MD)

    -- Search
    local search = create("TextBox", {
        Size = UDim2.new(1, -8, 0, 22),
        Position = UDim2.new(0, 4, 0, 32),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        PlaceholderText = T("sc_search"),
        PlaceholderColor3 = Theme.Colors.TextMuted,
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = leftPanel,
    })
    applyCorner(search, Theme.CornerRadius.SM)
    applyPadding(search, 0, 6, 0, 6)

    -- Kind filters
    local kinds = create("Frame", {
        Size = UDim2.new(1, -8, 0, 22),
        Position = UDim2.new(0, 4, 0, 57),
        BackgroundTransparency = 1,
        Parent = leftPanel,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = kinds,
    })
    local kindDefs = {
        { "all", T("sc_all") }, { "local", "📄 " .. T("sc_local") },
        { "module", "📘 " .. T("sc_module") }, { "running", "🟢 " .. T("sc_running") },
    }
    local kindButtons = {}
    for i, kd in ipairs(kindDefs) do
        local b = small(kinds, kd[2], kd[1] == _filterKind and Theme.Colors.Accent or Theme.Colors.BgTertiary, i)
        kindButtons[kd[1]] = b
        b.Activated:Connect(function()
            _filterKind = kd[1]
            for k, btn in pairs(kindButtons) do
                btn.BackgroundColor3 = (k == _filterKind) and Theme.Colors.Accent or Theme.Colors.BgTertiary
            end
            ScriptViewer._renderList()
        end)
    end

    _countLabel = create("TextLabel", {
        Size = UDim2.new(1, -8, 0, 14),
        Position = UDim2.new(0, 4, 0, 81),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = leftPanel,
    })

    _listScroll = create("ScrollingFrame", {
        Name = "ScriptListScroll",
        Size = UDim2.new(1, 0, 1, -98),
        Position = UDim2.new(0, 0, 0, 98),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = Framework.IS_MOBILE and 10 or 6,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ClipsDescendants = true,
        Parent = leftPanel,
    })
    _rowPool = {}
    _listScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        ScriptViewer._paintRows()
    end)
    _listScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ScriptViewer._paintRows()
    end)

    -- Right: code viewer
    local rightPanel = create("Frame", {
        Name = "CodePanel",
        Size = UDim2.new(0.62, -2, 1, 0),
        Position = UDim2.new(0.38, 2, 0, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Parent = tabContent,
    })

    -- Adaptive layout: side by side when the area is wide (PC, phone in
    -- landscape), stacked when it is tall (phone in portrait).
    local function relayout()
        local sz = tabContent.AbsoluteSize
        if sz.X <= 0 then return end
        if sz.X >= sz.Y * 1.15 then
            local listW = Framework.IS_MOBILE and 0.42 or 0.38
            leftPanel.Size = UDim2.new(listW, -2, 1, 0)
            leftPanel.Position = UDim2.new(0, 0, 0, 0)
            rightPanel.Size = UDim2.new(1 - listW, -2, 1, 0)
            rightPanel.Position = UDim2.new(listW, 2, 0, 0)
        else
            leftPanel.Size = UDim2.new(1, 0, 0.55, 0)
            leftPanel.Position = UDim2.new(0, 0, 0, 0)
            rightPanel.Size = UDim2.new(1, 0, 0.45, -2)
            rightPanel.Position = UDim2.new(0, 0, 0.55, 2)
        end
    end
    relayout()
    tabContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)

    local codeHeader = create("Frame", {
        Name = "CodeHeader",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        Parent = rightPanel,
    })

    _codeLabel = create("TextLabel", {
        Name = "CodeTitle",
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = T("sc_select"),
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = codeHeader,
    })

    local headerBtns = create("Frame", {
        Size = UDim2.new(0, 130, 0, 22),
        Position = UDim2.new(1, -134, 0, 3),
        BackgroundTransparency = 1,
        Parent = codeHeader,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = headerBtns,
    })
    local copyBtn = small(headerBtns, T("sc_copy"), Theme.Colors.Accent, 1)
    local saveBtn = small(headerBtns, T("sc_save"), Theme.Colors.Success, 2)

    _codeScroll = Framework.createScrollFrame(rightPanel, {
        Name = "CodeScroll",
        Size = UDim2.new(1, 0, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        Padding = 0,
        InnerPadding = 6,
    })
    _codeScroll.ScrollingDirection = Enum.ScrollingDirection.XY
    _codeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY

    ScriptViewer._setCode(T("sc_none"), Theme.Colors.TextSecondary)

    -- Handlers
    scanBtn.Activated:Connect(function()
        ScriptViewer._scanScripts()
    end)
    search:GetPropertyChangedSignal("Text"):Connect(function()
        _filterText = search.Text:lower()
        ScriptViewer._renderList()
    end)
    copyBtn.Activated:Connect(function()
        if _current and _current.source then
            Framework.copy(_current.source, T("c_source"))
        end
    end)
    saveBtn.Activated:Connect(function()
        if not _current or not _current.source then return end
        if not Compat.has("writefile") then
            Framework.notify(T("n_no_write", tostring(Compat.ExecutorName)), "error", 4)
            return
        end
        local folder = tostring(Config.get("exportFolder") or "RobloxSpy/exports") .. "/scripts"
        local current = ""
        for part in folder:gmatch("[^/]+") do
            current = (current == "") and part or (current .. "/" .. part)
            Compat.ensureFolder(current)
        end
        local safe = tostring(_current.path or "script"):gsub("[^%w%-%_%.]", "_"):sub(1, 120)
        local path = folder .. "/" .. safe .. ".lua"
        local ok, err = Compat.writeFile(path, _current.source)
        Framework.notify(ok and T("n_saved", path) or T("n_save_fail", tostring(err)), ok and "success" or "error", 4)
    end)

    -- Keep the previous scan after a UI rebuild (language change)
    ScriptViewer._renderList()
end

-- ── CODE DISPLAY ────────────────────────────────────────────────

function ScriptViewer._setCode(text, color)
    if not _codeScroll then return end
    for _, c in ipairs(_codeScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    -- Split into numbered chunks: one TextLabel per LINES_PER_CHUNK lines
    local lines = {}
    for line in (tostring(text) .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    local width = #tostring(#lines)
    local chunk, idx = {}, 0
    local function flush()
        if #chunk == 0 then return end
        idx = idx + 1
        create("TextLabel", {
            Name = "CodeChunk_" .. idx,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundTransparency = 1,
            Text = table.concat(chunk, "\n"),
            TextColor3 = color or Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = false,
            RichText = false,
            LayoutOrder = idx,
            Parent = _codeScroll,
        })
        chunk = {}
    end
    for i, l in ipairs(lines) do
        table.insert(chunk, string.format("%" .. width .. "d │ %s", i, l))
        if #chunk >= LINES_PER_CHUNK then flush() end
    end
    flush()
    _codeScroll.CanvasPosition = Vector2.new(0, 0)
end

-- ── SCAN ────────────────────────────────────────────────────────

function ScriptViewer._scanScripts()
    if not _listScroll or _scanning then return end
    _scanning = true

    task.spawn(function()
      local okScan = Errors.guard("ScriptViewer.scan", function()
        local seen = {}
        local found = {}
        local skipped = 0
        local running = {}

        local function add(inst)
            if inst == nil or seen[inst] or typeof(inst) ~= "Instance" then return end
            seen[inst] = true
            local cls
            pcall(function() cls = inst.ClassName end)
            local kind
            if cls == "LocalScript" then
                kind = "local"
            elseif cls == "ModuleScript" then
                kind = "module"
            elseif cls == "Script" then
                local rc
                pcall(function() rc = inst.RunContext end)
                if rc ~= Enum.RunContext.Client then return end
                kind = "local"
            else
                return
            end
            local name, path = "?", "?"
            pcall(function() name = inst.Name end)
            pcall(function() path = inst:GetFullName() end)
            -- Roblox's own CoreGui scripts can't be decompiled: skip them
            if path:sub(1, 8) == "CoreGui." or path:sub(1, 11) == "CorePackages" then
                skipped = skipped + 1
                return
            end
            table.insert(found, { inst = inst, name = name, path = path, kind = kind })
            if _countLabel and #found % 25 == 0 then
                _countLabel.Text = T("sc_scanning", #found)
            end
        end

        local function fromList(fname, mark)
            local fn = Compat.getGlobal(fname)
            if not fn then return end
            local okL, list = pcall(fn)
            if not okL then
                if Errors then pcall(Errors.add, "Scan " .. fname, list) end
                return
            end
            if type(list) ~= "table" then return end
            local n = 0
            for _, s in pairs(list) do
                if mark and typeof(s) == "Instance" then running[s] = true end
                local okA, errA = pcall(add, s)
                if not okA and Errors then pcall(Errors.add, "Scan " .. fname, errA) end
                n = n + 1
                if n % 2000 == 0 then task.wait() end
            end
        end

        if _countLabel then _countLabel.Text = T("sc_scanning", 0) end

        -- 1. Executor lists (fast, includes hidden/nil-parented scripts)
        fromList("getrunningscripts", true)
        fromList("getscripts")
        fromList("getloadedmodules")
        -- 2. Nil instances + every instance the executor knows about
        fromList("getnilinstances")
        fromList("getinstances")

        -- 3. Client-visible containers, walked one by one (yields → no freeze)
        local roots = {}
        for _, svc in ipairs({ "Workspace", "Players", "ReplicatedStorage", "ReplicatedFirst",
                               "StarterGui", "StarterPack", "StarterPlayer", "Lighting", "SoundService", "Teams", "Chat" }) do
            local okS, inst = pcall(function() return game:GetService(svc) end)
            if okS and inst then table.insert(roots, inst) end
        end
        pcall(function() for _, c in ipairs(game:GetChildren()) do table.insert(roots, c) end end)
        local n = 0
        for _, root in ipairs(roots) do
            local okD, all = pcall(function() return root:GetDescendants() end)
            if okD and type(all) == "table" then
                for _, inst in ipairs(all) do
                    pcall(add, inst)
                    n = n + 1
                    if n % 3000 == 0 then task.wait() end
                end
            end
        end

        for _, s in ipairs(found) do
            s.running = running[s.inst] == true
        end
        pcall(table.sort, found, function(a, b) return tostring(a.path) < tostring(b.path) end)

        _scripts = found
      end)
        _scanning = false
        if not okScan and _countLabel then _countLabel.Text = "⚠ " .. T("tab_errors") end
        Errors.guard("ScriptViewer.render", ScriptViewer._renderList)
    end)
end

-- Virtualized list: only the rows visible on screen exist, so even
-- tens of thousands of scripts render instantly and never overflow.

local function makeRow()
    local btn = create("TextButton", {
        Size = UDim2.new(1, -8, 0, ROW_H - 2),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BackgroundTransparency = 0.5,
        AutoButtonColor = false,
        Text = "",
        ClipsDescendants = true,
        Visible = false,
        Parent = _listScroll,
    })
    applyCorner(btn, Theme.CornerRadius.SM)
    local title = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 0, 15),
        Position = UDim2.new(0, 5, 0, Framework.IS_MOBILE and 4 or 1),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = btn,
    })
    local sub = create("TextLabel", {
        Name = "Path",
        Size = UDim2.new(1, -10, 0, 12),
        Position = UDim2.new(0, 5, 0, Framework.IS_MOBILE and 21 or 16),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = btn,
    })
    local row = { btn = btn, title = title, sub = sub, item = nil }
    btn.MouseEnter:Connect(function() btn.BackgroundTransparency = 0.1 end)
    btn.MouseLeave:Connect(function() btn.BackgroundTransparency = 0.5 end)
    btn.Activated:Connect(function()
        if row.item then ScriptViewer.view(row.item.inst, row.item.path) end
    end)
    return row
end

-- Paths are long: show the end (where the script name is) by trimming the start
local function shortPath(path, maxLen)
    path = tostring(path)
    if #path <= maxLen then return path end
    return "…" .. path:sub(#path - maxLen + 2)
end

function ScriptViewer._paintRows()
    Errors.guard("ScriptViewer.paint", ScriptViewer._paintRowsImpl)
end

function ScriptViewer._paintRowsImpl()
    if not _listScroll or not _listScroll.Parent then return end
    local viewH = _listScroll.AbsoluteSize.Y
    if viewH < 20 then viewH = 600 end
    local width = _listScroll.AbsoluteSize.X
    local top = _listScroll.CanvasPosition.Y
    local first = math.max(1, math.floor(top / ROW_H) + 1)
    local need = math.ceil(viewH / ROW_H) + 2
    while #_rowPool < need do table.insert(_rowPool, makeRow()) end
    local maxChars = math.max(16, math.floor((width - 14) / 5.5))
    for i, row in ipairs(_rowPool) do
        local idx = first + i - 1
        local item = (i <= need) and _view[idx] or nil
        if item then
            row.item = item
            row.btn.Position = UDim2.new(0, 4, 0, (idx - 1) * ROW_H + 2)
            row.title.Text = ((item.kind == "module") and "📘 " or "📄 ") .. (item.running and "🟢 " or "") .. tostring(item.name)
            row.sub.Text = shortPath(item.path, maxChars)
            row.btn.Visible = true
        else
            row.item = nil
            row.btn.Visible = false
        end
    end
end

function ScriptViewer._renderList()
    if not _listScroll then return end
    Errors.guard("ScriptViewer.render", function()
        _view = {}
        for _, s in ipairs(_scripts) do
            local okKind = (_filterKind == "all")
                or (_filterKind == "running" and s.running)
                or (_filterKind == s.kind)
            local okText = (_filterText == "")
                or tostring(s.path):lower():find(_filterText, 1, true) ~= nil
            if okKind and okText then table.insert(_view, s) end
        end

        local empty = _listScroll:FindFirstChild("EmptyState")
        if empty then empty:Destroy() end
        _listScroll.CanvasSize = UDim2.new(0, 0, 0, #_view * ROW_H + 6)
        _listScroll.CanvasPosition = Vector2.new(0, 0)
        if #_view == 0 then
            local e = Framework.emptyState(_listScroll, #_scripts == 0 and T("empty_scripts") or T("empty_filter"), "scripts")
            if e then e.Position = UDim2.new(0, 0, 0, 4) end
        end
        ScriptViewer._paintRows()

        if _countLabel then
            _countLabel.Text = T("sc_found", #_scripts) .. ((#_view < #_scripts) and ("  ·  " .. #_view .. " / " .. #_scripts) or "")
        end
    end)
end

-- ── VIEW / DECOMPILE ────────────────────────────────────────────

function ScriptViewer.view(scr, path)
    if not _codeScroll or not _codeLabel then return end
    if not path then pcall(function() path = scr:GetFullName() end) end

    _codeLabel.Text = tostring(path or "?")
    _codeLabel.TextColor3 = Theme.Colors.TextPrimary
    ScriptViewer._setCode(T("sc_decompiling"), Theme.Colors.TextMuted)

    task.spawn(function()
        local source = getSource(scr)
        if source then
            _current = { inst = scr, path = path, source = source }
            ScriptViewer._setCode(source, Theme.Colors.TextPrimary)
            local n = select(2, source:gsub("\n", "\n")) + 1
            _codeLabel.Text = tostring(path) .. "  ·  " .. T("sc_lines", n)
        else
            _current = nil
            local reason = _failReason[scr]
            local cls = "?"
            pcall(function() cls = scr.ClassName end)
            local msg = T("sc_fail", tostring(path or "?")) .. "\n-- Class: " .. cls
            if reason then msg = msg .. "\n-- " .. tostring(Compat.ExecutorName) .. ": " .. reason:gsub("^%-%-%s*", "") end
            if cls == "ModuleScript" then
                msg = msg .. "\n\n-- Tip: a ModuleScript that was never required has no bytecode loaded;\n-- play until the game uses it, then try again."
            end
            ScriptViewer._setCode(msg, Theme.Colors.TextMuted)
        end
    end)
end

-- Backward compatible name
ScriptViewer._viewScript = ScriptViewer.view

return ScriptViewer
