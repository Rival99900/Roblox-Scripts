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
local _current = nil         -- { inst, path, source }
local _filterText = ""
local _filterKind = "all"    -- all | local | module | running
local _scanning = false

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
        if source and source:match("^%-%- Decompil") and #source < 80 then source = nil end
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
        Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.42, 0) or UDim2.new(0.38, -2, 1, 0),
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

    _listScroll = Framework.createScrollFrame(leftPanel, {
        Name = "ScriptListScroll",
        Size = UDim2.new(1, 0, 1, -98),
        Position = UDim2.new(0, 0, 0, 98),
        Padding = 1,
        InnerPadding = 2,
    })

    -- Right: code viewer
    local rightPanel = create("Frame", {
        Name = "CodePanel",
        Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.58, -2) or UDim2.new(0.62, -2, 1, 0),
        Position = Framework.IS_MOBILE and UDim2.new(0, 0, 0.42, 2) or UDim2.new(0.38, 2, 0, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Parent = tabContent,
    })

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
        TextTruncate = Enum.TextTruncate.AtStart,
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
    if #_scripts > 0 then ScriptViewer._renderList() end
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
        local seen = {}
        local found = {}
        local running = {}

        local function add(inst)
            if seen[inst] then return end
            local okA, isScript = pcall(function()
                return inst:IsA("LocalScript") or inst:IsA("ModuleScript")
                    or (inst:IsA("Script") and inst.RunContext == Enum.RunContext.Client)
            end)
            if not okA or not isScript then return end
            seen[inst] = true
            local name, path, kind = "?", "?", "local"
            pcall(function() name = inst.Name end)
            pcall(function() path = inst:GetFullName() end)
            pcall(function() if inst:IsA("ModuleScript") then kind = "module" end end)
            table.insert(found, { inst = inst, name = name, path = path, kind = kind })
            if _countLabel and #found % 50 == 0 then
                _countLabel.Text = T("sc_scanning", #found)
            end
        end

        -- Running scripts (executor API)
        pcall(function()
            local fn = Compat.getGlobal("getrunningscripts")
            if fn then for _, s in ipairs(fn()) do running[s] = true end end
        end)

        -- 1. Executor lists (fast, includes hidden/nil-parented scripts)
        for _, fname in ipairs({ "getscripts", "getloadedmodules", "getrunningscripts" }) do
            pcall(function()
                local fn = Compat.getGlobal(fname)
                if fn then
                    for _, s in ipairs(fn()) do add(s) end
                end
            end)
        end

        -- 2. Nil instances
        pcall(function()
            local fn = Compat.getGlobal("getnilinstances")
            if fn then for _, s in ipairs(fn()) do add(s) end end
        end)

        -- 3. Whole game tree (yields regularly → no freeze)
        local okD, all = pcall(function() return game:GetDescendants() end)
        if okD then
            for i, inst in ipairs(all) do
                add(inst)
                if i % 3000 == 0 then task.wait() end
            end
        end

        for _, s in ipairs(found) do
            s.running = running[s.inst] == true
        end
        table.sort(found, function(a, b) return a.path < b.path end)

        _scripts = found
        _scanning = false
        ScriptViewer._renderList()
    end)
end

function ScriptViewer._renderList()
    if not _listScroll then return end
    for _, c in ipairs(_listScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    local shown = 0
    for i, s in ipairs(_scripts) do
        local okKind = (_filterKind == "all")
            or (_filterKind == "running" and s.running)
            or (_filterKind == s.kind)
        local okText = (_filterText == "")
            or s.path:lower():find(_filterText, 1, true) ~= nil
        if okKind and okText and shown < 800 then
            shown = shown + 1
            local icon = (s.kind == "module") and "📘" or "📄"
            if s.running then icon = icon .. "🟢" end

            local btn = create("TextButton", {
                Name = "Script_" .. i,
                Size = UDim2.new(1, -4, 0, 30),
                BackgroundColor3 = Theme.Colors.BgSecondary,
                BackgroundTransparency = 0.5,
                Text = "",
                LayoutOrder = i,
                Parent = _listScroll,
            })
            applyCorner(btn, Theme.CornerRadius.SM)
            create("TextLabel", {
                Size = UDim2.new(1, -10, 0, 15),
                Position = UDim2.new(0, 5, 0, 1),
                BackgroundTransparency = 1,
                Text = icon .. " " .. s.name,
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = btn,
            })
            create("TextLabel", {
                Size = UDim2.new(1, -10, 0, 12),
                Position = UDim2.new(0, 5, 0, 16),
                BackgroundTransparency = 1,
                Text = s.path,
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtStart,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                Framework.tween(btn, { BackgroundTransparency = 0 }, 0.1):Play()
            end)
            btn.MouseLeave:Connect(function()
                Framework.tween(btn, { BackgroundTransparency = 0.5 }, 0.1):Play()
            end)
            btn.Activated:Connect(function()
                ScriptViewer.view(s.inst, s.path)
            end)
        end
    end

    if _countLabel then
        _countLabel.Text = T("sc_found", #_scripts) .. (shown < #_scripts and ("  ·  " .. shown .. " / " .. #_scripts) or "")
    end
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
            ScriptViewer._setCode(T("sc_fail", tostring(path or "?")), Theme.Colors.TextMuted)
        end
    end)
end

-- Backward compatible name
ScriptViewer._viewScript = ScriptViewer.view

return ScriptViewer
