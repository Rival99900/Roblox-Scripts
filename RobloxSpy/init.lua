--[[
    ================================================================
    RobloxSpy — init.lua
    Ultimate Remote Spy + Instance Explorer + Session Recorder
    Fusion of SimpleSpy × DarkDEX V5 × Cobalt — with innovations

    Created by Rival960 with the help of Claude
    Version: 1.0.0
    Status: untested in-game
    ================================================================

    Usage:
        loadstring(game:HttpGet("URL_HERE"))()

    Or locally:
        dofile("RobloxSpy/init.lua")
]]

-- ── EXECUTOR COMPATIBILITY SHIM ─────────────────────────────────
if not task then
    task = {
        wait   = function(t) return wait(t) end,
        spawn  = function(f, ...) return spawn(f, ...) end,
        defer  = function(f, ...) return spawn(f, ...) end,
        delay  = function(t, f) return delay(t, f) end,
        cancel = function() end,
    }
end

-- ── LOAD CORE ───────────────────────────────────────────────────

-- For loadstring execution, modules are inline.
-- For development, we use require.
local Compat, Config, I18n, Serializer, Hooks, Session
local Framework, Theme, RemoteSpy
local Explorer, NetworkMonitor, ScriptViewer

local function tryRequire(path)
    local ok, mod = pcall(function() return require(path) end)
    if ok then return mod end
    return nil
end

-- Attempt module loading (works in Studio / file-based setups)
Compat     = tryRequire(script.core.compat)
Config     = tryRequire(script.core.config)
I18n       = tryRequire(script.core.i18n)
Serializer = tryRequire(script.core.serializer)
Hooks      = tryRequire(script.core.hooks)
Session    = tryRequire(script.core.session)
Framework  = tryRequire(script.gui.framework)
Theme      = tryRequire(script.gui.theme)
RemoteSpy      = tryRequire(script.modules["remote-spy"])
Explorer       = tryRequire(script.modules.explorer)
NetworkMonitor = tryRequire(script.modules["network-monitor"])
ScriptViewer   = tryRequire(script.modules["script-viewer"])

local T = (I18n and I18n.T) or function(k) return k end

local VERSION = "1.0.0"
local _window = nil
local _spyStarted = false
local _autoSaveThread = nil

-- Forward declarations
local buildWindow, buildHistoryTab, buildSettingsTab, startAutoSave

-- ── FILE HELPERS ────────────────────────────────────────────────

local function cleanFolder(text)
    text = tostring(text or ""):gsub("\\", "/"):gsub("%.%.", ""):gsub("[^%w%-%_/ ]", "")
    text = text:gsub("^/+", ""):gsub("/+$", "")
    if text == "" then text = "RobloxSpy/exports" end
    return text
end

local function ensureFolders(path)
    local current = ""
    for part in path:gmatch("[^/]+") do
        current = (current == "") and part or (current .. "/" .. part)
        Compat.ensureFolder(current)
    end
    if Compat.has("isfolder") then
        local ok, exists = pcall(function() return isfolder(path) end)
        return ok and exists
    end
    return true
end

-- Writes content into the export folder. Returns ok, pathOrError.
local function writeExport(fileName, content)
    if not Compat.has("writefile") then
        return false, T("n_no_write", tostring(Compat.ExecutorName))
    end
    if not content or content == "" then
        return false, T("n_nothing")
    end
    local folder = cleanFolder(Config.get("exportFolder"))
    if not pcall(ensureFolders, folder) then
        return false, T("n_folder_fail", folder)
    end
    local path = folder .. "/" .. fileName
    local ok, err = Compat.writeFile(path, content)
    if ok then return true, path end
    return false, T("n_save_fail", tostring(err))
end

-- ── AUTO-SAVE ───────────────────────────────────────────────────
-- One file per game run, overwritten at each interval.

startAutoSave = function()
    if _autoSaveThread then return end
    local runId = os.date("%Y%m%d_%H%M%S") .. "_" .. tostring(game.PlaceId)
    _autoSaveThread = task.spawn(function()
        while true do
            local interval = math.max(10, tonumber(Config.get("autoSaveInterval")) or 60)
            task.wait(interval)
            if Config.get("autoSave") and Compat.has("writefile") then
                pcall(function()
                    if RemoteSpy then writeExport("autosave_" .. runId .. ".txt", RemoteSpy.exportText()) end
                    if Session then
                        writeExport("autosave_" .. runId .. ".json", Session.exportCurrent("json"))
                        Session.save()
                    end
                end)
            end
        end
    end)
end

-- ── MAIN ────────────────────────────────────────────────────────

local function startSpy()
    if _spyStarted or not RemoteSpy then return end
    _spyStarted = true

    -- Feed network monitor
    Hooks.subscribe(function(event)
        if NetworkMonitor then
            NetworkMonitor.recordCall(event)
        end
    end)
    if Hooks.setLogIncoming then
        Hooks.setLogIncoming(Config.get("logIncoming") ~= false)
    end
    RemoteSpy.start()
    startAutoSave()

    -- Cleanup on teleport
    pcall(function()
        game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
            if RemoteSpy then RemoteSpy.stop() end
        end)
    end)
end

local function setRecordingStatus()
    if not _window then return end
    _window:setStatus(
        T("status_recording", (Compat and Compat.ExecutorName or "Unknown"),
            tostring(Hooks and Hooks.getStrategy and Hooks.getStrategy() or "?")),
        Theme and Theme.Colors.Success or Color3.fromRGB(80, 200, 120))
end

buildWindow = function()
    local sizePresets = Framework.IS_MOBILE and {
        Small  = UDim2.new(0.75, 0, 0.5, 0),
        Medium = UDim2.new(0.9, 0, 0.62, 0),
        Large  = UDim2.new(0.97, 0, 0.82, 0),
    } or {
        Small  = UDim2.new(0, 440, 0, 300),
        Medium = UDim2.new(0, 520, 0, 360),
        Large  = UDim2.new(0, 680, 0, 480),
    }

    local window = Framework.createWindow({
        Title = "🔍 RobloxSpy v" .. VERSION,
        Size = sizePresets[Config.get("windowSize") or "Medium"] or sizePresets.Medium,
    })
    if not window then
        warn("[RobloxSpy] Failed to create window.")
        return nil
    end
    _window = window

    -- Reopen button first: it must exist even if a tab fails to build
    pcall(Framework.createToggleButton, window)

    -- Tabs
    local spyTab       = window:addTab(T("tab_spy"), "🛰")
    local explorerTab  = window:addTab(T("tab_explorer"), "🗂")
    local networkTab   = window:addTab(T("tab_network"), "📶")
    local scriptsTab   = window:addTab(T("tab_scripts"), "🧾")
    local historyTab   = window:addTab(T("tab_history"), "🕘")
    local settingsTab  = window:addTab(T("tab_settings"), "🛠")

    -- Each tab is built in isolation: one error no longer blanks every menu
    local function buildTab(name, fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[RobloxSpy] Tab '" .. name .. "' failed: " .. tostring(err))
        end
    end

    if RemoteSpy then buildTab("Remote Spy", RemoteSpy.buildUI, spyTab) end
    if Explorer then
        buildTab("Explorer", Explorer.buildUI, explorerTab)
        -- "View source" in the Explorer opens the Scripts tab
        if Explorer.setViewSourceHandler and ScriptViewer then
            Explorer.setViewSourceHandler(function(inst)
                window:switchTab(T("tab_scripts"))
                ScriptViewer.view(inst)
            end)
        end
    end
    if NetworkMonitor then buildTab("Network", NetworkMonitor.buildUI, networkTab) end
    if ScriptViewer then buildTab("Scripts", ScriptViewer.buildUI, scriptsTab) end
    buildTab("History", buildHistoryTab, historyTab, window)
    buildTab("Settings", buildSettingsTab, settingsTab, window)

    if _spyStarted then setRecordingStatus() end
    return window
end

-- Rebuilds the whole interface (used when the language changes).
-- Hooks, session and captured events are kept.
local function rebuildWindow(openTabKey)
    if _window then
        pcall(function()
            if _window._toggleBtn then _window._toggleBtn:Destroy() end
        end)
        pcall(function() _window:destroy() end)
        _window = nil
    end
    local w = buildWindow()
    if w and openTabKey then
        pcall(function() w:switchTab(T(openTabKey)) end)
    end
end

local function main()
    print("═══════════════════════════════════════")
    print("  RobloxSpy v" .. VERSION)
    print("  Remote Spy • Explorer • Sessions")
    print("═══════════════════════════════════════")

    -- 1. Init compatibility layer
    if Compat then
        Compat.detect()
        Compat.initStorage()
        print("[RobloxSpy] Executor: " .. (Compat.ExecutorName or "Unknown"))
        print("[RobloxSpy] " .. Compat.report())
    end
    if I18n then
        print("[RobloxSpy] Language: " .. tostring(I18n.current()))
    end

    -- 2. Headless fallback
    if not Framework then
        warn("[RobloxSpy] GUI framework not loaded — running headless.")
        if Hooks and Session then
            Session.start()
            Hooks.subscribe(function(event)
                Session.record(event)
                local name = ""
                pcall(function() name = event.remote.Name end)
                print(string.format("[SPY] %s → %s", event.method or "?", name))
            end)
            Hooks.start()
        end
        return
    end

    -- 3. Window + tabs
    if not buildWindow() then return end

    -- 4. Start spy (once)
    startSpy()
    setRecordingStatus()

    print("[RobloxSpy] Ready.")
end

-- ── HISTORY TAB ─────────────────────────────────────────────────

buildHistoryTab = function(parent, window)
    if not Session or not Framework or not Theme then return end

    local create = Framework.create
    local applyCorner = Framework.applyCorner
    local applyPadding = Framework.applyPadding

    -- Top bar: title + refresh + global search
    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        Parent = parent,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -110, 0, 26),
        Position = UDim2.new(0, 8, 0, 2),
        BackgroundTransparency = 1,
        Text = T("hi_title"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Heading,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
    })
    local refreshBtn = create("TextButton", {
        Size = UDim2.new(0, 96, 0, 22),
        Position = UDim2.new(1, -102, 0, 4),
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = 0.4,
        Text = T("hi_refresh"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        Parent = top,
    })
    applyCorner(refreshBtn, Theme.CornerRadius.SM)
    local searchBox = create("TextBox", {
        Size = UDim2.new(1, -16, 0, 24),
        Position = UDim2.new(0, 8, 0, 30),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        PlaceholderText = T("hi_search_all"),
        PlaceholderColor3 = Theme.Colors.TextMuted,
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
    })
    applyCorner(searchBox, Theme.CornerRadius.SM)
    applyPadding(searchBox, 0, 6, 0, 6)

    local scroll = Framework.createScrollFrame(parent, {
        Name = "SessionList",
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        Padding = 4,
        InnerPadding = 6,
    })

    local function clear()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
    end

    local function label(text, color, order, size)
        return create("TextLabel", {
            Size = UDim2.new(1, -12, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = text,
            TextWrapped = true,
            TextColor3 = color or Theme.Colors.TextMuted,
            Font = Theme.Fonts.Body,
            TextSize = size or Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order or 0,
            Parent = scroll,
        })
    end

    local function smallBtn(parent2, text, color)
        local b = create("TextButton", {
            Size = UDim2.new(0, 0, 0, 22),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = color or Theme.Colors.BgTertiary,
            BackgroundTransparency = 0.45,
            Text = text,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Tiny,
            Parent = parent2,
        })
        applyCorner(b, Theme.CornerRadius.SM)
        applyPadding(b, 2, 6, 2, 6)
        return b
    end

    local refreshList -- forward

    -- Entry list of one session (viewer)
    local function openSession(meta, data)
        clear()
        local backRow = create("Frame", {
            Size = UDim2.new(1, -12, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = scroll,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            Parent = backRow,
        })
        smallBtn(backRow, T("back")).Activated:Connect(function() refreshList() end)
        smallBtn(backRow, T("hi_export"), Theme.Colors.Success).Activated:Connect(function()
            local ok, res = writeExport("session_" .. tostring(data.id) .. ".txt", Session.toText(data))
            if ok then
                Framework.notify(T("n_saved", res), "success", 4)
            else
                Framework.notify(res, "error", 4)
                Framework.copy(Session.toText(data), T("c_logs"))
            end
        end)
        smallBtn(backRow, T("sc_copy"), Theme.Colors.Accent).Activated:Connect(function()
            Framework.copy(Session.toText(data), T("c_logs"))
        end)

        local dur = (data.endTime or os.time()) - (data.startTime or os.time())
        label(string.format("🎮 %s  ·  PlaceId %s\n👤 %s  ·  🧩 %s\n🕒 %s  ·  ⏱ %s  ·  %s  ·  %s",
            tostring(data.gameName), tostring(data.placeId),
            tostring(data.playerName), tostring(data.executor),
            data.startTime and os.date("%Y-%m-%d %H:%M", data.startTime) or "?",
            T("hi_duration", math.floor(dur / 60), dur % 60),
            T("hi_calls", data.stats and data.stats.totalCalls or #(data.entries or {})),
            T("hi_unique", data.stats and data.stats.uniqueRemotes or 0)),
            Theme.Colors.TextSecondary, 1)

        local entries = data.entries or {}
        local limit = math.min(#entries, 400)
        label(T("hi_showing", limit, #entries), Theme.Colors.TextMuted, 2, Theme.TextSizes.Tiny)

        for i = 1, limit do
            local e = entries[i]
            local color = Theme.getRemoteColor(e.type)
            local row = create("Frame", {
                Size = UDim2.new(1, -12, 0, 30),
                BackgroundColor3 = Theme.Colors.BgSecondary,
                BackgroundTransparency = 0.3,
                LayoutOrder = 10 + i,
                Parent = scroll,
            })
            applyCorner(row, Theme.CornerRadius.SM)
            create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 14),
                Position = UDim2.new(0, 6, 0, 2),
                BackgroundTransparency = 1,
                Text = Theme.getRemoteLabel(e.type),
                TextColor3 = color,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            create("TextLabel", {
                Size = UDim2.new(1, -130, 0, 14),
                Position = UDim2.new(0, 68, 0, 2),
                BackgroundTransparency = 1,
                Text = tostring(e.remote),
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
            create("TextLabel", {
                Size = UDim2.new(0, 56, 0, 14),
                Position = UDim2.new(1, -60, 0, 2),
                BackgroundTransparency = 1,
                Text = string.format("%.1fs", (e.t or 0) / 1000),
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            create("TextLabel", {
                Size = UDim2.new(1, -12, 0, 12),
                Position = UDim2.new(0, 6, 0, 16),
                BackgroundTransparency = 1,
                Text = tostring(e.args or "") .. "   " .. tostring(e.path or ""),
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
        end
    end

    local function sessionCard(s, order)
        local card = create("TextButton", {
            Name = "Session_" .. order,
            Size = UDim2.new(1, -12, 0, 54),
            BackgroundColor3 = s.isCurrent and Theme.Colors.BgSelected or Theme.Colors.BgSecondary,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = order,
            Parent = scroll,
        })
        applyCorner(card, Theme.CornerRadius.MD)
        if s.isCurrent then
            Framework.applyStroke(card, Theme.Colors.Success, 1)
        end

        local badge = ""
        if s.isCurrent then badge = T("hi_current") .. "  "
        elseif s.placeId == game.PlaceId then badge = T("hi_same_game") .. "  " end

        create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 18),
            Position = UDim2.new(0, 8, 0, 4),
            BackgroundTransparency = 1,
            Text = badge .. tostring(s.gameName or "Unknown Game"),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = card,
        })

        local dur = (s.endTime or os.time()) - (s.startTime or os.time())
        create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 14),
            Position = UDim2.new(0, 8, 0, 22),
            BackgroundTransparency = 1,
            Text = (s.startTime and os.date("%Y-%m-%d %H:%M", s.startTime) or "?")
                .. "  ·  ⏱ " .. T("hi_duration", math.floor(dur / 60), dur % 60)
                .. "  ·  " .. T("hi_calls", s.totalCalls or 0)
                .. "  ·  " .. T("hi_unique", s.uniqueRemotes or 0),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = card,
        })
        create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 12),
            Position = UDim2.new(0, 8, 0, 37),
            BackgroundTransparency = 1,
            Text = "👤 " .. tostring(s.playerName or "?") .. "  ·  🧩 " .. tostring(s.executor or "?") .. "  ·  PlaceId " .. tostring(s.placeId),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = card,
        })

        local delBtn = create("TextButton", {
            Size = UDim2.new(0, 36, 0, 26),
            Position = UDim2.new(1, -44, 0.5, -13),
            BackgroundColor3 = Theme.Colors.Error,
            BackgroundTransparency = 0.6,
            Text = "🗑",
            TextSize = 12,
            Visible = not s.isCurrent,
            Parent = card,
        })
        applyCorner(delBtn, Theme.CornerRadius.SM)

        local deleting = false
        delBtn.Activated:Connect(function()
            deleting = true
            Session.deleteSession(s.filePath or s.id)
            Framework.notify(T("hi_deleted"), "info", 1.5)
            refreshList()
        end)
        card.Activated:Connect(function()
            task.defer(function()
                if deleting then return end
                local data = s.isCurrent and Session.getCurrent() or Session.loadSession(s.filePath or s.id)
                if data then openSession(s, data) end
            end)
        end)
    end

    refreshList = function()
        clear()

        if not Compat.has("listfiles") or not Compat.has("readfile") then
            label(T("hi_nolist"), Theme.Colors.Error, 0)
        end

        -- Always show the live session first (even without file access)
        local current = Session.getCurrent()
        local order = 1
        local seenCurrent = false

        local sessions = Session.listSessions()
        for _, s in ipairs(sessions) do
            if s.isCurrent then seenCurrent = true end
        end
        if current and not seenCurrent then
            sessionCard({
                id = current.id, gameName = current.gameName, placeId = current.placeId,
                startTime = current.startTime, totalCalls = current.stats and current.stats.totalCalls or 0,
                uniqueRemotes = current.stats and current.stats.uniqueRemotes or 0,
                executor = current.executor, playerName = current.playerName, isCurrent = true,
            }, order)
            order = order + 1
        end

        table.sort(sessions, function(a, b)
            if a.isCurrent ~= b.isCurrent then return a.isCurrent == true end
            return (a.startTime or 0) > (b.startTime or 0)
        end)
        for _, s in ipairs(sessions) do
            sessionCard(s, order)
            order = order + 1
        end

        if #sessions == 0 and not current then
            label(T("hi_none"), Theme.Colors.TextMuted, 1, Theme.TextSizes.Body)
        end
    end

    local function runSearch(query)
        if query == "" then refreshList() return end
        clear()
        local results = Session.searchAll(query, 30)
        local total = 0
        for _, r in ipairs(results) do total = total + r.total end
        label(T("hi_results", total, #results), Theme.Colors.TextSecondary, 0)
        local order = 1
        for _, r in ipairs(results) do
            label("🎮 " .. tostring(r.session.gameName) .. "  ·  "
                .. (r.session.startTime and os.date("%Y-%m-%d %H:%M", r.session.startTime) or "?"),
                Theme.Colors.TextAccent, order, Theme.TextSizes.Small)
            order = order + 1
            for _, m in ipairs(r.matches) do
                local e = m.entry
                label(string.format("   [%s] %s  %s", Theme.getRemoteLabel(e.type), tostring(e.remote), tostring(e.args or "")),
                    Theme.Colors.TextPrimary, order, Theme.TextSizes.Tiny)
                order = order + 1
            end
        end
    end

    local searchToken = 0
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchToken = searchToken + 1
        local my = searchToken
        task.delay(0.4, function()
            if my == searchToken then runSearch(searchBox.Text) end
        end)
    end)

    refreshBtn.Activated:Connect(function()
        pcall(Session.save)
        searchBox.Text = ""
        refreshList()
    end)

    -- Initial load
    task.defer(refreshList)
end

-- ── SETTINGS TAB ────────────────────────────────────────────────

buildSettingsTab = function(parent, window)
    if not Framework or not Theme or not Compat then return end

    local create = Framework.create
    local applyCorner = Framework.applyCorner
    local applyPadding = Framework.applyPadding
    local order = 0
    local function nextOrder() order = order + 1; return order end

    local scroll = Framework.createScrollFrame(parent, {
        Name = "SettingsScroll",
        Padding = 6,
        InnerPadding = 8,
    })

    local function heading(text)
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Heading,
            TextSize = Theme.TextSizes.Heading,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
    end

    local function note(text, color)
        return create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = text,
            TextWrapped = true,
            TextColor3 = color or Theme.Colors.TextMuted,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
    end

    local function button(text, color)
        local b = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = color or Theme.Colors.BgTertiary,
            BackgroundTransparency = 0.35,
            Text = text,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Body,
            TextWrapped = true,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(b, Theme.CornerRadius.SM)
        return b
    end

    local function toggle(text, initial, onChange)
        local state = initial and true or false
        local row = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(row, Theme.CornerRadius.SM)
        create("TextLabel", {
            Size = UDim2.new(1, -64, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        local pill = create("Frame", {
            Size = UDim2.new(0, 38, 0, 18),
            Position = UDim2.new(1, -46, 0.5, -9),
            BackgroundColor3 = Theme.Colors.BgTertiary,
            Parent = row,
        })
        applyCorner(pill, UDim.new(1, 0))
        local knob = create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(230, 230, 240),
            Parent = pill,
        })
        applyCorner(knob, UDim.new(1, 0))
        local function render()
            pill.BackgroundColor3 = state and Theme.Colors.Success or Theme.Colors.BgTertiary
            Framework.tween(knob, { Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) }, 0.12):Play()
        end
        render()
        row.Activated:Connect(function()
            state = not state
            render()
            if onChange then
                local ok, keep = pcall(onChange, state)
                if ok and keep == false then -- callback refused the change
                    state = not state
                    render()
                end
            end
        end)
    end

    local function choiceRow(options, selected, onPick)
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = row,
        })
        local buttons = {}
        for _, opt in ipairs(options) do
            local b = create("TextButton", {
                Size = UDim2.new(1 / #options, -5, 1, 0),
                BackgroundColor3 = (opt[1] == selected) and Theme.Colors.Accent or Theme.Colors.BgTertiary,
                Text = opt[2],
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Small,
                Parent = row,
            })
            applyCorner(b, Theme.CornerRadius.SM)
            buttons[opt[1]] = b
            b.Activated:Connect(function()
                for k, other in pairs(buttons) do
                    other.BackgroundColor3 = (k == opt[1]) and Theme.Colors.Accent or Theme.Colors.BgTertiary
                end
                onPick(opt[1])
            end)
        end
    end

    -- ── 1. LANGUAGE (drop-down) ──────────────────────────────────
    if I18n then
        heading(T("se_lang"))

        local current = I18n.current()
        local currentLang = nil
        for _, lang in ipairs(I18n.getLanguages()) do
            if lang.code == current then currentLang = lang end
        end

        -- Closed state: one button showing the current language
        local dropBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(dropBtn, Theme.CornerRadius.SM)
        Framework.applyStroke(dropBtn, Theme.Colors.Border, 1)
        create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = currentLang and (currentLang.flag .. "  " .. currentLang.name) or tostring(current),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = dropBtn,
        })
        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Theme.Colors.TextSecondary,
            Font = Theme.Fonts.Body,
            TextSize = 12,
            Parent = dropBtn,
        })

        -- Open state: scrollable list right under the button
        local listFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 190),
            BackgroundColor3 = Theme.Colors.BgPrimary,
            Visible = false,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(listFrame, Theme.CornerRadius.SM)
        Framework.applyStroke(listFrame, Theme.Colors.Border, 1)
        local list = Framework.createScrollFrame(listFrame, {
            Name = "LangList",
            Padding = 2,
            InnerPadding = 4,
        })

        for i, lang in ipairs(I18n.getLanguages()) do
            local isCur = (lang.code == current)
            local opt = create("TextButton", {
                Size = UDim2.new(1, -4, 0, 26),
                BackgroundColor3 = isCur and Theme.Colors.Accent or Theme.Colors.BgSecondary,
                BackgroundTransparency = isCur and 0.2 or 0.4,
                Text = "",
                LayoutOrder = i,
                Parent = list,
            })
            applyCorner(opt, Theme.CornerRadius.SM)
            create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = lang.flag .. "  " .. lang.name,
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = opt,
            })
            create("TextLabel", {
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(1, -34, 0, 0),
                BackgroundTransparency = 1,
                Text = isCur and "✓" or lang.code,
                TextColor3 = isCur and Theme.Colors.TextPrimary or Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                Parent = opt,
            })
            opt.Activated:Connect(function()
                listFrame.Visible = false
                arrow.Text = "▼"
                if lang.code == I18n.current() then return end
                I18n.setLanguage(lang.code)
                Config.set("language", lang.code)
                task.defer(function()
                    rebuildWindow("tab_settings")
                    Framework.notify(T("n_lang", lang.name), "success", 2)
                end)
            end)
        end

        dropBtn.Activated:Connect(function()
            listFrame.Visible = not listFrame.Visible
            arrow.Text = listFrame.Visible and "▲" or "▼"
        end)
    end

    -- ── 2. SAVE & EXPORT ─────────────────────────────────────────
    heading(T("se_save"))

    local canWrite = Compat.has("writefile")
    note(canWrite and T("se_where") or T("se_nowrite"),
        canWrite and Theme.Colors.TextMuted or Theme.Colors.Error)

    -- Folder input
    local folderRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        LayoutOrder = nextOrder(),
        Parent = scroll,
    })
    applyCorner(folderRow, Theme.CornerRadius.SM)
    create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = T("se_folder"),
        TextColor3 = Theme.Colors.TextSecondary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = folderRow,
    })
    local folderBox = create("TextBox", {
        Size = UDim2.new(1, -96, 1, -8),
        Position = UDim2.new(0, 90, 0, 4),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        Text = cleanFolder(Config.get("exportFolder")),
        PlaceholderText = "RobloxSpy/exports",
        ClearTextOnFocus = false,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = folderRow,
    })
    applyCorner(folderBox, Theme.CornerRadius.SM)
    applyPadding(folderBox, 0, 6, 0, 6)
    folderBox.FocusLost:Connect(function()
        local f = cleanFolder(folderBox.Text)
        folderBox.Text = f
        Config.set("exportFolder", f)
    end)

    local lastSaved = note("", Theme.Colors.TextMuted)

    local function saveLogs(ext, content)
        Config.set("exportFolder", cleanFolder(folderBox.Text))
        folderBox.Text = cleanFolder(folderBox.Text)
        local name = string.format("logs_%s_%d.%s", os.date("%Y%m%d_%H%M%S"), game.PlaceId, ext)
        local ok, res = writeExport(name, content)
        if ok then
            Framework.notify(T("n_saved", res), "success", 4)
            lastSaved.Text = T("se_last", res)
            lastSaved.TextColor3 = Theme.Colors.Success
        else
            Framework.notify(res, "error", 4)
        end
    end

    button(T("se_txt"), Theme.Colors.Accent).Activated:Connect(function()
        saveLogs("txt", RemoteSpy and RemoteSpy.exportText() or nil)
    end)
    button(T("se_json")).Activated:Connect(function()
        saveLogs("json", Session and Session.exportCurrent("json") or nil)
    end)
    button(T("se_csv")).Activated:Connect(function()
        saveLogs("csv", Session and Session.exportCurrent("csv") or nil)
    end)
    button(T("se_copy")).Activated:Connect(function()
        local text = RemoteSpy and RemoteSpy.exportText() or ""
        Framework.copy(text, T("c_logs"))
    end)

    -- Auto-save
    toggle(T("se_autosave"), Config.get("autoSave") == true, function(on)
        if on and not Compat.has("writefile") then
            Framework.notify(T("n_no_write", tostring(Compat.ExecutorName)), "error", 4)
            return false
        end
        Config.set("autoSave", on)
        Framework.notify(on and T("n_autosave_on", tonumber(Config.get("autoSaveInterval")) or 60, cleanFolder(Config.get("exportFolder"))) or T("n_autosave_off"), on and "success" or "info", 3)
        return true
    end)
    note(T("se_interval"), Theme.Colors.TextSecondary)
    choiceRow({ { 30, "30s" }, { 60, "1 min" }, { 300, "5 min" }, { 600, "10 min" } },
        tonumber(Config.get("autoSaveInterval")) or 60,
        function(v) Config.set("autoSaveInterval", v) end)

    -- ── 3. OPTIONS ───────────────────────────────────────────────
    heading(T("se_options"))

    toggle(T("se_incoming"), Config.get("logIncoming") ~= false, function(on)
        if Hooks and Hooks.setLogIncoming then Hooks.setLogIncoming(on) end
        Config.set("logIncoming", on)
        Framework.notify(on and T("n_inc_on") or T("n_inc_off"), "info", 1.5)
    end)
    toggle(T("se_autoscroll"), RemoteSpy and RemoteSpy.getAutoScroll and RemoteSpy.getAutoScroll(), function(on)
        if RemoteSpy and RemoteSpy.setAutoScroll then RemoteSpy.setAutoScroll(on) end
    end)
    toggle(T("se_pausecap"), Hooks and Hooks.isPaused and Hooks.isPaused(), function(on)
        if Hooks then if on then Hooks.pause() else Hooks.resume() end end
        Framework.notify(on and T("n_paused") or T("n_resumed"), "info", 1.5)
    end)

    -- Window size presets
    heading(T("se_size"))
    local presets = Framework.IS_MOBILE and {
        Small  = UDim2.new(0.75, 0, 0.5, 0),
        Medium = UDim2.new(0.9, 0, 0.62, 0),
        Large  = UDim2.new(0.97, 0, 0.82, 0),
    } or {
        Small  = UDim2.new(0, 440, 0, 300),
        Medium = UDim2.new(0, 520, 0, 360),
        Large  = UDim2.new(0, 680, 0, 480),
    }
    choiceRow({ { "Small", T("sz_small") }, { "Medium", T("sz_medium") }, { "Large", T("sz_large") } },
        Config.get("windowSize") or "Medium",
        function(key)
            Config.set("windowSize", key)
            if window and window.Frame then
                -- Convert scale sizes to pixels so the clamp keeps it on screen
                local target = presets[key]
                window.Frame.Size = target
                window._savedSize = target
                pcall(Framework.clampToScreen, window.Frame)
            end
        end)

    -- ── 4. INFO ──────────────────────────────────────────────────
    heading(T("se_info"))

    local info = {
        { T("i_executor"), Compat.ExecutorName or "Unknown" },
        { T("i_hooking"), Compat.has("hookmetamethod") and "✅ Namecall" or (Compat.has("hookfunction") and "⚠ Function" or "❌") },
        { T("i_incoming"), (Compat.getGlobal and Compat.getGlobal("getconnections")) and T("v_safe") or T("v_delayed") },
        { T("i_files"), Compat.has("writefile") and T("v_avail") or T("v_unavail") },
        { T("i_clip"), Compat.has("setclipboard") and T("v_avail") or T("v_unavail") },
        { T("i_platform"), Framework.IS_MOBILE and T("v_mobile") or T("v_pc") },
    }

    for _, pair in ipairs(info) do
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(row, Theme.CornerRadius.SM)

        create("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = pair[1],
            TextColor3 = Theme.Colors.TextSecondary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        create("TextLabel", {
            Size = UDim2.new(0.6, -12, 1, 0),
            Position = UDim2.new(0.4, 4, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(pair[2]),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
    end

    -- Credits
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "RobloxSpy v" .. VERSION .. "\n" .. T("credits"),
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        LayoutOrder = 1000,
        Parent = scroll,
    })
end

-- ── RUN ─────────────────────────────────────────────────────────

local ok, err = pcall(main)
if not ok then
    warn("[RobloxSpy] Fatal error: " .. tostring(err))
end
