--[[
    ================================================================
    RobloxSpy — init.lua
    Ultimate Remote Spy + Instance Explorer + Session Recorder
    Fusion of SimpleSpy × DarkDEX V5 × Cobalt — with innovations

    Created by Rival960 with the help of Claude
    Version: 1.1.0
    Status: v1.0.0 tested on Delta (PC + iPhone) — v1.1.0 in local testing
    ================================================================

    RELEASE NOTES — v1.1.0
    ----------------------
    Robustness
      • Running the script twice now replaces the old instance (no double hooks)
      • "Unload" button: restores __namecall, disconnects everything, removes the GUI
      • UI connections owned by the window → no leak when the language/theme changes
      • Anti-flood: max N logged calls per remote per second, identical calls grouped "×N"
      • Errors tab: every internal error is listed, deduplicated and copyable
      • Fixed: hookfunction fallback could call nil, R2S lost args after a nil,
        missing Serializer.serializeArgs, caller never saved in sessions
    Capture & analysis
      • InvokeServer return values (optional), OnClientInvoke (optional), Bindables (optional)
      • Per-remote stats, diff with the previous call, keyword alerts, watchlist
      • Ignore / block / watch lists saved per game (PlaceId)
      • Export a whole session as a replayable R2S script
    Performance
      • Explorer reuses its rows (no full rebuild on every click)
      • Auto-save appends only new entries to one file per run (live mode = every 2 s)
    Interface
      • Drawn icons (✕ / maximize / restore / minimize / tabs / reopen button)
        identical on every device and executor
      • Reopen button with unread counter, PC keybind (RightShift by default)
      • Mobile: bottom tab bar, bigger rows and buttons
      • Accent colors, window transparency, text size, tooltips, empty states
      • "What's new" window on first launch of each version

    Usage:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/RobloxSpy/loader.lua"))()
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

local Compat, Config, I18n, Errors, Serializer, Hooks, Session
local Framework, Theme, Icons, RemoteSpy
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
Errors     = tryRequire(script.core.errors)
if Errors and Errors.watchConsole then pcall(Errors.watchConsole) end
Serializer = tryRequire(script.core.serializer)
Hooks      = tryRequire(script.core.hooks)
Session    = tryRequire(script.core.session)
Framework  = tryRequire(script.gui.framework)
Theme      = tryRequire(script.gui.theme)
Icons      = tryRequire(script.gui.icons)
RemoteSpy      = tryRequire(script.modules["remote-spy"])
Explorer       = tryRequire(script.modules.explorer)
NetworkMonitor = tryRequire(script.modules["network-monitor"])
ScriptViewer   = tryRequire(script.modules["script-viewer"])

local T = (I18n and I18n.T) or function(k) return k end

local VERSION = "1.1.0"
local _window = nil
local _spyStarted = false
local _autoSaveThread = nil
local _alive = true          -- false once unloaded (stops every loop)
local _statusThread = nil

-- Forward declarations
local buildWindow, buildHistoryTab, buildSettingsTab, buildErrorsTab, startAutoSave, unloadAll

local function logError(source, err)
    if Errors then Errors.add(source, err) else warn("[RobloxSpy] " .. source .. ": " .. tostring(err)) end
end

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
local function writeExport(fileName, content, append)
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
    local ok, err
    if append and Compat.has("appendfile") and Compat.fileExists(path) then
        ok = Compat.appendFile(path, content)
    else
        ok, err = Compat.writeFile(path, content)
    end
    if ok then return true, path end
    return false, T("n_save_fail", tostring(err))
end

-- ── AUTO-SAVE (incremental) ─────────────────────────────────────
-- Only entries that are new since the last save are written. With
-- appendfile they are appended; files are split past MAX_PART_BYTES.

startAutoSave = function()
    if _autoSaveThread then return end
    -- One text file + one JSON file per run, updated in place on every save
    local runId = os.date("%Y%m%d_%H%M%S") .. "_" .. tostring(game.PlaceId)
    local txtName = "autosave_" .. runId .. ".txt"
    local jsonName = "autosave_" .. runId .. ".json"
    local lastSerial = 0
    local headerWritten = false
    local lastJson = 0

    _autoSaveThread = task.spawn(function()
        while _alive do
            local configured = tonumber(Config.get("autoSaveInterval")) or 60
            local live = configured <= 0
            task.wait(live and 2 or math.max(10, configured))
            if not _alive then break end
            if Config.get("autoSave") and Compat.has("writefile") and RemoteSpy then
                local ok, err = pcall(function()
                    local text, newest = RemoteSpy.exportTextSince(lastSerial)
                    if text ~= "" then
                        local chunk = text
                        if not headerWritten then
                            chunk = T("log_export_title") .. " — " .. os.date("%Y-%m-%d %H:%M:%S")
                                .. " — PlaceId " .. tostring(game.PlaceId) .. "\n" .. string.rep("=", 60) .. "\n" .. text
                        end
                        local wrote
                        if headerWritten and Compat.has("appendfile") then
                            wrote = writeExport(txtName, "\n" .. chunk, true)
                        else
                            local existing = headerWritten and (Compat.readFile(cleanFolder(Config.get("exportFolder")) .. "/" .. txtName) or "") or ""
                            wrote = writeExport(txtName, existing .. (existing ~= "" and "\n" or "") .. chunk, false)
                        end
                        if wrote then
                            headerWritten = true
                            lastSerial = newest
                        end
                    end
                    -- JSON snapshot: rewritten in place (throttled to 10 s in live mode)
                    if Session and (text ~= "" or not live) and (not live or os.clock() - lastJson >= 10) then
                        lastJson = os.clock()
                        writeExport(jsonName, Session.exportCurrent("json"))
                        Session.save()
                    end
                end)
                if not ok then logError("AutoSave", err) end
            end
        end
        _autoSaveThread = nil
    end)
end

local function applyHookOptions()
    if not Hooks then return end
    pcall(Hooks.setLogIncoming, Config.get("logIncoming") ~= false)
    pcall(Hooks.setCaptureReturns, Config.get("captureReturns") == true)
    pcall(Hooks.setCaptureClientInvoke, Config.get("captureClientInvoke") == true)
    pcall(Hooks.setSpyBindables, Config.get("spyBindables") == true)
    pcall(Hooks.setFloodLimit, tonumber(Config.get("floodLimit")) or 30)
end

local function setRecordingStatus()
    if not _window then return end
    local text = T("status_recording", (Compat and Compat.ExecutorName or "Unknown"),
        tostring(Hooks and Hooks.getStrategy and Hooks.getStrategy() or "?"))
    local count = Hooks and Hooks.getCallCount and Hooks.getCallCount() or 0
    text = text .. "  ·  " .. T("status_events", count)
    local skipped = Hooks and Hooks.getFloodSkipped and Hooks.getFloodSkipped() or 0
    if skipped > 0 then text = text .. "  ·  " .. T("status_flood", skipped) end
    local errCount = Errors and Errors.count() or 0
    if errCount > 0 then text = text .. "  ·  " .. T("status_errors", errCount) end
    _window:setStatus(text, (Hooks and Hooks.isPaused and Hooks.isPaused()) and Theme.Colors.Warning or Theme.Colors.Success)
end

local function startSpy()
    if _spyStarted or not RemoteSpy then return end
    _spyStarted = true

    Hooks.subscribe(function(event)
        if NetworkMonitor then
            NetworkMonitor.recordCall(event)
        end
    end)
    applyHookOptions()
    RemoteSpy.start()
    startAutoSave()

    -- Live status bar (events, flood, errors)
    _statusThread = task.spawn(function()
        while _alive do
            pcall(setRecordingStatus)
            task.wait(2)
        end
    end)

    -- Cleanup on teleport
    pcall(function()
        game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
            if RemoteSpy then pcall(RemoteSpy.stop) end
        end)
    end)
end

-- ── WINDOW ──────────────────────────────────────────────────────

local SIZE_PRESETS_MOBILE = {
    Small  = UDim2.new(0.75, 0, 0.5, 0),
    Medium = UDim2.new(0.9, 0, 0.62, 0),
    Large  = UDim2.new(0.97, 0, 0.82, 0),
}
local SIZE_PRESETS_PC = {
    Small  = UDim2.new(0, 440, 0, 300),
    Medium = UDim2.new(0, 540, 0, 370),
    Large  = UDim2.new(0, 700, 0, 490),
}

local function showReleaseNotes(force)
    if not _window then return end
    if not force and Config.get("lastSeenVersion") == VERSION then return end
    local lines = {}
    for i = 1, 10 do
        local key = "rn_" .. i
        local line = T(key)
        if line ~= key then table.insert(lines, "• " .. line) end
    end
    Framework.modal(_window, T("rn_title", VERSION), lines, {
        { T("ok"), Theme.Colors.Accent, function() Config.set("lastSeenVersion", VERSION) end },
    })
end

buildWindow = function()
    local presets = Framework.IS_MOBILE and SIZE_PRESETS_MOBILE or SIZE_PRESETS_PC

    local window = Framework.createWindow({
        Title = "RobloxSpy v" .. VERSION,
        Size = presets[Config.get("windowSize") or "Medium"] or presets.Medium,
    })
    if not window then
        logError("Window", "Failed to create window")
        return nil
    end
    _window = window

    -- Reopen button first: it must exist even if a tab fails to build
    pcall(Framework.createToggleButton, window)

    -- PC keybind
    if not Framework.IS_MOBILE then
        pcall(Framework.bindToggleKey, window, Config.get("toggleKey") or "RightShift")
    end

    -- Tabs (drawn icons — identical on every device)
    local spyTab       = window:addTab(T("tab_spy"), "spy")
    local explorerTab  = window:addTab(T("tab_explorer"), "explorer")
    local networkTab   = window:addTab(T("tab_network"), "network")
    local scriptsTab   = window:addTab(T("tab_scripts"), "scripts")
    local historyTab   = window:addTab(T("tab_history"), "history")
    local errorsTab    = window:addTab(T("tab_errors"), "errors")
    local settingsTab  = window:addTab(T("tab_settings"), "settings")

    -- Each tab is built in isolation: one error no longer blanks every menu
    local function buildTab(name, fn, ...)
        local args = table.pack(...)
        local ok, err = xpcall(function() return fn(table.unpack(args, 1, args.n)) end, function(e)
            return tostring(e) .. "\n" .. (debug and debug.traceback and debug.traceback("", 2) or "")
        end)
        if not ok then logError("Tab " .. name, err) end
    end

    if RemoteSpy then buildTab("Remote Spy", RemoteSpy.buildUI, spyTab) end
    if Explorer then
        buildTab("Explorer", Explorer.buildUI, explorerTab)
        if Explorer.setViewSourceHandler and ScriptViewer then
            Explorer.setViewSourceHandler(function(inst)
                window:switchTab(T("tab_scripts"))
                ScriptViewer.view(inst)
            end)
        end
    end
    if NetworkMonitor then
        buildTab("Network", NetworkMonitor.buildUI, networkTab)
        -- Click a top remote → filter the spy feed on it
        NetworkMonitor.onRemoteClick = function(name)
            window:switchTab(T("tab_spy"))
            if RemoteSpy and RemoteSpy.filterByRemote then RemoteSpy.filterByRemote(name) end
        end
    end
    if ScriptViewer then buildTab("Scripts", ScriptViewer.buildUI, scriptsTab) end
    buildTab("History", buildHistoryTab, historyTab, window)
    buildTab("Errors", buildErrorsTab, errorsTab, window)
    buildTab("Settings", buildSettingsTab, settingsTab, window)

    if _spyStarted then pcall(setRecordingStatus) end
    return window
end

-- Rebuilds the whole interface (language / theme / text size change).
-- Hooks, session and captured events are kept.
local function rebuildWindow(openTabKey)
    local wasMaximized = false
    if _window then
        wasMaximized = _window:isMaximized()
        pcall(function() _window:destroy() end)
        _window = nil
    end
    local w = buildWindow()
    if w then
        if openTabKey then pcall(function() w:switchTab(T(openTabKey)) end) end
        if wasMaximized then pcall(function() w:toggleMaximize(true) end) end
    end
end

-- Full unload: hooks restored, loops stopped, GUI removed, session saved.
unloadAll = function()
    _alive = false
    pcall(function() if Errors and Errors.stopConsole then Errors.stopConsole() end end)
    pcall(function() if Session then Session.save() end end)
    pcall(function() if Hooks and Hooks.unload then Hooks.unload() end end)
    pcall(function() if NetworkMonitor then NetworkMonitor.stop() end end)
    pcall(function() if _window then _window:destroy() end end)
    _window = nil
    pcall(function()
        local sg = Framework and Framework.getScreenGui and Framework.getScreenGui()
        if sg then sg:Destroy() end
    end)
    local G = (getgenv and getgenv()) or _G
    if G.RobloxSpy_Instance and G.RobloxSpy_Instance.version == VERSION and G.RobloxSpy_Instance.unload == unloadAll then
        G.RobloxSpy_Instance = nil
    end
    print("[RobloxSpy] Unloaded.")
end

local function main()
    print("═══════════════════════════════════════")
    print("  RobloxSpy v" .. VERSION)
    print("  Remote Spy • Explorer • Sessions")
    print("═══════════════════════════════════════")

    -- 0. Single instance: running the script again replaces the old one
    local G = (getgenv and getgenv()) or _G
    local previous = G.RobloxSpy_Instance
    if previous and type(previous.unload) == "function" then
        print("[RobloxSpy] Previous instance found (v" .. tostring(previous.version) .. ") — unloading it")
        pcall(previous.unload)
        task.wait(0.1)
    end
    -- Also remove a leftover GUI from an older build without unload()
    pcall(function()
        local parents = {}
        pcall(function() if gethui then table.insert(parents, gethui()) end end)
        pcall(function() table.insert(parents, game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")) end)
        pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
        for _, p in ipairs(parents) do
            local old = p and p:FindFirstChild("RobloxSpyGUI")
            if old then old:Destroy() end
        end
    end)
    G.RobloxSpy_Instance = { version = VERSION, unload = unloadAll }

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
    pcall(setRecordingStatus)

    -- 5. What's new (once per version)
    task.delay(0.6, function() pcall(showReleaseNotes, false) end)

    print("[RobloxSpy] Ready.")
end

-- ── ERRORS TAB ──────────────────────────────────────────────────

buildErrorsTab = function(parent, window)
    if not Errors or not Framework or not Theme then return end
    local create = Framework.create
    local applyCorner = Framework.applyCorner
    local applyPadding = Framework.applyPadding

    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        Parent = parent,
    })
    applyPadding(top, 4, 6, 4, 8)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = top,
    })
    local countLbl = create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Body,
        LayoutOrder = 1,
        Parent = top,
    })
    local function topBtn(text, color, order)
        local b = create("TextButton", {
            Size = UDim2.new(0, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = color,
            BackgroundTransparency = 0.4,
            Text = text,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Small,
            LayoutOrder = order,
            Parent = top,
        })
        applyCorner(b, Theme.CornerRadius.SM)
        applyPadding(b, 2, 8, 2, 8)
        return b
    end
    local copyBtn = topBtn(T("err_copy"), Theme.Colors.Accent, 2)
    local clearBtn = topBtn(T("err_clear"), Theme.Colors.Error, 3)

    local list = Framework.createScrollFrame(parent, {
        Name = "ErrorList",
        Size = UDim2.new(1, 0, 1, -34),
        Position = UDim2.new(0, 0, 0, 34),
        Padding = 3,
        InnerPadding = 6,
    })

    local refreshQueued = false
    local function refresh()
        refreshQueued = false
        if not list.Parent then return end
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local items = Errors.list()
        countLbl.Text = T("err_count", #items)
        if #items == 0 then
            Framework.emptyState(list, T("empty_errors"), "check")
            return
        end
        for i = #items, 1, -1 do
            local e = items[i]
            local row = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Colors.BgSecondary,
                LayoutOrder = #items - i,
                Parent = list,
            })
            applyCorner(row, Theme.CornerRadius.SM)
            applyPadding(row, 4, 8, 4, 8)
            create("TextBox", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = string.format("[%s]  ×%d  %s\n%s", os.date("%H:%M:%S", e.last), e.count, e.source, e.message),
                TextEditable = false,
                ClearTextOnFocus = false,
                TextWrapped = true,
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
        end
    end

    Errors.subscribe(function()
        if refreshQueued then return end
        refreshQueued = true
        task.delay(0.5, refresh) -- coalesce bursts
    end)

    copyBtn.Activated:Connect(function()
        Framework.copy(Errors.toText(), T("c_errors"))
    end)
    clearBtn.Activated:Connect(function()
        Errors.clear()
        refresh()
    end)

    refresh()
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
        local backRow = create("ScrollingFrame", { -- scrolls on narrow phones
            Size = UDim2.new(1, -12, 0, 26),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
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
        smallBtn(backRow, T("hi_export_script"), Theme.Colors.InvokeServer).Activated:Connect(function()
            local script = Session.toR2SScript(data)
            local ok, res = writeExport("replay_" .. tostring(data.id) .. ".lua", script)
            if ok then
                Framework.notify(T("n_saved", res), "success", 4)
            else
                Framework.copy(script, T("c_r2s"))
            end
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

    -- Drop-down selector (same look as the language picker)
    local function choiceRow(options, selected, onPick)
        local function labelOf(v)
            for _, o in ipairs(options) do if o[1] == v then return o[2] end end
            return tostring(v)
        end
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
        local valueLbl = create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = labelOf(selected),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
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
        local rowH = 28
        local listFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, math.min(#options, 6) * (rowH + 2) + 10),
            BackgroundColor3 = Theme.Colors.BgPrimary,
            Visible = false,
            LayoutOrder = nextOrder(),
            Parent = scroll,
        })
        applyCorner(listFrame, Theme.CornerRadius.SM)
        Framework.applyStroke(listFrame, Theme.Colors.Border, 1)
        local list = Framework.createScrollFrame(listFrame, { Padding = 2, InnerPadding = 4 })

        local current = selected
        local rows = {}
        local function paint()
            for v, r in pairs(rows) do
                local isCur = (v == current)
                r.btn.BackgroundColor3 = isCur and Theme.Colors.Accent or Theme.Colors.BgSecondary
                r.btn.BackgroundTransparency = isCur and 0.2 or 0.4
                r.check.Text = isCur and "✓" or ""
            end
            valueLbl.Text = labelOf(current)
        end
        for i, opt in ipairs(options) do
            local b = create("TextButton", {
                Size = UDim2.new(1, -4, 0, rowH),
                Text = "",
                LayoutOrder = i,
                Parent = list,
            })
            applyCorner(b, Theme.CornerRadius.SM)
            create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = opt[2],
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = b,
            })
            local check = create("TextLabel", {
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(1, -34, 0, 0),
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Small,
                Parent = b,
            })
            rows[opt[1]] = { btn = b, check = check }
            b.Activated:Connect(function()
                listFrame.Visible = false
                arrow.Text = "▼"
                if opt[1] == current then return end
                current = opt[1]
                paint()
                onPick(opt[1])
            end)
        end
        paint()
        dropBtn.Activated:Connect(function()
            listFrame.Visible = not listFrame.Visible
            arrow.Text = listFrame.Visible and "▲" or "▼"
        end)
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
        Framework.notify(on and T("n_autosave_on", (tonumber(Config.get("autoSaveInterval")) or 60) == 0 and 2 or (tonumber(Config.get("autoSaveInterval")) or 60), cleanFolder(Config.get("exportFolder"))) or T("n_autosave_off"), on and "success" or "info", 3)
        return true
    end)
    note(T("se_interval"), Theme.Colors.TextSecondary)
    choiceRow({ { 0, T("as_live") }, { 30, "30 s" }, { 60, "1 min" }, { 300, "5 min" }, { 600, "10 min" } },
        tonumber(Config.get("autoSaveInterval")) or 60,
        function(v) Config.set("autoSaveInterval", v) end)

    -- ── 3. CAPTURE ───────────────────────────────────────────────
    heading(T("se_capture"))

    toggle(T("se_incoming"), Config.get("logIncoming") ~= false, function(on)
        if Hooks and Hooks.setLogIncoming then Hooks.setLogIncoming(on) end
        Config.set("logIncoming", on)
        Framework.notify(on and T("n_inc_on") or T("n_inc_off"), "info", 1.5)
    end)
    toggle(T("se_returns"), Config.get("captureReturns") == true, function(on)
        Config.set("captureReturns", on)
        if Hooks and Hooks.setCaptureReturns then Hooks.setCaptureReturns(on) end
        Framework.notify(on and T("n_returns_on") or T("n_option_off"), on and "success" or "info", 3)
    end)
    note(T("se_returns_note"), Theme.Colors.TextMuted)
    toggle(T("se_clientinvoke"), Config.get("captureClientInvoke") == true, function(on)
        if on and not (Hooks and Hooks.canCaptureClientInvoke and Hooks.canCaptureClientInvoke()) then
            Framework.notify(T("n_need_fn", "getcallbackvalue", tostring(Compat.ExecutorName)), "error", 4)
            return false
        end
        Config.set("captureClientInvoke", on)
        if Hooks and Hooks.setCaptureClientInvoke then Hooks.setCaptureClientInvoke(on) end
        return true
    end)
    toggle(T("se_bindables"), Config.get("spyBindables") == true, function(on)
        Config.set("spyBindables", on)
        if Hooks and Hooks.setSpyBindables then Hooks.setSpyBindables(on) end
    end)
    toggle(T("se_group"), Config.get("groupDuplicates") ~= false, function(on)
        Config.set("groupDuplicates", on)
    end)
    note(T("se_flood"), Theme.Colors.TextSecondary)
    choiceRow({ { 0, T("off") }, { 5, "5 / s" }, { 10, "10 / s" }, { 30, "30 / s" }, { 60, "60 / s" }, { 100, "100 / s" }, { 250, "250 / s" } },
        tonumber(Config.get("floodLimit")) or 30,
        function(v)
            Config.set("floodLimit", v)
            if Hooks and Hooks.setFloodLimit then Hooks.setFloodLimit(v) end
        end)
    toggle(T("se_autoscroll"), RemoteSpy and RemoteSpy.getAutoScroll and RemoteSpy.getAutoScroll(), function(on)
        if RemoteSpy and RemoteSpy.setAutoScroll then RemoteSpy.setAutoScroll(on) end
    end)
    toggle(T("se_pausecap"), Hooks and Hooks.isPaused and Hooks.isPaused(), function(on)
        if Hooks then if on then Hooks.pause() else Hooks.resume() end end
        Framework.notify(on and T("n_paused") or T("n_resumed"), "info", 1.5)
    end)

    -- ── 4. ALERTS ────────────────────────────────────────────────
    heading(T("se_alerts"))
    toggle(T("se_alerts_on"), Config.get("alertsEnabled") ~= false, function(on)
        Config.set("alertsEnabled", on)
    end)
    note(T("se_keywords"), Theme.Colors.TextSecondary)
    local kwBox = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        Text = tostring(Config.get("alertKeywords") or ""),
        PlaceholderText = "buy, admin, ban…",
        ClearTextOnFocus = false,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = nextOrder(),
        Parent = scroll,
    })
    applyCorner(kwBox, Theme.CornerRadius.SM)
    applyPadding(kwBox, 0, 8, 0, 8)
    kwBox.FocusLost:Connect(function()
        Config.set("alertKeywords", kwBox.Text)
        if RemoteSpy and RemoteSpy.reloadKeywords then RemoteSpy.reloadKeywords() end
        Framework.notify(T("n_keywords_saved"), "success", 1.5)
    end)

    -- ── 5. APPEARANCE ────────────────────────────────────────────
    heading(T("se_appearance"))
    note(T("se_accent"), Theme.Colors.TextSecondary)
    local accentNames = { blue = T("c_blue"), purple = T("c_purple"), green = T("c_green"), red = T("c_red"), orange = T("c_orange") }
    local accentOpts = {}
    for _, a in ipairs(Theme.Accents) do table.insert(accentOpts, { a.id, accentNames[a.id] or a.id }) end
    choiceRow(accentOpts, Config.get("accent") or "blue", function(id)
        Config.set("accent", id)
        Theme.applyAccent(id)
        task.defer(function() rebuildWindow("tab_settings") end)
    end)
    note(T("se_transparency"), Theme.Colors.TextSecondary)
    choiceRow({ { 0, "0 %" }, { 0.1, "10 %" }, { 0.2, "20 %" }, { 0.3, "30 %" }, { 0.4, "40 %" }, { 0.5, "50 %" } },
        tonumber(Config.get("windowTransparency")) or 0,
        function(v)
            Config.set("windowTransparency", v)
            if window and window.setTransparency then window:setTransparency(v) end
        end)
    note(T("se_textsize"), Theme.Colors.TextSecondary)
    choiceRow({ { "small", T("sz_small") }, { "normal", T("sz_medium") }, { "large", T("sz_large") } },
        Config.get("textScale") or "normal",
        function(id)
            Config.set("textScale", id)
            Theme.applyTextScale(id)
            task.defer(function() rebuildWindow("tab_settings") end)
        end)

    if Framework.IS_MOBILE then
        toggle(T("se_bottomtabs"), Config.get("mobileBottomTabs") ~= false, function(on)
            Config.set("mobileBottomTabs", on)
            task.defer(function() rebuildWindow("tab_settings") end)
        end)
    else
        -- PC keybind
        local keyBtn = button(T("se_keybind", tostring(Config.get("toggleKey") or "RightShift")))
        keyBtn.Activated:Connect(function()
            keyBtn.Text = T("se_keybind_wait")
            Framework.captureKey(function(keyName)
                if keyName then
                    Config.set("toggleKey", keyName)
                    Framework.bindToggleKey(window, keyName)
                    Framework.notify(T("n_keybind", keyName), "success", 2)
                end
                keyBtn.Text = T("se_keybind", tostring(Config.get("toggleKey") or "RightShift"))
            end)
        end)
    end

    -- Window size presets
    heading(T("se_size"))
    local presets = Framework.IS_MOBILE and SIZE_PRESETS_MOBILE or SIZE_PRESETS_PC
    choiceRow({ { "Small", T("sz_small") }, { "Medium", T("sz_medium") }, { "Large", T("sz_large") } },
        Config.get("windowSize") or "Medium",
        function(key)
            Config.set("windowSize", key)
            if window and window.Frame then
                if window:isMaximized() then window:toggleMaximize(false) end
                local target = presets[key]
                window.Frame.Size = target
                window._savedSize = target
                pcall(Framework.clampToScreen, window.Frame)
            end
        end)

    -- ── 6. TOOLS ─────────────────────────────────────────────────
    heading(T("se_tools"))
    button(T("se_export_script"), Theme.Colors.InvokeServer).Activated:Connect(function()
        local data = Session and Session.getCurrent()
        if not data then Framework.notify(T("n_nothing"), "warning") return end
        local script = Session.toR2SScript(data)
        local ok, res = writeExport("replay_" .. tostring(data.id) .. ".lua", script)
        if ok then
            Framework.notify(T("n_saved", res), "success", 4)
        else
            Framework.copy(script, T("c_r2s"))
        end
    end)
    button(T("se_whatsnew")).Activated:Connect(function()
        showReleaseNotes(true)
    end)
    button(T("se_unload"), Theme.Colors.Error).Activated:Connect(function()
        Framework.modal(window, T("unload_title"), { T("unload_body") }, {
            { T("cancel"), Theme.Colors.BgTertiary },
            { T("se_unload"), Theme.Colors.Error, function() task.defer(unloadAll) end },
        })
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
        { "getcallbackvalue", (Compat.getGlobal and Compat.getGlobal("getcallbackvalue")) and T("v_avail") or T("v_unavail") },
        { "appendfile", Compat.has("appendfile") and T("v_avail") or T("v_unavail") },
        { "setnamecallmethod", (Compat.getGlobal and Compat.getGlobal("setnamecallmethod")) and T("v_avail") or T("v_unavail") },
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
