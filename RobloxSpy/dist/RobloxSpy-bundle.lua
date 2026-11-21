--[[
    RobloxSpy — Single-File Bundle
    Auto-generated — do not edit by hand
    All modules fused into one script via _G._RSPY registry
]]

_G._RSPY = _G._RSPY or {}

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/compat.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/compat.lua
        Executor compatibility layer & feature detection

        Detects capabilities of the running executor and provides
        shims/wrappers so the rest of RobloxSpy works uniformly.
    ]]

    local Compat = {}

    -- ── TASK SHIM ────────────────────────────────────────────────────
    if not task then
        task = {
            wait   = function(t) return wait(t) end,
            spawn  = function(f, ...) return spawn(f) end,
            defer  = function(f, ...) return spawn(f) end,
            delay  = function(t, f) return delay(t, f) end,
            cancel = function() end,
        }
    end

    -- ── GLOBAL RESOLUTION ───────────────────────────────────────────
    -- Executors inject globals in different places. This helper finds
    -- a global by name wherever it lives.

    local function resolveGlobal(name)
        -- 1. Direct _G access (works on most executors)
        local ok, val
        ok, val = pcall(function() return rawget(_G, name) end)
        if ok and val ~= nil then return val end

        -- 2. getgenv() — executor-specific global table (Wave, Delta, Solara, etc.)
        ok, val = pcall(function()
            if getgenv then return getgenv()[name] end
        end)
        if ok and val ~= nil then return val end

        -- 3. getfenv(0) — top-level environment
        ok, val = pcall(function() return getfenv(0)[name] end)
        if ok and val ~= nil then return val end

        -- 4. getfenv() — current environment
        ok, val = pcall(function() return getfenv()[name] end)
        if ok and val ~= nil then return val end

        -- 5. Direct global access via loadstring
        ok, val = pcall(function()
            return loadstring("return " .. name)()
        end)
        if ok and val ~= nil then return val end

        return nil
    end

    -- Cache resolved globals for performance
    local _globalCache = {}
    local function getGlobal(name)
        if _globalCache[name] == nil then
            local val = resolveGlobal(name)
            _globalCache[name] = val or false  -- false = checked but not found
        end
        local v = _globalCache[name]
        if v == false then return nil end
        return v
    end

    -- ── EXECUTOR IDENTIFICATION ──────────────────────────────────────
    function Compat.identify()
        local id = "Unknown"
        local ok, result

        -- Try identifyexecutor first (most executors have this)
        local identifyFn = getGlobal("identifyexecutor")
        if identifyFn then
            ok, result = pcall(identifyFn)
            if ok and result then
                id = tostring(result)
                Compat.ExecutorName = id
                return id
            end
        end

        -- Try getexecutorname
        local getNameFn = getGlobal("getexecutorname")
        if getNameFn then
            ok, result = pcall(getNameFn)
            if ok and result then
                id = tostring(result)
                Compat.ExecutorName = id
                return id
            end
        end

        -- Known executor-specific globals
        local checks = {
            { "Solara",   "SOLARA_EXECUTOR" },
            { "Volt",     "is_volt_executor" },
            { "Synapse",  "syn" },
            { "Krnl",     "KRNL_LOADED" },
        }
        for _, entry in ipairs(checks) do
            if getGlobal(entry[2]) then
                id = entry[1]
                break
            end
        end

        Compat.ExecutorName = id
        return id
    end

    -- ── FEATURE DETECTION ────────────────────────────────────────────
    local _detected = false
    local _features = {}

    function Compat.detect()
        if _detected then return _features end
        _detected = true

        local function has(name)
            return getGlobal(name) ~= nil
        end

        -- Hooking
        _features.hookfunction      = has("hookfunction") or has("replaceclosure")
        _features.hookmetamethod    = has("hookmetamethod")
        _features.newcclosure       = has("newcclosure")
        _features.getnamecallmethod = has("getnamecallmethod")
        _features.checkcaller       = has("checkcaller")
        _features.getcallingscript  = has("getcallingscript")
        _features.iscclosure        = has("iscclosure")
        _features.clonefunction     = has("clonefunction") or has("clonefunc")
        _features.getrawmetatable   = has("getrawmetatable")
        _features.setreadonly       = has("setreadonly") or has("make_writeable")

        -- File system
        _features.writefile  = has("writefile")
        _features.readfile   = has("readfile")
        _features.isfile     = has("isfile")
        _features.isfolder   = has("isfolder")
        _features.makefolder = has("makefolder") or has("mkdir")
        _features.listfiles  = has("listfiles")
        _features.delfile    = has("delfile")
        _features.appendfile = has("appendfile")

        -- Environment
        _features.getgenv       = has("getgenv")
        _features.getrenv       = has("getrenv")
        _features.getsenv       = has("getsenv")
        _features.getmenv       = has("getmenv")
        _features.getreg        = has("getreg")
        _features.getgc         = has("getgc")
        _features.getinstances  = has("getinstances")
        _features.getnilinstances = has("getnilinstances")

        -- Debug library
        _features.debug_getupvalue  = pcall(function() return debug and debug.getupvalue end) and debug.getupvalue ~= nil
        _features.debug_setupvalue  = pcall(function() return debug and debug.setupvalue end) and debug.setupvalue ~= nil
        _features.debug_getconstant = pcall(function() return debug and debug.getconstant end) and debug.getconstant ~= nil
        _features.debug_setconstant = pcall(function() return debug and debug.setconstant end) and debug.setconstant ~= nil
        _features.debug_getproto    = pcall(function() return debug and debug.getproto end) and debug.getproto ~= nil
        _features.debug_getstack    = pcall(function() return debug and debug.getstack end) and debug.getstack ~= nil
        _features.debug_getinfo     = pcall(function() return debug and debug.getinfo end) and debug.getinfo ~= nil

        -- Decompiler
        _features.decompile = has("decompile")

        -- Clipboard
        _features.setclipboard = has("setclipboard") or has("toclipboard")

        -- HTTP
        _features.request = has("request") or has("http_request") or (getGlobal("syn") and getGlobal("syn").request ~= nil)
        _features.httpget = pcall(function() return game.HttpGet end)

        -- Drawing API
        _features.Drawing = has("Drawing")

        -- Actors
        _features.run_on_actor          = has("run_on_actor")
        _features.getactors             = has("getactors")
        _features.create_comm_channel   = has("create_comm_channel")
        _features.get_comm_channel      = has("get_comm_channel")

        -- Misc
        _features.setfpscap          = has("setfpscap")
        _features.fireclickdetector  = has("fireclickdetector")
        _features.firetouchinterest  = has("firetouchinterest")
        _features.fireproximityprompt = has("fireproximityprompt")
        _features.saveinstance       = has("saveinstance") or has("save_instance")

        return _features
    end

    -- Shorthand: Compat.has("hookfunction") → bool
    function Compat.has(feature)
        local f = Compat.detect()
        return f[feature] == true
    end

    -- Expose getGlobal for direct access in performance-critical paths
    Compat.getGlobal = getGlobal

    -- ── SAFE WRAPPERS ────────────────────────────────────────────────

    function Compat.hookFunction(target, hook)
        local fn = getGlobal("hookfunction") or getGlobal("replaceclosure")
        if fn then return fn(target, hook) end
        error("[RobloxSpy] hookfunction not available on this executor")
    end

    function Compat.hookMetamethod(obj, method, hook)
        local fn = getGlobal("hookmetamethod")
        if fn then return fn(obj, method, hook) end
        error("[RobloxSpy] hookmetamethod not available on this executor")
    end

    function Compat.newCClosure(fn)
        local ncc = getGlobal("newcclosure")
        if ncc then return ncc(fn) end
        return fn
    end

    function Compat.getNamecallMethod()
        local fn = getGlobal("getnamecallmethod")
        if fn then return fn() end
        return nil
    end

    function Compat.checkcaller()
        local fn = getGlobal("checkcaller")
        if fn then return fn() end
        return false
    end

    function Compat.getCallingScript()
        local fn = getGlobal("getcallingscript")
        if fn then
            local ok, scr = pcall(fn)
            if ok then return scr end
        end
        return nil
    end

    function Compat.getRawMetatable(obj)
        local fn = getGlobal("getrawmetatable")
        if fn then return fn(obj) end
        return getmetatable(obj)
    end

    function Compat.setReadonly(tbl, val)
        local fn = getGlobal("setreadonly")
        if fn then return fn(tbl, val) end
        local fn2 = getGlobal("make_writeable")
        if fn2 and not val then return fn2(tbl) end
    end

    function Compat.setClipboard(text)
        local fn = getGlobal("setclipboard") or getGlobal("toclipboard")
        if fn then return fn(text) end
        warn("[RobloxSpy] Clipboard not available on this executor")
    end

    function Compat.decompile(scriptInst)
        local fn = getGlobal("decompile")
        if fn then
            local ok, src = pcall(fn, scriptInst)
            if ok then return src end
            return "-- Decompilation failed: " .. tostring(src)
        end
        return "-- Decompiler not available on this executor"
    end

    -- ── FILE SYSTEM WRAPPERS ─────────────────────────────────────────
    local SPY_ROOT = "RobloxSpy"

    function Compat.ensureFolder(path)
        local ok = pcall(function()
            local isfolderFn = getGlobal("isfolder")
            if isfolderFn and not isfolderFn(path) then
                local mkFn = getGlobal("makefolder") or getGlobal("mkdir")
                if mkFn then mkFn(path) end
            end
        end)
        return ok
    end

    function Compat.writeFile(path, content)
        local fn = getGlobal("writefile")
        if not fn then return false, "writefile not available" end
        local ok, err = pcall(fn, path, content)
        return ok, err
    end

    function Compat.readFile(path)
        local fn = getGlobal("readfile")
        if not fn then return nil, "readfile not available" end
        local ok, data = pcall(fn, path)
        if ok then return data end
        return nil, data
    end

    function Compat.fileExists(path)
        local fn = getGlobal("isfile")
        if fn then
            local ok, val = pcall(fn, path)
            return ok and val
        end
        local data = Compat.readFile(path)
        return data ~= nil
    end

    function Compat.listFiles(path)
        local fn = getGlobal("listfiles")
        if not fn then return {} end
        local ok, files = pcall(fn, path)
        if ok then return files end
        return {}
    end

    function Compat.deleteFile(path)
        local fn = getGlobal("delfile")
        if not fn then return false end
        local ok = pcall(fn, path)
        return ok
    end

    function Compat.appendFile(path, content)
        local fn = getGlobal("appendfile")
        if fn then
            local ok = pcall(fn, path, content)
            return ok
        end
        local existing = Compat.readFile(path) or ""
        return Compat.writeFile(path, existing .. content)
    end

    function Compat.initStorage()
        if not Compat.has("writefile") then
            return false, "File system not available"
        end
        Compat.ensureFolder(SPY_ROOT)
        Compat.ensureFolder(SPY_ROOT .. "/sessions")
        Compat.ensureFolder(SPY_ROOT .. "/exports")
        Compat.ensureFolder(SPY_ROOT .. "/config")
        return true
    end

    -- ── HTTP WRAPPER ─────────────────────────────────────────────────
    function Compat.httpRequest(options)
        local fn = getGlobal("request") or getGlobal("http_request")
        if fn then return fn(options) end
        local synLib = getGlobal("syn")
        if synLib and synLib.request then return synLib.request(options) end
        local httpLib = getGlobal("http")
        if httpLib and httpLib.request then return httpLib.request(options) end
        return nil
    end

    -- ── CAPABILITY REPORT ────────────────────────────────────────────
    function Compat.report()
        Compat.identify()
        local f = Compat.detect()

        local lines = {
            "[RobloxSpy] Executor: " .. Compat.ExecutorName,
            "[RobloxSpy] Capabilities:"
        }

        local categories = {
            { "Hooking",  {"hookfunction","hookmetamethod","newcclosure","getnamecallmethod","checkcaller","getrawmetatable","setreadonly"} },
            { "Files",    {"writefile","readfile","isfile","isfolder","makefolder","listfiles","appendfile"} },
            { "Debug",    {"debug_getupvalue","debug_setupvalue","debug_getconstant","debug_getproto","debug_getstack"} },
            { "Env",      {"getgenv","getrenv","getsenv","getgc","getinstances","getnilinstances"} },
            { "Actors",   {"run_on_actor","getactors","create_comm_channel"} },
            { "Misc",     {"decompile","setclipboard","Drawing","request","saveinstance"} },
        }

        for _, cat in ipairs(categories) do
            local yes, no = {}, {}
            for _, feat in ipairs(cat[2]) do
                if f[feat] then table.insert(yes, feat) else table.insert(no, feat) end
            end
            local line = "  " .. cat[1] .. ": "
            if #yes > 0 then line = line .. "✓ " .. table.concat(yes, ", ") end
            if #no > 0 then
                if #yes > 0 then line = line .. " | " end
                line = line .. "✗ " .. table.concat(no, ", ")
            end
            table.insert(lines, line)
        end

        return table.concat(lines, "\n")
    end

    -- Auto-detect on load
    Compat.identify()
    Compat.detect()
    _G._RSPY.Compat = Compat
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/config.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/config.lua
        Persistent user settings (language, auto-save, export folder...)

        Stored in RobloxSpy/config/settings.json when the executor can
        write files; otherwise kept in memory for the current run only.
    ]]

    local Compat = _G._RSPY.Compat

    local HttpService = game:GetService("HttpService")

    local Config = {}

    local CONFIG_PATH = "RobloxSpy/config/settings.json"

    local DEFAULTS = {
        language         = nil,                 -- nil = auto-detect from Roblox locale
        autoSave         = false,               -- auto-save logs to exportFolder
        autoSaveInterval = 60,                  -- seconds
        exportFolder     = "RobloxSpy/exports",
        logIncoming      = true,
        autoScroll       = true,
        windowSize       = "Medium",

        -- v1.1.0
        lastSeenVersion  = nil,                 -- shows the release notes once per version
        accent           = "blue",              -- blue | purple | green | red | orange
        textScale        = "normal",            -- small | normal | large
        windowTransparency = 0,                 -- 0 … 0.5
        toggleKey        = "RightShift",        -- PC keybind to show / hide
        mobileBottomTabs = true,                -- mobile: tab bar at the bottom
        floodLimit       = 30,                  -- logged calls per remote per second (0 = off)
        groupDuplicates  = true,                -- identical consecutive calls → one row "×N"
        captureReturns   = false,               -- InvokeServer return values
        captureClientInvoke = false,            -- OnClientInvoke (needs getcallbackvalue)
        spyBindables     = false,               -- BindableEvent / BindableFunction
        alertsEnabled    = true,
        alertKeywords    = "buy,purchase,admin,ban,kick,give,reward,money,cash,gems",
        games            = {},                  -- [PlaceId] = { ignore = {}, drop = {}, watch = {} }
    }

    local _data = {}
    for k, v in pairs(DEFAULTS) do _data[k] = v end

    function Config.load()
        if not Compat.has("readfile") then return false end
        local raw = Compat.readFile(CONFIG_PATH)
        if not raw or raw == "" then return false end
        local ok, parsed = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or type(parsed) ~= "table" then return false end
        for k, v in pairs(parsed) do
            if DEFAULTS[k] ~= nil or k == "language" or k == "lastSeenVersion" then
                _data[k] = v
            end
        end
        return true
    end

    function Config.save()
        if not Compat.has("writefile") then return false end
        pcall(function()
            Compat.ensureFolder("RobloxSpy")
            Compat.ensureFolder("RobloxSpy/config")
        end)
        local ok, json = pcall(function() return HttpService:JSONEncode(_data) end)
        if not ok then return false end
        local wrote = Compat.writeFile(CONFIG_PATH, json)
        return wrote
    end

    function Config.get(key)
        return _data[key]
    end

    -- Per-game rule lists (saved by PlaceId): kind = "ignore" | "drop" | "watch"
    function Config.getGameList(kind)
        local games = _data.games
        if type(games) ~= "table" then games = {}; _data.games = games end
        local g = games[tostring(game.PlaceId)]
        if type(g) ~= "table" then return {} end
        return type(g[kind]) == "table" and g[kind] or {}
    end

    function Config.setGameRule(kind, path, enabled)
        local games = _data.games
        if type(games) ~= "table" then games = {}; _data.games = games end
        local key = tostring(game.PlaceId)
        local g = games[key]
        if type(g) ~= "table" then g = {}; games[key] = g end
        local list = type(g[kind]) == "table" and g[kind] or {}
        local out, found = {}, false
        for _, p in ipairs(list) do
            if p == path then found = true end
            if p ~= path then table.insert(out, p) end
        end
        if enabled then table.insert(out, path) end
        g[kind] = out
        Config.save()
        return not found and enabled
    end

    function Config.set(key, value)
        _data[key] = value
        Config.save()
    end

    Config.load()
    _G._RSPY.Config = Config
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/i18n.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/i18n.lua
        Interface translations (21 languages)

        T(key, ...) returns the text in the current language, formatted with
        string.format when arguments are given. Falls back to English, then
        to the key itself, so a missing translation never breaks the UI.
        Language = saved choice (Config) or auto-detected from the Roblox locale.
    ]]

    local Config = _G._RSPY.Config

    local I18n = {}

    local ORDER = { "EN", "FR", "DE", "ES", "PT", "RU", "IT", "NL", "PL", "ZH", "JA", "TR", "KO", "AR", "VI", "SV", "EL", "RO", "UK", "CS", "DA" }

    local LANG = {}

    LANG.EN = {
        lang_name = "English",
        lang_flag = "🇬🇧",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorer",
        tab_network = "Network",
        tab_scripts = "Scripts",
        tab_history = "History",
        tab_settings = "Settings",
        status_ready = "Ready",
        status_recording = "● Recording — %s · hook: %s",
        pause = "⏸ Pause",
        resume = "▶ Resume",
        clear = "🧹 Clear",
        f_all = "◉ All",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Incoming",
        f_blocked = "⛔ Blocked",
        search_spy = "🔎 Filter remotes, args, paths...",
        feed_cleared = "Feed cleared",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "INCOMING",
        lbl_blocked = "BLOCKED",
        lbl_return = "RETURN",
        back = "← Back",
        copy_code = "📋 Copy code",
        copy_path = "🧭 Copy path",
        copy_args = "📦 Copy args",
        refire = "🔁 Re-fire",
        ignore = "🔇 Ignore",
        unignore = "🔊 Unignore",
        drop = "⛔ Block calls",
        undrop = "✅ Allow calls",
        delete = "🗑 Delete",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTS (%d)",
        sec_r2s = "🧾  R2S CODE (Remote → Script)",
        sec_replay = "🧪  REPLAY CODE",
        k_remote = "Remote",
        k_class = "Class",
        k_method = "Method",
        k_direction = "Direction",
        k_path = "Path",
        k_caller = "Caller",
        k_call = "Call #",
        k_time = "Time",
        k_status = "Status",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(unknown / executor)",
        time_fmt = "+%.3fs after spy start",
        st_logged = "Logged",
        st_dropped = "⛔ Calls blocked",
        st_ignored = "🔇 Ignored",
        no_args = "(no arguments)",
        n_refire_only_out = "Only outgoing calls can be re-fired",
        n_refired = "Re-fired %s",
        n_refire_fail = "Re-fire failed: %s",
        n_log_resumed = "Logging resumed for %s",
        n_ignored = "%s ignored — no more logs",
        n_cant_block_in = "Incoming events can't be blocked from the client",
        n_allowed = "Calls to %s allowed again",
        n_blocked = "Calls to %s are now BLOCKED",
        n_copied = "%s copied to clipboard",
        n_no_clip = "Clipboard unavailable on this executor",
        n_copy_fail = "Copy failed: %s",
        n_action_fail = "Action failed: %s",
        c_code = "Code",
        c_path = "Path",
        c_args = "Arguments",
        c_r2s = "R2S code",
        c_logs = "Logs",
        c_source = "Source",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Generated: %s",
        code_incoming = "-- RobloxSpy — Incoming event (server → client)",
        code_replay = "-- Replay it locally with firesignal (if your executor has it):",
        log_export_title = "RobloxSpy — Log export",
        net_total = "TOTAL CALLS",
        net_cps = "CALLS/SEC",
        net_unique = "UNIQUE",
        net_blocked = "BLOCKED",
        net_traffic = "Traffic (calls/sec, last 60s)",
        net_top = "🏆 Top Remotes (by call count)",
        ex_search = "🔍 Search the whole game...",
        ex_props = "Properties",
        ex_results = "%d results",
        ex_nil = "Nil Instances",
        ex_select = "Select an instance in the tree",
        ex_copy_path = "📋 Copy path",
        ex_copy_code = "🧾 Copy as code",
        ex_tp = "🚀 Teleport",
        ex_view_src = "📜 View source",
        ex_destroy = "🗑 Destroy",
        ex_clone = "📑 Clone",
        ex_attrs = "🏷  ATTRIBUTES",
        ex_tags = "🔖  TAGS",
        ex_children = "Children",
        ex_desc = "Descendants",
        ex_too_many = "Showing the first %d rows — use search",
        n_tp_ok = "Teleported to %s",
        n_tp_fail = "Can't teleport to this instance",
        n_destroyed = "%s destroyed (client side)",
        n_cloned = "%s cloned",
        n_prop_set = "%s = %s",
        n_prop_fail = "Can't set %s: %s",
        sc_scan = "🔍 Scan scripts",
        sc_search = "🔎 Filter scripts...",
        sc_found = "%d scripts found",
        sc_scanning = "Scanning... %d",
        sc_select = "Select a script to view",
        sc_copy = "📋 Copy",
        sc_save = "💾 Save",
        sc_none = "-- No script selected\n-- Click 'Scan scripts' then pick one",
        sc_fail = "-- Could not decompile this script\n-- Your executor may not support decompilation\n-- Path: %s",
        sc_decompiling = "-- Decompiling...",
        sc_all = "All",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Running",
        sc_lines = "%d lines",
        n_saved = "Saved → %s",
        n_save_fail = "Save failed: %s",
        n_no_write = "writefile is not supported by %s — use Copy instead",
        n_nothing = "Nothing to save yet",
        n_folder_fail = "Can't create folder '%s' on this executor",
        hi_title = "🕘 Session History",
        hi_refresh = "🔄 Refresh",
        hi_current = "🔴 LIVE",
        hi_none = "No saved sessions found.",
        hi_nolist = "Your executor can't list/read files — only the live session is shown.",
        hi_calls = "%d calls",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Search across all sessions...",
        hi_results = "%d matches in %d sessions",
        hi_export = "💾 Export .txt",
        hi_deleted = "Session deleted",
        hi_showing = "Showing %d of %d entries",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 This game",
        se_lang = "🌐 Language",
        se_save = "💾 Save logs",
        se_where = "Files are saved in your executor's workspace folder (PC: <Executor>/workspace — iPhone/Android: the executor's folder in the Files app).",
        se_nowrite = "⛔ Your executor can't write files (writefile missing). Use \"Copy logs\" instead.",
        se_folder = "📂 Folder",
        se_last = "Last save: %s",
        se_txt = "📝 Save logs (.txt — readable + R2S code)",
        se_json = "🧩 Save session (.json)",
        se_csv = "📊 Save session (.csv — Excel)",
        se_copy = "📋 Copy logs to clipboard (works everywhere)",
        se_autosave = "🔁 Auto-save logs to the folder",
        se_interval = "⏱ Auto-save interval",
        se_options = "🛠 Options",
        se_incoming = "📥 Log incoming events (server → client)",
        se_autoscroll = "⬇ Auto-scroll feed",
        se_pausecap = "⏸ Pause capture",
        se_size = "📐 Window size",
        sz_small = "Small",
        sz_medium = "Medium",
        sz_large = "Large",
        se_info = "ℹ️ Executor info",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Incoming",
        i_files = "File system",
        i_clip = "Clipboard",
        i_platform = "Platform",
        v_avail = "✅ Available",
        v_unavail = "❌ Unavailable",
        v_safe = "✅ Safe (getconnections)",
        v_delayed = "⚠ Delayed (10s)",
        v_mobile = "📱 Mobile",
        v_pc = "💻 PC",
        n_inc_on = "Incoming events logged",
        n_inc_off = "Incoming events ignored",
        n_paused = "Capture paused",
        n_resumed = "Capture resumed",
        n_autosave_on = "Auto-save every %ds → %s",
        n_autosave_off = "Auto-save off",
        n_lang = "Language: %s",
        credits = "by Rival960 — Made with the help of Claude",
        tab_errors = "Errors",
        ok = "OK",
        cancel = "Cancel",
        off = "Off",
        status_events = "%d events",
        status_flood = "%d skipped (flood)",
        status_errors = "%d errors",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Watched",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Watch",
        unwatch = "☆ Unwatch",
        st_watched = "⭐ Watched",
        dir_local = "🔁 Client ↔ Client (local)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (server asked the client)",
        code_clientinvoke_note = "-- The server called this RemoteFunction's OnClientInvoke with:",
        k_grouped = "Grouped",
        grouped_fmt = "%d identical calls in a row",
        k_flood = "Flood",
        flood_fmt = "%d calls skipped just before (anti-flood)",
        skipped_prefix = "(+%d skipped)",
        sec_stats = "📈  STATS FOR THIS REMOTE",
        k_total = "Total calls",
        k_rate = "Rate",
        rate_fmt = "%.1f calls / min",
        k_first_last = "First → last",
        k_callers = "Callers",
        diff_hint = "changes vs previous call in yellow",
        diff_was = "was: %s",
        sec_return = "↩  RETURNED BY THE SERVER",
        ret_nothing = "(nothing returned)",
        ret_waiting = "Waiting for the server's answer…",
        ret_disabled = "Enable \"Capture InvokeServer return values\" in Settings",
        n_alert = "🔔 Alert: %s (keyword \"%s\")",
        n_saved_game = "saved for this game",
        n_watch_on = "⭐ %s added to the watchlist",
        n_watch_off = "%s removed from the watchlist",
        empty_feed = "No events yet — play a bit, every remote call will appear here.",
        empty_filter = "Nothing matches this filter.",
        empty_network = "No traffic recorded yet.",
        empty_scripts = "Click \"Scan scripts\" to list the game's client scripts.",
        empty_errors = "No errors — everything is running fine.",
        net_click_hint = "click a row to filter the spy",
        err_copy = "📋 Copy all",
        err_clear = "🧹 Clear",
        err_count = "%d error(s)",
        c_errors = "Errors",
        hi_export_script = "🧾 Export as script",
        se_capture = "📡 Capture",
        se_returns = "↩ Capture InvokeServer return values",
        se_returns_note = "Shows what the server answers. Turn it off if a game behaves strangely.",
        se_clientinvoke = "📨 Capture OnClientInvoke (needs getcallbackvalue)",
        se_bindables = "🔗 Spy BindableEvent / BindableFunction",
        se_group = "🧮 Group identical calls (×N)",
        se_flood = "🌊 Anti-flood (max logged calls per remote per second)",
        se_alerts = "🔔 Alerts",
        se_alerts_on = "🔔 Notify when a remote name contains a keyword",
        se_keywords = "Keywords (comma separated)",
        n_keywords_saved = "Keywords saved",
        se_appearance = "🎨 Appearance",
        se_accent = "Accent color",
        c_blue = "Blue",
        c_purple = "Purple",
        c_green = "Green",
        c_red = "Red",
        c_orange = "Orange",
        se_transparency = "Window transparency",
        se_textsize = "Text size",
        se_bottomtabs = "📱 Tab bar at the bottom",
        se_keybind = "⌨ Show / hide key: %s (click to change)",
        se_keybind_wait = "Press a key… (Esc = cancel)",
        n_keybind = "Key set: %s",
        se_tools = "🧰 Tools",
        se_export_script = "🧾 Export this session as a replay script",
        se_whatsnew = "🎉 What's new",
        se_unload = "⏏ Unload RobloxSpy",
        unload_title = "Unload RobloxSpy?",
        unload_body = "Hooks are removed, the session is saved and the interface closes. Run the script again to restart it.",
        n_returns_on = "Return values captured for new InvokeServer calls",
        n_option_off = "Option disabled",
        n_need_fn = "%s is not supported by %s",
        tip_maximize = "Maximize / restore",
        tip_minimize = "Minimize",
        tip_close = "Hide (the round button brings it back)",
        tip_reopen = "Open RobloxSpy (drag to move)",
        tip_copy_r2s = "Copy the R2S code",
        tip_ignore = "Ignore this remote (still sent, not logged)",
        tip_delete = "Delete this row",
        tip_pause = "Pause / resume the capture",
        tip_clear = "Clear the feed",
        tip_expand = "Enlarge the window",
        tip_refire = "Send this call again",
        tip_watch = "Add to the watchlist (saved for this game)",
        tip_drop = "Block: the call never reaches the server",
        rn_title = "🎉 What's new in v%s",
        rn_1 = "Running the script twice replaces the old instance, and the new \"Unload\" button removes everything cleanly.",
        rn_2 = "Anti-flood and grouping: identical calls are merged into one row \"×N\".",
        rn_3 = "InvokeServer return values, OnClientInvoke and Bindables can be captured (Settings → Capture).",
        rn_4 = "Per-remote stats, highlighted differences with the previous call, keyword alerts.",
        rn_5 = "Watchlist and ignore / block lists are saved per game.",
        rn_6 = "Export a whole session as a replayable script (Settings → Tools, or History).",
        rn_7 = "New drawn icons, reopen button with an unread counter, PC keybind (RightShift).",
        rn_8 = "Mobile: bottom tab bar, bigger rows and buttons. Tooltips everywhere (long press on mobile).",
        rn_9 = "Accent colors, transparency and text size in Settings → Appearance.",
        rn_10 = "New Errors tab, faster Explorer, lighter auto-save — plus several bug fixes.",
        as_live = "Live (every 2 s)",
    }

    LANG.FR = {
        lang_name = "Français",
        lang_flag = "🇫🇷",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorateur",
        tab_network = "Réseau",
        tab_scripts = "Scripts",
        tab_history = "Historique",
        tab_settings = "Paramètres",
        status_ready = "Prêt",
        status_recording = "● Enregistrement — %s · hook : %s",
        pause = "⏸ Pause",
        resume = "▶ Reprendre",
        clear = "🧹 Vider",
        f_all = "◉ Tout",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Entrants",
        f_blocked = "⛔ Bloqués",
        search_spy = "🔎 Filtrer remotes, args, chemins...",
        feed_cleared = "Flux vidé",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "ENTRANT",
        lbl_blocked = "BLOQUÉ",
        lbl_return = "RETOUR",
        back = "← Retour",
        copy_code = "📋 Copier le code",
        copy_path = "🧭 Copier le chemin",
        copy_args = "📦 Copier les args",
        refire = "🔁 Renvoyer",
        ignore = "🔇 Ignorer",
        unignore = "🔊 Ne plus ignorer",
        drop = "⛔ Bloquer les appels",
        undrop = "✅ Autoriser les appels",
        delete = "🗑 Supprimer",
        sec_info = "ℹ️  INFOS",
        sec_args = "📦  ARGUMENTS (%d)",
        sec_r2s = "🧾  CODE R2S (Remote → Script)",
        sec_replay = "🧪  CODE DE REJEU",
        k_remote = "Remote",
        k_class = "Classe",
        k_method = "Méthode",
        k_direction = "Sens",
        k_path = "Chemin",
        k_caller = "Appelant",
        k_call = "Appel n°",
        k_time = "Temps",
        k_status = "Statut",
        dir_out = "📤 Client → Serveur",
        dir_in = "📥 Serveur → Client",
        caller_unknown = "(inconnu / executor)",
        time_fmt = "+%.3fs après le lancement",
        st_logged = "Enregistré",
        st_dropped = "⛔ Appels bloqués",
        st_ignored = "🔇 Ignoré",
        no_args = "(aucun argument)",
        n_refire_only_out = "Seuls les appels sortants peuvent être renvoyés",
        n_refired = "%s renvoyé",
        n_refire_fail = "Échec du renvoi : %s",
        n_log_resumed = "Logs réactivés pour %s",
        n_ignored = "%s ignoré — plus de logs",
        n_cant_block_in = "Les events entrants ne peuvent pas être bloqués côté client",
        n_allowed = "Appels vers %s de nouveau autorisés",
        n_blocked = "Appels vers %s maintenant BLOQUÉS",
        n_copied = "%s copié dans le presse-papiers",
        n_no_clip = "Presse-papiers indisponible sur cet executor",
        n_copy_fail = "Échec de la copie : %s",
        n_action_fail = "Action échouée : %s",
        c_code = "Code",
        c_path = "Chemin",
        c_args = "Arguments",
        c_r2s = "Code R2S",
        c_logs = "Logs",
        c_source = "Source",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Généré le : %s",
        code_incoming = "-- RobloxSpy — Event entrant (serveur → client)",
        code_replay = "-- Rejoue-le en local avec firesignal (si ton executor l'a) :",
        log_export_title = "RobloxSpy — Export des logs",
        net_total = "APPELS TOTAUX",
        net_cps = "APPELS/SEC",
        net_unique = "UNIQUES",
        net_blocked = "BLOQUÉS",
        net_traffic = "Trafic (appels/sec, 60 dernières s)",
        net_top = "🏆 Top remotes (par nombre d'appels)",
        ex_search = "🔍 Rechercher dans tout le jeu...",
        ex_props = "Propriétés",
        ex_results = "%d résultats",
        ex_nil = "Instances nil",
        ex_select = "Sélectionne une instance dans l'arbre",
        ex_copy_path = "📋 Copier le chemin",
        ex_copy_code = "🧾 Copier en code",
        ex_tp = "🚀 Téléporter",
        ex_view_src = "📜 Voir la source",
        ex_destroy = "🗑 Détruire",
        ex_clone = "📑 Cloner",
        ex_attrs = "🏷  ATTRIBUTS",
        ex_tags = "🔖  TAGS",
        ex_children = "Enfants",
        ex_desc = "Descendants",
        ex_too_many = "Seules les %d premières lignes sont affichées — utilise la recherche",
        n_tp_ok = "Téléporté à %s",
        n_tp_fail = "Impossible de se téléporter à cette instance",
        n_destroyed = "%s détruit (côté client)",
        n_cloned = "%s cloné",
        n_prop_set = "%s = %s",
        n_prop_fail = "Impossible de modifier %s : %s",
        sc_scan = "🔍 Scanner les scripts",
        sc_search = "🔎 Filtrer les scripts...",
        sc_found = "%d scripts trouvés",
        sc_scanning = "Scan en cours... %d",
        sc_select = "Sélectionne un script à afficher",
        sc_copy = "📋 Copier",
        sc_save = "💾 Sauver",
        sc_none = "-- Aucun script sélectionné\n-- Clique sur 'Scanner les scripts' puis choisis-en un",
        sc_fail = "-- Impossible de décompiler ce script\n-- Ton executor ne gère peut-être pas la décompilation\n-- Chemin : %s",
        sc_decompiling = "-- Décompilation...",
        sc_all = "Tous",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Actifs",
        sc_lines = "%d lignes",
        n_saved = "Sauvegardé → %s",
        n_save_fail = "Échec de la sauvegarde : %s",
        n_no_write = "writefile n'est pas supporté par %s — utilise Copier",
        n_nothing = "Rien à sauvegarder pour l'instant",
        n_folder_fail = "Impossible de créer le dossier '%s' sur cet executor",
        hi_title = "🕘 Historique des sessions",
        hi_refresh = "🔄 Actualiser",
        hi_current = "🔴 EN DIRECT",
        hi_none = "Aucune session sauvegardée.",
        hi_nolist = "Ton executor ne peut pas lister/lire les fichiers — seule la session en cours est affichée.",
        hi_calls = "%d appels",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Rechercher dans toutes les sessions...",
        hi_results = "%d résultats dans %d sessions",
        hi_export = "💾 Exporter .txt",
        hi_deleted = "Session supprimée",
        hi_showing = "%d entrées affichées sur %d",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Ce jeu",
        se_lang = "🌐 Langue",
        se_save = "💾 Sauvegarde des logs",
        se_where = "Les fichiers sont enregistrés dans le dossier workspace de ton executor (PC : <Executor>/workspace — iPhone/Android : le dossier de l'executor dans l'app Fichiers).",
        se_nowrite = "⛔ Ton executor ne peut pas écrire de fichiers (writefile absent). Utilise « Copier les logs ».",
        se_folder = "📂 Dossier",
        se_last = "Dernière sauvegarde : %s",
        se_txt = "📝 Sauver les logs (.txt — lisible + code R2S)",
        se_json = "🧩 Sauver la session (.json)",
        se_csv = "📊 Sauver la session (.csv — Excel)",
        se_copy = "📋 Copier les logs (marche partout)",
        se_autosave = "🔁 Sauvegarde auto dans le dossier",
        se_interval = "⏱ Intervalle de sauvegarde auto",
        se_options = "🛠 Options",
        se_incoming = "📥 Logger les events entrants (serveur → client)",
        se_autoscroll = "⬇ Défilement auto du flux",
        se_pausecap = "⏸ Mettre la capture en pause",
        se_size = "📐 Taille de la fenêtre",
        sz_small = "Petite",
        sz_medium = "Moyenne",
        sz_large = "Grande",
        se_info = "ℹ️ Infos executor",
        i_executor = "Executor",
        i_hooking = "Hook",
        i_incoming = "Entrants",
        i_files = "Fichiers",
        i_clip = "Presse-papiers",
        i_platform = "Plateforme",
        v_avail = "✅ Disponible",
        v_unavail = "❌ Indisponible",
        v_safe = "✅ Sûr (getconnections)",
        v_delayed = "⚠ Différé (10 s)",
        v_mobile = "📱 Mobile",
        v_pc = "💻 PC",
        n_inc_on = "Events entrants loggés",
        n_inc_off = "Events entrants ignorés",
        n_paused = "Capture en pause",
        n_resumed = "Capture reprise",
        n_autosave_on = "Sauvegarde auto toutes les %ds → %s",
        n_autosave_off = "Sauvegarde auto désactivée",
        n_lang = "Langue : %s",
        credits = "par Rival960 — Réalisé avec l'aide de Claude",
        tab_errors = "Erreurs",
        ok = "OK",
        cancel = "Annuler",
        off = "Off",
        status_events = "%d events",
        status_flood = "%d ignorés (flood)",
        status_errors = "%d erreurs",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Suivis",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Suivre",
        unwatch = "☆ Ne plus suivre",
        st_watched = "⭐ Suivi",
        dir_local = "🔁 Client ↔ Client (local)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (le serveur interroge le client)",
        code_clientinvoke_note = "-- Le serveur a appelé l'OnClientInvoke de ce RemoteFunction avec :",
        k_grouped = "Regroupé",
        grouped_fmt = "%d appels identiques à la suite",
        k_flood = "Flood",
        flood_fmt = "%d appels ignorés juste avant (anti-flood)",
        skipped_prefix = "(+%d ignorés)",
        sec_stats = "📈  STATS DE CE REMOTE",
        k_total = "Appels totaux",
        k_rate = "Fréquence",
        rate_fmt = "%.1f appels / min",
        k_first_last = "Premier → dernier",
        k_callers = "Appelants",
        diff_hint = "changements vs appel précédent en jaune",
        diff_was = "avant : %s",
        sec_return = "↩  RENVOYÉ PAR LE SERVEUR",
        ret_nothing = "(rien de renvoyé)",
        ret_waiting = "En attente de la réponse du serveur…",
        ret_disabled = "Active « Capturer les retours d'InvokeServer » dans les Paramètres",
        n_alert = "🔔 Alerte : %s (mot-clé « %s »)",
        n_saved_game = "enregistré pour ce jeu",
        n_watch_on = "⭐ %s ajouté à la watchlist",
        n_watch_off = "%s retiré de la watchlist",
        empty_feed = "Aucun event pour l'instant — joue un peu, chaque appel de remote s'affichera ici.",
        empty_filter = "Rien ne correspond à ce filtre.",
        empty_network = "Aucun trafic enregistré pour l'instant.",
        empty_scripts = "Clique sur « Scanner les scripts » pour lister les scripts client du jeu.",
        empty_errors = "Aucune erreur — tout fonctionne.",
        net_click_hint = "clique sur une ligne pour filtrer le spy",
        err_copy = "📋 Tout copier",
        err_clear = "🧹 Vider",
        err_count = "%d erreur(s)",
        c_errors = "Erreurs",
        hi_export_script = "🧾 Exporter en script",
        se_capture = "📡 Capture",
        se_returns = "↩ Capturer les retours d'InvokeServer",
        se_returns_note = "Affiche ce que répond le serveur. Désactive-le si un jeu se comporte bizarrement.",
        se_clientinvoke = "📨 Capturer les OnClientInvoke (nécessite getcallbackvalue)",
        se_bindables = "🔗 Espionner BindableEvent / BindableFunction",
        se_group = "🧮 Regrouper les appels identiques (×N)",
        se_flood = "🌊 Anti-flood (max d'appels loggés par remote et par seconde)",
        se_alerts = "🔔 Alertes",
        se_alerts_on = "🔔 Notifier quand le nom d'un remote contient un mot-clé",
        se_keywords = "Mots-clés (séparés par des virgules)",
        n_keywords_saved = "Mots-clés enregistrés",
        se_appearance = "🎨 Apparence",
        se_accent = "Couleur d'accent",
        c_blue = "Bleu",
        c_purple = "Violet",
        c_green = "Vert",
        c_red = "Rouge",
        c_orange = "Orange",
        se_transparency = "Transparence de la fenêtre",
        se_textsize = "Taille du texte",
        se_bottomtabs = "📱 Barre d'onglets en bas",
        se_keybind = "⌨ Touche afficher / cacher : %s (clique pour changer)",
        se_keybind_wait = "Appuie sur une touche… (Échap = annuler)",
        n_keybind = "Touche définie : %s",
        se_tools = "🧰 Outils",
        se_export_script = "🧾 Exporter cette session en script de replay",
        se_whatsnew = "🎉 Nouveautés",
        se_unload = "⏏ Décharger RobloxSpy",
        unload_title = "Décharger RobloxSpy ?",
        unload_body = "Les hooks sont retirés, la session est sauvegardée et l'interface se ferme. Relance le script pour le redémarrer.",
        n_returns_on = "Valeurs de retour capturées pour les nouveaux InvokeServer",
        n_option_off = "Option désactivée",
        n_need_fn = "%s n'est pas supporté par %s",
        tip_maximize = "Agrandir / restaurer",
        tip_minimize = "Réduire",
        tip_close = "Cacher (le bouton rond la fait revenir)",
        tip_reopen = "Ouvrir RobloxSpy (glisse pour déplacer)",
        tip_copy_r2s = "Copier le code R2S",
        tip_ignore = "Ignorer ce remote (toujours envoyé, plus loggé)",
        tip_delete = "Supprimer cette ligne",
        tip_pause = "Mettre en pause / reprendre la capture",
        tip_clear = "Vider le flux",
        tip_expand = "Agrandir la fenêtre",
        tip_refire = "Renvoyer cet appel",
        tip_watch = "Ajouter à la watchlist (enregistré pour ce jeu)",
        tip_drop = "Bloquer : l'appel n'arrive jamais au serveur",
        rn_title = "🎉 Nouveautés de la v%s",
        rn_1 = "Relancer le script remplace l'ancienne instance, et le nouveau bouton « Décharger » retire tout proprement.",
        rn_2 = "Anti-flood et regroupement : les appels identiques sont fusionnés en une ligne « ×N ».",
        rn_3 = "Les retours d'InvokeServer, les OnClientInvoke et les Bindables peuvent être capturés (Paramètres → Capture).",
        rn_4 = "Stats par remote, différences avec l'appel précédent surlignées, alertes par mot-clé.",
        rn_5 = "La watchlist et les listes ignorés / bloqués sont sauvegardées par jeu.",
        rn_6 = "Export d'une session complète en script rejouable (Paramètres → Outils, ou Historique).",
        rn_7 = "Nouvelles icônes dessinées, bouton de réouverture avec compteur, raccourci PC (RightShift).",
        rn_8 = "Mobile : onglets en bas, lignes et boutons plus grands. Infobulles partout (appui long sur mobile).",
        rn_9 = "Couleurs d'accent, transparence et taille du texte dans Paramètres → Apparence.",
        rn_10 = "Nouvel onglet Erreurs, Explorer plus rapide, auto-save plus léger — et plusieurs bugs corrigés.",
        as_live = "En continu (toutes les 2 s)",
    }

    LANG.DE = {
        lang_name = "Deutsch",
        lang_flag = "🇩🇪",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorer",
        tab_network = "Netzwerk",
        tab_scripts = "Skripte",
        tab_history = "Verlauf",
        tab_settings = "Einstellungen",
        status_ready = "Bereit",
        status_recording = "● Aufnahme — %s · Hook: %s",
        pause = "⏸ Pause",
        resume = "▶ Fortsetzen",
        clear = "🧹 Leeren",
        f_all = "◉ Alle",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Eingehend",
        f_blocked = "⛔ Blockiert",
        search_spy = "🔎 Remotes, Args, Pfade filtern...",
        feed_cleared = "Feed geleert",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "EINGEHEND",
        lbl_blocked = "BLOCKIERT",
        lbl_return = "RÜCKGABE",
        back = "← Zurück",
        copy_code = "📋 Code kopieren",
        copy_path = "🧭 Pfad kopieren",
        copy_args = "📦 Args kopieren",
        refire = "🔁 Erneut senden",
        ignore = "🔇 Ignorieren",
        unignore = "🔊 Nicht mehr ignorieren",
        drop = "⛔ Aufrufe blockieren",
        undrop = "✅ Aufrufe erlauben",
        delete = "🗑 Löschen",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTE (%d)",
        sec_r2s = "🧾  R2S-CODE (Remote → Script)",
        sec_replay = "🧪  WIEDERGABE-CODE",
        k_remote = "Remote",
        k_class = "Klasse",
        k_method = "Methode",
        k_direction = "Richtung",
        k_path = "Pfad",
        k_caller = "Aufrufer",
        k_call = "Aufruf Nr.",
        k_time = "Zeit",
        k_status = "Status",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(unbekannt / Executor)",
        time_fmt = "+%.3fs nach dem Start",
        st_logged = "Protokolliert",
        st_dropped = "⛔ Aufrufe blockiert",
        st_ignored = "🔇 Ignoriert",
        no_args = "(keine Argumente)",
        n_refire_only_out = "Nur ausgehende Aufrufe können erneut gesendet werden",
        n_refired = "%s erneut gesendet",
        n_refire_fail = "Erneutes Senden fehlgeschlagen: %s",
        n_log_resumed = "Protokollierung für %s fortgesetzt",
        n_ignored = "%s ignoriert — keine Logs mehr",
        n_cant_block_in = "Eingehende Events können clientseitig nicht blockiert werden",
        n_allowed = "Aufrufe an %s wieder erlaubt",
        n_blocked = "Aufrufe an %s sind jetzt BLOCKIERT",
        n_copied = "%s in die Zwischenablage kopiert",
        n_no_clip = "Zwischenablage auf diesem Executor nicht verfügbar",
        n_copy_fail = "Kopieren fehlgeschlagen: %s",
        n_action_fail = "Aktion fehlgeschlagen: %s",
        c_code = "Code",
        c_path = "Pfad",
        c_args = "Argumente",
        c_r2s = "R2S-Code",
        c_logs = "Logs",
        c_source = "Quelltext",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Erstellt: %s",
        code_incoming = "-- RobloxSpy — Eingehendes Event (Server → Client)",
        code_replay = "-- Lokal mit firesignal abspielen (falls dein Executor es hat):",
        log_export_title = "RobloxSpy — Log-Export",
        net_total = "AUFRUFE GESAMT",
        net_cps = "AUFRUFE/SEK",
        net_unique = "EINDEUTIG",
        net_blocked = "BLOCKIERT",
        net_traffic = "Traffic (Aufrufe/Sek, letzte 60 s)",
        net_top = "🏆 Top-Remotes (nach Aufrufen)",
        ex_search = "🔍 Das ganze Spiel durchsuchen...",
        ex_props = "Eigenschaften",
        ex_results = "%d Ergebnisse",
        ex_nil = "Nil-Instanzen",
        ex_select = "Wähle eine Instanz im Baum",
        ex_copy_path = "📋 Pfad kopieren",
        ex_copy_code = "🧾 Als Code kopieren",
        ex_tp = "🚀 Teleportieren",
        ex_view_src = "📜 Quelltext ansehen",
        ex_destroy = "🗑 Zerstören",
        ex_clone = "📑 Klonen",
        ex_attrs = "🏷  ATTRIBUTE",
        ex_tags = "🔖  TAGS",
        ex_children = "Kinder",
        ex_desc = "Nachkommen",
        ex_too_many = "Nur die ersten %d Zeilen — nutze die Suche",
        n_tp_ok = "Zu %s teleportiert",
        n_tp_fail = "Teleport zu dieser Instanz nicht möglich",
        n_destroyed = "%s zerstört (clientseitig)",
        n_cloned = "%s geklont",
        n_prop_set = "%s = %s",
        n_prop_fail = "%s kann nicht gesetzt werden: %s",
        sc_scan = "🔍 Skripte scannen",
        sc_search = "🔎 Skripte filtern...",
        sc_found = "%d Skripte gefunden",
        sc_scanning = "Scanne... %d",
        sc_select = "Wähle ein Skript zum Anzeigen",
        sc_copy = "📋 Kopieren",
        sc_save = "💾 Speichern",
        sc_none = "-- Kein Skript ausgewählt\n-- Klicke auf 'Skripte scannen' und wähle eins",
        sc_fail = "-- Dieses Skript konnte nicht dekompiliert werden\n-- Dein Executor unterstützt das evtl. nicht\n-- Pfad: %s",
        sc_decompiling = "-- Dekompiliere...",
        sc_all = "Alle",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Laufend",
        sc_lines = "%d Zeilen",
        n_saved = "Gespeichert → %s",
        n_save_fail = "Speichern fehlgeschlagen: %s",
        n_no_write = "writefile wird von %s nicht unterstützt — nutze Kopieren",
        n_nothing = "Noch nichts zu speichern",
        n_folder_fail = "Ordner '%s' kann auf diesem Executor nicht erstellt werden",
        hi_title = "🕘 Sitzungsverlauf",
        hi_refresh = "🔄 Aktualisieren",
        hi_current = "🔴 LIVE",
        hi_none = "Keine gespeicherten Sitzungen.",
        hi_nolist = "Dein Executor kann keine Dateien auflisten/lesen — nur die aktuelle Sitzung wird gezeigt.",
        hi_calls = "%d Aufrufe",
        hi_unique = "%d Remotes",
        hi_search_all = "🔎 In allen Sitzungen suchen...",
        hi_results = "%d Treffer in %d Sitzungen",
        hi_export = "💾 Als .txt exportieren",
        hi_deleted = "Sitzung gelöscht",
        hi_showing = "%d von %d Einträgen angezeigt",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Dieses Spiel",
        se_lang = "🌐 Sprache",
        se_save = "💾 Logs speichern",
        se_where = "Dateien landen im Workspace-Ordner deines Executors (PC: <Executor>/workspace — iPhone/Android: Ordner des Executors in der Dateien-App).",
        se_nowrite = "⛔ Dein Executor kann keine Dateien schreiben (writefile fehlt). Nutze „Logs kopieren“.",
        se_folder = "📂 Ordner",
        se_last = "Zuletzt gespeichert: %s",
        se_txt = "📝 Logs speichern (.txt — lesbar + R2S-Code)",
        se_json = "🧩 Sitzung speichern (.json)",
        se_csv = "📊 Sitzung speichern (.csv — Excel)",
        se_copy = "📋 Logs kopieren (funktioniert überall)",
        se_autosave = "🔁 Logs automatisch im Ordner speichern",
        se_interval = "⏱ Intervall der Auto-Speicherung",
        se_options = "🛠 Optionen",
        se_incoming = "📥 Eingehende Events protokollieren (Server → Client)",
        se_autoscroll = "⬇ Feed automatisch scrollen",
        se_pausecap = "⏸ Aufnahme pausieren",
        se_size = "📐 Fenstergröße",
        sz_small = "Klein",
        sz_medium = "Mittel",
        sz_large = "Groß",
        se_info = "ℹ️ Executor-Info",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Eingehend",
        i_files = "Dateisystem",
        i_clip = "Zwischenablage",
        i_platform = "Plattform",
        v_avail = "✅ Verfügbar",
        v_unavail = "❌ Nicht verfügbar",
        v_safe = "✅ Sicher (getconnections)",
        v_delayed = "⚠ Verzögert (10 s)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Eingehende Events werden protokolliert",
        n_inc_off = "Eingehende Events werden ignoriert",
        n_paused = "Aufnahme pausiert",
        n_resumed = "Aufnahme fortgesetzt",
        n_autosave_on = "Auto-Speicherung alle %ds → %s",
        n_autosave_off = "Auto-Speicherung aus",
        n_lang = "Sprache: %s",
        credits = "von Rival960 — Erstellt mit Hilfe von Claude",
        tab_errors = "Fehler",
        ok = "OK",
        cancel = "Abbrechen",
        off = "Aus",
        status_events = "%d Events",
        status_flood = "%d übersprungen (Flood)",
        status_errors = "%d Fehler",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Beobachtet",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Beobachten",
        unwatch = "☆ Nicht mehr beobachten",
        st_watched = "⭐ Beobachtet",
        dir_local = "🔁 Client ↔ Client (lokal)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (Server fragt den Client)",
        code_clientinvoke_note = "-- Der Server rief OnClientInvoke dieser RemoteFunction auf mit:",
        k_grouped = "Gruppiert",
        grouped_fmt = "%d identische Aufrufe hintereinander",
        k_flood = "Flood",
        flood_fmt = "%d Aufrufe kurz davor übersprungen (Anti-Flood)",
        skipped_prefix = "(+%d übersprungen)",
        sec_stats = "📈  STATISTIK DIESES REMOTES",
        k_total = "Aufrufe gesamt",
        k_rate = "Rate",
        rate_fmt = "%.1f Aufrufe / Min",
        k_first_last = "Erster → letzter",
        k_callers = "Aufrufer",
        diff_hint = "Änderungen zum vorigen Aufruf in Gelb",
        diff_was = "vorher: %s",
        sec_return = "↩  VOM SERVER ZURÜCKGEGEBEN",
        ret_nothing = "(nichts zurückgegeben)",
        ret_waiting = "Warte auf die Antwort des Servers…",
        ret_disabled = "Aktiviere „InvokeServer-Rückgabewerte erfassen“ in den Einstellungen",
        n_alert = "🔔 Alarm: %s (Stichwort „%s“)",
        n_saved_game = "für dieses Spiel gespeichert",
        n_watch_on = "⭐ %s zur Beobachtungsliste hinzugefügt",
        n_watch_off = "%s von der Beobachtungsliste entfernt",
        empty_feed = "Noch keine Events — spiel ein bisschen, jeder Remote-Aufruf erscheint hier.",
        empty_filter = "Nichts passt zu diesem Filter.",
        empty_network = "Noch kein Traffic aufgezeichnet.",
        empty_scripts = "Klicke auf „Skripte scannen“, um die Client-Skripte des Spiels aufzulisten.",
        empty_errors = "Keine Fehler — alles läuft.",
        net_click_hint = "Zeile anklicken, um den Spy zu filtern",
        err_copy = "📋 Alles kopieren",
        err_clear = "🧹 Leeren",
        err_count = "%d Fehler",
        c_errors = "Fehler",
        hi_export_script = "🧾 Als Skript exportieren",
        se_capture = "📡 Erfassung",
        se_returns = "↩ InvokeServer-Rückgabewerte erfassen",
        se_returns_note = "Zeigt, was der Server antwortet. Deaktivieren, falls sich ein Spiel seltsam verhält.",
        se_clientinvoke = "📨 OnClientInvoke erfassen (benötigt getcallbackvalue)",
        se_bindables = "🔗 BindableEvent / BindableFunction überwachen",
        se_group = "🧮 Identische Aufrufe gruppieren (×N)",
        se_flood = "🌊 Anti-Flood (max. protokollierte Aufrufe pro Remote pro Sekunde)",
        se_alerts = "🔔 Alarme",
        se_alerts_on = "🔔 Benachrichtigen, wenn ein Remote-Name ein Stichwort enthält",
        se_keywords = "Stichwörter (durch Komma getrennt)",
        n_keywords_saved = "Stichwörter gespeichert",
        se_appearance = "🎨 Darstellung",
        se_accent = "Akzentfarbe",
        c_blue = "Blau",
        c_purple = "Lila",
        c_green = "Grün",
        c_red = "Rot",
        c_orange = "Orange",
        se_transparency = "Fenstertransparenz",
        se_textsize = "Textgröße",
        se_bottomtabs = "📱 Tableiste unten",
        se_keybind = "⌨ Taste anzeigen / verbergen: %s (klicken zum Ändern)",
        se_keybind_wait = "Drücke eine Taste… (Esc = Abbrechen)",
        n_keybind = "Taste gesetzt: %s",
        se_tools = "🧰 Werkzeuge",
        se_export_script = "🧾 Diese Sitzung als Replay-Skript exportieren",
        se_whatsnew = "🎉 Neuigkeiten",
        se_unload = "⏏ RobloxSpy entladen",
        unload_title = "RobloxSpy entladen?",
        unload_body = "Die Hooks werden entfernt, die Sitzung gespeichert und die Oberfläche geschlossen. Führe das Skript erneut aus, um es neu zu starten.",
        n_returns_on = "Rückgabewerte für neue InvokeServer-Aufrufe werden erfasst",
        n_option_off = "Option deaktiviert",
        n_need_fn = "%s wird von %s nicht unterstützt",
        tip_maximize = "Maximieren / wiederherstellen",
        tip_minimize = "Minimieren",
        tip_close = "Ausblenden (der runde Knopf holt es zurück)",
        tip_reopen = "RobloxSpy öffnen (ziehen zum Verschieben)",
        tip_copy_r2s = "R2S-Code kopieren",
        tip_ignore = "Diesen Remote ignorieren (wird gesendet, nicht protokolliert)",
        tip_delete = "Diese Zeile löschen",
        tip_pause = "Erfassung pausieren / fortsetzen",
        tip_clear = "Feed leeren",
        tip_expand = "Fenster vergrößern",
        tip_refire = "Diesen Aufruf erneut senden",
        tip_watch = "Zur Beobachtungsliste hinzufügen (für dieses Spiel gespeichert)",
        tip_drop = "Blockieren: der Aufruf erreicht den Server nie",
        rn_title = "🎉 Neu in v%s",
        rn_1 = "Ein zweiter Start ersetzt die alte Instanz, und der neue Knopf „Entladen“ entfernt alles sauber.",
        rn_2 = "Anti-Flood und Gruppierung: identische Aufrufe werden zu einer Zeile „×N“ zusammengefasst.",
        rn_3 = "InvokeServer-Rückgaben, OnClientInvoke und Bindables können erfasst werden (Einstellungen → Erfassung).",
        rn_4 = "Statistik pro Remote, hervorgehobene Unterschiede zum vorigen Aufruf, Stichwort-Alarme.",
        rn_5 = "Beobachtungsliste und Ignorier-/Blockierlisten werden pro Spiel gespeichert.",
        rn_6 = "Eine ganze Sitzung als abspielbares Skript exportieren (Einstellungen → Werkzeuge oder Verlauf).",
        rn_7 = "Neue gezeichnete Icons, Öffnen-Knopf mit Zähler, PC-Taste (RightShift).",
        rn_8 = "Mobil: Tableiste unten, größere Zeilen und Knöpfe. Tooltips überall (langes Drücken auf Mobil).",
        rn_9 = "Akzentfarben, Transparenz und Textgröße unter Einstellungen → Darstellung.",
        rn_10 = "Neuer Fehler-Tab, schnellerer Explorer, leichtere Auto-Speicherung — plus mehrere Fehlerbehebungen.",
        as_live = "Live (alle 2 s)",
    }

    LANG.ES = {
        lang_name = "Español",
        lang_flag = "🇪🇸",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorador",
        tab_network = "Red",
        tab_scripts = "Scripts",
        tab_history = "Historial",
        tab_settings = "Ajustes",
        status_ready = "Listo",
        status_recording = "● Grabando — %s · hook: %s",
        pause = "⏸ Pausa",
        resume = "▶ Reanudar",
        clear = "🧹 Limpiar",
        f_all = "◉ Todo",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Entrantes",
        f_blocked = "⛔ Bloqueados",
        search_spy = "🔎 Filtrar remotes, args, rutas...",
        feed_cleared = "Registro limpiado",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "ENTRANTE",
        lbl_blocked = "BLOQUEADO",
        lbl_return = "RETORNO",
        back = "← Volver",
        copy_code = "📋 Copiar código",
        copy_path = "🧭 Copiar ruta",
        copy_args = "📦 Copiar args",
        refire = "🔁 Reenviar",
        ignore = "🔇 Ignorar",
        unignore = "🔊 Dejar de ignorar",
        drop = "⛔ Bloquear llamadas",
        undrop = "✅ Permitir llamadas",
        delete = "🗑 Eliminar",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTOS (%d)",
        sec_r2s = "🧾  CÓDIGO R2S (Remote → Script)",
        sec_replay = "🧪  CÓDIGO DE REPETICIÓN",
        k_remote = "Remote",
        k_class = "Clase",
        k_method = "Método",
        k_direction = "Dirección",
        k_path = "Ruta",
        k_caller = "Llamador",
        k_call = "Llamada n.º",
        k_time = "Tiempo",
        k_status = "Estado",
        dir_out = "📤 Cliente → Servidor",
        dir_in = "📥 Servidor → Cliente",
        caller_unknown = "(desconocido / executor)",
        time_fmt = "+%.3fs desde el inicio",
        st_logged = "Registrado",
        st_dropped = "⛔ Llamadas bloqueadas",
        st_ignored = "🔇 Ignorado",
        no_args = "(sin argumentos)",
        n_refire_only_out = "Solo se pueden reenviar llamadas salientes",
        n_refired = "%s reenviado",
        n_refire_fail = "Error al reenviar: %s",
        n_log_resumed = "Registro reanudado para %s",
        n_ignored = "%s ignorado — sin más registros",
        n_cant_block_in = "Los eventos entrantes no se pueden bloquear desde el cliente",
        n_allowed = "Llamadas a %s permitidas de nuevo",
        n_blocked = "Llamadas a %s ahora BLOQUEADAS",
        n_copied = "%s copiado al portapapeles",
        n_no_clip = "Portapapeles no disponible en este executor",
        n_copy_fail = "Error al copiar: %s",
        n_action_fail = "Acción fallida: %s",
        c_code = "Código",
        c_path = "Ruta",
        c_args = "Argumentos",
        c_r2s = "Código R2S",
        c_logs = "Registros",
        c_source = "Fuente",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Generado: %s",
        code_incoming = "-- RobloxSpy — Evento entrante (servidor → cliente)",
        code_replay = "-- Reprodúcelo localmente con firesignal (si tu executor lo tiene):",
        log_export_title = "RobloxSpy — Exportación de registros",
        net_total = "LLAMADAS TOTALES",
        net_cps = "LLAMADAS/SEG",
        net_unique = "ÚNICOS",
        net_blocked = "BLOQUEADOS",
        net_traffic = "Tráfico (llamadas/seg, últimos 60 s)",
        net_top = "🏆 Top remotes (por llamadas)",
        ex_search = "🔍 Buscar en todo el juego...",
        ex_props = "Propiedades",
        ex_results = "%d resultados",
        ex_nil = "Instancias nil",
        ex_select = "Selecciona una instancia en el árbol",
        ex_copy_path = "📋 Copiar ruta",
        ex_copy_code = "🧾 Copiar como código",
        ex_tp = "🚀 Teletransportar",
        ex_view_src = "📜 Ver código",
        ex_destroy = "🗑 Destruir",
        ex_clone = "📑 Clonar",
        ex_attrs = "🏷  ATRIBUTOS",
        ex_tags = "🔖  ETIQUETAS",
        ex_children = "Hijos",
        ex_desc = "Descendientes",
        ex_too_many = "Mostrando las primeras %d filas — usa la búsqueda",
        n_tp_ok = "Teletransportado a %s",
        n_tp_fail = "No se puede teletransportar a esta instancia",
        n_destroyed = "%s destruido (lado cliente)",
        n_cloned = "%s clonado",
        n_prop_set = "%s = %s",
        n_prop_fail = "No se puede cambiar %s: %s",
        sc_scan = "🔍 Escanear scripts",
        sc_search = "🔎 Filtrar scripts...",
        sc_found = "%d scripts encontrados",
        sc_scanning = "Escaneando... %d",
        sc_select = "Selecciona un script para ver",
        sc_copy = "📋 Copiar",
        sc_save = "💾 Guardar",
        sc_none = "-- Ningún script seleccionado\n-- Pulsa 'Escanear scripts' y elige uno",
        sc_fail = "-- No se pudo descompilar este script\n-- Tu executor quizá no soporta la descompilación\n-- Ruta: %s",
        sc_decompiling = "-- Descompilando...",
        sc_all = "Todos",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Activos",
        sc_lines = "%d líneas",
        n_saved = "Guardado → %s",
        n_save_fail = "Error al guardar: %s",
        n_no_write = "%s no soporta writefile — usa Copiar",
        n_nothing = "Aún no hay nada que guardar",
        n_folder_fail = "No se puede crear la carpeta '%s' en este executor",
        hi_title = "🕘 Historial de sesiones",
        hi_refresh = "🔄 Actualizar",
        hi_current = "🔴 EN VIVO",
        hi_none = "No hay sesiones guardadas.",
        hi_nolist = "Tu executor no puede listar/leer archivos — solo se muestra la sesión actual.",
        hi_calls = "%d llamadas",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Buscar en todas las sesiones...",
        hi_results = "%d coincidencias en %d sesiones",
        hi_export = "💾 Exportar .txt",
        hi_deleted = "Sesión eliminada",
        hi_showing = "Mostrando %d de %d entradas",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Este juego",
        se_lang = "🌐 Idioma",
        se_save = "💾 Guardar registros",
        se_where = "Los archivos se guardan en la carpeta workspace de tu executor (PC: <Executor>/workspace — iPhone/Android: carpeta del executor en la app Archivos).",
        se_nowrite = "⛔ Tu executor no puede escribir archivos (falta writefile). Usa \"Copiar registros\".",
        se_folder = "📂 Carpeta",
        se_last = "Último guardado: %s",
        se_txt = "📝 Guardar registros (.txt — legible + código R2S)",
        se_json = "🧩 Guardar sesión (.json)",
        se_csv = "📊 Guardar sesión (.csv — Excel)",
        se_copy = "📋 Copiar registros (funciona en todos)",
        se_autosave = "🔁 Guardado automático en la carpeta",
        se_interval = "⏱ Intervalo de guardado automático",
        se_options = "🛠 Opciones",
        se_incoming = "📥 Registrar eventos entrantes (servidor → cliente)",
        se_autoscroll = "⬇ Desplazamiento automático",
        se_pausecap = "⏸ Pausar captura",
        se_size = "📐 Tamaño de ventana",
        sz_small = "Pequeña",
        sz_medium = "Mediana",
        sz_large = "Grande",
        se_info = "ℹ️ Info del executor",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Entrantes",
        i_files = "Archivos",
        i_clip = "Portapapeles",
        i_platform = "Plataforma",
        v_avail = "✅ Disponible",
        v_unavail = "❌ No disponible",
        v_safe = "✅ Seguro (getconnections)",
        v_delayed = "⚠ Con retraso (10 s)",
        v_mobile = "📱 Móvil",
        v_pc = "💻 PC",
        n_inc_on = "Eventos entrantes registrados",
        n_inc_off = "Eventos entrantes ignorados",
        n_paused = "Captura en pausa",
        n_resumed = "Captura reanudada",
        n_autosave_on = "Guardado automático cada %ds → %s",
        n_autosave_off = "Guardado automático desactivado",
        n_lang = "Idioma: %s",
        credits = "por Rival960 — Hecho con la ayuda de Claude",
        tab_errors = "Errores",
        ok = "OK",
        cancel = "Cancelar",
        off = "No",
        status_events = "%d eventos",
        status_flood = "%d omitidos (flood)",
        status_errors = "%d errores",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Vigilados",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Vigilar",
        unwatch = "☆ Dejar de vigilar",
        st_watched = "⭐ Vigilado",
        dir_local = "🔁 Cliente ↔ Cliente (local)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (el servidor pregunta al cliente)",
        code_clientinvoke_note = "-- El servidor llamó al OnClientInvoke de este RemoteFunction con:",
        k_grouped = "Agrupado",
        grouped_fmt = "%d llamadas idénticas seguidas",
        k_flood = "Flood",
        flood_fmt = "%d llamadas omitidas justo antes (anti-flood)",
        skipped_prefix = "(+%d omitidas)",
        sec_stats = "📈  ESTADÍSTICAS DE ESTE REMOTE",
        k_total = "Llamadas totales",
        k_rate = "Frecuencia",
        rate_fmt = "%.1f llamadas / min",
        k_first_last = "Primera → última",
        k_callers = "Llamadores",
        diff_hint = "cambios respecto a la llamada anterior en amarillo",
        diff_was = "antes: %s",
        sec_return = "↩  DEVUELTO POR EL SERVIDOR",
        ret_nothing = "(no devolvió nada)",
        ret_waiting = "Esperando la respuesta del servidor…",
        ret_disabled = "Activa «Capturar los retornos de InvokeServer» en Ajustes",
        n_alert = "🔔 Alerta: %s (palabra clave «%s»)",
        n_saved_game = "guardado para este juego",
        n_watch_on = "⭐ %s añadido a la lista de vigilancia",
        n_watch_off = "%s quitado de la lista de vigilancia",
        empty_feed = "Aún no hay eventos — juega un poco, cada llamada a un remote aparecerá aquí.",
        empty_filter = "Nada coincide con este filtro.",
        empty_network = "Todavía no hay tráfico registrado.",
        empty_scripts = "Pulsa «Escanear scripts» para listar los scripts de cliente del juego.",
        empty_errors = "Sin errores — todo funciona.",
        net_click_hint = "pulsa una fila para filtrar el spy",
        err_copy = "📋 Copiar todo",
        err_clear = "🧹 Limpiar",
        err_count = "%d error(es)",
        c_errors = "Errores",
        hi_export_script = "🧾 Exportar como script",
        se_capture = "📡 Captura",
        se_returns = "↩ Capturar los retornos de InvokeServer",
        se_returns_note = "Muestra lo que responde el servidor. Desactívalo si un juego se comporta raro.",
        se_clientinvoke = "📨 Capturar OnClientInvoke (requiere getcallbackvalue)",
        se_bindables = "🔗 Espiar BindableEvent / BindableFunction",
        se_group = "🧮 Agrupar llamadas idénticas (×N)",
        se_flood = "🌊 Anti-flood (máx. llamadas registradas por remote y segundo)",
        se_alerts = "🔔 Alertas",
        se_alerts_on = "🔔 Avisar cuando el nombre de un remote contiene una palabra clave",
        se_keywords = "Palabras clave (separadas por comas)",
        n_keywords_saved = "Palabras clave guardadas",
        se_appearance = "🎨 Apariencia",
        se_accent = "Color de acento",
        c_blue = "Azul",
        c_purple = "Morado",
        c_green = "Verde",
        c_red = "Rojo",
        c_orange = "Naranja",
        se_transparency = "Transparencia de la ventana",
        se_textsize = "Tamaño del texto",
        se_bottomtabs = "📱 Barra de pestañas abajo",
        se_keybind = "⌨ Tecla mostrar / ocultar: %s (pulsa para cambiar)",
        se_keybind_wait = "Pulsa una tecla… (Esc = cancelar)",
        n_keybind = "Tecla definida: %s",
        se_tools = "🧰 Herramientas",
        se_export_script = "🧾 Exportar esta sesión como script de repetición",
        se_whatsnew = "🎉 Novedades",
        se_unload = "⏏ Descargar RobloxSpy",
        unload_title = "¿Descargar RobloxSpy?",
        unload_body = "Se quitan los hooks, se guarda la sesión y se cierra la interfaz. Vuelve a ejecutar el script para reiniciarlo.",
        n_returns_on = "Se capturan los retornos de los nuevos InvokeServer",
        n_option_off = "Opción desactivada",
        n_need_fn = "%s no es compatible con %s",
        tip_maximize = "Maximizar / restaurar",
        tip_minimize = "Minimizar",
        tip_close = "Ocultar (el botón redondo la trae de vuelta)",
        tip_reopen = "Abrir RobloxSpy (arrastra para mover)",
        tip_copy_r2s = "Copiar el código R2S",
        tip_ignore = "Ignorar este remote (se envía, no se registra)",
        tip_delete = "Eliminar esta fila",
        tip_pause = "Pausar / reanudar la captura",
        tip_clear = "Limpiar el registro",
        tip_expand = "Agrandar la ventana",
        tip_refire = "Enviar esta llamada otra vez",
        tip_watch = "Añadir a la lista de vigilancia (guardado para este juego)",
        tip_drop = "Bloquear: la llamada nunca llega al servidor",
        rn_title = "🎉 Novedades de la v%s",
        rn_1 = "Ejecutar el script dos veces reemplaza la instancia anterior, y el nuevo botón «Descargar» lo quita todo limpiamente.",
        rn_2 = "Anti-flood y agrupación: las llamadas idénticas se unen en una fila «×N».",
        rn_3 = "Se pueden capturar los retornos de InvokeServer, OnClientInvoke y Bindables (Ajustes → Captura).",
        rn_4 = "Estadísticas por remote, diferencias resaltadas con la llamada anterior, alertas por palabra clave.",
        rn_5 = "La lista de vigilancia y las listas de ignorados / bloqueados se guardan por juego.",
        rn_6 = "Exporta una sesión entera como script reproducible (Ajustes → Herramientas, o Historial).",
        rn_7 = "Nuevos iconos dibujados, botón de reapertura con contador, tecla en PC (RightShift).",
        rn_8 = "Móvil: pestañas abajo, filas y botones más grandes. Ayudas en todas partes (pulsación larga en móvil).",
        rn_9 = "Colores de acento, transparencia y tamaño del texto en Ajustes → Apariencia.",
        rn_10 = "Nueva pestaña Errores, Explorador más rápido, guardado automático más ligero — y varios errores corregidos.",
        as_live = "En vivo (cada 2 s)",
    }

    LANG.PT = {
        lang_name = "Português",
        lang_flag = "🇵🇹",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorador",
        tab_network = "Rede",
        tab_scripts = "Scripts",
        tab_history = "Histórico",
        tab_settings = "Configurações",
        status_ready = "Pronto",
        status_recording = "● Gravando — %s · hook: %s",
        pause = "⏸ Pausar",
        resume = "▶ Retomar",
        clear = "🧹 Limpar",
        f_all = "◉ Tudo",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Recebidos",
        f_blocked = "⛔ Bloqueados",
        search_spy = "🔎 Filtrar remotes, args, caminhos...",
        feed_cleared = "Feed limpo",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "RECEBIDO",
        lbl_blocked = "BLOQUEADO",
        lbl_return = "RETORNO",
        back = "← Voltar",
        copy_code = "📋 Copiar código",
        copy_path = "🧭 Copiar caminho",
        copy_args = "📦 Copiar args",
        refire = "🔁 Reenviar",
        ignore = "🔇 Ignorar",
        unignore = "🔊 Parar de ignorar",
        drop = "⛔ Bloquear chamadas",
        undrop = "✅ Permitir chamadas",
        delete = "🗑 Excluir",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTOS (%d)",
        sec_r2s = "🧾  CÓDIGO R2S (Remote → Script)",
        sec_replay = "🧪  CÓDIGO DE REPETIÇÃO",
        k_remote = "Remote",
        k_class = "Classe",
        k_method = "Método",
        k_direction = "Direção",
        k_path = "Caminho",
        k_caller = "Chamador",
        k_call = "Chamada nº",
        k_time = "Tempo",
        k_status = "Estado",
        dir_out = "📤 Cliente → Servidor",
        dir_in = "📥 Servidor → Cliente",
        caller_unknown = "(desconhecido / executor)",
        time_fmt = "+%.3fs após o início",
        st_logged = "Registrado",
        st_dropped = "⛔ Chamadas bloqueadas",
        st_ignored = "🔇 Ignorado",
        no_args = "(sem argumentos)",
        n_refire_only_out = "Só chamadas de saída podem ser reenviadas",
        n_refired = "%s reenviado",
        n_refire_fail = "Falha ao reenviar: %s",
        n_log_resumed = "Registro retomado para %s",
        n_ignored = "%s ignorado — sem mais registros",
        n_cant_block_in = "Eventos recebidos não podem ser bloqueados pelo cliente",
        n_allowed = "Chamadas para %s permitidas de novo",
        n_blocked = "Chamadas para %s agora BLOQUEADAS",
        n_copied = "%s copiado para a área de transferência",
        n_no_clip = "Área de transferência indisponível neste executor",
        n_copy_fail = "Falha ao copiar: %s",
        n_action_fail = "Ação falhou: %s",
        c_code = "Código",
        c_path = "Caminho",
        c_args = "Argumentos",
        c_r2s = "Código R2S",
        c_logs = "Registros",
        c_source = "Fonte",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Gerado: %s",
        code_incoming = "-- RobloxSpy — Evento recebido (servidor → cliente)",
        code_replay = "-- Reproduza localmente com firesignal (se o seu executor tiver):",
        log_export_title = "RobloxSpy — Exportação de registros",
        net_total = "CHAMADAS TOTAIS",
        net_cps = "CHAMADAS/S",
        net_unique = "ÚNICOS",
        net_blocked = "BLOQUEADOS",
        net_traffic = "Tráfego (chamadas/s, últimos 60 s)",
        net_top = "🏆 Top remotes (por chamadas)",
        ex_search = "🔍 Pesquisar no jogo inteiro...",
        ex_props = "Propriedades",
        ex_results = "%d resultados",
        ex_nil = "Instâncias nil",
        ex_select = "Selecione uma instância na árvore",
        ex_copy_path = "📋 Copiar caminho",
        ex_copy_code = "🧾 Copiar como código",
        ex_tp = "🚀 Teleportar",
        ex_view_src = "📜 Ver código",
        ex_destroy = "🗑 Destruir",
        ex_clone = "📑 Clonar",
        ex_attrs = "🏷  ATRIBUTOS",
        ex_tags = "🔖  TAGS",
        ex_children = "Filhos",
        ex_desc = "Descendentes",
        ex_too_many = "Mostrando as primeiras %d linhas — use a pesquisa",
        n_tp_ok = "Teleportado para %s",
        n_tp_fail = "Não é possível teleportar para esta instância",
        n_destroyed = "%s destruído (lado do cliente)",
        n_cloned = "%s clonado",
        n_prop_set = "%s = %s",
        n_prop_fail = "Não é possível alterar %s: %s",
        sc_scan = "🔍 Escanear scripts",
        sc_search = "🔎 Filtrar scripts...",
        sc_found = "%d scripts encontrados",
        sc_scanning = "Escaneando... %d",
        sc_select = "Selecione um script para ver",
        sc_copy = "📋 Copiar",
        sc_save = "💾 Salvar",
        sc_none = "-- Nenhum script selecionado\n-- Clique em 'Escanear scripts' e escolha um",
        sc_fail = "-- Não foi possível descompilar este script\n-- Seu executor talvez não suporte descompilação\n-- Caminho: %s",
        sc_decompiling = "-- Descompilando...",
        sc_all = "Todos",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Ativos",
        sc_lines = "%d linhas",
        n_saved = "Salvo → %s",
        n_save_fail = "Falha ao salvar: %s",
        n_no_write = "%s não suporta writefile — use Copiar",
        n_nothing = "Nada para salvar ainda",
        n_folder_fail = "Não é possível criar a pasta '%s' neste executor",
        hi_title = "🕘 Histórico de sessões",
        hi_refresh = "🔄 Atualizar",
        hi_current = "🔴 AO VIVO",
        hi_none = "Nenhuma sessão salva.",
        hi_nolist = "Seu executor não lista/lê arquivos — só a sessão atual é mostrada.",
        hi_calls = "%d chamadas",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Pesquisar em todas as sessões...",
        hi_results = "%d resultados em %d sessões",
        hi_export = "💾 Exportar .txt",
        hi_deleted = "Sessão excluída",
        hi_showing = "Mostrando %d de %d entradas",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Este jogo",
        se_lang = "🌐 Idioma",
        se_save = "💾 Salvar registros",
        se_where = "Os arquivos ficam na pasta workspace do seu executor (PC: <Executor>/workspace — iPhone/Android: pasta do executor no app Arquivos).",
        se_nowrite = "⛔ Seu executor não grava arquivos (writefile ausente). Use \"Copiar registros\".",
        se_folder = "📂 Pasta",
        se_last = "Último salvamento: %s",
        se_txt = "📝 Salvar registros (.txt — legível + código R2S)",
        se_json = "🧩 Salvar sessão (.json)",
        se_csv = "📊 Salvar sessão (.csv — Excel)",
        se_copy = "📋 Copiar registros (funciona em todos)",
        se_autosave = "🔁 Salvamento automático na pasta",
        se_interval = "⏱ Intervalo do salvamento automático",
        se_options = "🛠 Opções",
        se_incoming = "📥 Registrar eventos recebidos (servidor → cliente)",
        se_autoscroll = "⬇ Rolagem automática",
        se_pausecap = "⏸ Pausar captura",
        se_size = "📐 Tamanho da janela",
        sz_small = "Pequena",
        sz_medium = "Média",
        sz_large = "Grande",
        se_info = "ℹ️ Info do executor",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Recebidos",
        i_files = "Arquivos",
        i_clip = "Área de transferência",
        i_platform = "Plataforma",
        v_avail = "✅ Disponível",
        v_unavail = "❌ Indisponível",
        v_safe = "✅ Seguro (getconnections)",
        v_delayed = "⚠ Atrasado (10 s)",
        v_mobile = "📱 Celular",
        v_pc = "💻 PC",
        n_inc_on = "Eventos recebidos registrados",
        n_inc_off = "Eventos recebidos ignorados",
        n_paused = "Captura pausada",
        n_resumed = "Captura retomada",
        n_autosave_on = "Salvamento automático a cada %ds → %s",
        n_autosave_off = "Salvamento automático desligado",
        n_lang = "Idioma: %s",
        credits = "por Rival960 — Feito com a ajuda do Claude",
        tab_errors = "Erros",
        ok = "OK",
        cancel = "Cancelar",
        off = "Desl.",
        status_events = "%d eventos",
        status_flood = "%d ignorados (flood)",
        status_errors = "%d erros",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Observados",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Observar",
        unwatch = "☆ Parar de observar",
        st_watched = "⭐ Observado",
        dir_local = "🔁 Cliente ↔ Cliente (local)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (o servidor pergunta ao cliente)",
        code_clientinvoke_note = "-- O servidor chamou o OnClientInvoke deste RemoteFunction com:",
        k_grouped = "Agrupado",
        grouped_fmt = "%d chamadas idênticas seguidas",
        k_flood = "Flood",
        flood_fmt = "%d chamadas ignoradas logo antes (anti-flood)",
        skipped_prefix = "(+%d ignoradas)",
        sec_stats = "📈  ESTATÍSTICAS DESTE REMOTE",
        k_total = "Chamadas totais",
        k_rate = "Frequência",
        rate_fmt = "%.1f chamadas / min",
        k_first_last = "Primeira → última",
        k_callers = "Chamadores",
        diff_hint = "mudanças em relação à chamada anterior em amarelo",
        diff_was = "antes: %s",
        sec_return = "↩  RETORNADO PELO SERVIDOR",
        ret_nothing = "(nada retornado)",
        ret_waiting = "Aguardando a resposta do servidor…",
        ret_disabled = "Ative \"Capturar retornos do InvokeServer\" nas Configurações",
        n_alert = "🔔 Alerta: %s (palavra-chave \"%s\")",
        n_saved_game = "salvo para este jogo",
        n_watch_on = "⭐ %s adicionado à lista de observação",
        n_watch_off = "%s removido da lista de observação",
        empty_feed = "Nenhum evento ainda — jogue um pouco, cada chamada de remote aparecerá aqui.",
        empty_filter = "Nada corresponde a este filtro.",
        empty_network = "Nenhum tráfego registrado ainda.",
        empty_scripts = "Clique em \"Escanear scripts\" para listar os scripts de cliente do jogo.",
        empty_errors = "Nenhum erro — tudo funcionando.",
        net_click_hint = "clique numa linha para filtrar o spy",
        err_copy = "📋 Copiar tudo",
        err_clear = "🧹 Limpar",
        err_count = "%d erro(s)",
        c_errors = "Erros",
        hi_export_script = "🧾 Exportar como script",
        se_capture = "📡 Captura",
        se_returns = "↩ Capturar retornos do InvokeServer",
        se_returns_note = "Mostra o que o servidor responde. Desative se um jogo se comportar de forma estranha.",
        se_clientinvoke = "📨 Capturar OnClientInvoke (requer getcallbackvalue)",
        se_bindables = "🔗 Espionar BindableEvent / BindableFunction",
        se_group = "🧮 Agrupar chamadas idênticas (×N)",
        se_flood = "🌊 Anti-flood (máx. de chamadas registradas por remote por segundo)",
        se_alerts = "🔔 Alertas",
        se_alerts_on = "🔔 Avisar quando o nome de um remote contém uma palavra-chave",
        se_keywords = "Palavras-chave (separadas por vírgula)",
        n_keywords_saved = "Palavras-chave salvas",
        se_appearance = "🎨 Aparência",
        se_accent = "Cor de destaque",
        c_blue = "Azul",
        c_purple = "Roxo",
        c_green = "Verde",
        c_red = "Vermelho",
        c_orange = "Laranja",
        se_transparency = "Transparência da janela",
        se_textsize = "Tamanho do texto",
        se_bottomtabs = "📱 Barra de abas embaixo",
        se_keybind = "⌨ Tecla mostrar / esconder: %s (clique para mudar)",
        se_keybind_wait = "Pressione uma tecla… (Esc = cancelar)",
        n_keybind = "Tecla definida: %s",
        se_tools = "🧰 Ferramentas",
        se_export_script = "🧾 Exportar esta sessão como script de replay",
        se_whatsnew = "🎉 Novidades",
        se_unload = "⏏ Descarregar RobloxSpy",
        unload_title = "Descarregar RobloxSpy?",
        unload_body = "Os hooks são removidos, a sessão é salva e a interface fecha. Execute o script de novo para reiniciá-lo.",
        n_returns_on = "Retornos capturados para novos InvokeServer",
        n_option_off = "Opção desativada",
        n_need_fn = "%s não é suportado por %s",
        tip_maximize = "Maximizar / restaurar",
        tip_minimize = "Minimizar",
        tip_close = "Esconder (o botão redondo traz de volta)",
        tip_reopen = "Abrir RobloxSpy (arraste para mover)",
        tip_copy_r2s = "Copiar o código R2S",
        tip_ignore = "Ignorar este remote (ainda enviado, não registrado)",
        tip_delete = "Excluir esta linha",
        tip_pause = "Pausar / retomar a captura",
        tip_clear = "Limpar o feed",
        tip_expand = "Aumentar a janela",
        tip_refire = "Enviar esta chamada de novo",
        tip_watch = "Adicionar à lista de observação (salvo para este jogo)",
        tip_drop = "Bloquear: a chamada nunca chega ao servidor",
        rn_title = "🎉 Novidades da v%s",
        rn_1 = "Executar o script duas vezes substitui a instância antiga, e o novo botão \"Descarregar\" remove tudo de forma limpa.",
        rn_2 = "Anti-flood e agrupamento: chamadas idênticas viram uma linha \"×N\".",
        rn_3 = "Retornos do InvokeServer, OnClientInvoke e Bindables podem ser capturados (Configurações → Captura).",
        rn_4 = "Estatísticas por remote, diferenças destacadas com a chamada anterior, alertas por palavra-chave.",
        rn_5 = "A lista de observação e as listas de ignorados / bloqueados são salvas por jogo.",
        rn_6 = "Exporte uma sessão inteira como script reproduzível (Configurações → Ferramentas, ou Histórico).",
        rn_7 = "Novos ícones desenhados, botão de reabrir com contador, tecla no PC (RightShift).",
        rn_8 = "Celular: abas embaixo, linhas e botões maiores. Dicas em todo lugar (toque longo no celular).",
        rn_9 = "Cores de destaque, transparência e tamanho do texto em Configurações → Aparência.",
        rn_10 = "Nova aba Erros, Explorador mais rápido, salvamento automático mais leve — e vários bugs corrigidos.",
        as_live = "Ao vivo (a cada 2 s)",
    }

    LANG.RU = {
        lang_name = "Русский",
        lang_flag = "🇷🇺",
        tab_spy = "Remote Spy",
        tab_explorer = "Проводник",
        tab_network = "Сеть",
        tab_scripts = "Скрипты",
        tab_history = "История",
        tab_settings = "Настройки",
        status_ready = "Готово",
        status_recording = "● Запись — %s · хук: %s",
        pause = "⏸ Пауза",
        resume = "▶ Продолжить",
        clear = "🧹 Очистить",
        f_all = "◉ Все",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Входящие",
        f_blocked = "⛔ Заблок.",
        search_spy = "🔎 Фильтр: ремоуты, аргументы, пути...",
        feed_cleared = "Лента очищена",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "ВХОДЯЩИЙ",
        lbl_blocked = "БЛОК",
        lbl_return = "ВОЗВРАТ",
        back = "← Назад",
        copy_code = "📋 Копировать код",
        copy_path = "🧭 Копировать путь",
        copy_args = "📦 Копировать аргументы",
        refire = "🔁 Повторить",
        ignore = "🔇 Игнорировать",
        unignore = "🔊 Не игнорировать",
        drop = "⛔ Блокировать вызовы",
        undrop = "✅ Разрешить вызовы",
        delete = "🗑 Удалить",
        sec_info = "ℹ️  ИНФО",
        sec_args = "📦  АРГУМЕНТЫ (%d)",
        sec_r2s = "🧾  КОД R2S (Remote → Script)",
        sec_replay = "🧪  КОД ПОВТОРА",
        k_remote = "Ремоут",
        k_class = "Класс",
        k_method = "Метод",
        k_direction = "Направление",
        k_path = "Путь",
        k_caller = "Вызвал",
        k_call = "Вызов №",
        k_time = "Время",
        k_status = "Статус",
        dir_out = "📤 Клиент → Сервер",
        dir_in = "📥 Сервер → Клиент",
        caller_unknown = "(неизвестно / экзекутор)",
        time_fmt = "+%.3fs после запуска",
        st_logged = "Записано",
        st_dropped = "⛔ Вызовы заблокированы",
        st_ignored = "🔇 Игнорируется",
        no_args = "(нет аргументов)",
        n_refire_only_out = "Повторить можно только исходящие вызовы",
        n_refired = "%s отправлен повторно",
        n_refire_fail = "Ошибка повтора: %s",
        n_log_resumed = "Запись возобновлена для %s",
        n_ignored = "%s игнорируется — логов больше нет",
        n_cant_block_in = "Входящие события нельзя заблокировать на клиенте",
        n_allowed = "Вызовы %s снова разрешены",
        n_blocked = "Вызовы %s теперь ЗАБЛОКИРОВАНЫ",
        n_copied = "%s скопировано в буфер обмена",
        n_no_clip = "Буфер обмена недоступен в этом экзекуторе",
        n_copy_fail = "Ошибка копирования: %s",
        n_action_fail = "Ошибка действия: %s",
        c_code = "Код",
        c_path = "Путь",
        c_args = "Аргументы",
        c_r2s = "Код R2S",
        c_logs = "Логи",
        c_source = "Исходник",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Создано: %s",
        code_incoming = "-- RobloxSpy — Входящее событие (сервер → клиент)",
        code_replay = "-- Повтори локально через firesignal (если он есть в экзекуторе):",
        log_export_title = "RobloxSpy — Экспорт логов",
        net_total = "ВСЕГО ВЫЗОВОВ",
        net_cps = "ВЫЗОВОВ/С",
        net_unique = "УНИКАЛЬНЫХ",
        net_blocked = "ЗАБЛОК.",
        net_traffic = "Трафик (вызовов/с, последние 60 с)",
        net_top = "🏆 Топ ремоутов (по вызовам)",
        ex_search = "🔍 Поиск по всей игре...",
        ex_props = "Свойства",
        ex_results = "Найдено: %d",
        ex_nil = "Nil-объекты",
        ex_select = "Выбери объект в дереве",
        ex_copy_path = "📋 Копировать путь",
        ex_copy_code = "🧾 Копировать как код",
        ex_tp = "🚀 Телепорт",
        ex_view_src = "📜 Исходный код",
        ex_destroy = "🗑 Уничтожить",
        ex_clone = "📑 Клонировать",
        ex_attrs = "🏷  АТРИБУТЫ",
        ex_tags = "🔖  ТЕГИ",
        ex_children = "Дочерние",
        ex_desc = "Потомки",
        ex_too_many = "Показаны первые %d строк — используй поиск",
        n_tp_ok = "Телепорт к %s",
        n_tp_fail = "Нельзя телепортироваться к этому объекту",
        n_destroyed = "%s уничтожен (на клиенте)",
        n_cloned = "%s клонирован",
        n_prop_set = "%s = %s",
        n_prop_fail = "Нельзя изменить %s: %s",
        sc_scan = "🔍 Сканировать скрипты",
        sc_search = "🔎 Фильтр скриптов...",
        sc_found = "Найдено скриптов: %d",
        sc_scanning = "Сканирование... %d",
        sc_select = "Выбери скрипт для просмотра",
        sc_copy = "📋 Копировать",
        sc_save = "💾 Сохранить",
        sc_none = "-- Скрипт не выбран\n-- Нажми 'Сканировать скрипты' и выбери один",
        sc_fail = "-- Не удалось декомпилировать скрипт\n-- Возможно, экзекутор не поддерживает декомпиляцию\n-- Путь: %s",
        sc_decompiling = "-- Декомпиляция...",
        sc_all = "Все",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Активные",
        sc_lines = "Строк: %d",
        n_saved = "Сохранено → %s",
        n_save_fail = "Ошибка сохранения: %s",
        n_no_write = "%s не поддерживает writefile — используй копирование",
        n_nothing = "Пока нечего сохранять",
        n_folder_fail = "Нельзя создать папку '%s' в этом экзекуторе",
        hi_title = "🕘 История сессий",
        hi_refresh = "🔄 Обновить",
        hi_current = "🔴 СЕЙЧАС",
        hi_none = "Сохранённых сессий нет.",
        hi_nolist = "Экзекутор не умеет читать файлы — показана только текущая сессия.",
        hi_calls = "вызовов: %d",
        hi_unique = "ремоутов: %d",
        hi_search_all = "🔎 Поиск по всем сессиям...",
        hi_results = "%d совпадений в %d сессиях",
        hi_export = "💾 Экспорт .txt",
        hi_deleted = "Сессия удалена",
        hi_showing = "Показано %d из %d записей",
        hi_duration = "%dм %dс",
        hi_same_game = "📍 Эта игра",
        se_lang = "🌐 Язык",
        se_save = "💾 Сохранение логов",
        se_where = "Файлы сохраняются в папку workspace экзекутора (ПК: <Executor>/workspace — iPhone/Android: папка экзекутора в приложении «Файлы»).",
        se_nowrite = "⛔ Экзекутор не умеет писать файлы (нет writefile). Используй «Копировать логи».",
        se_folder = "📂 Папка",
        se_last = "Последнее сохранение: %s",
        se_txt = "📝 Сохранить логи (.txt — читаемо + код R2S)",
        se_json = "🧩 Сохранить сессию (.json)",
        se_csv = "📊 Сохранить сессию (.csv — Excel)",
        se_copy = "📋 Копировать логи (работает везде)",
        se_autosave = "🔁 Автосохранение логов в папку",
        se_interval = "⏱ Интервал автосохранения",
        se_options = "🛠 Параметры",
        se_incoming = "📥 Записывать входящие события (сервер → клиент)",
        se_autoscroll = "⬇ Автопрокрутка ленты",
        se_pausecap = "⏸ Приостановить запись",
        se_size = "📐 Размер окна",
        sz_small = "Маленькое",
        sz_medium = "Среднее",
        sz_large = "Большое",
        se_info = "ℹ️ Об экзекуторе",
        i_executor = "Экзекутор",
        i_hooking = "Хуки",
        i_incoming = "Входящие",
        i_files = "Файлы",
        i_clip = "Буфер обмена",
        i_platform = "Платформа",
        v_avail = "✅ Доступно",
        v_unavail = "❌ Недоступно",
        v_safe = "✅ Безопасно (getconnections)",
        v_delayed = "⚠ С задержкой (10 с)",
        v_mobile = "📱 Телефон",
        v_pc = "💻 ПК",
        n_inc_on = "Входящие события записываются",
        n_inc_off = "Входящие события игнорируются",
        n_paused = "Запись на паузе",
        n_resumed = "Запись продолжена",
        n_autosave_on = "Автосохранение каждые %ds → %s",
        n_autosave_off = "Автосохранение выключено",
        n_lang = "Язык: %s",
        credits = "от Rival960 — Сделано с помощью Claude",
        tab_errors = "Ошибки",
        ok = "ОК",
        cancel = "Отмена",
        off = "Выкл",
        status_events = "событий: %d",
        status_flood = "пропущено: %d (флуд)",
        status_errors = "ошибок: %d",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Отслеживаемые",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Отслеживать",
        unwatch = "☆ Не отслеживать",
        st_watched = "⭐ Отслеживается",
        dir_local = "🔁 Клиент ↔ Клиент (локально)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (сервер спрашивает клиента)",
        code_clientinvoke_note = "-- Сервер вызвал OnClientInvoke этого RemoteFunction с:",
        k_grouped = "Сгруппировано",
        grouped_fmt = "%d одинаковых вызовов подряд",
        k_flood = "Флуд",
        flood_fmt = "%d вызовов пропущено перед этим (антифлуд)",
        skipped_prefix = "(+%d пропущено)",
        sec_stats = "📈  СТАТИСТИКА ЭТОГО РЕМОУТА",
        k_total = "Всего вызовов",
        k_rate = "Частота",
        rate_fmt = "%.1f вызовов / мин",
        k_first_last = "Первый → последний",
        k_callers = "Вызывающие",
        diff_hint = "изменения относительно прошлого вызова — жёлтым",
        diff_was = "было: %s",
        sec_return = "↩  ВОЗВРАЩЕНО СЕРВЕРОМ",
        ret_nothing = "(ничего не возвращено)",
        ret_waiting = "Ожидание ответа сервера…",
        ret_disabled = "Включи «Захват возвратов InvokeServer» в настройках",
        n_alert = "🔔 Тревога: %s (ключевое слово «%s»)",
        n_saved_game = "сохранено для этой игры",
        n_watch_on = "⭐ %s добавлен в отслеживаемые",
        n_watch_off = "%s убран из отслеживаемых",
        empty_feed = "Событий пока нет — поиграй немного, каждый вызов ремоута появится здесь.",
        empty_filter = "Ничего не подходит под фильтр.",
        empty_network = "Трафик пока не записан.",
        empty_scripts = "Нажми «Сканировать скрипты», чтобы увидеть клиентские скрипты игры.",
        empty_errors = "Ошибок нет — всё работает.",
        net_click_hint = "нажми на строку, чтобы отфильтровать спай",
        err_copy = "📋 Копировать всё",
        err_clear = "🧹 Очистить",
        err_count = "ошибок: %d",
        c_errors = "Ошибки",
        hi_export_script = "🧾 Экспорт как скрипт",
        se_capture = "📡 Захват",
        se_returns = "↩ Захватывать возвраты InvokeServer",
        se_returns_note = "Показывает ответ сервера. Выключи, если игра ведёт себя странно.",
        se_clientinvoke = "📨 Захватывать OnClientInvoke (нужен getcallbackvalue)",
        se_bindables = "🔗 Следить за BindableEvent / BindableFunction",
        se_group = "🧮 Группировать одинаковые вызовы (×N)",
        se_flood = "🌊 Антифлуд (макс. записанных вызовов на ремоут в секунду)",
        se_alerts = "🔔 Оповещения",
        se_alerts_on = "🔔 Уведомлять, если имя ремоута содержит ключевое слово",
        se_keywords = "Ключевые слова (через запятую)",
        n_keywords_saved = "Ключевые слова сохранены",
        se_appearance = "🎨 Внешний вид",
        se_accent = "Цвет акцента",
        c_blue = "Синий",
        c_purple = "Фиолетовый",
        c_green = "Зелёный",
        c_red = "Красный",
        c_orange = "Оранжевый",
        se_transparency = "Прозрачность окна",
        se_textsize = "Размер текста",
        se_bottomtabs = "📱 Вкладки внизу",
        se_keybind = "⌨ Клавиша показать / скрыть: %s (нажми, чтобы сменить)",
        se_keybind_wait = "Нажми клавишу… (Esc = отмена)",
        n_keybind = "Клавиша: %s",
        se_tools = "🧰 Инструменты",
        se_export_script = "🧾 Экспорт сессии как скрипта повтора",
        se_whatsnew = "🎉 Что нового",
        se_unload = "⏏ Выгрузить RobloxSpy",
        unload_title = "Выгрузить RobloxSpy?",
        unload_body = "Хуки снимаются, сессия сохраняется, интерфейс закрывается. Запусти скрипт снова, чтобы перезапустить.",
        n_returns_on = "Возвраты новых InvokeServer захватываются",
        n_option_off = "Опция выключена",
        n_need_fn = "%s не поддерживается в %s",
        tip_maximize = "Развернуть / восстановить",
        tip_minimize = "Свернуть",
        tip_close = "Скрыть (круглая кнопка вернёт окно)",
        tip_reopen = "Открыть RobloxSpy (перетащи, чтобы двигать)",
        tip_copy_r2s = "Копировать код R2S",
        tip_ignore = "Игнорировать ремоут (отправляется, но не пишется)",
        tip_delete = "Удалить строку",
        tip_pause = "Пауза / продолжить захват",
        tip_clear = "Очистить ленту",
        tip_expand = "Увеличить окно",
        tip_refire = "Отправить вызов снова",
        tip_watch = "В отслеживаемые (сохраняется для игры)",
        tip_drop = "Блокировать: вызов не дойдёт до сервера",
        rn_title = "🎉 Что нового в v%s",
        rn_1 = "Повторный запуск заменяет старый экземпляр, а новая кнопка «Выгрузить» чисто всё убирает.",
        rn_2 = "Антифлуд и группировка: одинаковые вызовы объединяются в одну строку «×N».",
        rn_3 = "Можно захватывать возвраты InvokeServer, OnClientInvoke и Bindables (Настройки → Захват).",
        rn_4 = "Статистика по ремоутам, подсветка отличий от прошлого вызова, оповещения по ключевым словам.",
        rn_5 = "Отслеживаемые и списки игнора / блокировки сохраняются для каждой игры.",
        rn_6 = "Экспорт всей сессии как скрипта повтора (Настройки → Инструменты или История).",
        rn_7 = "Новые рисованные иконки, кнопка открытия со счётчиком, клавиша на ПК (RightShift).",
        rn_8 = "Телефон: вкладки внизу, крупные строки и кнопки. Подсказки везде (долгое нажатие на телефоне).",
        rn_9 = "Цвета акцента, прозрачность и размер текста в Настройки → Внешний вид.",
        rn_10 = "Новая вкладка «Ошибки», более быстрый проводник, лёгкое автосохранение — и исправления ошибок.",
        as_live = "Постоянно (каждые 2 с)",
    }

    LANG.IT = {
        lang_name = "Italiano",
        lang_flag = "🇮🇹",
        tab_spy = "Remote Spy",
        tab_explorer = "Esplora",
        tab_network = "Rete",
        tab_scripts = "Script",
        tab_history = "Cronologia",
        tab_settings = "Impostazioni",
        status_ready = "Pronto",
        status_recording = "● Registrazione — %s · hook: %s",
        pause = "⏸ Pausa",
        resume = "▶ Riprendi",
        clear = "🧹 Svuota",
        f_all = "◉ Tutti",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 In arrivo",
        f_blocked = "⛔ Bloccati",
        search_spy = "🔎 Filtra remote, argomenti, percorsi...",
        feed_cleared = "Feed svuotato",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "IN ARRIVO",
        lbl_blocked = "BLOCCATO",
        lbl_return = "RITORNO",
        back = "← Indietro",
        copy_code = "📋 Copia codice",
        copy_path = "🧭 Copia percorso",
        copy_args = "📦 Copia argomenti",
        refire = "🔁 Reinvia",
        ignore = "🔇 Ignora",
        unignore = "🔊 Non ignorare",
        drop = "⛔ Blocca chiamate",
        undrop = "✅ Consenti chiamate",
        delete = "🗑 Elimina",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGOMENTI (%d)",
        sec_r2s = "🧾  CODICE R2S (Remote → Script)",
        sec_replay = "🧪  CODICE DI REPLAY",
        k_remote = "Remote",
        k_class = "Classe",
        k_method = "Metodo",
        k_direction = "Direzione",
        k_path = "Percorso",
        k_caller = "Chiamante",
        k_call = "Chiamata n.",
        k_time = "Tempo",
        k_status = "Stato",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(sconosciuto / executor)",
        time_fmt = "+%.3fs dall'avvio",
        st_logged = "Registrato",
        st_dropped = "⛔ Chiamate bloccate",
        st_ignored = "🔇 Ignorato",
        no_args = "(nessun argomento)",
        n_refire_only_out = "Solo le chiamate in uscita possono essere reinviate",
        n_refired = "%s reinviato",
        n_refire_fail = "Reinvio fallito: %s",
        n_log_resumed = "Registrazione ripresa per %s",
        n_ignored = "%s ignorato — niente più log",
        n_cant_block_in = "Gli eventi in arrivo non si possono bloccare dal client",
        n_allowed = "Chiamate a %s di nuovo consentite",
        n_blocked = "Chiamate a %s ora BLOCCATE",
        n_copied = "%s copiato negli appunti",
        n_no_clip = "Appunti non disponibili su questo executor",
        n_copy_fail = "Copia fallita: %s",
        n_action_fail = "Azione fallita: %s",
        c_code = "Codice",
        c_path = "Percorso",
        c_args = "Argomenti",
        c_r2s = "Codice R2S",
        c_logs = "Log",
        c_source = "Sorgente",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Generato: %s",
        code_incoming = "-- RobloxSpy — Evento in arrivo (server → client)",
        code_replay = "-- Riproducilo in locale con firesignal (se il tuo executor lo ha):",
        log_export_title = "RobloxSpy — Esportazione log",
        net_total = "CHIAMATE TOTALI",
        net_cps = "CHIAMATE/S",
        net_unique = "UNICI",
        net_blocked = "BLOCCATI",
        net_traffic = "Traffico (chiamate/s, ultimi 60 s)",
        net_top = "🏆 Top remote (per chiamate)",
        ex_search = "🔍 Cerca in tutto il gioco...",
        ex_props = "Proprietà",
        ex_results = "%d risultati",
        ex_nil = "Istanze nil",
        ex_select = "Seleziona un'istanza nell'albero",
        ex_copy_path = "📋 Copia percorso",
        ex_copy_code = "🧾 Copia come codice",
        ex_tp = "🚀 Teletrasporto",
        ex_view_src = "📜 Vedi sorgente",
        ex_destroy = "🗑 Distruggi",
        ex_clone = "📑 Clona",
        ex_attrs = "🏷  ATTRIBUTI",
        ex_tags = "🔖  TAG",
        ex_children = "Figli",
        ex_desc = "Discendenti",
        ex_too_many = "Mostrate le prime %d righe — usa la ricerca",
        n_tp_ok = "Teletrasportato a %s",
        n_tp_fail = "Impossibile teletrasportarsi a questa istanza",
        n_destroyed = "%s distrutto (lato client)",
        n_cloned = "%s clonato",
        n_prop_set = "%s = %s",
        n_prop_fail = "Impossibile impostare %s: %s",
        sc_scan = "🔍 Scansiona script",
        sc_search = "🔎 Filtra script...",
        sc_found = "%d script trovati",
        sc_scanning = "Scansione... %d",
        sc_select = "Seleziona uno script da vedere",
        sc_copy = "📋 Copia",
        sc_save = "💾 Salva",
        sc_none = "-- Nessuno script selezionato\n-- Premi 'Scansiona script' e scegline uno",
        sc_fail = "-- Impossibile decompilare questo script\n-- Il tuo executor potrebbe non supportare la decompilazione\n-- Percorso: %s",
        sc_decompiling = "-- Decompilazione...",
        sc_all = "Tutti",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Attivi",
        sc_lines = "%d righe",
        n_saved = "Salvato → %s",
        n_save_fail = "Salvataggio fallito: %s",
        n_no_write = "%s non supporta writefile — usa Copia",
        n_nothing = "Ancora niente da salvare",
        n_folder_fail = "Impossibile creare la cartella '%s' su questo executor",
        hi_title = "🕘 Cronologia sessioni",
        hi_refresh = "🔄 Aggiorna",
        hi_current = "🔴 LIVE",
        hi_none = "Nessuna sessione salvata.",
        hi_nolist = "Il tuo executor non può elencare/leggere file — è mostrata solo la sessione attuale.",
        hi_calls = "%d chiamate",
        hi_unique = "%d remote",
        hi_search_all = "🔎 Cerca in tutte le sessioni...",
        hi_results = "%d risultati in %d sessioni",
        hi_export = "💾 Esporta .txt",
        hi_deleted = "Sessione eliminata",
        hi_showing = "Mostrate %d di %d voci",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Questo gioco",
        se_lang = "🌐 Lingua",
        se_save = "💾 Salva log",
        se_where = "I file vengono salvati nella cartella workspace dell'executor (PC: <Executor>/workspace — iPhone/Android: cartella dell'executor nell'app File).",
        se_nowrite = "⛔ Il tuo executor non può scrivere file (manca writefile). Usa \"Copia log\".",
        se_folder = "📂 Cartella",
        se_last = "Ultimo salvataggio: %s",
        se_txt = "📝 Salva log (.txt — leggibile + codice R2S)",
        se_json = "🧩 Salva sessione (.json)",
        se_csv = "📊 Salva sessione (.csv — Excel)",
        se_copy = "📋 Copia log negli appunti (funziona ovunque)",
        se_autosave = "🔁 Salvataggio automatico nella cartella",
        se_interval = "⏱ Intervallo del salvataggio automatico",
        se_options = "🛠 Opzioni",
        se_incoming = "📥 Registra eventi in arrivo (server → client)",
        se_autoscroll = "⬇ Scorrimento automatico",
        se_pausecap = "⏸ Metti in pausa la cattura",
        se_size = "📐 Dimensione finestra",
        sz_small = "Piccola",
        sz_medium = "Media",
        sz_large = "Grande",
        se_info = "ℹ️ Info executor",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "In arrivo",
        i_files = "File system",
        i_clip = "Appunti",
        i_platform = "Piattaforma",
        v_avail = "✅ Disponibile",
        v_unavail = "❌ Non disponibile",
        v_safe = "✅ Sicuro (getconnections)",
        v_delayed = "⚠ Ritardato (10 s)",
        v_mobile = "📱 Mobile",
        v_pc = "💻 PC",
        n_inc_on = "Eventi in arrivo registrati",
        n_inc_off = "Eventi in arrivo ignorati",
        n_paused = "Cattura in pausa",
        n_resumed = "Cattura ripresa",
        n_autosave_on = "Salvataggio automatico ogni %ds → %s",
        n_autosave_off = "Salvataggio automatico disattivato",
        n_lang = "Lingua: %s",
        credits = "di Rival960 — Realizzato con l'aiuto di Claude",
        tab_errors = "Errori",
        ok = "OK",
        cancel = "Annulla",
        off = "No",
        status_events = "%d eventi",
        status_flood = "%d saltati (flood)",
        status_errors = "%d errori",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Seguiti",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Segui",
        unwatch = "☆ Non seguire",
        st_watched = "⭐ Seguito",
        dir_local = "🔁 Client ↔ Client (locale)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (il server interroga il client)",
        code_clientinvoke_note = "-- Il server ha chiamato l'OnClientInvoke di questa RemoteFunction con:",
        k_grouped = "Raggruppato",
        grouped_fmt = "%d chiamate identiche di fila",
        k_flood = "Flood",
        flood_fmt = "%d chiamate saltate subito prima (anti-flood)",
        skipped_prefix = "(+%d saltate)",
        sec_stats = "📈  STATISTICHE DI QUESTO REMOTE",
        k_total = "Chiamate totali",
        k_rate = "Frequenza",
        rate_fmt = "%.1f chiamate / min",
        k_first_last = "Prima → ultima",
        k_callers = "Chiamanti",
        diff_hint = "differenze rispetto alla chiamata precedente in giallo",
        diff_was = "prima: %s",
        sec_return = "↩  RESTITUITO DAL SERVER",
        ret_nothing = "(nulla restituito)",
        ret_waiting = "In attesa della risposta del server…",
        ret_disabled = "Attiva \"Cattura i ritorni di InvokeServer\" nelle Impostazioni",
        n_alert = "🔔 Avviso: %s (parola chiave \"%s\")",
        n_saved_game = "salvato per questo gioco",
        n_watch_on = "⭐ %s aggiunto ai seguiti",
        n_watch_off = "%s rimosso dai seguiti",
        empty_feed = "Nessun evento per ora — gioca un po', ogni chiamata remote apparirà qui.",
        empty_filter = "Niente corrisponde a questo filtro.",
        empty_network = "Nessun traffico registrato per ora.",
        empty_scripts = "Premi \"Scansiona script\" per elencare gli script client del gioco.",
        empty_errors = "Nessun errore — tutto funziona.",
        net_click_hint = "clicca una riga per filtrare lo spy",
        err_copy = "📋 Copia tutto",
        err_clear = "🧹 Svuota",
        err_count = "%d errore/i",
        c_errors = "Errori",
        hi_export_script = "🧾 Esporta come script",
        se_capture = "📡 Cattura",
        se_returns = "↩ Cattura i ritorni di InvokeServer",
        se_returns_note = "Mostra cosa risponde il server. Disattivalo se un gioco si comporta in modo strano.",
        se_clientinvoke = "📨 Cattura OnClientInvoke (richiede getcallbackvalue)",
        se_bindables = "🔗 Spia BindableEvent / BindableFunction",
        se_group = "🧮 Raggruppa chiamate identiche (×N)",
        se_flood = "🌊 Anti-flood (max chiamate registrate per remote al secondo)",
        se_alerts = "🔔 Avvisi",
        se_alerts_on = "🔔 Avvisa quando il nome di un remote contiene una parola chiave",
        se_keywords = "Parole chiave (separate da virgole)",
        n_keywords_saved = "Parole chiave salvate",
        se_appearance = "🎨 Aspetto",
        se_accent = "Colore d'accento",
        c_blue = "Blu",
        c_purple = "Viola",
        c_green = "Verde",
        c_red = "Rosso",
        c_orange = "Arancione",
        se_transparency = "Trasparenza della finestra",
        se_textsize = "Dimensione del testo",
        se_bottomtabs = "📱 Barra delle schede in basso",
        se_keybind = "⌨ Tasto mostra / nascondi: %s (clicca per cambiare)",
        se_keybind_wait = "Premi un tasto… (Esc = annulla)",
        n_keybind = "Tasto impostato: %s",
        se_tools = "🧰 Strumenti",
        se_export_script = "🧾 Esporta questa sessione come script di replay",
        se_whatsnew = "🎉 Novità",
        se_unload = "⏏ Scarica RobloxSpy",
        unload_title = "Scaricare RobloxSpy?",
        unload_body = "Gli hook vengono rimossi, la sessione salvata e l'interfaccia chiusa. Riesegui lo script per riavviarlo.",
        n_returns_on = "Ritorni catturati per i nuovi InvokeServer",
        n_option_off = "Opzione disattivata",
        n_need_fn = "%s non è supportato da %s",
        tip_maximize = "Ingrandisci / ripristina",
        tip_minimize = "Riduci",
        tip_close = "Nascondi (il pulsante tondo la riporta)",
        tip_reopen = "Apri RobloxSpy (trascina per spostare)",
        tip_copy_r2s = "Copia il codice R2S",
        tip_ignore = "Ignora questo remote (inviato, non registrato)",
        tip_delete = "Elimina questa riga",
        tip_pause = "Pausa / riprendi la cattura",
        tip_clear = "Svuota il feed",
        tip_expand = "Ingrandisci la finestra",
        tip_refire = "Invia di nuovo questa chiamata",
        tip_watch = "Aggiungi ai seguiti (salvato per questo gioco)",
        tip_drop = "Blocca: la chiamata non arriva mai al server",
        rn_title = "🎉 Novità della v%s",
        rn_1 = "Rieseguire lo script sostituisce la vecchia istanza, e il nuovo pulsante \"Scarica\" rimuove tutto in modo pulito.",
        rn_2 = "Anti-flood e raggruppamento: le chiamate identiche diventano una riga \"×N\".",
        rn_3 = "Si possono catturare i ritorni di InvokeServer, OnClientInvoke e Bindables (Impostazioni → Cattura).",
        rn_4 = "Statistiche per remote, differenze evidenziate con la chiamata precedente, avvisi per parola chiave.",
        rn_5 = "I seguiti e le liste ignorati / bloccati vengono salvati per gioco.",
        rn_6 = "Esporta un'intera sessione come script riproducibile (Impostazioni → Strumenti, o Cronologia).",
        rn_7 = "Nuove icone disegnate, pulsante di riapertura con contatore, tasto su PC (RightShift).",
        rn_8 = "Mobile: schede in basso, righe e pulsanti più grandi. Suggerimenti ovunque (pressione lunga su mobile).",
        rn_9 = "Colori d'accento, trasparenza e dimensione del testo in Impostazioni → Aspetto.",
        rn_10 = "Nuova scheda Errori, Esplora più veloce, salvataggio automatico più leggero — e vari bug corretti.",
        as_live = "Continuo (ogni 2 s)",
    }

    LANG.NL = {
        lang_name = "Nederlands",
        lang_flag = "🇳🇱",
        tab_spy = "Remote Spy",
        tab_explorer = "Verkenner",
        tab_network = "Netwerk",
        tab_scripts = "Scripts",
        tab_history = "Geschiedenis",
        tab_settings = "Instellingen",
        status_ready = "Klaar",
        status_recording = "● Opnemen — %s · hook: %s",
        pause = "⏸ Pauze",
        resume = "▶ Hervatten",
        clear = "🧹 Wissen",
        f_all = "◉ Alles",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Inkomend",
        f_blocked = "⛔ Geblokkeerd",
        search_spy = "🔎 Filter remotes, args, paden...",
        feed_cleared = "Feed gewist",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "INKOMEND",
        lbl_blocked = "GEBLOKT",
        lbl_return = "RETOUR",
        back = "← Terug",
        copy_code = "📋 Code kopiëren",
        copy_path = "🧭 Pad kopiëren",
        copy_args = "📦 Args kopiëren",
        refire = "🔁 Opnieuw sturen",
        ignore = "🔇 Negeren",
        unignore = "🔊 Niet meer negeren",
        drop = "⛔ Aanroepen blokkeren",
        undrop = "✅ Aanroepen toestaan",
        delete = "🗑 Verwijderen",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTEN (%d)",
        sec_r2s = "🧾  R2S-CODE (Remote → Script)",
        sec_replay = "🧪  AFSPEELCODE",
        k_remote = "Remote",
        k_class = "Klasse",
        k_method = "Methode",
        k_direction = "Richting",
        k_path = "Pad",
        k_caller = "Aanroeper",
        k_call = "Aanroep nr.",
        k_time = "Tijd",
        k_status = "Status",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(onbekend / executor)",
        time_fmt = "+%.3fs na de start",
        st_logged = "Gelogd",
        st_dropped = "⛔ Aanroepen geblokkeerd",
        st_ignored = "🔇 Genegeerd",
        no_args = "(geen argumenten)",
        n_refire_only_out = "Alleen uitgaande aanroepen kunnen opnieuw worden gestuurd",
        n_refired = "%s opnieuw gestuurd",
        n_refire_fail = "Opnieuw sturen mislukt: %s",
        n_log_resumed = "Loggen hervat voor %s",
        n_ignored = "%s genegeerd — geen logs meer",
        n_cant_block_in = "Inkomende events kunnen niet vanaf de client worden geblokkeerd",
        n_allowed = "Aanroepen naar %s weer toegestaan",
        n_blocked = "Aanroepen naar %s zijn nu GEBLOKKEERD",
        n_copied = "%s gekopieerd naar klembord",
        n_no_clip = "Klembord niet beschikbaar op deze executor",
        n_copy_fail = "Kopiëren mislukt: %s",
        n_action_fail = "Actie mislukt: %s",
        c_code = "Code",
        c_path = "Pad",
        c_args = "Argumenten",
        c_r2s = "R2S-code",
        c_logs = "Logs",
        c_source = "Bron",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Gegenereerd: %s",
        code_incoming = "-- RobloxSpy — Inkomend event (server → client)",
        code_replay = "-- Speel lokaal af met firesignal (als je executor het heeft):",
        log_export_title = "RobloxSpy — Logexport",
        net_total = "TOTAAL AANROEPEN",
        net_cps = "AANROEPEN/S",
        net_unique = "UNIEK",
        net_blocked = "GEBLOKKEERD",
        net_traffic = "Verkeer (aanroepen/s, laatste 60 s)",
        net_top = "🏆 Top-remotes (op aanroepen)",
        ex_search = "🔍 Hele spel doorzoeken...",
        ex_props = "Eigenschappen",
        ex_results = "%d resultaten",
        ex_nil = "Nil-instanties",
        ex_select = "Kies een instantie in de boom",
        ex_copy_path = "📋 Pad kopiëren",
        ex_copy_code = "🧾 Als code kopiëren",
        ex_tp = "🚀 Teleporteren",
        ex_view_src = "📜 Bron bekijken",
        ex_destroy = "🗑 Vernietigen",
        ex_clone = "📑 Klonen",
        ex_attrs = "🏷  ATTRIBUTEN",
        ex_tags = "🔖  TAGS",
        ex_children = "Kinderen",
        ex_desc = "Afstammelingen",
        ex_too_many = "Eerste %d rijen getoond — gebruik zoeken",
        n_tp_ok = "Geteleporteerd naar %s",
        n_tp_fail = "Kan niet naar deze instantie teleporteren",
        n_destroyed = "%s vernietigd (clientzijde)",
        n_cloned = "%s gekloond",
        n_prop_set = "%s = %s",
        n_prop_fail = "Kan %s niet instellen: %s",
        sc_scan = "🔍 Scripts scannen",
        sc_search = "🔎 Scripts filteren...",
        sc_found = "%d scripts gevonden",
        sc_scanning = "Scannen... %d",
        sc_select = "Kies een script om te bekijken",
        sc_copy = "📋 Kopiëren",
        sc_save = "💾 Opslaan",
        sc_none = "-- Geen script gekozen\n-- Klik op 'Scripts scannen' en kies er een",
        sc_fail = "-- Dit script kon niet worden gedecompileerd\n-- Je executor ondersteunt dit misschien niet\n-- Pad: %s",
        sc_decompiling = "-- Decompileren...",
        sc_all = "Alle",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Actief",
        sc_lines = "%d regels",
        n_saved = "Opgeslagen → %s",
        n_save_fail = "Opslaan mislukt: %s",
        n_no_write = "%s ondersteunt geen writefile — gebruik Kopiëren",
        n_nothing = "Nog niets om op te slaan",
        n_folder_fail = "Map '%s' kan niet worden gemaakt op deze executor",
        hi_title = "🕘 Sessiegeschiedenis",
        hi_refresh = "🔄 Vernieuwen",
        hi_current = "🔴 LIVE",
        hi_none = "Geen opgeslagen sessies.",
        hi_nolist = "Je executor kan geen bestanden lezen — alleen de huidige sessie wordt getoond.",
        hi_calls = "%d aanroepen",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Zoeken in alle sessies...",
        hi_results = "%d treffers in %d sessies",
        hi_export = "💾 Exporteren .txt",
        hi_deleted = "Sessie verwijderd",
        hi_showing = "%d van %d items getoond",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Dit spel",
        se_lang = "🌐 Taal",
        se_save = "💾 Logs opslaan",
        se_where = "Bestanden komen in de workspace-map van je executor (pc: <Executor>/workspace — iPhone/Android: map van de executor in de Bestanden-app).",
        se_nowrite = "⛔ Je executor kan geen bestanden schrijven (writefile ontbreekt). Gebruik \"Logs kopiëren\".",
        se_folder = "📂 Map",
        se_last = "Laatst opgeslagen: %s",
        se_txt = "📝 Logs opslaan (.txt — leesbaar + R2S-code)",
        se_json = "🧩 Sessie opslaan (.json)",
        se_csv = "📊 Sessie opslaan (.csv — Excel)",
        se_copy = "📋 Logs kopiëren (werkt overal)",
        se_autosave = "🔁 Logs automatisch opslaan in map",
        se_interval = "⏱ Interval automatisch opslaan",
        se_options = "🛠 Opties",
        se_incoming = "📥 Inkomende events loggen (server → client)",
        se_autoscroll = "⬇ Feed automatisch scrollen",
        se_pausecap = "⏸ Opname pauzeren",
        se_size = "📐 Venstergrootte",
        sz_small = "Klein",
        sz_medium = "Middel",
        sz_large = "Groot",
        se_info = "ℹ️ Executor-info",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Inkomend",
        i_files = "Bestanden",
        i_clip = "Klembord",
        i_platform = "Platform",
        v_avail = "✅ Beschikbaar",
        v_unavail = "❌ Niet beschikbaar",
        v_safe = "✅ Veilig (getconnections)",
        v_delayed = "⚠ Vertraagd (10 s)",
        v_mobile = "📱 Mobiel",
        v_pc = "💻 PC",
        n_inc_on = "Inkomende events worden gelogd",
        n_inc_off = "Inkomende events worden genegeerd",
        n_paused = "Opname gepauzeerd",
        n_resumed = "Opname hervat",
        n_autosave_on = "Automatisch opslaan elke %ds → %s",
        n_autosave_off = "Automatisch opslaan uit",
        n_lang = "Taal: %s",
        credits = "door Rival960 — Gemaakt met hulp van Claude",
        tab_errors = "Fouten",
        ok = "OK",
        cancel = "Annuleren",
        off = "Uit",
        status_events = "%d events",
        status_flood = "%d overgeslagen (flood)",
        status_errors = "%d fouten",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Gevolgd",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Volgen",
        unwatch = "☆ Niet meer volgen",
        st_watched = "⭐ Gevolgd",
        dir_local = "🔁 Client ↔ Client (lokaal)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (server vraagt de client)",
        code_clientinvoke_note = "-- De server riep OnClientInvoke van deze RemoteFunction aan met:",
        k_grouped = "Gegroepeerd",
        grouped_fmt = "%d identieke aanroepen achter elkaar",
        k_flood = "Flood",
        flood_fmt = "%d aanroepen vlak ervoor overgeslagen (anti-flood)",
        skipped_prefix = "(+%d overgeslagen)",
        sec_stats = "📈  STATISTIEKEN VAN DEZE REMOTE",
        k_total = "Totaal aanroepen",
        k_rate = "Frequentie",
        rate_fmt = "%.1f aanroepen / min",
        k_first_last = "Eerste → laatste",
        k_callers = "Aanroepers",
        diff_hint = "wijzigingen t.o.v. vorige aanroep in geel",
        diff_was = "was: %s",
        sec_return = "↩  TERUGGEGEVEN DOOR DE SERVER",
        ret_nothing = "(niets teruggegeven)",
        ret_waiting = "Wachten op het antwoord van de server…",
        ret_disabled = "Zet \"InvokeServer-returnwaarden vastleggen\" aan in Instellingen",
        n_alert = "🔔 Melding: %s (trefwoord \"%s\")",
        n_saved_game = "opgeslagen voor dit spel",
        n_watch_on = "⭐ %s toegevoegd aan de volglijst",
        n_watch_off = "%s verwijderd van de volglijst",
        empty_feed = "Nog geen events — speel even, elke remote-aanroep verschijnt hier.",
        empty_filter = "Niets komt overeen met dit filter.",
        empty_network = "Nog geen verkeer vastgelegd.",
        empty_scripts = "Klik op \"Scripts scannen\" om de clientscripts van het spel te tonen.",
        empty_errors = "Geen fouten — alles werkt.",
        net_click_hint = "klik op een rij om de spy te filteren",
        err_copy = "📋 Alles kopiëren",
        err_clear = "🧹 Wissen",
        err_count = "%d fout(en)",
        c_errors = "Fouten",
        hi_export_script = "🧾 Exporteren als script",
        se_capture = "📡 Vastleggen",
        se_returns = "↩ InvokeServer-returnwaarden vastleggen",
        se_returns_note = "Toont wat de server antwoordt. Zet uit als een spel zich vreemd gedraagt.",
        se_clientinvoke = "📨 OnClientInvoke vastleggen (vereist getcallbackvalue)",
        se_bindables = "🔗 BindableEvent / BindableFunction bespioneren",
        se_group = "🧮 Identieke aanroepen groeperen (×N)",
        se_flood = "🌊 Anti-flood (max. gelogde aanroepen per remote per seconde)",
        se_alerts = "🔔 Meldingen",
        se_alerts_on = "🔔 Melden als een remote-naam een trefwoord bevat",
        se_keywords = "Trefwoorden (gescheiden door komma's)",
        n_keywords_saved = "Trefwoorden opgeslagen",
        se_appearance = "🎨 Uiterlijk",
        se_accent = "Accentkleur",
        c_blue = "Blauw",
        c_purple = "Paars",
        c_green = "Groen",
        c_red = "Rood",
        c_orange = "Oranje",
        se_transparency = "Venstertransparantie",
        se_textsize = "Tekstgrootte",
        se_bottomtabs = "📱 Tabbalk onderaan",
        se_keybind = "⌨ Toets tonen / verbergen: %s (klik om te wijzigen)",
        se_keybind_wait = "Druk op een toets… (Esc = annuleren)",
        n_keybind = "Toets ingesteld: %s",
        se_tools = "🧰 Hulpmiddelen",
        se_export_script = "🧾 Deze sessie exporteren als afspeelscript",
        se_whatsnew = "🎉 Wat is er nieuw",
        se_unload = "⏏ RobloxSpy ontladen",
        unload_title = "RobloxSpy ontladen?",
        unload_body = "De hooks worden verwijderd, de sessie opgeslagen en de interface gesloten. Voer het script opnieuw uit om te herstarten.",
        n_returns_on = "Returnwaarden van nieuwe InvokeServer worden vastgelegd",
        n_option_off = "Optie uitgeschakeld",
        n_need_fn = "%s wordt niet ondersteund door %s",
        tip_maximize = "Maximaliseren / herstellen",
        tip_minimize = "Minimaliseren",
        tip_close = "Verbergen (de ronde knop brengt het terug)",
        tip_reopen = "RobloxSpy openen (sleep om te verplaatsen)",
        tip_copy_r2s = "R2S-code kopiëren",
        tip_ignore = "Deze remote negeren (wordt verzonden, niet gelogd)",
        tip_delete = "Deze rij verwijderen",
        tip_pause = "Vastleggen pauzeren / hervatten",
        tip_clear = "Feed wissen",
        tip_expand = "Venster vergroten",
        tip_refire = "Deze aanroep opnieuw sturen",
        tip_watch = "Aan volglijst toevoegen (opgeslagen voor dit spel)",
        tip_drop = "Blokkeren: de aanroep bereikt de server nooit",
        rn_title = "🎉 Nieuw in v%s",
        rn_1 = "Het script opnieuw starten vervangt de oude instantie, en de nieuwe knop \"Ontladen\" ruimt alles netjes op.",
        rn_2 = "Anti-flood en groeperen: identieke aanroepen worden één rij \"×N\".",
        rn_3 = "InvokeServer-returns, OnClientInvoke en Bindables kunnen worden vastgelegd (Instellingen → Vastleggen).",
        rn_4 = "Statistieken per remote, gemarkeerde verschillen met de vorige aanroep, meldingen op trefwoord.",
        rn_5 = "De volglijst en de negeer- / blokkeerlijsten worden per spel opgeslagen.",
        rn_6 = "Exporteer een hele sessie als afspeelbaar script (Instellingen → Hulpmiddelen, of Geschiedenis).",
        rn_7 = "Nieuwe getekende iconen, openknop met teller, pc-toets (RightShift).",
        rn_8 = "Mobiel: tabbalk onderaan, grotere rijen en knoppen. Tooltips overal (lang drukken op mobiel).",
        rn_9 = "Accentkleuren, transparantie en tekstgrootte in Instellingen → Uiterlijk.",
        rn_10 = "Nieuw tabblad Fouten, snellere verkenner, lichter automatisch opslaan — plus diverse bugfixes.",
        as_live = "Live (elke 2 s)",
    }

    LANG.PL = {
        lang_name = "Polski",
        lang_flag = "🇵🇱",
        tab_spy = "Remote Spy",
        tab_explorer = "Eksplorator",
        tab_network = "Sieć",
        tab_scripts = "Skrypty",
        tab_history = "Historia",
        tab_settings = "Ustawienia",
        status_ready = "Gotowe",
        status_recording = "● Nagrywanie — %s · hook: %s",
        pause = "⏸ Pauza",
        resume = "▶ Wznów",
        clear = "🧹 Wyczyść",
        f_all = "◉ Wszystko",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Przychodzące",
        f_blocked = "⛔ Zablokowane",
        search_spy = "🔎 Filtruj remote'y, argumenty, ścieżki...",
        feed_cleared = "Lista wyczyszczona",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "PRZYCH.",
        lbl_blocked = "ZABLOK.",
        lbl_return = "ZWROT",
        back = "← Wstecz",
        copy_code = "📋 Kopiuj kod",
        copy_path = "🧭 Kopiuj ścieżkę",
        copy_args = "📦 Kopiuj argumenty",
        refire = "🔁 Wyślij ponownie",
        ignore = "🔇 Ignoruj",
        unignore = "🔊 Przestań ignorować",
        drop = "⛔ Blokuj wywołania",
        undrop = "✅ Zezwól na wywołania",
        delete = "🗑 Usuń",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTY (%d)",
        sec_r2s = "🧾  KOD R2S (Remote → Script)",
        sec_replay = "🧪  KOD ODTWORZENIA",
        k_remote = "Remote",
        k_class = "Klasa",
        k_method = "Metoda",
        k_direction = "Kierunek",
        k_path = "Ścieżka",
        k_caller = "Wywołujący",
        k_call = "Wywołanie nr",
        k_time = "Czas",
        k_status = "Status",
        dir_out = "📤 Klient → Serwer",
        dir_in = "📥 Serwer → Klient",
        caller_unknown = "(nieznany / executor)",
        time_fmt = "+%.3fs od startu",
        st_logged = "Zapisane",
        st_dropped = "⛔ Wywołania zablokowane",
        st_ignored = "🔇 Ignorowane",
        no_args = "(brak argumentów)",
        n_refire_only_out = "Ponownie można wysłać tylko wywołania wychodzące",
        n_refired = "Ponownie wysłano %s",
        n_refire_fail = "Błąd ponownego wysłania: %s",
        n_log_resumed = "Wznowiono zapis dla %s",
        n_ignored = "%s ignorowany — koniec logów",
        n_cant_block_in = "Zdarzeń przychodzących nie da się zablokować po stronie klienta",
        n_allowed = "Wywołania %s znów dozwolone",
        n_blocked = "Wywołania %s są teraz ZABLOKOWANE",
        n_copied = "%s skopiowano do schowka",
        n_no_clip = "Schowek niedostępny w tym executorze",
        n_copy_fail = "Błąd kopiowania: %s",
        n_action_fail = "Akcja nieudana: %s",
        c_code = "Kod",
        c_path = "Ścieżka",
        c_args = "Argumenty",
        c_r2s = "Kod R2S",
        c_logs = "Logi",
        c_source = "Źródło",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Wygenerowano: %s",
        code_incoming = "-- RobloxSpy — Zdarzenie przychodzące (serwer → klient)",
        code_replay = "-- Odtwórz lokalnie przez firesignal (jeśli executor go ma):",
        log_export_title = "RobloxSpy — Eksport logów",
        net_total = "WSZYSTKIE WYWOŁANIA",
        net_cps = "WYWOŁANIA/S",
        net_unique = "UNIKALNE",
        net_blocked = "ZABLOKOWANE",
        net_traffic = "Ruch (wywołania/s, ostatnie 60 s)",
        net_top = "🏆 Top remote'y (wg wywołań)",
        ex_search = "🔍 Szukaj w całej grze...",
        ex_props = "Właściwości",
        ex_results = "Wyników: %d",
        ex_nil = "Instancje nil",
        ex_select = "Wybierz instancję w drzewie",
        ex_copy_path = "📋 Kopiuj ścieżkę",
        ex_copy_code = "🧾 Kopiuj jako kod",
        ex_tp = "🚀 Teleportuj",
        ex_view_src = "📜 Pokaż źródło",
        ex_destroy = "🗑 Zniszcz",
        ex_clone = "📑 Klonuj",
        ex_attrs = "🏷  ATRYBUTY",
        ex_tags = "🔖  TAGI",
        ex_children = "Dzieci",
        ex_desc = "Potomkowie",
        ex_too_many = "Pokazano pierwsze %d wierszy — użyj wyszukiwania",
        n_tp_ok = "Teleportowano do %s",
        n_tp_fail = "Nie można teleportować się do tej instancji",
        n_destroyed = "Zniszczono %s (po stronie klienta)",
        n_cloned = "Sklonowano %s",
        n_prop_set = "%s = %s",
        n_prop_fail = "Nie można ustawić %s: %s",
        sc_scan = "🔍 Skanuj skrypty",
        sc_search = "🔎 Filtruj skrypty...",
        sc_found = "Znaleziono skryptów: %d",
        sc_scanning = "Skanowanie... %d",
        sc_select = "Wybierz skrypt do podglądu",
        sc_copy = "📋 Kopiuj",
        sc_save = "💾 Zapisz",
        sc_none = "-- Nie wybrano skryptu\n-- Kliknij 'Skanuj skrypty' i wybierz jeden",
        sc_fail = "-- Nie udało się zdekompilować skryptu\n-- Twój executor może nie obsługiwać dekompilacji\n-- Ścieżka: %s",
        sc_decompiling = "-- Dekompilacja...",
        sc_all = "Wszystkie",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Działające",
        sc_lines = "Linii: %d",
        n_saved = "Zapisano → %s",
        n_save_fail = "Błąd zapisu: %s",
        n_no_write = "%s nie obsługuje writefile — użyj Kopiuj",
        n_nothing = "Na razie nic do zapisania",
        n_folder_fail = "Nie można utworzyć folderu '%s' w tym executorze",
        hi_title = "🕘 Historia sesji",
        hi_refresh = "🔄 Odśwież",
        hi_current = "🔴 NA ŻYWO",
        hi_none = "Brak zapisanych sesji.",
        hi_nolist = "Twój executor nie odczytuje plików — pokazano tylko bieżącą sesję.",
        hi_calls = "Wywołań: %d",
        hi_unique = "Remote'ów: %d",
        hi_search_all = "🔎 Szukaj we wszystkich sesjach...",
        hi_results = "%d wyników w %d sesjach",
        hi_export = "💾 Eksportuj .txt",
        hi_deleted = "Sesja usunięta",
        hi_showing = "Pokazano %d z %d wpisów",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Ta gra",
        se_lang = "🌐 Język",
        se_save = "💾 Zapis logów",
        se_where = "Pliki trafiają do folderu workspace executora (PC: <Executor>/workspace — iPhone/Android: folder executora w aplikacji Pliki).",
        se_nowrite = "⛔ Twój executor nie zapisuje plików (brak writefile). Użyj „Kopiuj logi”.",
        se_folder = "📂 Folder",
        se_last = "Ostatni zapis: %s",
        se_txt = "📝 Zapisz logi (.txt — czytelne + kod R2S)",
        se_json = "🧩 Zapisz sesję (.json)",
        se_csv = "📊 Zapisz sesję (.csv — Excel)",
        se_copy = "📋 Kopiuj logi (działa wszędzie)",
        se_autosave = "🔁 Automatyczny zapis logów do folderu",
        se_interval = "⏱ Odstęp automatycznego zapisu",
        se_options = "🛠 Opcje",
        se_incoming = "📥 Zapisuj zdarzenia przychodzące (serwer → klient)",
        se_autoscroll = "⬇ Automatyczne przewijanie",
        se_pausecap = "⏸ Wstrzymaj przechwytywanie",
        se_size = "📐 Rozmiar okna",
        sz_small = "Małe",
        sz_medium = "Średnie",
        sz_large = "Duże",
        se_info = "ℹ️ Informacje o executorze",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Przychodzące",
        i_files = "Pliki",
        i_clip = "Schowek",
        i_platform = "Platforma",
        v_avail = "✅ Dostępne",
        v_unavail = "❌ Niedostępne",
        v_safe = "✅ Bezpieczne (getconnections)",
        v_delayed = "⚠ Opóźnione (10 s)",
        v_mobile = "📱 Telefon",
        v_pc = "💻 PC",
        n_inc_on = "Zdarzenia przychodzące są zapisywane",
        n_inc_off = "Zdarzenia przychodzące są ignorowane",
        n_paused = "Przechwytywanie wstrzymane",
        n_resumed = "Przechwytywanie wznowione",
        n_autosave_on = "Autozapis co %ds → %s",
        n_autosave_off = "Autozapis wyłączony",
        n_lang = "Język: %s",
        credits = "autor: Rival960 — Stworzone z pomocą Claude",
        tab_errors = "Błędy",
        ok = "OK",
        cancel = "Anuluj",
        off = "Wył.",
        status_events = "zdarzeń: %d",
        status_flood = "pominięto: %d (flood)",
        status_errors = "błędów: %d",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Obserwowane",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Obserwuj",
        unwatch = "☆ Przestań obserwować",
        st_watched = "⭐ Obserwowany",
        dir_local = "🔁 Klient ↔ Klient (lokalnie)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (serwer pyta klienta)",
        code_clientinvoke_note = "-- Serwer wywołał OnClientInvoke tej RemoteFunction z:",
        k_grouped = "Zgrupowane",
        grouped_fmt = "%d identycznych wywołań pod rząd",
        k_flood = "Flood",
        flood_fmt = "%d wywołań pominiętych tuż przed (antyflood)",
        skipped_prefix = "(+%d pominięto)",
        sec_stats = "📈  STATYSTYKI TEGO REMOTE'A",
        k_total = "Wszystkie wywołania",
        k_rate = "Częstość",
        rate_fmt = "%.1f wywołań / min",
        k_first_last = "Pierwsze → ostatnie",
        k_callers = "Wywołujący",
        diff_hint = "zmiany względem poprzedniego wywołania na żółto",
        diff_was = "było: %s",
        sec_return = "↩  ZWRÓCONE PRZEZ SERWER",
        ret_nothing = "(nic nie zwrócono)",
        ret_waiting = "Czekam na odpowiedź serwera…",
        ret_disabled = "Włącz „Przechwytuj wyniki InvokeServer” w Ustawieniach",
        n_alert = "🔔 Alert: %s (słowo kluczowe „%s”)",
        n_saved_game = "zapisano dla tej gry",
        n_watch_on = "⭐ Dodano %s do obserwowanych",
        n_watch_off = "Usunięto %s z obserwowanych",
        empty_feed = "Brak zdarzeń — pograj chwilę, każde wywołanie remote'a pojawi się tutaj.",
        empty_filter = "Nic nie pasuje do tego filtra.",
        empty_network = "Nie zarejestrowano jeszcze ruchu.",
        empty_scripts = "Kliknij „Skanuj skrypty”, aby wyświetlić skrypty klienta gry.",
        empty_errors = "Brak błędów — wszystko działa.",
        net_click_hint = "kliknij wiersz, aby przefiltrować spy",
        err_copy = "📋 Kopiuj wszystko",
        err_clear = "🧹 Wyczyść",
        err_count = "błędów: %d",
        c_errors = "Błędy",
        hi_export_script = "🧾 Eksportuj jako skrypt",
        se_capture = "📡 Przechwytywanie",
        se_returns = "↩ Przechwytuj wyniki InvokeServer",
        se_returns_note = "Pokazuje odpowiedź serwera. Wyłącz, jeśli gra zachowuje się dziwnie.",
        se_clientinvoke = "📨 Przechwytuj OnClientInvoke (wymaga getcallbackvalue)",
        se_bindables = "🔗 Śledź BindableEvent / BindableFunction",
        se_group = "🧮 Grupuj identyczne wywołania (×N)",
        se_flood = "🌊 Antyflood (maks. zapisanych wywołań na remote na sekundę)",
        se_alerts = "🔔 Alerty",
        se_alerts_on = "🔔 Powiadamiaj, gdy nazwa remote'a zawiera słowo kluczowe",
        se_keywords = "Słowa kluczowe (oddzielone przecinkami)",
        n_keywords_saved = "Słowa kluczowe zapisane",
        se_appearance = "🎨 Wygląd",
        se_accent = "Kolor akcentu",
        c_blue = "Niebieski",
        c_purple = "Fioletowy",
        c_green = "Zielony",
        c_red = "Czerwony",
        c_orange = "Pomarańczowy",
        se_transparency = "Przezroczystość okna",
        se_textsize = "Rozmiar tekstu",
        se_bottomtabs = "📱 Pasek kart na dole",
        se_keybind = "⌨ Klawisz pokaż / ukryj: %s (kliknij, aby zmienić)",
        se_keybind_wait = "Naciśnij klawisz… (Esc = anuluj)",
        n_keybind = "Ustawiono klawisz: %s",
        se_tools = "🧰 Narzędzia",
        se_export_script = "🧾 Eksportuj sesję jako skrypt odtwarzania",
        se_whatsnew = "🎉 Co nowego",
        se_unload = "⏏ Wyładuj RobloxSpy",
        unload_title = "Wyładować RobloxSpy?",
        unload_body = "Hooki zostaną usunięte, sesja zapisana, a interfejs zamknięty. Uruchom skrypt ponownie, aby go zrestartować.",
        n_returns_on = "Wyniki nowych InvokeServer są przechwytywane",
        n_option_off = "Opcja wyłączona",
        n_need_fn = "%s nie jest obsługiwane przez %s",
        tip_maximize = "Maksymalizuj / przywróć",
        tip_minimize = "Minimalizuj",
        tip_close = "Ukryj (okrągły przycisk je przywróci)",
        tip_reopen = "Otwórz RobloxSpy (przeciągnij, aby przesunąć)",
        tip_copy_r2s = "Kopiuj kod R2S",
        tip_ignore = "Ignoruj ten remote (wysyłany, ale nie logowany)",
        tip_delete = "Usuń ten wiersz",
        tip_pause = "Wstrzymaj / wznów przechwytywanie",
        tip_clear = "Wyczyść listę",
        tip_expand = "Powiększ okno",
        tip_refire = "Wyślij to wywołanie ponownie",
        tip_watch = "Dodaj do obserwowanych (zapisane dla tej gry)",
        tip_drop = "Blokuj: wywołanie nigdy nie dotrze do serwera",
        rn_title = "🎉 Nowości w v%s",
        rn_1 = "Ponowne uruchomienie zastępuje starą instancję, a nowy przycisk „Wyładuj” czysto wszystko usuwa.",
        rn_2 = "Antyflood i grupowanie: identyczne wywołania łączą się w jeden wiersz „×N”.",
        rn_3 = "Można przechwytywać wyniki InvokeServer, OnClientInvoke i Bindables (Ustawienia → Przechwytywanie).",
        rn_4 = "Statystyki remote'ów, podświetlone różnice z poprzednim wywołaniem, alerty słów kluczowych.",
        rn_5 = "Obserwowane oraz listy ignorowanych / blokowanych są zapisywane dla każdej gry.",
        rn_6 = "Eksport całej sesji jako skryptu do odtworzenia (Ustawienia → Narzędzia lub Historia).",
        rn_7 = "Nowe rysowane ikony, przycisk otwierania z licznikiem, klawisz na PC (RightShift).",
        rn_8 = "Telefon: karty na dole, większe wiersze i przyciski. Podpowiedzi wszędzie (długie naciśnięcie na telefonie).",
        rn_9 = "Kolory akcentu, przezroczystość i rozmiar tekstu w Ustawienia → Wygląd.",
        rn_10 = "Nowa karta Błędy, szybszy eksplorator, lżejszy autozapis — i kilka poprawek błędów.",
        as_live = "Na bieżąco (co 2 s)",
    }

    LANG.ZH = {
        lang_name = "中文",
        lang_flag = "🇨🇳",
        tab_spy = "远程监视",
        tab_explorer = "资源管理器",
        tab_network = "网络",
        tab_scripts = "脚本",
        tab_history = "历史",
        tab_settings = "设置",
        status_ready = "就绪",
        status_recording = "● 记录中 — %s · 钩子：%s",
        pause = "⏸ 暂停",
        resume = "▶ 继续",
        clear = "🧹 清空",
        f_all = "◉ 全部",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 传入",
        f_blocked = "⛔ 已拦截",
        search_spy = "🔎 筛选远程、参数、路径...",
        feed_cleared = "列表已清空",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "传入",
        lbl_blocked = "已拦截",
        lbl_return = "返回",
        back = "← 返回",
        copy_code = "📋 复制代码",
        copy_path = "🧭 复制路径",
        copy_args = "📦 复制参数",
        refire = "🔁 重新发送",
        ignore = "🔇 忽略",
        unignore = "🔊 取消忽略",
        drop = "⛔ 拦截调用",
        undrop = "✅ 允许调用",
        delete = "🗑 删除",
        sec_info = "ℹ️  信息",
        sec_args = "📦  参数 (%d)",
        sec_r2s = "🧾  R2S 代码 (Remote → Script)",
        sec_replay = "🧪  重放代码",
        k_remote = "远程",
        k_class = "类",
        k_method = "方法",
        k_direction = "方向",
        k_path = "路径",
        k_caller = "调用者",
        k_call = "调用编号",
        k_time = "时间",
        k_status = "状态",
        dir_out = "📤 客户端 → 服务器",
        dir_in = "📥 服务器 → 客户端",
        caller_unknown = "（未知 / 执行器）",
        time_fmt = "启动后 +%.3fs",
        st_logged = "已记录",
        st_dropped = "⛔ 调用已拦截",
        st_ignored = "🔇 已忽略",
        no_args = "（无参数）",
        n_refire_only_out = "只能重新发送传出调用",
        n_refired = "已重新发送 %s",
        n_refire_fail = "重新发送失败：%s",
        n_log_resumed = "已恢复记录 %s",
        n_ignored = "已忽略 %s — 不再记录",
        n_cant_block_in = "传入事件无法在客户端拦截",
        n_allowed = "已重新允许调用 %s",
        n_blocked = "对 %s 的调用已被拦截",
        n_copied = "%s 已复制到剪贴板",
        n_no_clip = "此执行器不支持剪贴板",
        n_copy_fail = "复制失败：%s",
        n_action_fail = "操作失败：%s",
        c_code = "代码",
        c_path = "路径",
        c_args = "参数",
        c_r2s = "R2S 代码",
        c_logs = "日志",
        c_source = "源码",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- 生成时间：%s",
        code_incoming = "-- RobloxSpy — 传入事件（服务器 → 客户端）",
        code_replay = "-- 使用 firesignal 在本地重放（如果执行器支持）：",
        log_export_title = "RobloxSpy — 日志导出",
        net_total = "总调用",
        net_cps = "调用/秒",
        net_unique = "唯一",
        net_blocked = "已拦截",
        net_traffic = "流量（调用/秒，最近 60 秒）",
        net_top = "🏆 热门远程（按调用次数）",
        ex_search = "🔍 搜索整个游戏...",
        ex_props = "属性",
        ex_results = "%d 个结果",
        ex_nil = "Nil 实例",
        ex_select = "在树中选择一个实例",
        ex_copy_path = "📋 复制路径",
        ex_copy_code = "🧾 复制为代码",
        ex_tp = "🚀 传送",
        ex_view_src = "📜 查看源码",
        ex_destroy = "🗑 销毁",
        ex_clone = "📑 克隆",
        ex_attrs = "🏷  特性",
        ex_tags = "🔖  标签",
        ex_children = "子项",
        ex_desc = "后代",
        ex_too_many = "仅显示前 %d 行 — 请使用搜索",
        n_tp_ok = "已传送到 %s",
        n_tp_fail = "无法传送到此实例",
        n_destroyed = "已销毁 %s（客户端）",
        n_cloned = "已克隆 %s",
        n_prop_set = "%s = %s",
        n_prop_fail = "无法设置 %s：%s",
        sc_scan = "🔍 扫描脚本",
        sc_search = "🔎 筛选脚本...",
        sc_found = "找到 %d 个脚本",
        sc_scanning = "扫描中... %d",
        sc_select = "选择要查看的脚本",
        sc_copy = "📋 复制",
        sc_save = "💾 保存",
        sc_none = "-- 未选择脚本\n-- 点击“扫描脚本”然后选择一个",
        sc_fail = "-- 无法反编译此脚本\n-- 你的执行器可能不支持反编译\n-- 路径：%s",
        sc_decompiling = "-- 反编译中...",
        sc_all = "全部",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "运行中",
        sc_lines = "%d 行",
        n_saved = "已保存 → %s",
        n_save_fail = "保存失败：%s",
        n_no_write = "%s 不支持 writefile — 请使用复制",
        n_nothing = "暂无可保存内容",
        n_folder_fail = "无法在此执行器上创建文件夹“%s”",
        hi_title = "🕘 会话历史",
        hi_refresh = "🔄 刷新",
        hi_current = "🔴 实时",
        hi_none = "没有已保存的会话。",
        hi_nolist = "你的执行器无法读取文件 — 仅显示当前会话。",
        hi_calls = "%d 次调用",
        hi_unique = "%d 个远程",
        hi_search_all = "🔎 在所有会话中搜索...",
        hi_results = "共 %d 条匹配，分布在 %d 个会话中",
        hi_export = "💾 导出 .txt",
        hi_deleted = "会话已删除",
        hi_showing = "显示 %d / %d 条记录",
        hi_duration = "%d分 %d秒",
        hi_same_game = "📍 本游戏",
        se_lang = "🌐 语言",
        se_save = "💾 保存日志",
        se_where = "文件保存在执行器的 workspace 文件夹中（PC：<Executor>/workspace — iPhone/Android：“文件”应用中的执行器文件夹）。",
        se_nowrite = "⛔ 你的执行器无法写入文件（缺少 writefile）。请使用“复制日志”。",
        se_folder = "📂 文件夹",
        se_last = "最近保存：%s",
        se_txt = "📝 保存日志（.txt — 可读 + R2S 代码）",
        se_json = "🧩 保存会话（.json）",
        se_csv = "📊 保存会话（.csv — Excel）",
        se_copy = "📋 复制日志到剪贴板（通用）",
        se_autosave = "🔁 自动保存日志到文件夹",
        se_interval = "⏱ 自动保存间隔",
        se_options = "🛠 选项",
        se_incoming = "📥 记录传入事件（服务器 → 客户端）",
        se_autoscroll = "⬇ 自动滚动",
        se_pausecap = "⏸ 暂停捕获",
        se_size = "📐 窗口大小",
        sz_small = "小",
        sz_medium = "中",
        sz_large = "大",
        se_info = "ℹ️ 执行器信息",
        i_executor = "执行器",
        i_hooking = "钩子",
        i_incoming = "传入",
        i_files = "文件系统",
        i_clip = "剪贴板",
        i_platform = "平台",
        v_avail = "✅ 可用",
        v_unavail = "❌ 不可用",
        v_safe = "✅ 安全（getconnections）",
        v_delayed = "⚠ 延迟（10 秒）",
        v_mobile = "📱 手机",
        v_pc = "💻 电脑",
        n_inc_on = "正在记录传入事件",
        n_inc_off = "已忽略传入事件",
        n_paused = "捕获已暂停",
        n_resumed = "捕获已继续",
        n_autosave_on = "每 %d 秒自动保存 → %s",
        n_autosave_off = "自动保存已关闭",
        n_lang = "语言：%s",
        credits = "作者 Rival960 — 在 Claude 的帮助下制作",
        tab_errors = "错误",
        ok = "确定",
        cancel = "取消",
        off = "关",
        status_events = "%d 个事件",
        status_flood = "已跳过 %d（防刷屏）",
        status_errors = "%d 个错误",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ 关注",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ 关注",
        unwatch = "☆ 取消关注",
        st_watched = "⭐ 已关注",
        dir_local = "🔁 客户端 ↔ 客户端（本地）",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke（服务器询问客户端）",
        code_clientinvoke_note = "-- 服务器调用了此 RemoteFunction 的 OnClientInvoke，参数：",
        k_grouped = "已合并",
        grouped_fmt = "连续 %d 次相同调用",
        k_flood = "刷屏",
        flood_fmt = "此前跳过了 %d 次调用（防刷屏）",
        skipped_prefix = "（+%d 已跳过）",
        sec_stats = "📈  此远程的统计",
        k_total = "总调用数",
        k_rate = "频率",
        rate_fmt = "%.1f 次 / 分钟",
        k_first_last = "首次 → 最近",
        k_callers = "调用者",
        diff_hint = "与上一次调用的不同之处以黄色显示",
        diff_was = "之前：%s",
        sec_return = "↩  服务器返回值",
        ret_nothing = "（无返回值）",
        ret_waiting = "正在等待服务器响应…",
        ret_disabled = "请在设置中开启“捕获 InvokeServer 返回值”",
        n_alert = "🔔 警报：%s（关键词“%s”）",
        n_saved_game = "已为此游戏保存",
        n_watch_on = "⭐ 已将 %s 加入关注列表",
        n_watch_off = "已将 %s 移出关注列表",
        empty_feed = "暂无事件 — 玩一会儿，每次远程调用都会显示在这里。",
        empty_filter = "没有符合筛选条件的内容。",
        empty_network = "尚未记录流量。",
        empty_scripts = "点击“扫描脚本”以列出游戏的客户端脚本。",
        empty_errors = "没有错误 — 一切正常。",
        net_click_hint = "点击某行可筛选监视列表",
        err_copy = "📋 全部复制",
        err_clear = "🧹 清空",
        err_count = "%d 个错误",
        c_errors = "错误",
        hi_export_script = "🧾 导出为脚本",
        se_capture = "📡 捕获",
        se_returns = "↩ 捕获 InvokeServer 返回值",
        se_returns_note = "显示服务器的响应。如果游戏表现异常，请关闭。",
        se_clientinvoke = "📨 捕获 OnClientInvoke（需要 getcallbackvalue）",
        se_bindables = "🔗 监视 BindableEvent / BindableFunction",
        se_group = "🧮 合并相同调用（×N）",
        se_flood = "🌊 防刷屏（每个远程每秒最多记录的调用数）",
        se_alerts = "🔔 警报",
        se_alerts_on = "🔔 当远程名称包含关键词时通知",
        se_keywords = "关键词（用逗号分隔）",
        n_keywords_saved = "关键词已保存",
        se_appearance = "🎨 外观",
        se_accent = "强调色",
        c_blue = "蓝色",
        c_purple = "紫色",
        c_green = "绿色",
        c_red = "红色",
        c_orange = "橙色",
        se_transparency = "窗口透明度",
        se_textsize = "文字大小",
        se_bottomtabs = "📱 标签栏置于底部",
        se_keybind = "⌨ 显示 / 隐藏按键：%s（点击更改）",
        se_keybind_wait = "请按一个键…（Esc = 取消）",
        n_keybind = "按键已设置：%s",
        se_tools = "🧰 工具",
        se_export_script = "🧾 将此会话导出为重放脚本",
        se_whatsnew = "🎉 新功能",
        se_unload = "⏏ 卸载 RobloxSpy",
        unload_title = "卸载 RobloxSpy？",
        unload_body = "将移除钩子、保存会话并关闭界面。再次运行脚本即可重新启动。",
        n_returns_on = "新的 InvokeServer 返回值将被捕获",
        n_option_off = "选项已关闭",
        n_need_fn = "%s 不受 %s 支持",
        tip_maximize = "最大化 / 还原",
        tip_minimize = "最小化",
        tip_close = "隐藏（圆形按钮可重新打开）",
        tip_reopen = "打开 RobloxSpy（拖动可移动）",
        tip_copy_r2s = "复制 R2S 代码",
        tip_ignore = "忽略此远程（仍会发送，但不记录）",
        tip_delete = "删除此行",
        tip_pause = "暂停 / 继续捕获",
        tip_clear = "清空列表",
        tip_expand = "放大窗口",
        tip_refire = "再次发送此调用",
        tip_watch = "加入关注列表（为此游戏保存）",
        tip_drop = "拦截：调用永远不会到达服务器",
        rn_title = "🎉 v%s 新功能",
        rn_1 = "再次运行脚本会替换旧实例，新的“卸载”按钮可干净地移除一切。",
        rn_2 = "防刷屏与合并：相同的调用合并为一行“×N”。",
        rn_3 = "可捕获 InvokeServer 返回值、OnClientInvoke 和 Bindables（设置 → 捕获）。",
        rn_4 = "每个远程的统计、与上一次调用的差异高亮、关键词警报。",
        rn_5 = "关注列表以及忽略 / 拦截列表按游戏保存。",
        rn_6 = "将整个会话导出为可重放脚本（设置 → 工具，或历史）。",
        rn_7 = "全新绘制图标，带未读计数的打开按钮，PC 快捷键（RightShift）。",
        rn_8 = "手机：标签栏在底部，行和按钮更大。处处有提示（手机上长按）。",
        rn_9 = "在设置 → 外观中调整强调色、透明度和文字大小。",
        rn_10 = "新增错误标签页，资源管理器更快，自动保存更轻量 — 并修复了多个错误。",
        as_live = "实时（每 2 秒）",
    }

    LANG.JA = {
        lang_name = "日本語",
        lang_flag = "🇯🇵",
        tab_spy = "リモートスパイ",
        tab_explorer = "エクスプローラー",
        tab_network = "ネットワーク",
        tab_scripts = "スクリプト",
        tab_history = "履歴",
        tab_settings = "設定",
        status_ready = "準備完了",
        status_recording = "● 記録中 — %s · フック: %s",
        pause = "⏸ 一時停止",
        resume = "▶ 再開",
        clear = "🧹 クリア",
        f_all = "◉ すべて",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 受信",
        f_blocked = "⛔ ブロック済み",
        search_spy = "🔎 リモート・引数・パスで絞り込み...",
        feed_cleared = "フィードをクリアしました",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "受信",
        lbl_blocked = "ブロック",
        lbl_return = "戻り値",
        back = "← 戻る",
        copy_code = "📋 コードをコピー",
        copy_path = "🧭 パスをコピー",
        copy_args = "📦 引数をコピー",
        refire = "🔁 再送信",
        ignore = "🔇 無視",
        unignore = "🔊 無視を解除",
        drop = "⛔ 呼び出しをブロック",
        undrop = "✅ 呼び出しを許可",
        delete = "🗑 削除",
        sec_info = "ℹ️  情報",
        sec_args = "📦  引数 (%d)",
        sec_r2s = "🧾  R2S コード (Remote → Script)",
        sec_replay = "🧪  再生コード",
        k_remote = "リモート",
        k_class = "クラス",
        k_method = "メソッド",
        k_direction = "方向",
        k_path = "パス",
        k_caller = "呼び出し元",
        k_call = "呼び出し番号",
        k_time = "時間",
        k_status = "状態",
        dir_out = "📤 クライアント → サーバー",
        dir_in = "📥 サーバー → クライアント",
        caller_unknown = "（不明 / エグゼキューター）",
        time_fmt = "開始から +%.3fs",
        st_logged = "記録済み",
        st_dropped = "⛔ 呼び出しブロック中",
        st_ignored = "🔇 無視中",
        no_args = "（引数なし）",
        n_refire_only_out = "再送信できるのは送信呼び出しのみです",
        n_refired = "%s を再送信しました",
        n_refire_fail = "再送信に失敗: %s",
        n_log_resumed = "%s の記録を再開しました",
        n_ignored = "%s を無視 — 今後は記録しません",
        n_cant_block_in = "受信イベントはクライアント側でブロックできません",
        n_allowed = "%s への呼び出しを再び許可しました",
        n_blocked = "%s への呼び出しをブロックしました",
        n_copied = "%s をクリップボードにコピーしました",
        n_no_clip = "このエグゼキューターではクリップボードが使えません",
        n_copy_fail = "コピーに失敗: %s",
        n_action_fail = "操作に失敗: %s",
        c_code = "コード",
        c_path = "パス",
        c_args = "引数",
        c_r2s = "R2S コード",
        c_logs = "ログ",
        c_source = "ソース",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- 生成日時: %s",
        code_incoming = "-- RobloxSpy — 受信イベント（サーバー → クライアント）",
        code_replay = "-- firesignal でローカル再生（エグゼキューターが対応している場合）:",
        log_export_title = "RobloxSpy — ログ出力",
        net_total = "総呼び出し",
        net_cps = "呼び出し/秒",
        net_unique = "ユニーク",
        net_blocked = "ブロック",
        net_traffic = "トラフィック（呼び出し/秒、直近 60 秒）",
        net_top = "🏆 上位リモート（呼び出し数）",
        ex_search = "🔍 ゲーム全体を検索...",
        ex_props = "プロパティ",
        ex_results = "%d 件の結果",
        ex_nil = "Nil インスタンス",
        ex_select = "ツリーからインスタンスを選択",
        ex_copy_path = "📋 パスをコピー",
        ex_copy_code = "🧾 コードとしてコピー",
        ex_tp = "🚀 テレポート",
        ex_view_src = "📜 ソースを見る",
        ex_destroy = "🗑 削除する",
        ex_clone = "📑 複製",
        ex_attrs = "🏷  属性",
        ex_tags = "🔖  タグ",
        ex_children = "子",
        ex_desc = "子孫",
        ex_too_many = "最初の %d 行のみ表示 — 検索を使ってください",
        n_tp_ok = "%s にテレポートしました",
        n_tp_fail = "このインスタンスにはテレポートできません",
        n_destroyed = "%s を削除しました（クライアント側）",
        n_cloned = "%s を複製しました",
        n_prop_set = "%s = %s",
        n_prop_fail = "%s を設定できません: %s",
        sc_scan = "🔍 スクリプトをスキャン",
        sc_search = "🔎 スクリプトを絞り込み...",
        sc_found = "%d 個のスクリプト",
        sc_scanning = "スキャン中... %d",
        sc_select = "表示するスクリプトを選択",
        sc_copy = "📋 コピー",
        sc_save = "💾 保存",
        sc_none = "-- スクリプト未選択\n-- 「スクリプトをスキャン」を押して選んでください",
        sc_fail = "-- このスクリプトを逆コンパイルできません\n-- エグゼキューターが未対応の可能性があります\n-- パス: %s",
        sc_decompiling = "-- 逆コンパイル中...",
        sc_all = "すべて",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "実行中",
        sc_lines = "%d 行",
        n_saved = "保存しました → %s",
        n_save_fail = "保存に失敗: %s",
        n_no_write = "%s は writefile に未対応 — コピーを使ってください",
        n_nothing = "まだ保存するものがありません",
        n_folder_fail = "このエグゼキューターではフォルダ '%s' を作成できません",
        hi_title = "🕘 セッション履歴",
        hi_refresh = "🔄 更新",
        hi_current = "🔴 ライブ",
        hi_none = "保存されたセッションはありません。",
        hi_nolist = "エグゼキューターがファイルを読めません — 現在のセッションのみ表示します。",
        hi_calls = "%d 回の呼び出し",
        hi_unique = "%d 個のリモート",
        hi_search_all = "🔎 全セッションを検索...",
        hi_results = "%d 件の一致（%d セッション）",
        hi_export = "💾 .txt で出力",
        hi_deleted = "セッションを削除しました",
        hi_showing = "%d / %d 件を表示",
        hi_duration = "%d分 %d秒",
        hi_same_game = "📍 このゲーム",
        se_lang = "🌐 言語",
        se_save = "💾 ログの保存",
        se_where = "ファイルはエグゼキューターの workspace フォルダに保存されます（PC: <Executor>/workspace — iPhone/Android:「ファイル」アプリ内のエグゼキューターのフォルダ）。",
        se_nowrite = "⛔ エグゼキューターがファイルを書き込めません（writefile なし）。「ログをコピー」を使ってください。",
        se_folder = "📂 フォルダ",
        se_last = "最終保存: %s",
        se_txt = "📝 ログを保存（.txt — 読みやすい + R2S コード）",
        se_json = "🧩 セッションを保存（.json）",
        se_csv = "📊 セッションを保存（.csv — Excel）",
        se_copy = "📋 ログをコピー（どこでも使えます）",
        se_autosave = "🔁 ログをフォルダに自動保存",
        se_interval = "⏱ 自動保存の間隔",
        se_options = "🛠 オプション",
        se_incoming = "📥 受信イベントを記録（サーバー → クライアント）",
        se_autoscroll = "⬇ 自動スクロール",
        se_pausecap = "⏸ キャプチャを一時停止",
        se_size = "📐 ウィンドウサイズ",
        sz_small = "小",
        sz_medium = "中",
        sz_large = "大",
        se_info = "ℹ️ エグゼキューター情報",
        i_executor = "エグゼキューター",
        i_hooking = "フック",
        i_incoming = "受信",
        i_files = "ファイル",
        i_clip = "クリップボード",
        i_platform = "プラットフォーム",
        v_avail = "✅ 利用可能",
        v_unavail = "❌ 利用不可",
        v_safe = "✅ 安全（getconnections）",
        v_delayed = "⚠ 遅延（10 秒）",
        v_mobile = "📱 モバイル",
        v_pc = "💻 PC",
        n_inc_on = "受信イベントを記録します",
        n_inc_off = "受信イベントを無視します",
        n_paused = "キャプチャを一時停止しました",
        n_resumed = "キャプチャを再開しました",
        n_autosave_on = "%d 秒ごとに自動保存 → %s",
        n_autosave_off = "自動保存オフ",
        n_lang = "言語: %s",
        credits = "制作 Rival960 — Claude の協力で作成",
        tab_errors = "エラー",
        ok = "OK",
        cancel = "キャンセル",
        off = "オフ",
        status_events = "%d 件のイベント",
        status_flood = "%d 件スキップ（フラッド）",
        status_errors = "%d 件のエラー",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ ウォッチ",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ ウォッチ",
        unwatch = "☆ ウォッチ解除",
        st_watched = "⭐ ウォッチ中",
        dir_local = "🔁 クライアント ↔ クライアント（ローカル）",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke（サーバーがクライアントに問い合わせ）",
        code_clientinvoke_note = "-- サーバーがこの RemoteFunction の OnClientInvoke を次の引数で呼び出しました:",
        k_grouped = "まとめ表示",
        grouped_fmt = "同一の呼び出しが %d 回連続",
        k_flood = "フラッド",
        flood_fmt = "直前に %d 回の呼び出しをスキップ（フラッド対策）",
        skipped_prefix = "（+%d スキップ）",
        sec_stats = "📈  このリモートの統計",
        k_total = "総呼び出し",
        k_rate = "頻度",
        rate_fmt = "%.1f 回 / 分",
        k_first_last = "最初 → 最後",
        k_callers = "呼び出し元",
        diff_hint = "前回の呼び出しとの違いを黄色で表示",
        diff_was = "前回: %s",
        sec_return = "↩  サーバーからの戻り値",
        ret_nothing = "（戻り値なし）",
        ret_waiting = "サーバーの応答を待っています…",
        ret_disabled = "設定で「InvokeServer の戻り値をキャプチャ」を有効にしてください",
        n_alert = "🔔 アラート: %s（キーワード「%s」）",
        n_saved_game = "このゲーム用に保存しました",
        n_watch_on = "⭐ %s をウォッチリストに追加",
        n_watch_off = "%s をウォッチリストから削除",
        empty_feed = "まだイベントはありません — 少し遊ぶと、リモート呼び出しがここに表示されます。",
        empty_filter = "このフィルターに一致するものはありません。",
        empty_network = "まだトラフィックは記録されていません。",
        empty_scripts = "「スクリプトをスキャン」を押すと、ゲームのクライアントスクリプトを一覧表示します。",
        empty_errors = "エラーはありません — すべて正常です。",
        net_click_hint = "行をクリックするとスパイを絞り込みます",
        err_copy = "📋 すべてコピー",
        err_clear = "🧹 クリア",
        err_count = "%d 件のエラー",
        c_errors = "エラー",
        hi_export_script = "🧾 スクリプトとして出力",
        se_capture = "📡 キャプチャ",
        se_returns = "↩ InvokeServer の戻り値をキャプチャ",
        se_returns_note = "サーバーの応答を表示します。ゲームの挙動がおかしい場合はオフにしてください。",
        se_clientinvoke = "📨 OnClientInvoke をキャプチャ（getcallbackvalue が必要）",
        se_bindables = "🔗 BindableEvent / BindableFunction を監視",
        se_group = "🧮 同一の呼び出しをまとめる（×N）",
        se_flood = "🌊 フラッド対策（リモートごとの毎秒の最大記録数）",
        se_alerts = "🔔 アラート",
        se_alerts_on = "🔔 リモート名にキーワードが含まれると通知",
        se_keywords = "キーワード（カンマ区切り）",
        n_keywords_saved = "キーワードを保存しました",
        se_appearance = "🎨 外観",
        se_accent = "アクセントカラー",
        c_blue = "青",
        c_purple = "紫",
        c_green = "緑",
        c_red = "赤",
        c_orange = "オレンジ",
        se_transparency = "ウィンドウの透明度",
        se_textsize = "文字サイズ",
        se_bottomtabs = "📱 タブバーを下に表示",
        se_keybind = "⌨ 表示 / 非表示キー: %s（クリックで変更）",
        se_keybind_wait = "キーを押してください…（Esc = キャンセル）",
        n_keybind = "キーを設定: %s",
        se_tools = "🧰 ツール",
        se_export_script = "🧾 このセッションを再生スクリプトとして出力",
        se_whatsnew = "🎉 新機能",
        se_unload = "⏏ RobloxSpy をアンロード",
        unload_title = "RobloxSpy をアンロードしますか？",
        unload_body = "フックを外し、セッションを保存して、画面を閉じます。再起動するにはスクリプトをもう一度実行してください。",
        n_returns_on = "新しい InvokeServer の戻り値をキャプチャします",
        n_option_off = "オプションを無効にしました",
        n_need_fn = "%s は %s で利用できません",
        tip_maximize = "最大化 / 元に戻す",
        tip_minimize = "最小化",
        tip_close = "隠す（丸いボタンで戻せます）",
        tip_reopen = "RobloxSpy を開く（ドラッグで移動）",
        tip_copy_r2s = "R2S コードをコピー",
        tip_ignore = "このリモートを無視（送信はされるが記録しない）",
        tip_delete = "この行を削除",
        tip_pause = "キャプチャを一時停止 / 再開",
        tip_clear = "フィードをクリア",
        tip_expand = "ウィンドウを拡大",
        tip_refire = "この呼び出しを再送信",
        tip_watch = "ウォッチリストに追加（このゲーム用に保存）",
        tip_drop = "ブロック: 呼び出しはサーバーに届きません",
        rn_title = "🎉 v%s の新機能",
        rn_1 = "スクリプトを再実行すると古いインスタンスが置き換わり、新しい「アンロード」ボタンですべてきれいに削除できます。",
        rn_2 = "フラッド対策とまとめ表示: 同一の呼び出しは「×N」の1行にまとまります。",
        rn_3 = "InvokeServer の戻り値、OnClientInvoke、Bindables をキャプチャ可能（設定 → キャプチャ）。",
        rn_4 = "リモートごとの統計、前回の呼び出しとの差分の強調、キーワードアラート。",
        rn_5 = "ウォッチリストと無視 / ブロックのリストはゲームごとに保存されます。",
        rn_6 = "セッション全体を再生可能なスクリプトとして出力（設定 → ツール、または履歴）。",
        rn_7 = "新しい描画アイコン、未読カウンター付きの再表示ボタン、PC のキー（RightShift）。",
        rn_8 = "モバイル: タブバーを下に、行とボタンを大きく。どこでもヒント表示（モバイルは長押し）。",
        rn_9 = "アクセントカラー、透明度、文字サイズは 設定 → 外観 で変更できます。",
        rn_10 = "新しいエラータブ、より速いエクスプローラー、軽くなった自動保存 — さらに複数の不具合を修正。",
        as_live = "リアルタイム（2 秒ごと）",
    }

    LANG.TR = {
        lang_name = "Türkçe",
        lang_flag = "🇹🇷",
        tab_spy = "Remote Spy",
        tab_explorer = "Gezgin",
        tab_network = "Ağ",
        tab_scripts = "Scriptler",
        tab_history = "Geçmiş",
        tab_settings = "Ayarlar",
        status_ready = "Hazır",
        status_recording = "● Kaydediliyor — %s · hook: %s",
        pause = "⏸ Duraklat",
        resume = "▶ Devam et",
        clear = "🧹 Temizle",
        f_all = "◉ Tümü",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Gelen",
        f_blocked = "⛔ Engelli",
        search_spy = "🔎 Remote, argüman, yol filtrele...",
        feed_cleared = "Akış temizlendi",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "GELEN",
        lbl_blocked = "ENGELLİ",
        lbl_return = "DÖNÜŞ",
        back = "← Geri",
        copy_code = "📋 Kodu kopyala",
        copy_path = "🧭 Yolu kopyala",
        copy_args = "📦 Argümanları kopyala",
        refire = "🔁 Tekrar gönder",
        ignore = "🔇 Yoksay",
        unignore = "🔊 Yoksaymayı bırak",
        drop = "⛔ Çağrıları engelle",
        undrop = "✅ Çağrılara izin ver",
        delete = "🗑 Sil",
        sec_info = "ℹ️  BİLGİ",
        sec_args = "📦  ARGÜMANLAR (%d)",
        sec_r2s = "🧾  R2S KODU (Remote → Script)",
        sec_replay = "🧪  TEKRAR OYNATMA KODU",
        k_remote = "Remote",
        k_class = "Sınıf",
        k_method = "Metot",
        k_direction = "Yön",
        k_path = "Yol",
        k_caller = "Çağıran",
        k_call = "Çağrı no",
        k_time = "Zaman",
        k_status = "Durum",
        dir_out = "📤 İstemci → Sunucu",
        dir_in = "📥 Sunucu → İstemci",
        caller_unknown = "(bilinmiyor / executor)",
        time_fmt = "Başlangıçtan +%.3fs sonra",
        st_logged = "Kaydedildi",
        st_dropped = "⛔ Çağrılar engellendi",
        st_ignored = "🔇 Yoksayıldı",
        no_args = "(argüman yok)",
        n_refire_only_out = "Yalnızca giden çağrılar tekrar gönderilebilir",
        n_refired = "%s tekrar gönderildi",
        n_refire_fail = "Tekrar gönderme başarısız: %s",
        n_log_resumed = "%s için kayıt devam ediyor",
        n_ignored = "%s yoksayıldı — artık kayıt yok",
        n_cant_block_in = "Gelen olaylar istemci tarafında engellenemez",
        n_allowed = "%s çağrılarına tekrar izin verildi",
        n_blocked = "%s çağrıları artık ENGELLİ",
        n_copied = "%s panoya kopyalandı",
        n_no_clip = "Bu executor'da pano kullanılamıyor",
        n_copy_fail = "Kopyalama başarısız: %s",
        n_action_fail = "İşlem başarısız: %s",
        c_code = "Kod",
        c_path = "Yol",
        c_args = "Argümanlar",
        c_r2s = "R2S kodu",
        c_logs = "Kayıtlar",
        c_source = "Kaynak",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Oluşturuldu: %s",
        code_incoming = "-- RobloxSpy — Gelen olay (sunucu → istemci)",
        code_replay = "-- firesignal ile yerelde tekrar oynat (executor destekliyorsa):",
        log_export_title = "RobloxSpy — Kayıt dışa aktarma",
        net_total = "TOPLAM ÇAĞRI",
        net_cps = "ÇAĞRI/SN",
        net_unique = "BENZERSİZ",
        net_blocked = "ENGELLİ",
        net_traffic = "Trafik (çağrı/sn, son 60 sn)",
        net_top = "🏆 En çok kullanılan remote'lar",
        ex_search = "🔍 Tüm oyunda ara...",
        ex_props = "Özellikler",
        ex_results = "%d sonuç",
        ex_nil = "Nil örnekler",
        ex_select = "Ağaçtan bir örnek seç",
        ex_copy_path = "📋 Yolu kopyala",
        ex_copy_code = "🧾 Kod olarak kopyala",
        ex_tp = "🚀 Işınlan",
        ex_view_src = "📜 Kaynağı gör",
        ex_destroy = "🗑 Yok et",
        ex_clone = "📑 Klonla",
        ex_attrs = "🏷  NİTELİKLER",
        ex_tags = "🔖  ETİKETLER",
        ex_children = "Alt öğeler",
        ex_desc = "Torunlar",
        ex_too_many = "İlk %d satır gösteriliyor — aramayı kullan",
        n_tp_ok = "%s konumuna ışınlanıldı",
        n_tp_fail = "Bu örneğe ışınlanılamıyor",
        n_destroyed = "%s yok edildi (istemci tarafı)",
        n_cloned = "%s klonlandı",
        n_prop_set = "%s = %s",
        n_prop_fail = "%s ayarlanamadı: %s",
        sc_scan = "🔍 Scriptleri tara",
        sc_search = "🔎 Scriptleri filtrele...",
        sc_found = "%d script bulundu",
        sc_scanning = "Taranıyor... %d",
        sc_select = "Görüntülemek için bir script seç",
        sc_copy = "📋 Kopyala",
        sc_save = "💾 Kaydet",
        sc_none = "-- Script seçilmedi\n-- 'Scriptleri tara'ya bas ve birini seç",
        sc_fail = "-- Bu script decompile edilemedi\n-- Executor'ın bunu desteklemiyor olabilir\n-- Yol: %s",
        sc_decompiling = "-- Decompile ediliyor...",
        sc_all = "Tümü",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Çalışan",
        sc_lines = "%d satır",
        n_saved = "Kaydedildi → %s",
        n_save_fail = "Kaydetme başarısız: %s",
        n_no_write = "%s writefile desteklemiyor — Kopyala'yı kullan",
        n_nothing = "Henüz kaydedilecek bir şey yok",
        n_folder_fail = "Bu executor'da '%s' klasörü oluşturulamıyor",
        hi_title = "🕘 Oturum geçmişi",
        hi_refresh = "🔄 Yenile",
        hi_current = "🔴 CANLI",
        hi_none = "Kayıtlı oturum yok.",
        hi_nolist = "Executor'ın dosya okuyamıyor — yalnızca mevcut oturum gösteriliyor.",
        hi_calls = "%d çağrı",
        hi_unique = "%d remote",
        hi_search_all = "🔎 Tüm oturumlarda ara...",
        hi_results = "%d eşleşme, %d oturumda",
        hi_export = "💾 .txt olarak dışa aktar",
        hi_deleted = "Oturum silindi",
        hi_showing = "%d / %d kayıt gösteriliyor",
        hi_duration = "%ddk %dsn",
        hi_same_game = "📍 Bu oyun",
        se_lang = "🌐 Dil",
        se_save = "💾 Kayıtları kaydet",
        se_where = "Dosyalar executor'ın workspace klasörüne kaydedilir (PC: <Executor>/workspace — iPhone/Android: Dosyalar uygulamasındaki executor klasörü).",
        se_nowrite = "⛔ Executor'ın dosya yazamıyor (writefile yok). \"Kayıtları kopyala\"yı kullan.",
        se_folder = "📂 Klasör",
        se_last = "Son kayıt: %s",
        se_txt = "📝 Kayıtları kaydet (.txt — okunabilir + R2S kodu)",
        se_json = "🧩 Oturumu kaydet (.json)",
        se_csv = "📊 Oturumu kaydet (.csv — Excel)",
        se_copy = "📋 Kayıtları panoya kopyala (her yerde çalışır)",
        se_autosave = "🔁 Kayıtları klasöre otomatik kaydet",
        se_interval = "⏱ Otomatik kayıt aralığı",
        se_options = "🛠 Seçenekler",
        se_incoming = "📥 Gelen olayları kaydet (sunucu → istemci)",
        se_autoscroll = "⬇ Otomatik kaydırma",
        se_pausecap = "⏸ Yakalamayı duraklat",
        se_size = "📐 Pencere boyutu",
        sz_small = "Küçük",
        sz_medium = "Orta",
        sz_large = "Büyük",
        se_info = "ℹ️ Executor bilgisi",
        i_executor = "Executor",
        i_hooking = "Hook",
        i_incoming = "Gelen",
        i_files = "Dosya sistemi",
        i_clip = "Pano",
        i_platform = "Platform",
        v_avail = "✅ Mevcut",
        v_unavail = "❌ Yok",
        v_safe = "✅ Güvenli (getconnections)",
        v_delayed = "⚠ Gecikmeli (10 sn)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Gelen olaylar kaydediliyor",
        n_inc_off = "Gelen olaylar yoksayılıyor",
        n_paused = "Yakalama duraklatıldı",
        n_resumed = "Yakalama devam ediyor",
        n_autosave_on = "Her %d sn otomatik kayıt → %s",
        n_autosave_off = "Otomatik kayıt kapalı",
        n_lang = "Dil: %s",
        credits = "Rival960 tarafından — Claude'un yardımıyla yapıldı",
        tab_errors = "Hatalar",
        ok = "Tamam",
        cancel = "İptal",
        off = "Kapalı",
        status_events = "%d olay",
        status_flood = "%d atlandı (flood)",
        status_errors = "%d hata",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ İzlenenler",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ İzle",
        unwatch = "☆ İzlemeyi bırak",
        st_watched = "⭐ İzleniyor",
        dir_local = "🔁 İstemci ↔ İstemci (yerel)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (sunucu istemciye soruyor)",
        code_clientinvoke_note = "-- Sunucu bu RemoteFunction'ın OnClientInvoke'unu şu argümanlarla çağırdı:",
        k_grouped = "Gruplandı",
        grouped_fmt = "Art arda %d aynı çağrı",
        k_flood = "Flood",
        flood_fmt = "Hemen önce %d çağrı atlandı (anti-flood)",
        skipped_prefix = "(+%d atlandı)",
        sec_stats = "📈  BU REMOTE'UN İSTATİSTİKLERİ",
        k_total = "Toplam çağrı",
        k_rate = "Sıklık",
        rate_fmt = "dakikada %.1f çağrı",
        k_first_last = "İlk → son",
        k_callers = "Çağıranlar",
        diff_hint = "önceki çağrıya göre değişenler sarı",
        diff_was = "önce: %s",
        sec_return = "↩  SUNUCUNUN DÖNDÜRDÜĞÜ",
        ret_nothing = "(hiçbir şey döndürülmedi)",
        ret_waiting = "Sunucunun yanıtı bekleniyor…",
        ret_disabled = "Ayarlar'da \"InvokeServer dönüş değerlerini yakala\"yı aç",
        n_alert = "🔔 Uyarı: %s (anahtar kelime \"%s\")",
        n_saved_game = "bu oyun için kaydedildi",
        n_watch_on = "⭐ %s izleme listesine eklendi",
        n_watch_off = "%s izleme listesinden çıkarıldı",
        empty_feed = "Henüz olay yok — biraz oyna, her remote çağrısı burada görünecek.",
        empty_filter = "Bu filtreye uyan bir şey yok.",
        empty_network = "Henüz trafik kaydedilmedi.",
        empty_scripts = "Oyunun istemci scriptlerini listelemek için \"Scriptleri tara\"ya bas.",
        empty_errors = "Hata yok — her şey çalışıyor.",
        net_click_hint = "spy'ı filtrelemek için bir satıra tıkla",
        err_copy = "📋 Hepsini kopyala",
        err_clear = "🧹 Temizle",
        err_count = "%d hata",
        c_errors = "Hatalar",
        hi_export_script = "🧾 Script olarak dışa aktar",
        se_capture = "📡 Yakalama",
        se_returns = "↩ InvokeServer dönüş değerlerini yakala",
        se_returns_note = "Sunucunun yanıtını gösterir. Oyun garip davranırsa kapat.",
        se_clientinvoke = "📨 OnClientInvoke yakala (getcallbackvalue gerekir)",
        se_bindables = "🔗 BindableEvent / BindableFunction izle",
        se_group = "🧮 Aynı çağrıları grupla (×N)",
        se_flood = "🌊 Anti-flood (remote başına saniyede en fazla kayıt)",
        se_alerts = "🔔 Uyarılar",
        se_alerts_on = "🔔 Remote adı bir anahtar kelime içerince bildir",
        se_keywords = "Anahtar kelimeler (virgülle ayrılmış)",
        n_keywords_saved = "Anahtar kelimeler kaydedildi",
        se_appearance = "🎨 Görünüm",
        se_accent = "Vurgu rengi",
        c_blue = "Mavi",
        c_purple = "Mor",
        c_green = "Yeşil",
        c_red = "Kırmızı",
        c_orange = "Turuncu",
        se_transparency = "Pencere saydamlığı",
        se_textsize = "Yazı boyutu",
        se_bottomtabs = "📱 Sekme çubuğu altta",
        se_keybind = "⌨ Göster / gizle tuşu: %s (değiştirmek için tıkla)",
        se_keybind_wait = "Bir tuşa bas… (Esc = iptal)",
        n_keybind = "Tuş ayarlandı: %s",
        se_tools = "🧰 Araçlar",
        se_export_script = "🧾 Bu oturumu tekrar oynatma scripti olarak dışa aktar",
        se_whatsnew = "🎉 Yenilikler",
        se_unload = "⏏ RobloxSpy'ı kaldır",
        unload_title = "RobloxSpy kaldırılsın mı?",
        unload_body = "Hook'lar kaldırılır, oturum kaydedilir ve arayüz kapanır. Yeniden başlatmak için scripti tekrar çalıştır.",
        n_returns_on = "Yeni InvokeServer dönüş değerleri yakalanıyor",
        n_option_off = "Seçenek kapatıldı",
        n_need_fn = "%s, %s tarafından desteklenmiyor",
        tip_maximize = "Büyüt / geri yükle",
        tip_minimize = "Küçült",
        tip_close = "Gizle (yuvarlak düğme geri getirir)",
        tip_reopen = "RobloxSpy'ı aç (taşımak için sürükle)",
        tip_copy_r2s = "R2S kodunu kopyala",
        tip_ignore = "Bu remote'u yoksay (gönderilir, kaydedilmez)",
        tip_delete = "Bu satırı sil",
        tip_pause = "Yakalamayı duraklat / devam ettir",
        tip_clear = "Akışı temizle",
        tip_expand = "Pencereyi büyüt",
        tip_refire = "Bu çağrıyı tekrar gönder",
        tip_watch = "İzleme listesine ekle (bu oyun için kaydedilir)",
        tip_drop = "Engelle: çağrı sunucuya hiç ulaşmaz",
        rn_title = "🎉 v%s yenilikleri",
        rn_1 = "Scripti tekrar çalıştırmak eski örneği değiştirir; yeni \"Kaldır\" düğmesi her şeyi temizce kaldırır.",
        rn_2 = "Anti-flood ve gruplama: aynı çağrılar tek satırda \"×N\" olarak birleşir.",
        rn_3 = "InvokeServer dönüşleri, OnClientInvoke ve Bindables yakalanabilir (Ayarlar → Yakalama).",
        rn_4 = "Remote başına istatistikler, önceki çağrıyla farkların vurgulanması, anahtar kelime uyarıları.",
        rn_5 = "İzleme listesi ve yoksay / engelle listeleri oyun başına kaydedilir.",
        rn_6 = "Bütün bir oturumu tekrar oynatılabilir script olarak dışa aktar (Ayarlar → Araçlar veya Geçmiş).",
        rn_7 = "Yeni çizilmiş simgeler, okunmamış sayaçlı açma düğmesi, PC tuşu (RightShift).",
        rn_8 = "Mobil: sekmeler altta, daha büyük satırlar ve düğmeler. Her yerde ipuçları (mobilde uzun bas).",
        rn_9 = "Vurgu renkleri, saydamlık ve yazı boyutu Ayarlar → Görünüm'de.",
        rn_10 = "Yeni Hatalar sekmesi, daha hızlı gezgin, daha hafif otomatik kayıt — ve birçok hata düzeltmesi.",
        as_live = "Canlı (2 sn'de bir)",
    }

    LANG.KO = {
        lang_name = "한국어",
        lang_flag = "🇰🇷",
        tab_spy = "리모트 스파이",
        tab_explorer = "탐색기",
        tab_network = "네트워크",
        tab_scripts = "스크립트",
        tab_history = "기록",
        tab_settings = "설정",
        status_ready = "준비됨",
        status_recording = "● 기록 중 — %s · 후크: %s",
        pause = "⏸ 일시정지",
        resume = "▶ 재개",
        clear = "🧹 지우기",
        f_all = "◉ 전체",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 수신",
        f_blocked = "⛔ 차단됨",
        search_spy = "🔎 리모트, 인수, 경로 필터...",
        feed_cleared = "피드를 비웠습니다",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "수신",
        lbl_blocked = "차단",
        lbl_return = "반환",
        back = "← 뒤로",
        copy_code = "📋 코드 복사",
        copy_path = "🧭 경로 복사",
        copy_args = "📦 인수 복사",
        refire = "🔁 다시 보내기",
        ignore = "🔇 무시",
        unignore = "🔊 무시 해제",
        drop = "⛔ 호출 차단",
        undrop = "✅ 호출 허용",
        delete = "🗑 삭제",
        sec_info = "ℹ️  정보",
        sec_args = "📦  인수 (%d)",
        sec_r2s = "🧾  R2S 코드 (Remote → Script)",
        sec_replay = "🧪  재생 코드",
        k_remote = "리모트",
        k_class = "클래스",
        k_method = "메서드",
        k_direction = "방향",
        k_path = "경로",
        k_caller = "호출자",
        k_call = "호출 번호",
        k_time = "시간",
        k_status = "상태",
        dir_out = "📤 클라이언트 → 서버",
        dir_in = "📥 서버 → 클라이언트",
        caller_unknown = "(알 수 없음 / 익스큐터)",
        time_fmt = "시작 후 +%.3fs",
        st_logged = "기록됨",
        st_dropped = "⛔ 호출 차단됨",
        st_ignored = "🔇 무시됨",
        no_args = "(인수 없음)",
        n_refire_only_out = "보내는 호출만 다시 보낼 수 있습니다",
        n_refired = "%s 다시 보냄",
        n_refire_fail = "다시 보내기 실패: %s",
        n_log_resumed = "%s 기록 재개",
        n_ignored = "%s 무시 — 더 이상 기록 안 함",
        n_cant_block_in = "수신 이벤트는 클라이언트에서 차단할 수 없습니다",
        n_allowed = "%s 호출이 다시 허용됨",
        n_blocked = "%s 호출이 이제 차단됨",
        n_copied = "%s 클립보드에 복사됨",
        n_no_clip = "이 익스큐터에서는 클립보드를 쓸 수 없습니다",
        n_copy_fail = "복사 실패: %s",
        n_action_fail = "작업 실패: %s",
        c_code = "코드",
        c_path = "경로",
        c_args = "인수",
        c_r2s = "R2S 코드",
        c_logs = "로그",
        c_source = "소스",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- 생성: %s",
        code_incoming = "-- RobloxSpy — 수신 이벤트 (서버 → 클라이언트)",
        code_replay = "-- firesignal로 로컬에서 재생 (익스큐터가 지원하는 경우):",
        log_export_title = "RobloxSpy — 로그 내보내기",
        net_total = "총 호출",
        net_cps = "호출/초",
        net_unique = "고유",
        net_blocked = "차단",
        net_traffic = "트래픽 (호출/초, 최근 60초)",
        net_top = "🏆 상위 리모트 (호출 수)",
        ex_search = "🔍 게임 전체 검색...",
        ex_props = "속성",
        ex_results = "결과 %d개",
        ex_nil = "Nil 인스턴스",
        ex_select = "트리에서 인스턴스를 선택하세요",
        ex_copy_path = "📋 경로 복사",
        ex_copy_code = "🧾 코드로 복사",
        ex_tp = "🚀 텔레포트",
        ex_view_src = "📜 소스 보기",
        ex_destroy = "🗑 파괴",
        ex_clone = "📑 복제",
        ex_attrs = "🏷  특성",
        ex_tags = "🔖  태그",
        ex_children = "자식",
        ex_desc = "하위 항목",
        ex_too_many = "처음 %d줄만 표시 — 검색을 사용하세요",
        n_tp_ok = "%s(으)로 텔레포트",
        n_tp_fail = "이 인스턴스로 텔레포트할 수 없습니다",
        n_destroyed = "%s 파괴됨 (클라이언트)",
        n_cloned = "%s 복제됨",
        n_prop_set = "%s = %s",
        n_prop_fail = "%s 설정 불가: %s",
        sc_scan = "🔍 스크립트 스캔",
        sc_search = "🔎 스크립트 필터...",
        sc_found = "스크립트 %d개 발견",
        sc_scanning = "스캔 중... %d",
        sc_select = "볼 스크립트를 선택하세요",
        sc_copy = "📋 복사",
        sc_save = "💾 저장",
        sc_none = "-- 선택된 스크립트 없음\n-- '스크립트 스캔'을 누르고 하나를 고르세요",
        sc_fail = "-- 이 스크립트를 디컴파일할 수 없습니다\n-- 익스큐터가 디컴파일을 지원하지 않을 수 있습니다\n-- 경로: %s",
        sc_decompiling = "-- 디컴파일 중...",
        sc_all = "전체",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "실행 중",
        sc_lines = "%d줄",
        n_saved = "저장됨 → %s",
        n_save_fail = "저장 실패: %s",
        n_no_write = "%s은(는) writefile을 지원하지 않습니다 — 복사를 사용하세요",
        n_nothing = "아직 저장할 내용이 없습니다",
        n_folder_fail = "이 익스큐터에서 '%s' 폴더를 만들 수 없습니다",
        hi_title = "🕘 세션 기록",
        hi_refresh = "🔄 새로고침",
        hi_current = "🔴 실시간",
        hi_none = "저장된 세션이 없습니다.",
        hi_nolist = "익스큐터가 파일을 읽을 수 없습니다 — 현재 세션만 표시됩니다.",
        hi_calls = "호출 %d회",
        hi_unique = "리모트 %d개",
        hi_search_all = "🔎 모든 세션에서 검색...",
        hi_results = "%d건 일치 (세션 %d개)",
        hi_export = "💾 .txt로 내보내기",
        hi_deleted = "세션 삭제됨",
        hi_showing = "%d / %d개 항목 표시",
        hi_duration = "%d분 %d초",
        hi_same_game = "📍 이 게임",
        se_lang = "🌐 언어",
        se_save = "💾 로그 저장",
        se_where = "파일은 익스큐터의 workspace 폴더에 저장됩니다 (PC: <Executor>/workspace — iPhone/Android: 파일 앱의 익스큐터 폴더).",
        se_nowrite = "⛔ 익스큐터가 파일을 쓸 수 없습니다 (writefile 없음). \"로그 복사\"를 사용하세요.",
        se_folder = "📂 폴더",
        se_last = "마지막 저장: %s",
        se_txt = "📝 로그 저장 (.txt — 읽기 쉬움 + R2S 코드)",
        se_json = "🧩 세션 저장 (.json)",
        se_csv = "📊 세션 저장 (.csv — Excel)",
        se_copy = "📋 로그를 클립보드에 복사 (어디서나 작동)",
        se_autosave = "🔁 폴더에 로그 자동 저장",
        se_interval = "⏱ 자동 저장 간격",
        se_options = "🛠 옵션",
        se_incoming = "📥 수신 이벤트 기록 (서버 → 클라이언트)",
        se_autoscroll = "⬇ 자동 스크롤",
        se_pausecap = "⏸ 캡처 일시정지",
        se_size = "📐 창 크기",
        sz_small = "작게",
        sz_medium = "보통",
        sz_large = "크게",
        se_info = "ℹ️ 익스큐터 정보",
        i_executor = "익스큐터",
        i_hooking = "후킹",
        i_incoming = "수신",
        i_files = "파일 시스템",
        i_clip = "클립보드",
        i_platform = "플랫폼",
        v_avail = "✅ 사용 가능",
        v_unavail = "❌ 사용 불가",
        v_safe = "✅ 안전 (getconnections)",
        v_delayed = "⚠ 지연 (10초)",
        v_mobile = "📱 모바일",
        v_pc = "💻 PC",
        n_inc_on = "수신 이벤트를 기록합니다",
        n_inc_off = "수신 이벤트를 무시합니다",
        n_paused = "캡처 일시정지됨",
        n_resumed = "캡처 재개됨",
        n_autosave_on = "%d초마다 자동 저장 → %s",
        n_autosave_off = "자동 저장 꺼짐",
        n_lang = "언어: %s",
        credits = "제작 Rival960 — Claude의 도움으로 제작",
        tab_errors = "오류",
        ok = "확인",
        cancel = "취소",
        off = "끔",
        status_events = "이벤트 %d개",
        status_flood = "%d개 건너뜀 (플러드)",
        status_errors = "오류 %d개",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ 관심 목록",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ 관심 등록",
        unwatch = "☆ 관심 해제",
        st_watched = "⭐ 관심 등록됨",
        dir_local = "🔁 클라이언트 ↔ 클라이언트 (로컬)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (서버가 클라이언트에 요청)",
        code_clientinvoke_note = "-- 서버가 이 RemoteFunction의 OnClientInvoke를 다음 인수로 호출했습니다:",
        k_grouped = "묶음",
        grouped_fmt = "같은 호출 %d번 연속",
        k_flood = "플러드",
        flood_fmt = "바로 전에 %d번 호출을 건너뜀 (안티 플러드)",
        skipped_prefix = "(+%d개 건너뜀)",
        sec_stats = "📈  이 리모트의 통계",
        k_total = "총 호출",
        k_rate = "빈도",
        rate_fmt = "분당 %.1f번",
        k_first_last = "처음 → 마지막",
        k_callers = "호출자",
        diff_hint = "이전 호출과 달라진 값은 노란색",
        diff_was = "이전: %s",
        sec_return = "↩  서버가 반환한 값",
        ret_nothing = "(반환값 없음)",
        ret_waiting = "서버 응답을 기다리는 중…",
        ret_disabled = "설정에서 \"InvokeServer 반환값 캡처\"를 켜세요",
        n_alert = "🔔 알림: %s (키워드 \"%s\")",
        n_saved_game = "이 게임에 저장됨",
        n_watch_on = "⭐ %s을(를) 관심 목록에 추가",
        n_watch_off = "%s을(를) 관심 목록에서 제거",
        empty_feed = "아직 이벤트가 없습니다 — 조금 플레이하면 모든 리모트 호출이 여기에 표시됩니다.",
        empty_filter = "이 필터에 맞는 항목이 없습니다.",
        empty_network = "아직 기록된 트래픽이 없습니다.",
        empty_scripts = "\"스크립트 스캔\"을 눌러 게임의 클라이언트 스크립트를 나열하세요.",
        empty_errors = "오류 없음 — 모두 정상입니다.",
        net_click_hint = "행을 누르면 스파이를 필터링합니다",
        err_copy = "📋 모두 복사",
        err_clear = "🧹 지우기",
        err_count = "오류 %d개",
        c_errors = "오류",
        hi_export_script = "🧾 스크립트로 내보내기",
        se_capture = "📡 캡처",
        se_returns = "↩ InvokeServer 반환값 캡처",
        se_returns_note = "서버의 응답을 보여줍니다. 게임이 이상하게 동작하면 끄세요.",
        se_clientinvoke = "📨 OnClientInvoke 캡처 (getcallbackvalue 필요)",
        se_bindables = "🔗 BindableEvent / BindableFunction 감시",
        se_group = "🧮 같은 호출 묶기 (×N)",
        se_flood = "🌊 안티 플러드 (리모트당 초당 최대 기록 수)",
        se_alerts = "🔔 알림",
        se_alerts_on = "🔔 리모트 이름에 키워드가 있으면 알림",
        se_keywords = "키워드 (쉼표로 구분)",
        n_keywords_saved = "키워드 저장됨",
        se_appearance = "🎨 모양",
        se_accent = "강조 색상",
        c_blue = "파랑",
        c_purple = "보라",
        c_green = "초록",
        c_red = "빨강",
        c_orange = "주황",
        se_transparency = "창 투명도",
        se_textsize = "글자 크기",
        se_bottomtabs = "📱 탭 바를 아래에",
        se_keybind = "⌨ 표시 / 숨기기 키: %s (눌러서 변경)",
        se_keybind_wait = "키를 누르세요… (Esc = 취소)",
        n_keybind = "키 설정됨: %s",
        se_tools = "🧰 도구",
        se_export_script = "🧾 이 세션을 재생 스크립트로 내보내기",
        se_whatsnew = "🎉 새로운 기능",
        se_unload = "⏏ RobloxSpy 언로드",
        unload_title = "RobloxSpy를 언로드할까요?",
        unload_body = "후크가 제거되고 세션이 저장되며 인터페이스가 닫힙니다. 다시 시작하려면 스크립트를 다시 실행하세요.",
        n_returns_on = "새 InvokeServer의 반환값을 캡처합니다",
        n_option_off = "옵션 꺼짐",
        n_need_fn = "%s은(는) %s에서 지원되지 않습니다",
        tip_maximize = "최대화 / 복원",
        tip_minimize = "최소화",
        tip_close = "숨기기 (둥근 버튼으로 다시 열기)",
        tip_reopen = "RobloxSpy 열기 (드래그로 이동)",
        tip_copy_r2s = "R2S 코드 복사",
        tip_ignore = "이 리모트 무시 (전송은 되지만 기록 안 함)",
        tip_delete = "이 행 삭제",
        tip_pause = "캡처 일시정지 / 재개",
        tip_clear = "피드 지우기",
        tip_expand = "창 크게 보기",
        tip_refire = "이 호출 다시 보내기",
        tip_watch = "관심 목록에 추가 (이 게임에 저장)",
        tip_drop = "차단: 호출이 서버에 절대 도달하지 않음",
        rn_title = "🎉 v%s 새로운 기능",
        rn_1 = "스크립트를 다시 실행하면 이전 인스턴스를 대체하고, 새 \"언로드\" 버튼으로 모두 깔끔하게 제거합니다.",
        rn_2 = "안티 플러드와 묶기: 같은 호출은 \"×N\" 한 줄로 합쳐집니다.",
        rn_3 = "InvokeServer 반환값, OnClientInvoke, Bindables를 캡처할 수 있습니다 (설정 → 캡처).",
        rn_4 = "리모트별 통계, 이전 호출과의 차이 강조, 키워드 알림.",
        rn_5 = "관심 목록과 무시 / 차단 목록은 게임별로 저장됩니다.",
        rn_6 = "세션 전체를 재생 가능한 스크립트로 내보내기 (설정 → 도구 또는 기록).",
        rn_7 = "새로 그린 아이콘, 읽지 않은 수가 표시되는 열기 버튼, PC 키 (RightShift).",
        rn_8 = "모바일: 아래쪽 탭 바, 더 큰 행과 버튼. 어디서나 도움말 (모바일은 길게 누르기).",
        rn_9 = "강조 색상, 투명도, 글자 크기는 설정 → 모양에서 바꿀 수 있습니다.",
        rn_10 = "새 오류 탭, 더 빠른 탐색기, 가벼워진 자동 저장 — 그리고 여러 버그 수정.",
        as_live = "실시간 (2초마다)",
    }

    LANG.AR = {
        lang_name = "العربية",
        lang_flag = "🇸🇦",
        tab_spy = "مراقب الريموت",
        tab_explorer = "المستكشف",
        tab_network = "الشبكة",
        tab_scripts = "السكربتات",
        tab_history = "السجل",
        tab_settings = "الإعدادات",
        status_ready = "جاهز",
        status_recording = "● جارٍ التسجيل — %s · الخطاف: %s",
        pause = "⏸ إيقاف مؤقت",
        resume = "▶ استئناف",
        clear = "🧹 مسح",
        f_all = "◉ الكل",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 الواردة",
        f_blocked = "⛔ المحظورة",
        search_spy = "🔎 تصفية الريموت، الوسائط، المسارات...",
        feed_cleared = "تم مسح القائمة",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "وارد",
        lbl_blocked = "محظور",
        lbl_return = "إرجاع",
        back = "← رجوع",
        copy_code = "📋 نسخ الكود",
        copy_path = "🧭 نسخ المسار",
        copy_args = "📦 نسخ الوسائط",
        refire = "🔁 إعادة الإرسال",
        ignore = "🔇 تجاهل",
        unignore = "🔊 إلغاء التجاهل",
        drop = "⛔ حظر الاستدعاءات",
        undrop = "✅ السماح بالاستدعاءات",
        delete = "🗑 حذف",
        sec_info = "ℹ️  معلومات",
        sec_args = "📦  الوسائط (%d)",
        sec_r2s = "🧾  كود R2S (Remote → Script)",
        sec_replay = "🧪  كود الإعادة",
        k_remote = "الريموت",
        k_class = "الفئة",
        k_method = "الطريقة",
        k_direction = "الاتجاه",
        k_path = "المسار",
        k_caller = "المستدعي",
        k_call = "رقم الاستدعاء",
        k_time = "الوقت",
        k_status = "الحالة",
        dir_out = "📤 العميل → الخادم",
        dir_in = "📥 الخادم → العميل",
        caller_unknown = "(غير معروف / المنفّذ)",
        time_fmt = "+%.3fs بعد البدء",
        st_logged = "مُسجَّل",
        st_dropped = "⛔ الاستدعاءات محظورة",
        st_ignored = "🔇 متجاهَل",
        no_args = "(بدون وسائط)",
        n_refire_only_out = "يمكن إعادة إرسال الاستدعاءات الصادرة فقط",
        n_refired = "تمت إعادة إرسال %s",
        n_refire_fail = "فشلت إعادة الإرسال: %s",
        n_log_resumed = "استُؤنف تسجيل %s",
        n_ignored = "تم تجاهل %s — لا مزيد من السجلات",
        n_cant_block_in = "لا يمكن حظر الأحداث الواردة من جهة العميل",
        n_allowed = "عاد السماح باستدعاءات %s",
        n_blocked = "استدعاءات %s محظورة الآن",
        n_copied = "تم نسخ %s إلى الحافظة",
        n_no_clip = "الحافظة غير متاحة في هذا المنفّذ",
        n_copy_fail = "فشل النسخ: %s",
        n_action_fail = "فشل الإجراء: %s",
        c_code = "الكود",
        c_path = "المسار",
        c_args = "الوسائط",
        c_r2s = "كود R2S",
        c_logs = "السجلات",
        c_source = "المصدر",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- تاريخ الإنشاء: %s",
        code_incoming = "-- RobloxSpy — حدث وارد (الخادم → العميل)",
        code_replay = "-- أعد تشغيله محليًا عبر firesignal (إن كان منفّذك يدعمه):",
        log_export_title = "RobloxSpy — تصدير السجلات",
        net_total = "إجمالي الاستدعاءات",
        net_cps = "استدعاء/ث",
        net_unique = "فريدة",
        net_blocked = "محظورة",
        net_traffic = "حركة المرور (استدعاء/ث، آخر 60 ث)",
        net_top = "🏆 أكثر الريموت استخدامًا",
        ex_search = "🔍 البحث في اللعبة كاملة...",
        ex_props = "الخصائص",
        ex_results = "%d نتيجة",
        ex_nil = "كائنات nil",
        ex_select = "اختر كائنًا من الشجرة",
        ex_copy_path = "📋 نسخ المسار",
        ex_copy_code = "🧾 نسخ ككود",
        ex_tp = "🚀 انتقال",
        ex_view_src = "📜 عرض المصدر",
        ex_destroy = "🗑 تدمير",
        ex_clone = "📑 استنساخ",
        ex_attrs = "🏷  السمات",
        ex_tags = "🔖  الوسوم",
        ex_children = "الأبناء",
        ex_desc = "الأحفاد",
        ex_too_many = "عرض أول %d صف فقط — استخدم البحث",
        n_tp_ok = "تم الانتقال إلى %s",
        n_tp_fail = "لا يمكن الانتقال إلى هذا الكائن",
        n_destroyed = "تم تدمير %s (من جهة العميل)",
        n_cloned = "تم استنساخ %s",
        n_prop_set = "%s = %s",
        n_prop_fail = "تعذّر تعيين %s: %s",
        sc_scan = "🔍 فحص السكربتات",
        sc_search = "🔎 تصفية السكربتات...",
        sc_found = "تم العثور على %d سكربت",
        sc_scanning = "جارٍ الفحص... %d",
        sc_select = "اختر سكربتًا لعرضه",
        sc_copy = "📋 نسخ",
        sc_save = "💾 حفظ",
        sc_none = "-- لم يتم اختيار سكربت\n-- اضغط 'فحص السكربتات' ثم اختر واحدًا",
        sc_fail = "-- تعذّر فك ترجمة هذا السكربت\n-- قد لا يدعم منفّذك فك الترجمة\n-- المسار: %s",
        sc_decompiling = "-- جارٍ فك الترجمة...",
        sc_all = "الكل",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "قيد التشغيل",
        sc_lines = "%d سطر",
        n_saved = "تم الحفظ → %s",
        n_save_fail = "فشل الحفظ: %s",
        n_no_write = "%s لا يدعم writefile — استخدم النسخ",
        n_nothing = "لا يوجد ما يُحفظ بعد",
        n_folder_fail = "تعذّر إنشاء المجلد '%s' في هذا المنفّذ",
        hi_title = "🕘 سجل الجلسات",
        hi_refresh = "🔄 تحديث",
        hi_current = "🔴 مباشر",
        hi_none = "لا توجد جلسات محفوظة.",
        hi_nolist = "منفّذك لا يستطيع قراءة الملفات — تُعرض الجلسة الحالية فقط.",
        hi_calls = "%d استدعاء",
        hi_unique = "%d ريموت",
        hi_search_all = "🔎 البحث في كل الجلسات...",
        hi_results = "%d نتيجة في %d جلسة",
        hi_export = "💾 تصدير .txt",
        hi_deleted = "تم حذف الجلسة",
        hi_showing = "عرض %d من %d إدخال",
        hi_duration = "%dد %dث",
        hi_same_game = "📍 هذه اللعبة",
        se_lang = "🌐 اللغة",
        se_save = "💾 حفظ السجلات",
        se_where = "تُحفظ الملفات في مجلد workspace الخاص بالمنفّذ (الحاسوب: <Executor>/workspace — iPhone/Android: مجلد المنفّذ في تطبيق الملفات).",
        se_nowrite = "⛔ منفّذك لا يستطيع كتابة الملفات (writefile غير موجود). استخدم \"نسخ السجلات\".",
        se_folder = "📂 المجلد",
        se_last = "آخر حفظ: %s",
        se_txt = "📝 حفظ السجلات (.txt — مقروء + كود R2S)",
        se_json = "🧩 حفظ الجلسة (.json)",
        se_csv = "📊 حفظ الجلسة (.csv — Excel)",
        se_copy = "📋 نسخ السجلات إلى الحافظة (يعمل في كل مكان)",
        se_autosave = "🔁 حفظ تلقائي للسجلات في المجلد",
        se_interval = "⏱ فاصل الحفظ التلقائي",
        se_options = "🛠 خيارات",
        se_incoming = "📥 تسجيل الأحداث الواردة (الخادم → العميل)",
        se_autoscroll = "⬇ تمرير تلقائي",
        se_pausecap = "⏸ إيقاف الالتقاط مؤقتًا",
        se_size = "📐 حجم النافذة",
        sz_small = "صغير",
        sz_medium = "متوسط",
        sz_large = "كبير",
        se_info = "ℹ️ معلومات المنفّذ",
        i_executor = "المنفّذ",
        i_hooking = "الخطاف",
        i_incoming = "الواردة",
        i_files = "نظام الملفات",
        i_clip = "الحافظة",
        i_platform = "المنصة",
        v_avail = "✅ متاح",
        v_unavail = "❌ غير متاح",
        v_safe = "✅ آمن (getconnections)",
        v_delayed = "⚠ مؤجَّل (10 ث)",
        v_mobile = "📱 جوال",
        v_pc = "💻 حاسوب",
        n_inc_on = "يتم تسجيل الأحداث الواردة",
        n_inc_off = "يتم تجاهل الأحداث الواردة",
        n_paused = "تم إيقاف الالتقاط مؤقتًا",
        n_resumed = "تم استئناف الالتقاط",
        n_autosave_on = "حفظ تلقائي كل %d ث → %s",
        n_autosave_off = "الحفظ التلقائي متوقف",
        n_lang = "اللغة: %s",
        credits = "بواسطة Rival960 — صُنع بمساعدة Claude",
        tab_errors = "الأخطاء",
        ok = "موافق",
        cancel = "إلغاء",
        off = "إيقاف",
        status_events = "%d حدث",
        status_flood = "تم تخطي %d (إغراق)",
        status_errors = "%d خطأ",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ المراقَبة",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ مراقبة",
        unwatch = "☆ إلغاء المراقبة",
        st_watched = "⭐ مراقَب",
        dir_local = "🔁 عميل ↔ عميل (محلي)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (الخادم يسأل العميل)",
        code_clientinvoke_note = "-- استدعى الخادم OnClientInvoke لهذه RemoteFunction مع:",
        k_grouped = "مجمّع",
        grouped_fmt = "%d استدعاءات متطابقة متتالية",
        k_flood = "إغراق",
        flood_fmt = "تم تخطي %d استدعاء قبل ذلك مباشرة (مضاد الإغراق)",
        skipped_prefix = "(+%d متخطى)",
        sec_stats = "📈  إحصائيات هذا الريموت",
        k_total = "إجمالي الاستدعاءات",
        k_rate = "المعدّل",
        rate_fmt = "%.1f استدعاء / دقيقة",
        k_first_last = "الأول → الأخير",
        k_callers = "المستدعون",
        diff_hint = "التغييرات مقارنة بالاستدعاء السابق باللون الأصفر",
        diff_was = "سابقًا: %s",
        sec_return = "↩  ما أعاده الخادم",
        ret_nothing = "(لم يُعد شيئًا)",
        ret_waiting = "بانتظار رد الخادم…",
        ret_disabled = "فعّل \"التقاط قيم إرجاع InvokeServer\" في الإعدادات",
        n_alert = "🔔 تنبيه: %s (الكلمة المفتاحية \"%s\")",
        n_saved_game = "حُفظ لهذه اللعبة",
        n_watch_on = "⭐ أُضيف %s إلى قائمة المراقبة",
        n_watch_off = "أُزيل %s من قائمة المراقبة",
        empty_feed = "لا توجد أحداث بعد — العب قليلًا، وسيظهر هنا كل استدعاء ريموت.",
        empty_filter = "لا شيء يطابق هذا الفلتر.",
        empty_network = "لم تُسجَّل أي حركة بعد.",
        empty_scripts = "اضغط \"فحص السكربتات\" لعرض سكربتات العميل في اللعبة.",
        empty_errors = "لا أخطاء — كل شيء يعمل.",
        net_click_hint = "اضغط على صف لتصفية المراقب",
        err_copy = "📋 نسخ الكل",
        err_clear = "🧹 مسح",
        err_count = "%d خطأ",
        c_errors = "الأخطاء",
        hi_export_script = "🧾 تصدير كسكربت",
        se_capture = "📡 الالتقاط",
        se_returns = "↩ التقاط قيم إرجاع InvokeServer",
        se_returns_note = "يعرض ما يرد به الخادم. أوقفه إذا تصرفت اللعبة بشكل غريب.",
        se_clientinvoke = "📨 التقاط OnClientInvoke (يتطلب getcallbackvalue)",
        se_bindables = "🔗 مراقبة BindableEvent / BindableFunction",
        se_group = "🧮 تجميع الاستدعاءات المتطابقة (×N)",
        se_flood = "🌊 مضاد الإغراق (أقصى عدد استدعاءات مسجّلة لكل ريموت في الثانية)",
        se_alerts = "🔔 التنبيهات",
        se_alerts_on = "🔔 التنبيه عندما يحتوي اسم الريموت على كلمة مفتاحية",
        se_keywords = "الكلمات المفتاحية (مفصولة بفواصل)",
        n_keywords_saved = "تم حفظ الكلمات المفتاحية",
        se_appearance = "🎨 المظهر",
        se_accent = "لون التمييز",
        c_blue = "أزرق",
        c_purple = "بنفسجي",
        c_green = "أخضر",
        c_red = "أحمر",
        c_orange = "برتقالي",
        se_transparency = "شفافية النافذة",
        se_textsize = "حجم النص",
        se_bottomtabs = "📱 شريط التبويبات في الأسفل",
        se_keybind = "⌨ مفتاح الإظهار / الإخفاء: %s (اضغط للتغيير)",
        se_keybind_wait = "اضغط مفتاحًا… (Esc = إلغاء)",
        n_keybind = "تم تعيين المفتاح: %s",
        se_tools = "🧰 الأدوات",
        se_export_script = "🧾 تصدير هذه الجلسة كسكربت إعادة تشغيل",
        se_whatsnew = "🎉 الجديد",
        se_unload = "⏏ إلغاء تحميل RobloxSpy",
        unload_title = "إلغاء تحميل RobloxSpy؟",
        unload_body = "تُزال الخطافات وتُحفظ الجلسة وتُغلق الواجهة. شغّل السكربت مرة أخرى لإعادة تشغيله.",
        n_returns_on = "تُلتقط قيم إرجاع InvokeServer الجديدة",
        n_option_off = "تم إيقاف الخيار",
        n_need_fn = "%s غير مدعوم في %s",
        tip_maximize = "تكبير / استعادة",
        tip_minimize = "تصغير",
        tip_close = "إخفاء (الزر الدائري يعيدها)",
        tip_reopen = "فتح RobloxSpy (اسحب للتحريك)",
        tip_copy_r2s = "نسخ كود R2S",
        tip_ignore = "تجاهل هذا الريموت (يُرسل لكن لا يُسجَّل)",
        tip_delete = "حذف هذا الصف",
        tip_pause = "إيقاف / استئناف الالتقاط",
        tip_clear = "مسح القائمة",
        tip_expand = "تكبير النافذة",
        tip_refire = "إرسال هذا الاستدعاء مجددًا",
        tip_watch = "إضافة إلى قائمة المراقبة (يُحفظ لهذه اللعبة)",
        tip_drop = "حظر: لن يصل الاستدعاء إلى الخادم أبدًا",
        rn_title = "🎉 الجديد في v%s",
        rn_1 = "تشغيل السكربت مرتين يستبدل النسخة القديمة، وزر \"إلغاء التحميل\" الجديد يزيل كل شيء بنظافة.",
        rn_2 = "مضاد الإغراق والتجميع: الاستدعاءات المتطابقة تُدمج في صف واحد \"×N\".",
        rn_3 = "يمكن التقاط قيم إرجاع InvokeServer وOnClientInvoke وBindables (الإعدادات → الالتقاط).",
        rn_4 = "إحصائيات لكل ريموت، إبراز الفروقات مع الاستدعاء السابق، تنبيهات بالكلمات المفتاحية.",
        rn_5 = "قائمة المراقبة وقوائم التجاهل / الحظر تُحفظ لكل لعبة.",
        rn_6 = "تصدير جلسة كاملة كسكربت قابل لإعادة التشغيل (الإعدادات → الأدوات، أو السجل).",
        rn_7 = "أيقونات مرسومة جديدة، زر فتح مع عدّاد غير المقروء، مفتاح على الحاسوب (RightShift).",
        rn_8 = "الجوال: التبويبات في الأسفل، صفوف وأزرار أكبر. تلميحات في كل مكان (ضغط مطوّل على الجوال).",
        rn_9 = "ألوان التمييز والشفافية وحجم النص في الإعدادات → المظهر.",
        rn_10 = "تبويب أخطاء جديد، مستكشف أسرع، حفظ تلقائي أخف — وإصلاح عدة أخطاء.",
        as_live = "مباشر (كل 2 ث)",
    }

    LANG.VI = {
        lang_name = "Tiếng Việt",
        lang_flag = "🇻🇳",
        tab_spy = "Remote Spy",
        tab_explorer = "Trình duyệt",
        tab_network = "Mạng",
        tab_scripts = "Script",
        tab_history = "Lịch sử",
        tab_settings = "Cài đặt",
        status_ready = "Sẵn sàng",
        status_recording = "● Đang ghi — %s · hook: %s",
        pause = "⏸ Tạm dừng",
        resume = "▶ Tiếp tục",
        clear = "🧹 Xóa",
        f_all = "◉ Tất cả",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Nhận vào",
        f_blocked = "⛔ Đã chặn",
        search_spy = "🔎 Lọc remote, tham số, đường dẫn...",
        feed_cleared = "Đã xóa danh sách",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "NHẬN VÀO",
        lbl_blocked = "ĐÃ CHẶN",
        lbl_return = "TRẢ VỀ",
        back = "← Quay lại",
        copy_code = "📋 Sao chép code",
        copy_path = "🧭 Sao chép đường dẫn",
        copy_args = "📦 Sao chép tham số",
        refire = "🔁 Gửi lại",
        ignore = "🔇 Bỏ qua",
        unignore = "🔊 Hết bỏ qua",
        drop = "⛔ Chặn lệnh gọi",
        undrop = "✅ Cho phép lệnh gọi",
        delete = "🗑 Xóa",
        sec_info = "ℹ️  THÔNG TIN",
        sec_args = "📦  THAM SỐ (%d)",
        sec_r2s = "🧾  CODE R2S (Remote → Script)",
        sec_replay = "🧪  CODE PHÁT LẠI",
        k_remote = "Remote",
        k_class = "Lớp",
        k_method = "Phương thức",
        k_direction = "Hướng",
        k_path = "Đường dẫn",
        k_caller = "Bên gọi",
        k_call = "Lần gọi số",
        k_time = "Thời gian",
        k_status = "Trạng thái",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(không rõ / executor)",
        time_fmt = "+%.3fs sau khi bắt đầu",
        st_logged = "Đã ghi",
        st_dropped = "⛔ Lệnh gọi bị chặn",
        st_ignored = "🔇 Đã bỏ qua",
        no_args = "(không có tham số)",
        n_refire_only_out = "Chỉ gửi lại được lệnh gọi đi",
        n_refired = "Đã gửi lại %s",
        n_refire_fail = "Gửi lại thất bại: %s",
        n_log_resumed = "Tiếp tục ghi cho %s",
        n_ignored = "Đã bỏ qua %s — không ghi nữa",
        n_cant_block_in = "Không thể chặn sự kiện nhận vào từ phía client",
        n_allowed = "Đã cho phép lại lệnh gọi tới %s",
        n_blocked = "Lệnh gọi tới %s hiện ĐÃ BỊ CHẶN",
        n_copied = "Đã sao chép %s vào bộ nhớ tạm",
        n_no_clip = "Executor này không có bộ nhớ tạm",
        n_copy_fail = "Sao chép thất bại: %s",
        n_action_fail = "Thao tác thất bại: %s",
        c_code = "Code",
        c_path = "Đường dẫn",
        c_args = "Tham số",
        c_r2s = "Code R2S",
        c_logs = "Nhật ký",
        c_source = "Mã nguồn",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Tạo lúc: %s",
        code_incoming = "-- RobloxSpy — Sự kiện nhận vào (server → client)",
        code_replay = "-- Phát lại cục bộ bằng firesignal (nếu executor có hỗ trợ):",
        log_export_title = "RobloxSpy — Xuất nhật ký",
        net_total = "TỔNG LỆNH GỌI",
        net_cps = "LỆNH GỌI/GIÂY",
        net_unique = "DUY NHẤT",
        net_blocked = "ĐÃ CHẶN",
        net_traffic = "Lưu lượng (lệnh gọi/giây, 60 giây gần nhất)",
        net_top = "🏆 Remote hàng đầu (theo số lần gọi)",
        ex_search = "🔍 Tìm trong toàn bộ game...",
        ex_props = "Thuộc tính",
        ex_results = "%d kết quả",
        ex_nil = "Instance nil",
        ex_select = "Chọn một instance trong cây",
        ex_copy_path = "📋 Sao chép đường dẫn",
        ex_copy_code = "🧾 Sao chép dạng code",
        ex_tp = "🚀 Dịch chuyển",
        ex_view_src = "📜 Xem mã nguồn",
        ex_destroy = "🗑 Hủy",
        ex_clone = "📑 Nhân bản",
        ex_attrs = "🏷  THUỘC TÍNH RIÊNG",
        ex_tags = "🔖  THẺ",
        ex_children = "Con",
        ex_desc = "Hậu duệ",
        ex_too_many = "Chỉ hiện %d dòng đầu — hãy dùng tìm kiếm",
        n_tp_ok = "Đã dịch chuyển tới %s",
        n_tp_fail = "Không thể dịch chuyển tới instance này",
        n_destroyed = "Đã hủy %s (phía client)",
        n_cloned = "Đã nhân bản %s",
        n_prop_set = "%s = %s",
        n_prop_fail = "Không thể đặt %s: %s",
        sc_scan = "🔍 Quét script",
        sc_search = "🔎 Lọc script...",
        sc_found = "Tìm thấy %d script",
        sc_scanning = "Đang quét... %d",
        sc_select = "Chọn một script để xem",
        sc_copy = "📋 Sao chép",
        sc_save = "💾 Lưu",
        sc_none = "-- Chưa chọn script\n-- Bấm 'Quét script' rồi chọn một cái",
        sc_fail = "-- Không thể dịch ngược script này\n-- Executor của bạn có thể không hỗ trợ\n-- Đường dẫn: %s",
        sc_decompiling = "-- Đang dịch ngược...",
        sc_all = "Tất cả",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Đang chạy",
        sc_lines = "%d dòng",
        n_saved = "Đã lưu → %s",
        n_save_fail = "Lưu thất bại: %s",
        n_no_write = "%s không hỗ trợ writefile — hãy dùng Sao chép",
        n_nothing = "Chưa có gì để lưu",
        n_folder_fail = "Không thể tạo thư mục '%s' trên executor này",
        hi_title = "🕘 Lịch sử phiên",
        hi_refresh = "🔄 Làm mới",
        hi_current = "🔴 TRỰC TIẾP",
        hi_none = "Không có phiên nào được lưu.",
        hi_nolist = "Executor không đọc được tệp — chỉ hiện phiên hiện tại.",
        hi_calls = "%d lệnh gọi",
        hi_unique = "%d remote",
        hi_search_all = "🔎 Tìm trong mọi phiên...",
        hi_results = "%d kết quả trong %d phiên",
        hi_export = "💾 Xuất .txt",
        hi_deleted = "Đã xóa phiên",
        hi_showing = "Hiện %d / %d mục",
        hi_duration = "%dph %dg",
        hi_same_game = "📍 Game này",
        se_lang = "🌐 Ngôn ngữ",
        se_save = "💾 Lưu nhật ký",
        se_where = "Tệp được lưu trong thư mục workspace của executor (PC: <Executor>/workspace — iPhone/Android: thư mục của executor trong ứng dụng Tệp).",
        se_nowrite = "⛔ Executor không ghi được tệp (thiếu writefile). Hãy dùng \"Sao chép nhật ký\".",
        se_folder = "📂 Thư mục",
        se_last = "Lần lưu cuối: %s",
        se_txt = "📝 Lưu nhật ký (.txt — dễ đọc + code R2S)",
        se_json = "🧩 Lưu phiên (.json)",
        se_csv = "📊 Lưu phiên (.csv — Excel)",
        se_copy = "📋 Sao chép nhật ký (dùng được mọi nơi)",
        se_autosave = "🔁 Tự động lưu nhật ký vào thư mục",
        se_interval = "⏱ Khoảng thời gian tự động lưu",
        se_options = "🛠 Tùy chọn",
        se_incoming = "📥 Ghi sự kiện nhận vào (server → client)",
        se_autoscroll = "⬇ Tự động cuộn",
        se_pausecap = "⏸ Tạm dừng ghi",
        se_size = "📐 Kích thước cửa sổ",
        sz_small = "Nhỏ",
        sz_medium = "Vừa",
        sz_large = "Lớn",
        se_info = "ℹ️ Thông tin executor",
        i_executor = "Executor",
        i_hooking = "Hook",
        i_incoming = "Nhận vào",
        i_files = "Hệ thống tệp",
        i_clip = "Bộ nhớ tạm",
        i_platform = "Nền tảng",
        v_avail = "✅ Có sẵn",
        v_unavail = "❌ Không có",
        v_safe = "✅ An toàn (getconnections)",
        v_delayed = "⚠ Trễ (10 giây)",
        v_mobile = "📱 Điện thoại",
        v_pc = "💻 PC",
        n_inc_on = "Đang ghi sự kiện nhận vào",
        n_inc_off = "Bỏ qua sự kiện nhận vào",
        n_paused = "Đã tạm dừng ghi",
        n_resumed = "Đã tiếp tục ghi",
        n_autosave_on = "Tự động lưu mỗi %d giây → %s",
        n_autosave_off = "Tắt tự động lưu",
        n_lang = "Ngôn ngữ: %s",
        credits = "bởi Rival960 — Làm với sự trợ giúp của Claude",
        tab_errors = "Lỗi",
        ok = "OK",
        cancel = "Hủy",
        off = "Tắt",
        status_events = "%d sự kiện",
        status_flood = "%d bị bỏ qua (flood)",
        status_errors = "%d lỗi",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Theo dõi",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Theo dõi",
        unwatch = "☆ Bỏ theo dõi",
        st_watched = "⭐ Đang theo dõi",
        dir_local = "🔁 Client ↔ Client (cục bộ)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (server hỏi client)",
        code_clientinvoke_note = "-- Server đã gọi OnClientInvoke của RemoteFunction này với:",
        k_grouped = "Đã gộp",
        grouped_fmt = "%d lệnh gọi giống nhau liên tiếp",
        k_flood = "Flood",
        flood_fmt = "%d lệnh gọi bị bỏ qua ngay trước đó (chống flood)",
        skipped_prefix = "(+%d bị bỏ qua)",
        sec_stats = "📈  THỐNG KÊ REMOTE NÀY",
        k_total = "Tổng lệnh gọi",
        k_rate = "Tần suất",
        rate_fmt = "%.1f lệnh gọi / phút",
        k_first_last = "Đầu → cuối",
        k_callers = "Bên gọi",
        diff_hint = "thay đổi so với lần gọi trước màu vàng",
        diff_was = "trước: %s",
        sec_return = "↩  SERVER TRẢ VỀ",
        ret_nothing = "(không trả về gì)",
        ret_waiting = "Đang chờ phản hồi của server…",
        ret_disabled = "Bật \"Ghi giá trị trả về của InvokeServer\" trong Cài đặt",
        n_alert = "🔔 Cảnh báo: %s (từ khóa \"%s\")",
        n_saved_game = "đã lưu cho game này",
        n_watch_on = "⭐ Đã thêm %s vào danh sách theo dõi",
        n_watch_off = "Đã gỡ %s khỏi danh sách theo dõi",
        empty_feed = "Chưa có sự kiện — chơi một chút, mọi lệnh gọi remote sẽ hiện ở đây.",
        empty_filter = "Không có gì khớp bộ lọc này.",
        empty_network = "Chưa ghi nhận lưu lượng nào.",
        empty_scripts = "Bấm \"Quét script\" để liệt kê script client của game.",
        empty_errors = "Không có lỗi — mọi thứ đều ổn.",
        net_click_hint = "bấm vào một dòng để lọc spy",
        err_copy = "📋 Sao chép tất cả",
        err_clear = "🧹 Xóa",
        err_count = "%d lỗi",
        c_errors = "Lỗi",
        hi_export_script = "🧾 Xuất thành script",
        se_capture = "📡 Ghi nhận",
        se_returns = "↩ Ghi giá trị trả về của InvokeServer",
        se_returns_note = "Hiển thị server trả lời gì. Tắt nếu game hoạt động lạ.",
        se_clientinvoke = "📨 Ghi OnClientInvoke (cần getcallbackvalue)",
        se_bindables = "🔗 Theo dõi BindableEvent / BindableFunction",
        se_group = "🧮 Gộp các lệnh gọi giống nhau (×N)",
        se_flood = "🌊 Chống flood (tối đa lệnh gọi được ghi mỗi remote mỗi giây)",
        se_alerts = "🔔 Cảnh báo",
        se_alerts_on = "🔔 Báo khi tên remote chứa từ khóa",
        se_keywords = "Từ khóa (cách nhau bởi dấu phẩy)",
        n_keywords_saved = "Đã lưu từ khóa",
        se_appearance = "🎨 Giao diện",
        se_accent = "Màu nhấn",
        c_blue = "Xanh dương",
        c_purple = "Tím",
        c_green = "Xanh lá",
        c_red = "Đỏ",
        c_orange = "Cam",
        se_transparency = "Độ trong suốt cửa sổ",
        se_textsize = "Cỡ chữ",
        se_bottomtabs = "📱 Thanh tab ở dưới",
        se_keybind = "⌨ Phím hiện / ẩn: %s (bấm để đổi)",
        se_keybind_wait = "Nhấn một phím… (Esc = hủy)",
        n_keybind = "Đã đặt phím: %s",
        se_tools = "🧰 Công cụ",
        se_export_script = "🧾 Xuất phiên này thành script phát lại",
        se_whatsnew = "🎉 Có gì mới",
        se_unload = "⏏ Gỡ RobloxSpy",
        unload_title = "Gỡ RobloxSpy?",
        unload_body = "Các hook sẽ bị gỡ, phiên được lưu và giao diện đóng lại. Chạy lại script để khởi động lại.",
        n_returns_on = "Đang ghi giá trị trả về của các InvokeServer mới",
        n_option_off = "Đã tắt tùy chọn",
        n_need_fn = "%s không được %s hỗ trợ",
        tip_maximize = "Phóng to / khôi phục",
        tip_minimize = "Thu nhỏ",
        tip_close = "Ẩn (nút tròn sẽ mở lại)",
        tip_reopen = "Mở RobloxSpy (kéo để di chuyển)",
        tip_copy_r2s = "Sao chép code R2S",
        tip_ignore = "Bỏ qua remote này (vẫn gửi, không ghi)",
        tip_delete = "Xóa dòng này",
        tip_pause = "Tạm dừng / tiếp tục ghi",
        tip_clear = "Xóa danh sách",
        tip_expand = "Phóng to cửa sổ",
        tip_refire = "Gửi lại lệnh gọi này",
        tip_watch = "Thêm vào danh sách theo dõi (lưu cho game này)",
        tip_drop = "Chặn: lệnh gọi không bao giờ tới server",
        rn_title = "🎉 Có gì mới trong v%s",
        rn_1 = "Chạy script lần nữa sẽ thay phiên bản cũ, và nút \"Gỡ\" mới dọn sạch mọi thứ.",
        rn_2 = "Chống flood và gộp: các lệnh gọi giống nhau gộp thành một dòng \"×N\".",
        rn_3 = "Có thể ghi giá trị trả về InvokeServer, OnClientInvoke và Bindables (Cài đặt → Ghi nhận).",
        rn_4 = "Thống kê từng remote, tô sáng khác biệt với lần gọi trước, cảnh báo theo từ khóa.",
        rn_5 = "Danh sách theo dõi và danh sách bỏ qua / chặn được lưu theo từng game.",
        rn_6 = "Xuất cả một phiên thành script phát lại được (Cài đặt → Công cụ, hoặc Lịch sử).",
        rn_7 = "Biểu tượng vẽ mới, nút mở lại có bộ đếm chưa đọc, phím tắt trên PC (RightShift).",
        rn_8 = "Điện thoại: tab ở dưới, dòng và nút lớn hơn. Chú thích ở khắp nơi (nhấn giữ trên điện thoại).",
        rn_9 = "Màu nhấn, độ trong suốt và cỡ chữ ở Cài đặt → Giao diện.",
        rn_10 = "Tab Lỗi mới, trình duyệt nhanh hơn, tự động lưu nhẹ hơn — cùng nhiều lỗi đã được sửa.",
        as_live = "Liên tục (mỗi 2 giây)",
    }

    LANG.SV = {
        lang_name = "Svenska",
        lang_flag = "🇸🇪",
        tab_spy = "Remote Spy",
        tab_explorer = "Utforskare",
        tab_network = "Nätverk",
        tab_scripts = "Skript",
        tab_history = "Historik",
        tab_settings = "Inställningar",
        status_ready = "Klar",
        status_recording = "● Spelar in — %s · hook: %s",
        pause = "⏸ Pausa",
        resume = "▶ Fortsätt",
        clear = "🧹 Rensa",
        f_all = "◉ Alla",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Inkommande",
        f_blocked = "⛔ Blockerade",
        search_spy = "🔎 Filtrera remotes, argument, sökvägar...",
        feed_cleared = "Flödet rensat",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "INKOMMANDE",
        lbl_blocked = "BLOCKERAD",
        lbl_return = "RETUR",
        back = "← Tillbaka",
        copy_code = "📋 Kopiera kod",
        copy_path = "🧭 Kopiera sökväg",
        copy_args = "📦 Kopiera argument",
        refire = "🔁 Skicka igen",
        ignore = "🔇 Ignorera",
        unignore = "🔊 Sluta ignorera",
        drop = "⛔ Blockera anrop",
        undrop = "✅ Tillåt anrop",
        delete = "🗑 Ta bort",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENT (%d)",
        sec_r2s = "🧾  R2S-KOD (Remote → Script)",
        sec_replay = "🧪  UPPSPELNINGSKOD",
        k_remote = "Remote",
        k_class = "Klass",
        k_method = "Metod",
        k_direction = "Riktning",
        k_path = "Sökväg",
        k_caller = "Anropare",
        k_call = "Anrop nr",
        k_time = "Tid",
        k_status = "Status",
        dir_out = "📤 Klient → Server",
        dir_in = "📥 Server → Klient",
        caller_unknown = "(okänd / executor)",
        time_fmt = "+%.3fs efter start",
        st_logged = "Loggad",
        st_dropped = "⛔ Anrop blockerade",
        st_ignored = "🔇 Ignorerad",
        no_args = "(inga argument)",
        n_refire_only_out = "Endast utgående anrop kan skickas igen",
        n_refired = "%s skickades igen",
        n_refire_fail = "Kunde inte skicka igen: %s",
        n_log_resumed = "Loggning återupptagen för %s",
        n_ignored = "%s ignoreras — inga fler loggar",
        n_cant_block_in = "Inkommande händelser kan inte blockeras från klienten",
        n_allowed = "Anrop till %s tillåtna igen",
        n_blocked = "Anrop till %s är nu BLOCKERADE",
        n_copied = "%s kopierat till urklipp",
        n_no_clip = "Urklipp saknas i denna executor",
        n_copy_fail = "Kopiering misslyckades: %s",
        n_action_fail = "Åtgärden misslyckades: %s",
        c_code = "Kod",
        c_path = "Sökväg",
        c_args = "Argument",
        c_r2s = "R2S-kod",
        c_logs = "Loggar",
        c_source = "Källkod",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Skapad: %s",
        code_incoming = "-- RobloxSpy — Inkommande händelse (server → klient)",
        code_replay = "-- Spela upp lokalt med firesignal (om din executor har det):",
        log_export_title = "RobloxSpy — Loggexport",
        net_total = "TOTALT ANTAL ANROP",
        net_cps = "ANROP/S",
        net_unique = "UNIKA",
        net_blocked = "BLOCKERADE",
        net_traffic = "Trafik (anrop/s, senaste 60 s)",
        net_top = "🏆 Toppremotes (efter anrop)",
        ex_search = "🔍 Sök i hela spelet...",
        ex_props = "Egenskaper",
        ex_results = "%d resultat",
        ex_nil = "Nil-instanser",
        ex_select = "Välj en instans i trädet",
        ex_copy_path = "📋 Kopiera sökväg",
        ex_copy_code = "🧾 Kopiera som kod",
        ex_tp = "🚀 Teleportera",
        ex_view_src = "📜 Visa källkod",
        ex_destroy = "🗑 Förstör",
        ex_clone = "📑 Klona",
        ex_attrs = "🏷  ATTRIBUT",
        ex_tags = "🔖  TAGGAR",
        ex_children = "Barn",
        ex_desc = "Ättlingar",
        ex_too_many = "Visar de första %d raderna — använd sökning",
        n_tp_ok = "Teleporterad till %s",
        n_tp_fail = "Kan inte teleportera till denna instans",
        n_destroyed = "%s förstörd (klientsidan)",
        n_cloned = "%s klonad",
        n_prop_set = "%s = %s",
        n_prop_fail = "Kan inte ändra %s: %s",
        sc_scan = "🔍 Skanna skript",
        sc_search = "🔎 Filtrera skript...",
        sc_found = "%d skript hittade",
        sc_scanning = "Skannar... %d",
        sc_select = "Välj ett skript att visa",
        sc_copy = "📋 Kopiera",
        sc_save = "💾 Spara",
        sc_none = "-- Inget skript valt\n-- Klicka på 'Skanna skript' och välj ett",
        sc_fail = "-- Kunde inte dekompilera skriptet\n-- Din executor stöder kanske inte dekompilering\n-- Sökväg: %s",
        sc_decompiling = "-- Dekompilerar...",
        sc_all = "Alla",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Körs",
        sc_lines = "%d rader",
        n_saved = "Sparat → %s",
        n_save_fail = "Kunde inte spara: %s",
        n_no_write = "%s stöder inte writefile — använd Kopiera",
        n_nothing = "Inget att spara ännu",
        n_folder_fail = "Kan inte skapa mappen '%s' i denna executor",
        hi_title = "🕘 Sessionshistorik",
        hi_refresh = "🔄 Uppdatera",
        hi_current = "🔴 LIVE",
        hi_none = "Inga sparade sessioner.",
        hi_nolist = "Din executor kan inte läsa filer — endast aktuell session visas.",
        hi_calls = "%d anrop",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Sök i alla sessioner...",
        hi_results = "%d träffar i %d sessioner",
        hi_export = "💾 Exportera .txt",
        hi_deleted = "Sessionen borttagen",
        hi_showing = "Visar %d av %d poster",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Detta spel",
        se_lang = "🌐 Språk",
        se_save = "💾 Spara loggar",
        se_where = "Filer sparas i executorns workspace-mapp (PC: <Executor>/workspace — iPhone/Android: executorns mapp i appen Filer).",
        se_nowrite = "⛔ Din executor kan inte skriva filer (writefile saknas). Använd \"Kopiera loggar\".",
        se_folder = "📂 Mapp",
        se_last = "Senast sparat: %s",
        se_txt = "📝 Spara loggar (.txt — läsbart + R2S-kod)",
        se_json = "🧩 Spara session (.json)",
        se_csv = "📊 Spara session (.csv — Excel)",
        se_copy = "📋 Kopiera loggar (fungerar överallt)",
        se_autosave = "🔁 Spara loggar automatiskt i mappen",
        se_interval = "⏱ Intervall för autospar",
        se_options = "🛠 Alternativ",
        se_incoming = "📥 Logga inkommande händelser (server → klient)",
        se_autoscroll = "⬇ Autoskrolla flödet",
        se_pausecap = "⏸ Pausa inspelningen",
        se_size = "📐 Fönsterstorlek",
        sz_small = "Liten",
        sz_medium = "Mellan",
        sz_large = "Stor",
        se_info = "ℹ️ Executor-info",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Inkommande",
        i_files = "Filsystem",
        i_clip = "Urklipp",
        i_platform = "Plattform",
        v_avail = "✅ Tillgängligt",
        v_unavail = "❌ Ej tillgängligt",
        v_safe = "✅ Säkert (getconnections)",
        v_delayed = "⚠ Fördröjt (10 s)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Inkommande händelser loggas",
        n_inc_off = "Inkommande händelser ignoreras",
        n_paused = "Inspelning pausad",
        n_resumed = "Inspelning återupptagen",
        n_autosave_on = "Autospar var %ds → %s",
        n_autosave_off = "Autospar av",
        n_lang = "Språk: %s",
        credits = "av Rival960 — Gjord med hjälp av Claude",
        tab_errors = "Fel",
        ok = "OK",
        cancel = "Avbryt",
        off = "Av",
        status_events = "%d händelser",
        status_flood = "%d hoppades över (flood)",
        status_errors = "%d fel",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Bevakade",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Bevaka",
        unwatch = "☆ Sluta bevaka",
        st_watched = "⭐ Bevakad",
        dir_local = "🔁 Klient ↔ Klient (lokalt)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (servern frågar klienten)",
        code_clientinvoke_note = "-- Servern anropade OnClientInvoke på denna RemoteFunction med:",
        k_grouped = "Grupperad",
        grouped_fmt = "%d identiska anrop i rad",
        k_flood = "Flood",
        flood_fmt = "%d anrop hoppades över precis innan (anti-flood)",
        skipped_prefix = "(+%d överhoppade)",
        sec_stats = "📈  STATISTIK FÖR DENNA REMOTE",
        k_total = "Totalt antal anrop",
        k_rate = "Frekvens",
        rate_fmt = "%.1f anrop / min",
        k_first_last = "Första → senaste",
        k_callers = "Anropare",
        diff_hint = "ändringar mot förra anropet i gult",
        diff_was = "förut: %s",
        sec_return = "↩  RETURNERAT AV SERVERN",
        ret_nothing = "(inget returnerades)",
        ret_waiting = "Väntar på serverns svar…",
        ret_disabled = "Aktivera \"Fånga InvokeServer-returvärden\" i Inställningar",
        n_alert = "🔔 Varning: %s (nyckelord \"%s\")",
        n_saved_game = "sparat för detta spel",
        n_watch_on = "⭐ %s lades till i bevakningslistan",
        n_watch_off = "%s togs bort från bevakningslistan",
        empty_feed = "Inga händelser än — spela lite, varje remote-anrop visas här.",
        empty_filter = "Inget matchar detta filter.",
        empty_network = "Ingen trafik registrerad än.",
        empty_scripts = "Klicka på \"Skanna skript\" för att lista spelets klientskript.",
        empty_errors = "Inga fel — allt fungerar.",
        net_click_hint = "klicka på en rad för att filtrera spyn",
        err_copy = "📋 Kopiera allt",
        err_clear = "🧹 Rensa",
        err_count = "%d fel",
        c_errors = "Fel",
        hi_export_script = "🧾 Exportera som skript",
        se_capture = "📡 Infångning",
        se_returns = "↩ Fånga InvokeServer-returvärden",
        se_returns_note = "Visar vad servern svarar. Stäng av om ett spel beter sig konstigt.",
        se_clientinvoke = "📨 Fånga OnClientInvoke (kräver getcallbackvalue)",
        se_bindables = "🔗 Spionera på BindableEvent / BindableFunction",
        se_group = "🧮 Gruppera identiska anrop (×N)",
        se_flood = "🌊 Anti-flood (max loggade anrop per remote per sekund)",
        se_alerts = "🔔 Varningar",
        se_alerts_on = "🔔 Meddela när ett remote-namn innehåller ett nyckelord",
        se_keywords = "Nyckelord (kommaseparerade)",
        n_keywords_saved = "Nyckelord sparade",
        se_appearance = "🎨 Utseende",
        se_accent = "Accentfärg",
        c_blue = "Blå",
        c_purple = "Lila",
        c_green = "Grön",
        c_red = "Röd",
        c_orange = "Orange",
        se_transparency = "Fönstrets genomskinlighet",
        se_textsize = "Textstorlek",
        se_bottomtabs = "📱 Flikfält längst ner",
        se_keybind = "⌨ Tangent visa / dölj: %s (klicka för att ändra)",
        se_keybind_wait = "Tryck på en tangent… (Esc = avbryt)",
        n_keybind = "Tangent inställd: %s",
        se_tools = "🧰 Verktyg",
        se_export_script = "🧾 Exportera denna session som uppspelningsskript",
        se_whatsnew = "🎉 Nyheter",
        se_unload = "⏏ Ladda ur RobloxSpy",
        unload_title = "Ladda ur RobloxSpy?",
        unload_body = "Hookarna tas bort, sessionen sparas och gränssnittet stängs. Kör skriptet igen för att starta om.",
        n_returns_on = "Returvärden för nya InvokeServer fångas",
        n_option_off = "Alternativet avstängt",
        n_need_fn = "%s stöds inte av %s",
        tip_maximize = "Maximera / återställ",
        tip_minimize = "Minimera",
        tip_close = "Dölj (den runda knappen tar tillbaka det)",
        tip_reopen = "Öppna RobloxSpy (dra för att flytta)",
        tip_copy_r2s = "Kopiera R2S-koden",
        tip_ignore = "Ignorera denna remote (skickas, loggas inte)",
        tip_delete = "Ta bort denna rad",
        tip_pause = "Pausa / återuppta infångningen",
        tip_clear = "Rensa flödet",
        tip_expand = "Förstora fönstret",
        tip_refire = "Skicka detta anrop igen",
        tip_watch = "Lägg till i bevakningslistan (sparas för detta spel)",
        tip_drop = "Blockera: anropet når aldrig servern",
        rn_title = "🎉 Nytt i v%s",
        rn_1 = "Att köra skriptet igen ersätter den gamla instansen, och nya knappen \"Ladda ur\" tar bort allt rent.",
        rn_2 = "Anti-flood och gruppering: identiska anrop slås ihop till en rad \"×N\".",
        rn_3 = "InvokeServer-returer, OnClientInvoke och Bindables kan fångas (Inställningar → Infångning).",
        rn_4 = "Statistik per remote, markerade skillnader mot förra anropet, nyckelordsvarningar.",
        rn_5 = "Bevakningslistan och ignorera- / blockeralistor sparas per spel.",
        rn_6 = "Exportera en hel session som uppspelningsbart skript (Inställningar → Verktyg, eller Historik).",
        rn_7 = "Nya ritade ikoner, öppna-knapp med räknare för olästa, PC-tangent (RightShift).",
        rn_8 = "Mobil: flikar längst ner, större rader och knappar. Tips överallt (långt tryck på mobil).",
        rn_9 = "Accentfärger, genomskinlighet och textstorlek under Inställningar → Utseende.",
        rn_10 = "Ny Fel-flik, snabbare utforskare, lättare autospar — plus flera buggfixar.",
        as_live = "Live (var 2:e s)",
    }

    LANG.EL = {
        lang_name = "Ελληνικά",
        lang_flag = "🇬🇷",
        tab_spy = "Remote Spy",
        tab_explorer = "Εξερευνητής",
        tab_network = "Δίκτυο",
        tab_scripts = "Σκριπτ",
        tab_history = "Ιστορικό",
        tab_settings = "Ρυθμίσεις",
        status_ready = "Έτοιμο",
        status_recording = "● Καταγραφή — %s · hook: %s",
        pause = "⏸ Παύση",
        resume = "▶ Συνέχεια",
        clear = "🧹 Καθαρισμός",
        f_all = "◉ Όλα",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Εισερχόμενα",
        f_blocked = "⛔ Αποκλεισμένα",
        search_spy = "🔎 Φίλτρο remotes, ορισμάτων, διαδρομών...",
        feed_cleared = "Η λίστα καθαρίστηκε",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "ΕΙΣΕΡΧ.",
        lbl_blocked = "ΑΠΟΚΛ.",
        lbl_return = "ΕΠΙΣΤΡΟΦΗ",
        back = "← Πίσω",
        copy_code = "📋 Αντιγραφή κώδικα",
        copy_path = "🧭 Αντιγραφή διαδρομής",
        copy_args = "📦 Αντιγραφή ορισμάτων",
        refire = "🔁 Επαναποστολή",
        ignore = "🔇 Παράβλεψη",
        unignore = "🔊 Άρση παράβλεψης",
        drop = "⛔ Αποκλεισμός κλήσεων",
        undrop = "✅ Να επιτρέπονται οι κλήσεις",
        delete = "🗑 Διαγραφή",
        sec_info = "ℹ️  ΠΛΗΡΟΦΟΡΙΕΣ",
        sec_args = "📦  ΟΡΙΣΜΑΤΑ (%d)",
        sec_r2s = "🧾  ΚΩΔΙΚΑΣ R2S (Remote → Script)",
        sec_replay = "🧪  ΚΩΔΙΚΑΣ ΑΝΑΠΑΡΑΓΩΓΗΣ",
        k_remote = "Remote",
        k_class = "Κλάση",
        k_method = "Μέθοδος",
        k_direction = "Κατεύθυνση",
        k_path = "Διαδρομή",
        k_caller = "Καλών",
        k_call = "Κλήση αρ.",
        k_time = "Χρόνος",
        k_status = "Κατάσταση",
        dir_out = "📤 Πελάτης → Διακομιστής",
        dir_in = "📥 Διακομιστής → Πελάτης",
        caller_unknown = "(άγνωστο / executor)",
        time_fmt = "+%.3fs μετά την έναρξη",
        st_logged = "Καταγράφηκε",
        st_dropped = "⛔ Κλήσεις αποκλεισμένες",
        st_ignored = "🔇 Σε παράβλεψη",
        no_args = "(χωρίς ορίσματα)",
        n_refire_only_out = "Μόνο οι εξερχόμενες κλήσεις μπορούν να ξανασταλούν",
        n_refired = "Το %s στάλθηκε ξανά",
        n_refire_fail = "Αποτυχία επαναποστολής: %s",
        n_log_resumed = "Συνέχιση καταγραφής για %s",
        n_ignored = "Το %s παραβλέπεται — τέλος καταγραφών",
        n_cant_block_in = "Τα εισερχόμενα συμβάντα δεν αποκλείονται από τον πελάτη",
        n_allowed = "Οι κλήσεις προς %s επιτρέπονται ξανά",
        n_blocked = "Οι κλήσεις προς %s είναι πλέον ΑΠΟΚΛΕΙΣΜΕΝΕΣ",
        n_copied = "Το %s αντιγράφηκε στο πρόχειρο",
        n_no_clip = "Το πρόχειρο δεν είναι διαθέσιμο σε αυτόν τον executor",
        n_copy_fail = "Αποτυχία αντιγραφής: %s",
        n_action_fail = "Αποτυχία ενέργειας: %s",
        c_code = "Κώδικας",
        c_path = "Διαδρομή",
        c_args = "Ορίσματα",
        c_r2s = "Κώδικας R2S",
        c_logs = "Καταγραφές",
        c_source = "Πηγή",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Δημιουργήθηκε: %s",
        code_incoming = "-- RobloxSpy — Εισερχόμενο συμβάν (διακομιστής → πελάτης)",
        code_replay = "-- Αναπαραγωγή τοπικά με firesignal (αν το υποστηρίζει ο executor):",
        log_export_title = "RobloxSpy — Εξαγωγή καταγραφών",
        net_total = "ΣΥΝΟΛΟ ΚΛΗΣΕΩΝ",
        net_cps = "ΚΛΗΣΕΙΣ/Δ",
        net_unique = "ΜΟΝΑΔΙΚΑ",
        net_blocked = "ΑΠΟΚΛ.",
        net_traffic = "Κίνηση (κλήσεις/δ, τελευταία 60 δ)",
        net_top = "🏆 Κορυφαία remotes (κατά κλήσεις)",
        ex_search = "🔍 Αναζήτηση σε όλο το παιχνίδι...",
        ex_props = "Ιδιότητες",
        ex_results = "%d αποτελέσματα",
        ex_nil = "Αντικείμενα nil",
        ex_select = "Επίλεξε ένα αντικείμενο στο δέντρο",
        ex_copy_path = "📋 Αντιγραφή διαδρομής",
        ex_copy_code = "🧾 Αντιγραφή ως κώδικας",
        ex_tp = "🚀 Τηλεμεταφορά",
        ex_view_src = "📜 Προβολή πηγής",
        ex_destroy = "🗑 Καταστροφή",
        ex_clone = "📑 Κλωνοποίηση",
        ex_attrs = "🏷  ΧΑΡΑΚΤΗΡΙΣΤΙΚΑ",
        ex_tags = "🔖  ΕΤΙΚΕΤΕΣ",
        ex_children = "Παιδιά",
        ex_desc = "Απόγονοι",
        ex_too_many = "Εμφανίζονται οι πρώτες %d γραμμές — χρησιμοποίησε αναζήτηση",
        n_tp_ok = "Τηλεμεταφορά στο %s",
        n_tp_fail = "Δεν είναι δυνατή η τηλεμεταφορά εδώ",
        n_destroyed = "Το %s καταστράφηκε (πλευρά πελάτη)",
        n_cloned = "Το %s κλωνοποιήθηκε",
        n_prop_set = "%s = %s",
        n_prop_fail = "Αδύνατη η αλλαγή του %s: %s",
        sc_scan = "🔍 Σάρωση σκριπτ",
        sc_search = "🔎 Φίλτρο σκριπτ...",
        sc_found = "Βρέθηκαν %d σκριπτ",
        sc_scanning = "Σάρωση... %d",
        sc_select = "Επίλεξε σκριπτ για προβολή",
        sc_copy = "📋 Αντιγραφή",
        sc_save = "💾 Αποθήκευση",
        sc_none = "-- Δεν επιλέχθηκε σκριπτ\n-- Πάτα 'Σάρωση σκριπτ' και διάλεξε ένα",
        sc_fail = "-- Αδύνατη η αποσυμπίληση του σκριπτ\n-- Ο executor ίσως δεν την υποστηρίζει\n-- Διαδρομή: %s",
        sc_decompiling = "-- Αποσυμπίληση...",
        sc_all = "Όλα",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Ενεργά",
        sc_lines = "%d γραμμές",
        n_saved = "Αποθηκεύτηκε → %s",
        n_save_fail = "Αποτυχία αποθήκευσης: %s",
        n_no_write = "Ο %s δεν υποστηρίζει writefile — χρησιμοποίησε Αντιγραφή",
        n_nothing = "Δεν υπάρχει τίποτα για αποθήκευση ακόμα",
        n_folder_fail = "Αδύνατη η δημιουργία του φακέλου '%s' σε αυτόν τον executor",
        hi_title = "🕘 Ιστορικό συνεδριών",
        hi_refresh = "🔄 Ανανέωση",
        hi_current = "🔴 ΖΩΝΤΑΝΑ",
        hi_none = "Δεν υπάρχουν αποθηκευμένες συνεδρίες.",
        hi_nolist = "Ο executor δεν διαβάζει αρχεία — εμφανίζεται μόνο η τρέχουσα συνεδρία.",
        hi_calls = "%d κλήσεις",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Αναζήτηση σε όλες τις συνεδρίες...",
        hi_results = "%d αποτελέσματα σε %d συνεδρίες",
        hi_export = "💾 Εξαγωγή .txt",
        hi_deleted = "Η συνεδρία διαγράφηκε",
        hi_showing = "Εμφανίζονται %d από %d εγγραφές",
        hi_duration = "%dλ %dδ",
        hi_same_game = "📍 Αυτό το παιχνίδι",
        se_lang = "🌐 Γλώσσα",
        se_save = "💾 Αποθήκευση καταγραφών",
        se_where = "Τα αρχεία αποθηκεύονται στον φάκελο workspace του executor (PC: <Executor>/workspace — iPhone/Android: φάκελος του executor στην εφαρμογή Αρχεία).",
        se_nowrite = "⛔ Ο executor δεν γράφει αρχεία (λείπει το writefile). Χρησιμοποίησε «Αντιγραφή καταγραφών».",
        se_folder = "📂 Φάκελος",
        se_last = "Τελευταία αποθήκευση: %s",
        se_txt = "📝 Αποθήκευση καταγραφών (.txt — αναγνώσιμο + κώδικας R2S)",
        se_json = "🧩 Αποθήκευση συνεδρίας (.json)",
        se_csv = "📊 Αποθήκευση συνεδρίας (.csv — Excel)",
        se_copy = "📋 Αντιγραφή καταγραφών (λειτουργεί παντού)",
        se_autosave = "🔁 Αυτόματη αποθήκευση στον φάκελο",
        se_interval = "⏱ Διάστημα αυτόματης αποθήκευσης",
        se_options = "🛠 Επιλογές",
        se_incoming = "📥 Καταγραφή εισερχόμενων (διακομιστής → πελάτης)",
        se_autoscroll = "⬇ Αυτόματη κύλιση",
        se_pausecap = "⏸ Παύση καταγραφής",
        se_size = "📐 Μέγεθος παραθύρου",
        sz_small = "Μικρό",
        sz_medium = "Μεσαίο",
        sz_large = "Μεγάλο",
        se_info = "ℹ️ Πληροφορίες executor",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Εισερχόμενα",
        i_files = "Αρχεία",
        i_clip = "Πρόχειρο",
        i_platform = "Πλατφόρμα",
        v_avail = "✅ Διαθέσιμο",
        v_unavail = "❌ Μη διαθέσιμο",
        v_safe = "✅ Ασφαλές (getconnections)",
        v_delayed = "⚠ Καθυστέρηση (10 δ)",
        v_mobile = "📱 Κινητό",
        v_pc = "💻 PC",
        n_inc_on = "Τα εισερχόμενα καταγράφονται",
        n_inc_off = "Τα εισερχόμενα παραβλέπονται",
        n_paused = "Η καταγραφή σε παύση",
        n_resumed = "Η καταγραφή συνεχίζεται",
        n_autosave_on = "Αυτόματη αποθήκευση κάθε %d δ → %s",
        n_autosave_off = "Αυτόματη αποθήκευση ανενεργή",
        n_lang = "Γλώσσα: %s",
        credits = "από Rival960 — Φτιαγμένο με τη βοήθεια του Claude",
        tab_errors = "Σφάλματα",
        ok = "OK",
        cancel = "Άκυρο",
        off = "Ανενεργό",
        status_events = "%d συμβάντα",
        status_flood = "%d παραλείφθηκαν (flood)",
        status_errors = "%d σφάλματα",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Παρακολουθούμενα",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Παρακολούθηση",
        unwatch = "☆ Διακοπή παρακολούθησης",
        st_watched = "⭐ Παρακολουθείται",
        dir_local = "🔁 Πελάτης ↔ Πελάτης (τοπικά)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (ο διακομιστής ρωτά τον πελάτη)",
        code_clientinvoke_note = "-- Ο διακομιστής κάλεσε το OnClientInvoke αυτού του RemoteFunction με:",
        k_grouped = "Ομαδοποίηση",
        grouped_fmt = "%d ίδιες κλήσεις στη σειρά",
        k_flood = "Flood",
        flood_fmt = "%d κλήσεις παραλείφθηκαν ακριβώς πριν (anti-flood)",
        skipped_prefix = "(+%d παραλείφθηκαν)",
        sec_stats = "📈  ΣΤΑΤΙΣΤΙΚΑ ΑΥΤΟΥ ΤΟΥ REMOTE",
        k_total = "Σύνολο κλήσεων",
        k_rate = "Συχνότητα",
        rate_fmt = "%.1f κλήσεις / λεπτό",
        k_first_last = "Πρώτη → τελευταία",
        k_callers = "Καλούντες",
        diff_hint = "οι αλλαγές από την προηγούμενη κλήση με κίτρινο",
        diff_was = "πριν: %s",
        sec_return = "↩  ΕΠΙΣΤΡΑΦΗΚΕ ΑΠΟ ΤΟΝ ΔΙΑΚΟΜΙΣΤΗ",
        ret_nothing = "(δεν επιστράφηκε τίποτα)",
        ret_waiting = "Αναμονή απάντησης διακομιστή…",
        ret_disabled = "Ενεργοποίησε «Καταγραφή επιστροφών InvokeServer» στις Ρυθμίσεις",
        n_alert = "🔔 Ειδοποίηση: %s (λέξη-κλειδί «%s»)",
        n_saved_game = "αποθηκεύτηκε για αυτό το παιχνίδι",
        n_watch_on = "⭐ Το %s προστέθηκε στη λίστα παρακολούθησης",
        n_watch_off = "Το %s αφαιρέθηκε από τη λίστα παρακολούθησης",
        empty_feed = "Κανένα συμβάν ακόμα — παίξε λίγο, κάθε κλήση remote θα εμφανιστεί εδώ.",
        empty_filter = "Τίποτα δεν ταιριάζει σε αυτό το φίλτρο.",
        empty_network = "Δεν έχει καταγραφεί κίνηση ακόμα.",
        empty_scripts = "Πάτα «Σάρωση σκριπτ» για να δεις τα σκριπτ πελάτη του παιχνιδιού.",
        empty_errors = "Κανένα σφάλμα — όλα λειτουργούν.",
        net_click_hint = "πάτα μια γραμμή για φιλτράρισμα του spy",
        err_copy = "📋 Αντιγραφή όλων",
        err_clear = "🧹 Καθαρισμός",
        err_count = "%d σφάλμα(τα)",
        c_errors = "Σφάλματα",
        hi_export_script = "🧾 Εξαγωγή ως σκριπτ",
        se_capture = "📡 Καταγραφή",
        se_returns = "↩ Καταγραφή επιστροφών InvokeServer",
        se_returns_note = "Δείχνει τι απαντά ο διακομιστής. Απενεργοποίησέ το αν ένα παιχνίδι συμπεριφέρεται παράξενα.",
        se_clientinvoke = "📨 Καταγραφή OnClientInvoke (απαιτεί getcallbackvalue)",
        se_bindables = "🔗 Παρακολούθηση BindableEvent / BindableFunction",
        se_group = "🧮 Ομαδοποίηση ίδιων κλήσεων (×N)",
        se_flood = "🌊 Anti-flood (μέγιστες καταγεγραμμένες κλήσεις ανά remote ανά δευτερόλεπτο)",
        se_alerts = "🔔 Ειδοποιήσεις",
        se_alerts_on = "🔔 Ειδοποίηση όταν το όνομα remote περιέχει λέξη-κλειδί",
        se_keywords = "Λέξεις-κλειδιά (χωρισμένες με κόμμα)",
        n_keywords_saved = "Οι λέξεις-κλειδιά αποθηκεύτηκαν",
        se_appearance = "🎨 Εμφάνιση",
        se_accent = "Χρώμα έμφασης",
        c_blue = "Μπλε",
        c_purple = "Μωβ",
        c_green = "Πράσινο",
        c_red = "Κόκκινο",
        c_orange = "Πορτοκαλί",
        se_transparency = "Διαφάνεια παραθύρου",
        se_textsize = "Μέγεθος κειμένου",
        se_bottomtabs = "📱 Γραμμή καρτελών κάτω",
        se_keybind = "⌨ Πλήκτρο εμφάνισης / απόκρυψης: %s (πάτα για αλλαγή)",
        se_keybind_wait = "Πάτα ένα πλήκτρο… (Esc = άκυρο)",
        n_keybind = "Ορίστηκε πλήκτρο: %s",
        se_tools = "🧰 Εργαλεία",
        se_export_script = "🧾 Εξαγωγή αυτής της συνεδρίας ως σκριπτ αναπαραγωγής",
        se_whatsnew = "🎉 Τι νέο υπάρχει",
        se_unload = "⏏ Αποφόρτωση RobloxSpy",
        unload_title = "Αποφόρτωση του RobloxSpy;",
        unload_body = "Τα hooks αφαιρούνται, η συνεδρία αποθηκεύεται και το περιβάλλον κλείνει. Τρέξε ξανά το σκριπτ για επανεκκίνηση.",
        n_returns_on = "Καταγράφονται οι επιστροφές των νέων InvokeServer",
        n_option_off = "Η επιλογή απενεργοποιήθηκε",
        n_need_fn = "Το %s δεν υποστηρίζεται από τον %s",
        tip_maximize = "Μεγιστοποίηση / επαναφορά",
        tip_minimize = "Ελαχιστοποίηση",
        tip_close = "Απόκρυψη (το στρογγυλό κουμπί το επαναφέρει)",
        tip_reopen = "Άνοιγμα RobloxSpy (σύρε για μετακίνηση)",
        tip_copy_r2s = "Αντιγραφή κώδικα R2S",
        tip_ignore = "Παράβλεψη αυτού του remote (στέλνεται, δεν καταγράφεται)",
        tip_delete = "Διαγραφή αυτής της γραμμής",
        tip_pause = "Παύση / συνέχεια καταγραφής",
        tip_clear = "Καθαρισμός λίστας",
        tip_expand = "Μεγέθυνση παραθύρου",
        tip_refire = "Ξανά αποστολή αυτής της κλήσης",
        tip_watch = "Προσθήκη στη λίστα παρακολούθησης (αποθηκεύεται για αυτό το παιχνίδι)",
        tip_drop = "Αποκλεισμός: η κλήση δεν φτάνει ποτέ στον διακομιστή",
        rn_title = "🎉 Τι νέο στην v%s",
        rn_1 = "Αν τρέξεις ξανά το σκριπτ, αντικαθιστά την παλιά εκτέλεση, και το νέο κουμπί «Αποφόρτωση» αφαιρεί τα πάντα καθαρά.",
        rn_2 = "Anti-flood και ομαδοποίηση: οι ίδιες κλήσεις γίνονται μία γραμμή «×N».",
        rn_3 = "Μπορούν να καταγραφούν επιστροφές InvokeServer, OnClientInvoke και Bindables (Ρυθμίσεις → Καταγραφή).",
        rn_4 = "Στατιστικά ανά remote, επισήμανση διαφορών με την προηγούμενη κλήση, ειδοποιήσεις λέξεων-κλειδιών.",
        rn_5 = "Η λίστα παρακολούθησης και οι λίστες παράβλεψης / αποκλεισμού αποθηκεύονται ανά παιχνίδι.",
        rn_6 = "Εξαγωγή ολόκληρης συνεδρίας ως σκριπτ αναπαραγωγής (Ρυθμίσεις → Εργαλεία ή Ιστορικό).",
        rn_7 = "Νέα σχεδιασμένα εικονίδια, κουμπί ανοίγματος με μετρητή, πλήκτρο στο PC (RightShift).",
        rn_8 = "Κινητό: καρτέλες κάτω, μεγαλύτερες γραμμές και κουμπιά. Συμβουλές παντού (παρατεταμένο πάτημα στο κινητό).",
        rn_9 = "Χρώματα έμφασης, διαφάνεια και μέγεθος κειμένου στις Ρυθμίσεις → Εμφάνιση.",
        rn_10 = "Νέα καρτέλα Σφάλματα, ταχύτερος εξερευνητής, ελαφρύτερη αυτόματη αποθήκευση — και αρκετές διορθώσεις.",
        as_live = "Συνεχώς (κάθε 2 δ)",
    }

    LANG.RO = {
        lang_name = "Română",
        lang_flag = "🇷🇴",
        tab_spy = "Remote Spy",
        tab_explorer = "Explorator",
        tab_network = "Rețea",
        tab_scripts = "Scripturi",
        tab_history = "Istoric",
        tab_settings = "Setări",
        status_ready = "Gata",
        status_recording = "● Înregistrare — %s · hook: %s",
        pause = "⏸ Pauză",
        resume = "▶ Reia",
        clear = "🧹 Golește",
        f_all = "◉ Toate",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Primite",
        f_blocked = "⛔ Blocate",
        search_spy = "🔎 Filtrează remote-uri, argumente, căi...",
        feed_cleared = "Lista a fost golită",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "PRIMIT",
        lbl_blocked = "BLOCAT",
        lbl_return = "RETUR",
        back = "← Înapoi",
        copy_code = "📋 Copiază codul",
        copy_path = "🧭 Copiază calea",
        copy_args = "📦 Copiază argumentele",
        refire = "🔁 Retrimite",
        ignore = "🔇 Ignoră",
        unignore = "🔊 Nu mai ignora",
        drop = "⛔ Blochează apelurile",
        undrop = "✅ Permite apelurile",
        delete = "🗑 Șterge",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTE (%d)",
        sec_r2s = "🧾  COD R2S (Remote → Script)",
        sec_replay = "🧪  COD DE REDARE",
        k_remote = "Remote",
        k_class = "Clasă",
        k_method = "Metodă",
        k_direction = "Direcție",
        k_path = "Cale",
        k_caller = "Apelant",
        k_call = "Apel nr.",
        k_time = "Timp",
        k_status = "Stare",
        dir_out = "📤 Client → Server",
        dir_in = "📥 Server → Client",
        caller_unknown = "(necunoscut / executor)",
        time_fmt = "+%.3fs după pornire",
        st_logged = "Înregistrat",
        st_dropped = "⛔ Apeluri blocate",
        st_ignored = "🔇 Ignorat",
        no_args = "(fără argumente)",
        n_refire_only_out = "Doar apelurile trimise pot fi retrimise",
        n_refired = "%s retrimis",
        n_refire_fail = "Retrimitere eșuată: %s",
        n_log_resumed = "Înregistrare reluată pentru %s",
        n_ignored = "%s ignorat — fără alte loguri",
        n_cant_block_in = "Evenimentele primite nu pot fi blocate din client",
        n_allowed = "Apelurile către %s sunt din nou permise",
        n_blocked = "Apelurile către %s sunt acum BLOCATE",
        n_copied = "%s copiat în clipboard",
        n_no_clip = "Clipboard indisponibil pe acest executor",
        n_copy_fail = "Copiere eșuată: %s",
        n_action_fail = "Acțiune eșuată: %s",
        c_code = "Cod",
        c_path = "Cale",
        c_args = "Argumente",
        c_r2s = "Cod R2S",
        c_logs = "Loguri",
        c_source = "Sursă",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Generat: %s",
        code_incoming = "-- RobloxSpy — Eveniment primit (server → client)",
        code_replay = "-- Redă-l local cu firesignal (dacă executorul îl are):",
        log_export_title = "RobloxSpy — Export loguri",
        net_total = "TOTAL APELURI",
        net_cps = "APELURI/S",
        net_unique = "UNICE",
        net_blocked = "BLOCATE",
        net_traffic = "Trafic (apeluri/s, ultimele 60 s)",
        net_top = "🏆 Top remote-uri (după apeluri)",
        ex_search = "🔍 Caută în tot jocul...",
        ex_props = "Proprietăți",
        ex_results = "%d rezultate",
        ex_nil = "Instanțe nil",
        ex_select = "Alege o instanță din arbore",
        ex_copy_path = "📋 Copiază calea",
        ex_copy_code = "🧾 Copiază ca cod",
        ex_tp = "🚀 Teleportare",
        ex_view_src = "📜 Vezi sursa",
        ex_destroy = "🗑 Distruge",
        ex_clone = "📑 Clonează",
        ex_attrs = "🏷  ATRIBUTE",
        ex_tags = "🔖  ETICHETE",
        ex_children = "Copii",
        ex_desc = "Descendenți",
        ex_too_many = "Se afișează primele %d rânduri — folosește căutarea",
        n_tp_ok = "Teleportat la %s",
        n_tp_fail = "Nu te poți teleporta la această instanță",
        n_destroyed = "%s distrus (pe client)",
        n_cloned = "%s clonat",
        n_prop_set = "%s = %s",
        n_prop_fail = "Nu se poate seta %s: %s",
        sc_scan = "🔍 Scanează scripturile",
        sc_search = "🔎 Filtrează scripturile...",
        sc_found = "%d scripturi găsite",
        sc_scanning = "Se scanează... %d",
        sc_select = "Alege un script de afișat",
        sc_copy = "📋 Copiază",
        sc_save = "💾 Salvează",
        sc_none = "-- Niciun script selectat\n-- Apasă 'Scanează scripturile' și alege unul",
        sc_fail = "-- Scriptul nu a putut fi decompilat\n-- Executorul tău poate nu suportă decompilarea\n-- Cale: %s",
        sc_decompiling = "-- Se decompilează...",
        sc_all = "Toate",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Active",
        sc_lines = "%d rânduri",
        n_saved = "Salvat → %s",
        n_save_fail = "Salvare eșuată: %s",
        n_no_write = "%s nu suportă writefile — folosește Copiază",
        n_nothing = "Nimic de salvat încă",
        n_folder_fail = "Nu se poate crea folderul '%s' pe acest executor",
        hi_title = "🕘 Istoricul sesiunilor",
        hi_refresh = "🔄 Reîmprospătează",
        hi_current = "🔴 LIVE",
        hi_none = "Nu există sesiuni salvate.",
        hi_nolist = "Executorul nu poate citi fișiere — se afișează doar sesiunea curentă.",
        hi_calls = "%d apeluri",
        hi_unique = "%d remote-uri",
        hi_search_all = "🔎 Caută în toate sesiunile...",
        hi_results = "%d potriviri în %d sesiuni",
        hi_export = "💾 Exportă .txt",
        hi_deleted = "Sesiune ștearsă",
        hi_showing = "Se afișează %d din %d intrări",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Acest joc",
        se_lang = "🌐 Limbă",
        se_save = "💾 Salvare loguri",
        se_where = "Fișierele sunt salvate în folderul workspace al executorului (PC: <Executor>/workspace — iPhone/Android: folderul executorului din aplicația Fișiere).",
        se_nowrite = "⛔ Executorul nu poate scrie fișiere (lipsește writefile). Folosește „Copiază logurile”.",
        se_folder = "📂 Folder",
        se_last = "Ultima salvare: %s",
        se_txt = "📝 Salvează logurile (.txt — lizibil + cod R2S)",
        se_json = "🧩 Salvează sesiunea (.json)",
        se_csv = "📊 Salvează sesiunea (.csv — Excel)",
        se_copy = "📋 Copiază logurile (merge peste tot)",
        se_autosave = "🔁 Salvare automată în folder",
        se_interval = "⏱ Interval de salvare automată",
        se_options = "🛠 Opțiuni",
        se_incoming = "📥 Înregistrează evenimentele primite (server → client)",
        se_autoscroll = "⬇ Derulare automată",
        se_pausecap = "⏸ Pune captura pe pauză",
        se_size = "📐 Mărimea ferestrei",
        sz_small = "Mică",
        sz_medium = "Medie",
        sz_large = "Mare",
        se_info = "ℹ️ Info executor",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Primite",
        i_files = "Fișiere",
        i_clip = "Clipboard",
        i_platform = "Platformă",
        v_avail = "✅ Disponibil",
        v_unavail = "❌ Indisponibil",
        v_safe = "✅ Sigur (getconnections)",
        v_delayed = "⚠ Întârziat (10 s)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Evenimentele primite sunt înregistrate",
        n_inc_off = "Evenimentele primite sunt ignorate",
        n_paused = "Captură pe pauză",
        n_resumed = "Captură reluată",
        n_autosave_on = "Salvare automată la fiecare %ds → %s",
        n_autosave_off = "Salvare automată oprită",
        n_lang = "Limbă: %s",
        credits = "de Rival960 — Realizat cu ajutorul lui Claude",
        tab_errors = "Erori",
        ok = "OK",
        cancel = "Anulează",
        off = "Oprit",
        status_events = "%d evenimente",
        status_flood = "%d sărite (flood)",
        status_errors = "%d erori",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Urmărite",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Urmărește",
        unwatch = "☆ Nu mai urmări",
        st_watched = "⭐ Urmărit",
        dir_local = "🔁 Client ↔ Client (local)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (serverul întreabă clientul)",
        code_clientinvoke_note = "-- Serverul a apelat OnClientInvoke al acestui RemoteFunction cu:",
        k_grouped = "Grupat",
        grouped_fmt = "%d apeluri identice la rând",
        k_flood = "Flood",
        flood_fmt = "%d apeluri sărite chiar înainte (anti-flood)",
        skipped_prefix = "(+%d sărite)",
        sec_stats = "📈  STATISTICI PENTRU ACEST REMOTE",
        k_total = "Apeluri totale",
        k_rate = "Frecvență",
        rate_fmt = "%.1f apeluri / min",
        k_first_last = "Primul → ultimul",
        k_callers = "Apelanți",
        diff_hint = "schimbările față de apelul anterior cu galben",
        diff_was = "înainte: %s",
        sec_return = "↩  RETURNAT DE SERVER",
        ret_nothing = "(nimic returnat)",
        ret_waiting = "Se așteaptă răspunsul serverului…",
        ret_disabled = "Activează „Capturează valorile returnate de InvokeServer” în Setări",
        n_alert = "🔔 Alertă: %s (cuvânt-cheie „%s”)",
        n_saved_game = "salvat pentru acest joc",
        n_watch_on = "⭐ %s adăugat în lista de urmărire",
        n_watch_off = "%s scos din lista de urmărire",
        empty_feed = "Niciun eveniment încă — joacă puțin, fiecare apel remote va apărea aici.",
        empty_filter = "Nimic nu corespunde acestui filtru.",
        empty_network = "Niciun trafic înregistrat încă.",
        empty_scripts = "Apasă „Scanează scripturile” pentru a lista scripturile client ale jocului.",
        empty_errors = "Nicio eroare — totul funcționează.",
        net_click_hint = "apasă pe un rând pentru a filtra spy-ul",
        err_copy = "📋 Copiază tot",
        err_clear = "🧹 Golește",
        err_count = "%d eroare(i)",
        c_errors = "Erori",
        hi_export_script = "🧾 Exportă ca script",
        se_capture = "📡 Captură",
        se_returns = "↩ Capturează valorile returnate de InvokeServer",
        se_returns_note = "Arată ce răspunde serverul. Dezactivează dacă un joc se comportă ciudat.",
        se_clientinvoke = "📨 Capturează OnClientInvoke (necesită getcallbackvalue)",
        se_bindables = "🔗 Spionează BindableEvent / BindableFunction",
        se_group = "🧮 Grupează apelurile identice (×N)",
        se_flood = "🌊 Anti-flood (max. apeluri înregistrate per remote pe secundă)",
        se_alerts = "🔔 Alerte",
        se_alerts_on = "🔔 Notifică atunci când numele unui remote conține un cuvânt-cheie",
        se_keywords = "Cuvinte-cheie (separate prin virgulă)",
        n_keywords_saved = "Cuvinte-cheie salvate",
        se_appearance = "🎨 Aspect",
        se_accent = "Culoare de accent",
        c_blue = "Albastru",
        c_purple = "Mov",
        c_green = "Verde",
        c_red = "Roșu",
        c_orange = "Portocaliu",
        se_transparency = "Transparența ferestrei",
        se_textsize = "Mărimea textului",
        se_bottomtabs = "📱 Bara de file jos",
        se_keybind = "⌨ Tastă afișare / ascundere: %s (apasă pentru a schimba)",
        se_keybind_wait = "Apasă o tastă… (Esc = anulează)",
        n_keybind = "Tastă setată: %s",
        se_tools = "🧰 Unelte",
        se_export_script = "🧾 Exportă această sesiune ca script de redare",
        se_whatsnew = "🎉 Noutăți",
        se_unload = "⏏ Descarcă RobloxSpy",
        unload_title = "Descarci RobloxSpy?",
        unload_body = "Hook-urile sunt eliminate, sesiunea este salvată și interfața se închide. Rulează din nou scriptul pentru a-l reporni.",
        n_returns_on = "Se capturează valorile returnate de noile InvokeServer",
        n_option_off = "Opțiune dezactivată",
        n_need_fn = "%s nu este suportat de %s",
        tip_maximize = "Maximizează / restabilește",
        tip_minimize = "Minimizează",
        tip_close = "Ascunde (butonul rotund o readuce)",
        tip_reopen = "Deschide RobloxSpy (trage pentru a muta)",
        tip_copy_r2s = "Copiază codul R2S",
        tip_ignore = "Ignoră acest remote (trimis, dar neînregistrat)",
        tip_delete = "Șterge acest rând",
        tip_pause = "Pune pe pauză / reia captura",
        tip_clear = "Golește lista",
        tip_expand = "Mărește fereastra",
        tip_refire = "Trimite din nou acest apel",
        tip_watch = "Adaugă în lista de urmărire (salvat pentru acest joc)",
        tip_drop = "Blochează: apelul nu ajunge niciodată la server",
        rn_title = "🎉 Noutăți în v%s",
        rn_1 = "Rularea scriptului a doua oară înlocuiește instanța veche, iar noul buton „Descarcă” elimină totul curat.",
        rn_2 = "Anti-flood și grupare: apelurile identice devin un singur rând „×N”.",
        rn_3 = "Se pot captura valorile returnate de InvokeServer, OnClientInvoke și Bindables (Setări → Captură).",
        rn_4 = "Statistici per remote, diferențe evidențiate față de apelul anterior, alerte pe cuvinte-cheie.",
        rn_5 = "Lista de urmărire și listele de ignorate / blocate sunt salvate per joc.",
        rn_6 = "Exportă o sesiune întreagă ca script redabil (Setări → Unelte, sau Istoric).",
        rn_7 = "Iconițe noi desenate, buton de redeschidere cu contor, tastă pe PC (RightShift).",
        rn_8 = "Mobil: file jos, rânduri și butoane mai mari. Indicii peste tot (apăsare lungă pe mobil).",
        rn_9 = "Culori de accent, transparență și mărimea textului în Setări → Aspect.",
        rn_10 = "Filă nouă Erori, explorator mai rapid, salvare automată mai ușoară — și mai multe erori reparate.",
        as_live = "Continuu (la 2 s)",
    }

    LANG.UK = {
        lang_name = "Українська",
        lang_flag = "🇺🇦",
        tab_spy = "Remote Spy",
        tab_explorer = "Провідник",
        tab_network = "Мережа",
        tab_scripts = "Скрипти",
        tab_history = "Історія",
        tab_settings = "Налаштування",
        status_ready = "Готово",
        status_recording = "● Запис — %s · хук: %s",
        pause = "⏸ Пауза",
        resume = "▶ Продовжити",
        clear = "🧹 Очистити",
        f_all = "◉ Усі",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Вхідні",
        f_blocked = "⛔ Заблок.",
        search_spy = "🔎 Фільтр: ремоути, аргументи, шляхи...",
        feed_cleared = "Стрічку очищено",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "ВХІДНИЙ",
        lbl_blocked = "БЛОК",
        lbl_return = "ПОВЕРНЕННЯ",
        back = "← Назад",
        copy_code = "📋 Копіювати код",
        copy_path = "🧭 Копіювати шлях",
        copy_args = "📦 Копіювати аргументи",
        refire = "🔁 Повторити",
        ignore = "🔇 Ігнорувати",
        unignore = "🔊 Не ігнорувати",
        drop = "⛔ Блокувати виклики",
        undrop = "✅ Дозволити виклики",
        delete = "🗑 Видалити",
        sec_info = "ℹ️  ІНФО",
        sec_args = "📦  АРГУМЕНТИ (%d)",
        sec_r2s = "🧾  КОД R2S (Remote → Script)",
        sec_replay = "🧪  КОД ПОВТОРУ",
        k_remote = "Ремоут",
        k_class = "Клас",
        k_method = "Метод",
        k_direction = "Напрямок",
        k_path = "Шлях",
        k_caller = "Викликав",
        k_call = "Виклик №",
        k_time = "Час",
        k_status = "Статус",
        dir_out = "📤 Клієнт → Сервер",
        dir_in = "📥 Сервер → Клієнт",
        caller_unknown = "(невідомо / екзекутор)",
        time_fmt = "+%.3fs після запуску",
        st_logged = "Записано",
        st_dropped = "⛔ Виклики заблоковано",
        st_ignored = "🔇 Ігнорується",
        no_args = "(без аргументів)",
        n_refire_only_out = "Повторити можна лише вихідні виклики",
        n_refired = "%s надіслано повторно",
        n_refire_fail = "Помилка повтору: %s",
        n_log_resumed = "Запис відновлено для %s",
        n_ignored = "%s ігнорується — логів більше немає",
        n_cant_block_in = "Вхідні події не можна заблокувати на клієнті",
        n_allowed = "Виклики %s знову дозволено",
        n_blocked = "Виклики %s тепер ЗАБЛОКОВАНО",
        n_copied = "%s скопійовано в буфер обміну",
        n_no_clip = "Буфер обміну недоступний у цьому екзекуторі",
        n_copy_fail = "Помилка копіювання: %s",
        n_action_fail = "Помилка дії: %s",
        c_code = "Код",
        c_path = "Шлях",
        c_args = "Аргументи",
        c_r2s = "Код R2S",
        c_logs = "Логи",
        c_source = "Вихідний код",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Створено: %s",
        code_incoming = "-- RobloxSpy — Вхідна подія (сервер → клієнт)",
        code_replay = "-- Повтори локально через firesignal (якщо він є в екзекуторі):",
        log_export_title = "RobloxSpy — Експорт логів",
        net_total = "УСЬОГО ВИКЛИКІВ",
        net_cps = "ВИКЛИКІВ/С",
        net_unique = "УНІКАЛЬНИХ",
        net_blocked = "ЗАБЛОК.",
        net_traffic = "Трафік (викликів/с, останні 60 с)",
        net_top = "🏆 Топ ремоутів (за викликами)",
        ex_search = "🔍 Пошук по всій грі...",
        ex_props = "Властивості",
        ex_results = "Знайдено: %d",
        ex_nil = "Nil-об'єкти",
        ex_select = "Вибери об'єкт у дереві",
        ex_copy_path = "📋 Копіювати шлях",
        ex_copy_code = "🧾 Копіювати як код",
        ex_tp = "🚀 Телепорт",
        ex_view_src = "📜 Вихідний код",
        ex_destroy = "🗑 Знищити",
        ex_clone = "📑 Клонувати",
        ex_attrs = "🏷  АТРИБУТИ",
        ex_tags = "🔖  ТЕГИ",
        ex_children = "Дочірні",
        ex_desc = "Нащадки",
        ex_too_many = "Показано перші %d рядків — скористайся пошуком",
        n_tp_ok = "Телепорт до %s",
        n_tp_fail = "Не можна телепортуватися до цього об'єкта",
        n_destroyed = "%s знищено (на клієнті)",
        n_cloned = "%s клоновано",
        n_prop_set = "%s = %s",
        n_prop_fail = "Не можна змінити %s: %s",
        sc_scan = "🔍 Сканувати скрипти",
        sc_search = "🔎 Фільтр скриптів...",
        sc_found = "Знайдено скриптів: %d",
        sc_scanning = "Сканування... %d",
        sc_select = "Вибери скрипт для перегляду",
        sc_copy = "📋 Копіювати",
        sc_save = "💾 Зберегти",
        sc_none = "-- Скрипт не вибрано\n-- Натисни 'Сканувати скрипти' і вибери один",
        sc_fail = "-- Не вдалося декомпілювати скрипт\n-- Можливо, екзекутор не підтримує декомпіляцію\n-- Шлях: %s",
        sc_decompiling = "-- Декомпіляція...",
        sc_all = "Усі",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Активні",
        sc_lines = "Рядків: %d",
        n_saved = "Збережено → %s",
        n_save_fail = "Помилка збереження: %s",
        n_no_write = "%s не підтримує writefile — використай копіювання",
        n_nothing = "Поки нічого зберігати",
        n_folder_fail = "Не можна створити теку '%s' у цьому екзекуторі",
        hi_title = "🕘 Історія сесій",
        hi_refresh = "🔄 Оновити",
        hi_current = "🔴 ЗАРАЗ",
        hi_none = "Збережених сесій немає.",
        hi_nolist = "Екзекутор не читає файли — показано лише поточну сесію.",
        hi_calls = "викликів: %d",
        hi_unique = "ремоутів: %d",
        hi_search_all = "🔎 Пошук у всіх сесіях...",
        hi_results = "%d збігів у %d сесіях",
        hi_export = "💾 Експорт .txt",
        hi_deleted = "Сесію видалено",
        hi_showing = "Показано %d з %d записів",
        hi_duration = "%dхв %dс",
        hi_same_game = "📍 Ця гра",
        se_lang = "🌐 Мова",
        se_save = "💾 Збереження логів",
        se_where = "Файли зберігаються в теку workspace екзекутора (ПК: <Executor>/workspace — iPhone/Android: тека екзекутора в застосунку «Файли»).",
        se_nowrite = "⛔ Екзекутор не може записувати файли (немає writefile). Використай «Копіювати логи».",
        se_folder = "📂 Тека",
        se_last = "Останнє збереження: %s",
        se_txt = "📝 Зберегти логи (.txt — читабельно + код R2S)",
        se_json = "🧩 Зберегти сесію (.json)",
        se_csv = "📊 Зберегти сесію (.csv — Excel)",
        se_copy = "📋 Копіювати логи (працює всюди)",
        se_autosave = "🔁 Автозбереження логів у теку",
        se_interval = "⏱ Інтервал автозбереження",
        se_options = "🛠 Параметри",
        se_incoming = "📥 Записувати вхідні події (сервер → клієнт)",
        se_autoscroll = "⬇ Автопрокручування",
        se_pausecap = "⏸ Призупинити запис",
        se_size = "📐 Розмір вікна",
        sz_small = "Мале",
        sz_medium = "Середнє",
        sz_large = "Велике",
        se_info = "ℹ️ Про екзекутор",
        i_executor = "Екзекутор",
        i_hooking = "Хуки",
        i_incoming = "Вхідні",
        i_files = "Файли",
        i_clip = "Буфер обміну",
        i_platform = "Платформа",
        v_avail = "✅ Доступно",
        v_unavail = "❌ Недоступно",
        v_safe = "✅ Безпечно (getconnections)",
        v_delayed = "⚠ Із затримкою (10 с)",
        v_mobile = "📱 Телефон",
        v_pc = "💻 ПК",
        n_inc_on = "Вхідні події записуються",
        n_inc_off = "Вхідні події ігноруються",
        n_paused = "Запис призупинено",
        n_resumed = "Запис продовжено",
        n_autosave_on = "Автозбереження кожні %ds → %s",
        n_autosave_off = "Автозбереження вимкнено",
        n_lang = "Мова: %s",
        credits = "від Rival960 — Зроблено за допомогою Claude",
        tab_errors = "Помилки",
        ok = "ОК",
        cancel = "Скасувати",
        off = "Вимк",
        status_events = "подій: %d",
        status_flood = "пропущено: %d (флуд)",
        status_errors = "помилок: %d",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Відстежувані",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Відстежувати",
        unwatch = "☆ Не відстежувати",
        st_watched = "⭐ Відстежується",
        dir_local = "🔁 Клієнт ↔ Клієнт (локально)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (сервер питає клієнта)",
        code_clientinvoke_note = "-- Сервер викликав OnClientInvoke цієї RemoteFunction з:",
        k_grouped = "Згруповано",
        grouped_fmt = "%d однакових викликів поспіль",
        k_flood = "Флуд",
        flood_fmt = "%d викликів пропущено перед цим (антифлуд)",
        skipped_prefix = "(+%d пропущено)",
        sec_stats = "📈  СТАТИСТИКА ЦЬОГО РЕМОУТА",
        k_total = "Усього викликів",
        k_rate = "Частота",
        rate_fmt = "%.1f викликів / хв",
        k_first_last = "Перший → останній",
        k_callers = "Хто викликав",
        diff_hint = "зміни щодо попереднього виклику — жовтим",
        diff_was = "було: %s",
        sec_return = "↩  ПОВЕРНУТО СЕРВЕРОМ",
        ret_nothing = "(нічого не повернуто)",
        ret_waiting = "Очікування відповіді сервера…",
        ret_disabled = "Увімкни «Захоплювати повернення InvokeServer» у налаштуваннях",
        n_alert = "🔔 Тривога: %s (ключове слово «%s»)",
        n_saved_game = "збережено для цієї гри",
        n_watch_on = "⭐ %s додано до відстежуваних",
        n_watch_off = "%s прибрано з відстежуваних",
        empty_feed = "Подій поки немає — пограй трохи, кожен виклик ремоута з'явиться тут.",
        empty_filter = "Нічого не відповідає фільтру.",
        empty_network = "Трафік ще не записано.",
        empty_scripts = "Натисни «Сканувати скрипти», щоб побачити клієнтські скрипти гри.",
        empty_errors = "Помилок немає — усе працює.",
        net_click_hint = "натисни рядок, щоб відфільтрувати спай",
        err_copy = "📋 Копіювати все",
        err_clear = "🧹 Очистити",
        err_count = "помилок: %d",
        c_errors = "Помилки",
        hi_export_script = "🧾 Експорт як скрипт",
        se_capture = "📡 Захоплення",
        se_returns = "↩ Захоплювати повернення InvokeServer",
        se_returns_note = "Показує відповідь сервера. Вимкни, якщо гра поводиться дивно.",
        se_clientinvoke = "📨 Захоплювати OnClientInvoke (потрібен getcallbackvalue)",
        se_bindables = "🔗 Стежити за BindableEvent / BindableFunction",
        se_group = "🧮 Групувати однакові виклики (×N)",
        se_flood = "🌊 Антифлуд (макс. записаних викликів на ремоут за секунду)",
        se_alerts = "🔔 Сповіщення",
        se_alerts_on = "🔔 Сповіщати, якщо назва ремоута містить ключове слово",
        se_keywords = "Ключові слова (через кому)",
        n_keywords_saved = "Ключові слова збережено",
        se_appearance = "🎨 Вигляд",
        se_accent = "Колір акценту",
        c_blue = "Синій",
        c_purple = "Фіолетовий",
        c_green = "Зелений",
        c_red = "Червоний",
        c_orange = "Помаранчевий",
        se_transparency = "Прозорість вікна",
        se_textsize = "Розмір тексту",
        se_bottomtabs = "📱 Вкладки внизу",
        se_keybind = "⌨ Клавіша показати / сховати: %s (натисни, щоб змінити)",
        se_keybind_wait = "Натисни клавішу… (Esc = скасувати)",
        n_keybind = "Клавіша: %s",
        se_tools = "🧰 Інструменти",
        se_export_script = "🧾 Експорт сесії як скрипта повтору",
        se_whatsnew = "🎉 Що нового",
        se_unload = "⏏ Вивантажити RobloxSpy",
        unload_title = "Вивантажити RobloxSpy?",
        unload_body = "Хуки знімаються, сесія зберігається, інтерфейс закривається. Запусти скрипт знову, щоб перезапустити.",
        n_returns_on = "Повернення нових InvokeServer захоплюються",
        n_option_off = "Опцію вимкнено",
        n_need_fn = "%s не підтримується в %s",
        tip_maximize = "Розгорнути / відновити",
        tip_minimize = "Згорнути",
        tip_close = "Сховати (кругла кнопка поверне вікно)",
        tip_reopen = "Відкрити RobloxSpy (перетягни, щоб рухати)",
        tip_copy_r2s = "Копіювати код R2S",
        tip_ignore = "Ігнорувати ремоут (надсилається, але не пишеться)",
        tip_delete = "Видалити рядок",
        tip_pause = "Пауза / продовжити захоплення",
        tip_clear = "Очистити стрічку",
        tip_expand = "Збільшити вікно",
        tip_refire = "Надіслати виклик знову",
        tip_watch = "До відстежуваних (зберігається для гри)",
        tip_drop = "Блокувати: виклик не дійде до сервера",
        rn_title = "🎉 Що нового у v%s",
        rn_1 = "Повторний запуск замінює старий екземпляр, а нова кнопка «Вивантажити» чисто все прибирає.",
        rn_2 = "Антифлуд і групування: однакові виклики об'єднуються в один рядок «×N».",
        rn_3 = "Можна захоплювати повернення InvokeServer, OnClientInvoke і Bindables (Налаштування → Захоплення).",
        rn_4 = "Статистика ремоутів, підсвічування відмінностей від попереднього виклику, сповіщення за ключовими словами.",
        rn_5 = "Відстежувані та списки ігнору / блокування зберігаються для кожної гри.",
        rn_6 = "Експорт усієї сесії як скрипта повтору (Налаштування → Інструменти або Історія).",
        rn_7 = "Нові намальовані іконки, кнопка відкриття з лічильником, клавіша на ПК (RightShift).",
        rn_8 = "Телефон: вкладки внизу, більші рядки й кнопки. Підказки всюди (довге натискання на телефоні).",
        rn_9 = "Кольори акценту, прозорість і розмір тексту в Налаштування → Вигляд.",
        rn_10 = "Нова вкладка «Помилки», швидший провідник, легше автозбереження — і виправлення помилок.",
        as_live = "Постійно (кожні 2 с)",
    }

    LANG.CS = {
        lang_name = "Čeština",
        lang_flag = "🇨🇿",
        tab_spy = "Remote Spy",
        tab_explorer = "Průzkumník",
        tab_network = "Síť",
        tab_scripts = "Skripty",
        tab_history = "Historie",
        tab_settings = "Nastavení",
        status_ready = "Připraveno",
        status_recording = "● Nahrávání — %s · hook: %s",
        pause = "⏸ Pauza",
        resume = "▶ Pokračovat",
        clear = "🧹 Vymazat",
        f_all = "◉ Vše",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Příchozí",
        f_blocked = "⛔ Blokované",
        search_spy = "🔎 Filtrovat remoty, argumenty, cesty...",
        feed_cleared = "Seznam vymazán",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "PŘÍCHOZÍ",
        lbl_blocked = "BLOKOVÁNO",
        lbl_return = "NÁVRAT",
        back = "← Zpět",
        copy_code = "📋 Kopírovat kód",
        copy_path = "🧭 Kopírovat cestu",
        copy_args = "📦 Kopírovat argumenty",
        refire = "🔁 Odeslat znovu",
        ignore = "🔇 Ignorovat",
        unignore = "🔊 Přestat ignorovat",
        drop = "⛔ Blokovat volání",
        undrop = "✅ Povolit volání",
        delete = "🗑 Smazat",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTY (%d)",
        sec_r2s = "🧾  KÓD R2S (Remote → Script)",
        sec_replay = "🧪  KÓD PŘEHRÁNÍ",
        k_remote = "Remote",
        k_class = "Třída",
        k_method = "Metoda",
        k_direction = "Směr",
        k_path = "Cesta",
        k_caller = "Volající",
        k_call = "Volání č.",
        k_time = "Čas",
        k_status = "Stav",
        dir_out = "📤 Klient → Server",
        dir_in = "📥 Server → Klient",
        caller_unknown = "(neznámý / executor)",
        time_fmt = "+%.3fs od spuštění",
        st_logged = "Zaznamenáno",
        st_dropped = "⛔ Volání blokována",
        st_ignored = "🔇 Ignorováno",
        no_args = "(žádné argumenty)",
        n_refire_only_out = "Znovu lze odeslat jen odchozí volání",
        n_refired = "%s odesláno znovu",
        n_refire_fail = "Opětovné odeslání selhalo: %s",
        n_log_resumed = "Záznam obnoven pro %s",
        n_ignored = "%s ignorován — žádné další logy",
        n_cant_block_in = "Příchozí události nelze blokovat na straně klienta",
        n_allowed = "Volání %s jsou znovu povolena",
        n_blocked = "Volání %s jsou nyní BLOKOVÁNA",
        n_copied = "%s zkopírováno do schránky",
        n_no_clip = "Schránka není v tomto executoru dostupná",
        n_copy_fail = "Kopírování selhalo: %s",
        n_action_fail = "Akce selhala: %s",
        c_code = "Kód",
        c_path = "Cesta",
        c_args = "Argumenty",
        c_r2s = "Kód R2S",
        c_logs = "Logy",
        c_source = "Zdroj",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Vytvořeno: %s",
        code_incoming = "-- RobloxSpy — Příchozí událost (server → klient)",
        code_replay = "-- Přehraj lokálně přes firesignal (pokud ho executor má):",
        log_export_title = "RobloxSpy — Export logů",
        net_total = "CELKEM VOLÁNÍ",
        net_cps = "VOLÁNÍ/S",
        net_unique = "UNIKÁTNÍ",
        net_blocked = "BLOKOVÁNO",
        net_traffic = "Provoz (volání/s, posledních 60 s)",
        net_top = "🏆 Nejčastější remoty",
        ex_search = "🔍 Hledat v celé hře...",
        ex_props = "Vlastnosti",
        ex_results = "%d výsledků",
        ex_nil = "Instance nil",
        ex_select = "Vyber instanci ve stromu",
        ex_copy_path = "📋 Kopírovat cestu",
        ex_copy_code = "🧾 Kopírovat jako kód",
        ex_tp = "🚀 Teleport",
        ex_view_src = "📜 Zobrazit zdroj",
        ex_destroy = "🗑 Zničit",
        ex_clone = "📑 Klonovat",
        ex_attrs = "🏷  ATRIBUTY",
        ex_tags = "🔖  ŠTÍTKY",
        ex_children = "Potomci",
        ex_desc = "Všichni potomci",
        ex_too_many = "Zobrazeno prvních %d řádků — použij hledání",
        n_tp_ok = "Teleportováno k %s",
        n_tp_fail = "K této instanci se nelze teleportovat",
        n_destroyed = "%s zničeno (na klientu)",
        n_cloned = "%s naklonováno",
        n_prop_set = "%s = %s",
        n_prop_fail = "Nelze nastavit %s: %s",
        sc_scan = "🔍 Skenovat skripty",
        sc_search = "🔎 Filtrovat skripty...",
        sc_found = "Nalezeno skriptů: %d",
        sc_scanning = "Skenování... %d",
        sc_select = "Vyber skript k zobrazení",
        sc_copy = "📋 Kopírovat",
        sc_save = "💾 Uložit",
        sc_none = "-- Není vybrán žádný skript\n-- Klikni na 'Skenovat skripty' a vyber jeden",
        sc_fail = "-- Skript nelze dekompilovat\n-- Tvůj executor dekompilaci možná nepodporuje\n-- Cesta: %s",
        sc_decompiling = "-- Dekompilace...",
        sc_all = "Vše",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Běžící",
        sc_lines = "Řádků: %d",
        n_saved = "Uloženo → %s",
        n_save_fail = "Uložení selhalo: %s",
        n_no_write = "%s nepodporuje writefile — použij Kopírovat",
        n_nothing = "Zatím není co uložit",
        n_folder_fail = "Složku '%s' nelze v tomto executoru vytvořit",
        hi_title = "🕘 Historie relací",
        hi_refresh = "🔄 Obnovit",
        hi_current = "🔴 ŽIVĚ",
        hi_none = "Žádné uložené relace.",
        hi_nolist = "Tvůj executor neumí číst soubory — zobrazena je jen aktuální relace.",
        hi_calls = "Volání: %d",
        hi_unique = "Remotů: %d",
        hi_search_all = "🔎 Hledat ve všech relacích...",
        hi_results = "%d shod v %d relacích",
        hi_export = "💾 Exportovat .txt",
        hi_deleted = "Relace smazána",
        hi_showing = "Zobrazeno %d z %d záznamů",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Tato hra",
        se_lang = "🌐 Jazyk",
        se_save = "💾 Ukládání logů",
        se_where = "Soubory se ukládají do složky workspace executoru (PC: <Executor>/workspace — iPhone/Android: složka executoru v aplikaci Soubory).",
        se_nowrite = "⛔ Tvůj executor neumí zapisovat soubory (chybí writefile). Použij „Kopírovat logy“.",
        se_folder = "📂 Složka",
        se_last = "Naposledy uloženo: %s",
        se_txt = "📝 Uložit logy (.txt — čitelné + kód R2S)",
        se_json = "🧩 Uložit relaci (.json)",
        se_csv = "📊 Uložit relaci (.csv — Excel)",
        se_copy = "📋 Kopírovat logy (funguje všude)",
        se_autosave = "🔁 Automaticky ukládat logy do složky",
        se_interval = "⏱ Interval automatického ukládání",
        se_options = "🛠 Možnosti",
        se_incoming = "📥 Zaznamenávat příchozí události (server → klient)",
        se_autoscroll = "⬇ Automatické posouvání",
        se_pausecap = "⏸ Pozastavit záznam",
        se_size = "📐 Velikost okna",
        sz_small = "Malé",
        sz_medium = "Střední",
        sz_large = "Velké",
        se_info = "ℹ️ Info o executoru",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Příchozí",
        i_files = "Souborový systém",
        i_clip = "Schránka",
        i_platform = "Platforma",
        v_avail = "✅ Dostupné",
        v_unavail = "❌ Nedostupné",
        v_safe = "✅ Bezpečné (getconnections)",
        v_delayed = "⚠ Zpožděné (10 s)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Příchozí události se zaznamenávají",
        n_inc_off = "Příchozí události se ignorují",
        n_paused = "Záznam pozastaven",
        n_resumed = "Záznam obnoven",
        n_autosave_on = "Automatické ukládání každých %ds → %s",
        n_autosave_off = "Automatické ukládání vypnuto",
        n_lang = "Jazyk: %s",
        credits = "od Rival960 — Vytvořeno s pomocí Claude",
        tab_errors = "Chyby",
        ok = "OK",
        cancel = "Zrušit",
        off = "Vyp.",
        status_events = "událostí: %d",
        status_flood = "přeskočeno: %d (flood)",
        status_errors = "chyb: %d",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Sledované",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Sledovat",
        unwatch = "☆ Přestat sledovat",
        st_watched = "⭐ Sledováno",
        dir_local = "🔁 Klient ↔ Klient (lokálně)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (server se ptá klienta)",
        code_clientinvoke_note = "-- Server zavolal OnClientInvoke této RemoteFunction s:",
        k_grouped = "Seskupeno",
        grouped_fmt = "%d stejných volání za sebou",
        k_flood = "Flood",
        flood_fmt = "%d volání přeskočeno těsně předtím (anti-flood)",
        skipped_prefix = "(+%d přeskočeno)",
        sec_stats = "📈  STATISTIKY TOHOTO REMOTU",
        k_total = "Celkem volání",
        k_rate = "Frekvence",
        rate_fmt = "%.1f volání / min",
        k_first_last = "První → poslední",
        k_callers = "Volající",
        diff_hint = "změny oproti předchozímu volání žlutě",
        diff_was = "dříve: %s",
        sec_return = "↩  VRÁCENO SERVEREM",
        ret_nothing = "(nic nevráceno)",
        ret_waiting = "Čekám na odpověď serveru…",
        ret_disabled = "Zapni „Zachytávat návratové hodnoty InvokeServer“ v Nastavení",
        n_alert = "🔔 Upozornění: %s (klíčové slovo „%s“)",
        n_saved_game = "uloženo pro tuto hru",
        n_watch_on = "⭐ %s přidán do sledovaných",
        n_watch_off = "%s odebrán ze sledovaných",
        empty_feed = "Zatím žádné události — chvíli hraj, každé volání remotu se objeví tady.",
        empty_filter = "Tomuto filtru nic neodpovídá.",
        empty_network = "Zatím nebyl zaznamenán žádný provoz.",
        empty_scripts = "Klikni na „Skenovat skripty“ pro výpis klientských skriptů hry.",
        empty_errors = "Žádné chyby — vše funguje.",
        net_click_hint = "klikni na řádek pro filtrování spye",
        err_copy = "📋 Kopírovat vše",
        err_clear = "🧹 Vymazat",
        err_count = "chyb: %d",
        c_errors = "Chyby",
        hi_export_script = "🧾 Exportovat jako skript",
        se_capture = "📡 Zachytávání",
        se_returns = "↩ Zachytávat návratové hodnoty InvokeServer",
        se_returns_note = "Ukazuje, co server odpoví. Vypni, pokud se hra chová divně.",
        se_clientinvoke = "📨 Zachytávat OnClientInvoke (vyžaduje getcallbackvalue)",
        se_bindables = "🔗 Sledovat BindableEvent / BindableFunction",
        se_group = "🧮 Seskupovat stejná volání (×N)",
        se_flood = "🌊 Anti-flood (max. zaznamenaných volání na remote za sekundu)",
        se_alerts = "🔔 Upozornění",
        se_alerts_on = "🔔 Upozornit, když název remotu obsahuje klíčové slovo",
        se_keywords = "Klíčová slova (oddělená čárkou)",
        n_keywords_saved = "Klíčová slova uložena",
        se_appearance = "🎨 Vzhled",
        se_accent = "Barva zvýraznění",
        c_blue = "Modrá",
        c_purple = "Fialová",
        c_green = "Zelená",
        c_red = "Červená",
        c_orange = "Oranžová",
        se_transparency = "Průhlednost okna",
        se_textsize = "Velikost textu",
        se_bottomtabs = "📱 Lišta karet dole",
        se_keybind = "⌨ Klávesa zobrazit / skrýt: %s (klikni pro změnu)",
        se_keybind_wait = "Stiskni klávesu… (Esc = zrušit)",
        n_keybind = "Klávesa nastavena: %s",
        se_tools = "🧰 Nástroje",
        se_export_script = "🧾 Exportovat tuto relaci jako skript pro přehrání",
        se_whatsnew = "🎉 Co je nového",
        se_unload = "⏏ Uvolnit RobloxSpy",
        unload_title = "Uvolnit RobloxSpy?",
        unload_body = "Hooky se odstraní, relace se uloží a rozhraní se zavře. Pro restart spusť skript znovu.",
        n_returns_on = "Návratové hodnoty nových InvokeServer se zachytávají",
        n_option_off = "Možnost vypnuta",
        n_need_fn = "%s není podporováno v %s",
        tip_maximize = "Maximalizovat / obnovit",
        tip_minimize = "Minimalizovat",
        tip_close = "Skrýt (kulaté tlačítko ho vrátí)",
        tip_reopen = "Otevřít RobloxSpy (táhni pro přesun)",
        tip_copy_r2s = "Kopírovat kód R2S",
        tip_ignore = "Ignorovat tento remote (odesílá se, nezaznamenává)",
        tip_delete = "Smazat tento řádek",
        tip_pause = "Pozastavit / obnovit zachytávání",
        tip_clear = "Vymazat seznam",
        tip_expand = "Zvětšit okno",
        tip_refire = "Odeslat toto volání znovu",
        tip_watch = "Přidat do sledovaných (uloženo pro tuto hru)",
        tip_drop = "Blokovat: volání nikdy nedorazí na server",
        rn_title = "🎉 Novinky ve v%s",
        rn_1 = "Opětovné spuštění nahradí starou instanci a nové tlačítko „Uvolnit“ vše čistě odstraní.",
        rn_2 = "Anti-flood a seskupování: stejná volání se spojí do jednoho řádku „×N“.",
        rn_3 = "Lze zachytávat návratové hodnoty InvokeServer, OnClientInvoke a Bindables (Nastavení → Zachytávání).",
        rn_4 = "Statistiky remotů, zvýrazněné rozdíly oproti předchozímu volání, upozornění na klíčová slova.",
        rn_5 = "Sledované a seznamy ignorovaných / blokovaných se ukládají pro každou hru.",
        rn_6 = "Export celé relace jako přehratelného skriptu (Nastavení → Nástroje nebo Historie).",
        rn_7 = "Nové kreslené ikony, tlačítko otevření s počítadlem, klávesa na PC (RightShift).",
        rn_8 = "Mobil: karty dole, větší řádky a tlačítka. Nápověda všude (dlouhý stisk na mobilu).",
        rn_9 = "Barvy zvýraznění, průhlednost a velikost textu v Nastavení → Vzhled.",
        rn_10 = "Nová karta Chyby, rychlejší průzkumník, lehčí automatické ukládání — a řada oprav chyb.",
        as_live = "Průběžně (každé 2 s)",
    }

    LANG.DA = {
        lang_name = "Dansk",
        lang_flag = "🇩🇰",
        tab_spy = "Remote Spy",
        tab_explorer = "Stifinder",
        tab_network = "Netværk",
        tab_scripts = "Scripts",
        tab_history = "Historik",
        tab_settings = "Indstillinger",
        status_ready = "Klar",
        status_recording = "● Optager — %s · hook: %s",
        pause = "⏸ Pause",
        resume = "▶ Fortsæt",
        clear = "🧹 Ryd",
        f_all = "◉ Alle",
        f_fire = "🔥 Fire",
        f_invoke = "📞 Invoke",
        f_incoming = "📥 Indgående",
        f_blocked = "⛔ Blokeret",
        search_spy = "🔎 Filtrér remotes, argumenter, stier...",
        feed_cleared = "Listen er ryddet",
        lbl_fire = "FIRE",
        lbl_invoke = "INVOKE",
        lbl_incoming = "INDGÅENDE",
        lbl_blocked = "BLOKERET",
        lbl_return = "RETUR",
        back = "← Tilbage",
        copy_code = "📋 Kopiér kode",
        copy_path = "🧭 Kopiér sti",
        copy_args = "📦 Kopiér argumenter",
        refire = "🔁 Send igen",
        ignore = "🔇 Ignorér",
        unignore = "🔊 Stop med at ignorere",
        drop = "⛔ Blokér kald",
        undrop = "✅ Tillad kald",
        delete = "🗑 Slet",
        sec_info = "ℹ️  INFO",
        sec_args = "📦  ARGUMENTER (%d)",
        sec_r2s = "🧾  R2S-KODE (Remote → Script)",
        sec_replay = "🧪  AFSPILNINGSKODE",
        k_remote = "Remote",
        k_class = "Klasse",
        k_method = "Metode",
        k_direction = "Retning",
        k_path = "Sti",
        k_caller = "Kalder",
        k_call = "Kald nr.",
        k_time = "Tid",
        k_status = "Status",
        dir_out = "📤 Klient → Server",
        dir_in = "📥 Server → Klient",
        caller_unknown = "(ukendt / executor)",
        time_fmt = "+%.3fs efter start",
        st_logged = "Logget",
        st_dropped = "⛔ Kald blokeret",
        st_ignored = "🔇 Ignoreret",
        no_args = "(ingen argumenter)",
        n_refire_only_out = "Kun udgående kald kan sendes igen",
        n_refired = "%s sendt igen",
        n_refire_fail = "Kunne ikke sende igen: %s",
        n_log_resumed = "Logning genoptaget for %s",
        n_ignored = "%s ignoreres — ikke flere logs",
        n_cant_block_in = "Indgående events kan ikke blokeres fra klienten",
        n_allowed = "Kald til %s er tilladt igen",
        n_blocked = "Kald til %s er nu BLOKERET",
        n_copied = "%s kopieret til udklipsholderen",
        n_no_clip = "Udklipsholder er ikke tilgængelig i denne executor",
        n_copy_fail = "Kopiering mislykkedes: %s",
        n_action_fail = "Handling mislykkedes: %s",
        c_code = "Kode",
        c_path = "Sti",
        c_args = "Argumenter",
        c_r2s = "R2S-kode",
        c_logs = "Logs",
        c_source = "Kildekode",
        code_r2s = "-- RobloxSpy — Remote-to-Script",
        code_generated = "-- Oprettet: %s",
        code_incoming = "-- RobloxSpy — Indgående event (server → klient)",
        code_replay = "-- Afspil lokalt med firesignal (hvis din executor har det):",
        log_export_title = "RobloxSpy — Logeksport",
        net_total = "KALD I ALT",
        net_cps = "KALD/S",
        net_unique = "UNIKKE",
        net_blocked = "BLOKERET",
        net_traffic = "Trafik (kald/s, seneste 60 s)",
        net_top = "🏆 Top-remotes (efter kald)",
        ex_search = "🔍 Søg i hele spillet...",
        ex_props = "Egenskaber",
        ex_results = "%d resultater",
        ex_nil = "Nil-instanser",
        ex_select = "Vælg en instans i træet",
        ex_copy_path = "📋 Kopiér sti",
        ex_copy_code = "🧾 Kopiér som kode",
        ex_tp = "🚀 Teleportér",
        ex_view_src = "📜 Vis kildekode",
        ex_destroy = "🗑 Ødelæg",
        ex_clone = "📑 Klon",
        ex_attrs = "🏷  ATTRIBUTTER",
        ex_tags = "🔖  TAGS",
        ex_children = "Børn",
        ex_desc = "Efterkommere",
        ex_too_many = "Viser de første %d rækker — brug søgning",
        n_tp_ok = "Teleporteret til %s",
        n_tp_fail = "Kan ikke teleportere til denne instans",
        n_destroyed = "%s ødelagt (klientside)",
        n_cloned = "%s klonet",
        n_prop_set = "%s = %s",
        n_prop_fail = "Kan ikke ændre %s: %s",
        sc_scan = "🔍 Scan scripts",
        sc_search = "🔎 Filtrér scripts...",
        sc_found = "%d scripts fundet",
        sc_scanning = "Scanner... %d",
        sc_select = "Vælg et script at vise",
        sc_copy = "📋 Kopiér",
        sc_save = "💾 Gem",
        sc_none = "-- Intet script valgt\n-- Klik på 'Scan scripts' og vælg et",
        sc_fail = "-- Scriptet kunne ikke dekompileres\n-- Din executor understøtter måske ikke dekompilering\n-- Sti: %s",
        sc_decompiling = "-- Dekompilerer...",
        sc_all = "Alle",
        sc_local = "Local",
        sc_module = "Module",
        sc_running = "Kører",
        sc_lines = "%d linjer",
        n_saved = "Gemt → %s",
        n_save_fail = "Kunne ikke gemme: %s",
        n_no_write = "%s understøtter ikke writefile — brug Kopiér",
        n_nothing = "Intet at gemme endnu",
        n_folder_fail = "Kan ikke oprette mappen '%s' i denne executor",
        hi_title = "🕘 Sessionshistorik",
        hi_refresh = "🔄 Opdatér",
        hi_current = "🔴 LIVE",
        hi_none = "Ingen gemte sessioner.",
        hi_nolist = "Din executor kan ikke læse filer — kun den aktuelle session vises.",
        hi_calls = "%d kald",
        hi_unique = "%d remotes",
        hi_search_all = "🔎 Søg i alle sessioner...",
        hi_results = "%d match i %d sessioner",
        hi_export = "💾 Eksportér .txt",
        hi_deleted = "Session slettet",
        hi_showing = "Viser %d af %d poster",
        hi_duration = "%dm %ds",
        hi_same_game = "📍 Dette spil",
        se_lang = "🌐 Sprog",
        se_save = "💾 Gem logs",
        se_where = "Filer gemmes i executorens workspace-mappe (PC: <Executor>/workspace — iPhone/Android: executorens mappe i appen Filer).",
        se_nowrite = "⛔ Din executor kan ikke skrive filer (writefile mangler). Brug \"Kopiér logs\".",
        se_folder = "📂 Mappe",
        se_last = "Senest gemt: %s",
        se_txt = "📝 Gem logs (.txt — læsbart + R2S-kode)",
        se_json = "🧩 Gem session (.json)",
        se_csv = "📊 Gem session (.csv — Excel)",
        se_copy = "📋 Kopiér logs (virker overalt)",
        se_autosave = "🔁 Gem logs automatisk i mappen",
        se_interval = "⏱ Interval for autogem",
        se_options = "🛠 Indstillinger",
        se_incoming = "📥 Log indgående events (server → klient)",
        se_autoscroll = "⬇ Automatisk rulning",
        se_pausecap = "⏸ Sæt optagelse på pause",
        se_size = "📐 Vinduesstørrelse",
        sz_small = "Lille",
        sz_medium = "Mellem",
        sz_large = "Stor",
        se_info = "ℹ️ Executor-info",
        i_executor = "Executor",
        i_hooking = "Hooking",
        i_incoming = "Indgående",
        i_files = "Filsystem",
        i_clip = "Udklipsholder",
        i_platform = "Platform",
        v_avail = "✅ Tilgængelig",
        v_unavail = "❌ Ikke tilgængelig",
        v_safe = "✅ Sikker (getconnections)",
        v_delayed = "⚠ Forsinket (10 s)",
        v_mobile = "📱 Mobil",
        v_pc = "💻 PC",
        n_inc_on = "Indgående events logges",
        n_inc_off = "Indgående events ignoreres",
        n_paused = "Optagelse sat på pause",
        n_resumed = "Optagelse genoptaget",
        n_autosave_on = "Autogem hvert %ds → %s",
        n_autosave_off = "Autogem slået fra",
        n_lang = "Sprog: %s",
        credits = "af Rival960 — Lavet med hjælp fra Claude",
        tab_errors = "Fejl",
        ok = "OK",
        cancel = "Annullér",
        off = "Fra",
        status_events = "%d events",
        status_flood = "%d sprunget over (flood)",
        status_errors = "%d fejl",
        f_clientinvoke = "📨 ClientInvoke",
        f_bindable = "🔗 Bindable",
        f_watched = "⭐ Overvågede",
        lbl_clientinvoke = "C-INVOKE",
        lbl_bindable = "BINDABLE",
        watch = "⭐ Overvåg",
        unwatch = "☆ Stop overvågning",
        st_watched = "⭐ Overvåges",
        dir_local = "🔁 Klient ↔ Klient (lokalt)",
        code_clientinvoke = "-- RobloxSpy — OnClientInvoke (serveren spørger klienten)",
        code_clientinvoke_note = "-- Serveren kaldte OnClientInvoke på denne RemoteFunction med:",
        k_grouped = "Grupperet",
        grouped_fmt = "%d identiske kald i træk",
        k_flood = "Flood",
        flood_fmt = "%d kald sprunget over lige før (anti-flood)",
        skipped_prefix = "(+%d sprunget over)",
        sec_stats = "📈  STATISTIK FOR DENNE REMOTE",
        k_total = "Kald i alt",
        k_rate = "Frekvens",
        rate_fmt = "%.1f kald / min",
        k_first_last = "Første → seneste",
        k_callers = "Kaldere",
        diff_hint = "ændringer ift. forrige kald med gult",
        diff_was = "før: %s",
        sec_return = "↩  RETURNERET AF SERVEREN",
        ret_nothing = "(intet returneret)",
        ret_waiting = "Venter på serverens svar…",
        ret_disabled = "Slå \"Fang InvokeServer-returværdier\" til i Indstillinger",
        n_alert = "🔔 Advarsel: %s (nøgleord \"%s\")",
        n_saved_game = "gemt for dette spil",
        n_watch_on = "⭐ %s føjet til overvågningslisten",
        n_watch_off = "%s fjernet fra overvågningslisten",
        empty_feed = "Ingen events endnu — spil lidt, hvert remote-kald vises her.",
        empty_filter = "Intet matcher dette filter.",
        empty_network = "Ingen trafik registreret endnu.",
        empty_scripts = "Klik på \"Scan scripts\" for at vise spillets klientscripts.",
        empty_errors = "Ingen fejl — alt kører.",
        net_click_hint = "klik på en række for at filtrere spyen",
        err_copy = "📋 Kopiér alt",
        err_clear = "🧹 Ryd",
        err_count = "%d fejl",
        c_errors = "Fejl",
        hi_export_script = "🧾 Eksportér som script",
        se_capture = "📡 Opsamling",
        se_returns = "↩ Fang InvokeServer-returværdier",
        se_returns_note = "Viser hvad serveren svarer. Slå fra, hvis et spil opfører sig mærkeligt.",
        se_clientinvoke = "📨 Fang OnClientInvoke (kræver getcallbackvalue)",
        se_bindables = "🔗 Spionér på BindableEvent / BindableFunction",
        se_group = "🧮 Gruppér identiske kald (×N)",
        se_flood = "🌊 Anti-flood (maks. loggede kald pr. remote pr. sekund)",
        se_alerts = "🔔 Advarsler",
        se_alerts_on = "🔔 Giv besked, når et remote-navn indeholder et nøgleord",
        se_keywords = "Nøgleord (adskilt med komma)",
        n_keywords_saved = "Nøgleord gemt",
        se_appearance = "🎨 Udseende",
        se_accent = "Accentfarve",
        c_blue = "Blå",
        c_purple = "Lilla",
        c_green = "Grøn",
        c_red = "Rød",
        c_orange = "Orange",
        se_transparency = "Vinduets gennemsigtighed",
        se_textsize = "Tekststørrelse",
        se_bottomtabs = "📱 Fanebjælke nederst",
        se_keybind = "⌨ Tast vis / skjul: %s (klik for at ændre)",
        se_keybind_wait = "Tryk på en tast… (Esc = annullér)",
        n_keybind = "Tast indstillet: %s",
        se_tools = "🧰 Værktøjer",
        se_export_script = "🧾 Eksportér denne session som afspilningsscript",
        se_whatsnew = "🎉 Nyheder",
        se_unload = "⏏ Afmonter RobloxSpy",
        unload_title = "Afmonter RobloxSpy?",
        unload_body = "Hooks fjernes, sessionen gemmes og grænsefladen lukkes. Kør scriptet igen for at genstarte.",
        n_returns_on = "Returværdier for nye InvokeServer fanges",
        n_option_off = "Indstilling slået fra",
        n_need_fn = "%s understøttes ikke af %s",
        tip_maximize = "Maksimér / gendan",
        tip_minimize = "Minimér",
        tip_close = "Skjul (den runde knap henter det tilbage)",
        tip_reopen = "Åbn RobloxSpy (træk for at flytte)",
        tip_copy_r2s = "Kopiér R2S-koden",
        tip_ignore = "Ignorér denne remote (sendes, logges ikke)",
        tip_delete = "Slet denne række",
        tip_pause = "Sæt opsamling på pause / genoptag",
        tip_clear = "Ryd listen",
        tip_expand = "Forstør vinduet",
        tip_refire = "Send dette kald igen",
        tip_watch = "Føj til overvågningslisten (gemt for dette spil)",
        tip_drop = "Blokér: kaldet når aldrig serveren",
        rn_title = "🎉 Nyt i v%s",
        rn_1 = "At køre scriptet igen erstatter den gamle instans, og den nye \"Afmonter\"-knap fjerner alt rent.",
        rn_2 = "Anti-flood og gruppering: identiske kald samles i én række \"×N\".",
        rn_3 = "InvokeServer-returværdier, OnClientInvoke og Bindables kan fanges (Indstillinger → Opsamling).",
        rn_4 = "Statistik pr. remote, fremhævede forskelle fra forrige kald, nøgleordsadvarsler.",
        rn_5 = "Overvågningslisten og ignorér- / blokérlister gemmes pr. spil.",
        rn_6 = "Eksportér en hel session som afspilleligt script (Indstillinger → Værktøjer eller Historik).",
        rn_7 = "Nye tegnede ikoner, åbn-knap med tæller for ulæste, PC-tast (RightShift).",
        rn_8 = "Mobil: faner nederst, større rækker og knapper. Tips overalt (langt tryk på mobil).",
        rn_9 = "Accentfarver, gennemsigtighed og tekststørrelse under Indstillinger → Udseende.",
        rn_10 = "Ny Fejl-fane, hurtigere stifinder, lettere autogem — plus flere fejlrettelser.",
        as_live = "Live (hvert 2. s)",
    }

    -- Roblox locale prefix → language code
    local LOCALE_MAP = {
        en = "EN", fr = "FR", de = "DE", es = "ES", pt = "PT", ru = "RU", it = "IT",
        nl = "NL", pl = "PL", zh = "ZH", ja = "JA", tr = "TR", ko = "KO", ar = "AR",
        vi = "VI", sv = "SV", el = "EL", ro = "RO", uk = "UK", cs = "CS", da = "DA",
    }

    local function detectLanguage()
        local code = nil
        pcall(function()
            local loc = game:GetService("LocalizationService").RobloxLocaleId -- e.g. "fr-fr"
            code = LOCALE_MAP[tostring(loc):sub(1, 2):lower()]
        end)
        if not code then
            pcall(function()
                local loc = game:GetService("Players").LocalPlayer.LocaleId
                code = LOCALE_MAP[tostring(loc):sub(1, 2):lower()]
            end)
        end
        return code or "EN"
    end

    local _current = Config.get("language")
    if not _current or not LANG[_current] then
        _current = detectLanguage()
    end

    function I18n.T(key, ...)
        local text = (LANG[_current] and LANG[_current][key]) or LANG.EN[key] or key
        if select("#", ...) > 0 then
            local ok, res = pcall(string.format, text, ...)
            if ok then return res end
            local okEN, resEN = pcall(string.format, LANG.EN[key] or key, ...)
            return okEN and resEN or text
        end
        return text
    end

    function I18n.setLanguage(code)
        if LANG[code] then
            _current = code
            return true
        end
        return false
    end

    function I18n.current()
        return _current
    end

    function I18n.getLanguages()
        local list = {}
        for _, code in ipairs(ORDER) do
            local t = LANG[code]
            if t then
                table.insert(list, { code = code, name = t.lang_name or code, flag = t.lang_flag or "" })
            end
        end
        return list
    end
    _G._RSPY.I18n = I18n
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/errors.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/errors.lua
        Internal error journal

        Every error RobloxSpy catches is recorded here (deduplicated with a
        counter) instead of being lost in the F9 console. The Errors tab
        lists them so the user can copy and report them.
    ]]

    local Errors = {}

    local MAX_ENTRIES = 200

    local _list = {}      -- ordered entries { source, message, count, first, last }
    local _byKey = {}     -- [source .. message] = entry
    local _listeners = {}

    local function notify(entry)
        for _, fn in ipairs(_listeners) do
            pcall(fn, entry)
        end
    end

    -- Records an error. Returns true the first time this exact error is seen.
    function Errors.add(source, message)
        source = tostring(source or "?")
        message = tostring(message or "?")
        local key = source .. "\0" .. message
        local now = os.time()

        local entry = _byKey[key]
        if entry then
            entry.count = entry.count + 1
            entry.last = now
            notify(entry)
            return false
        end

        entry = { source = source, message = message, count = 1, first = now, last = now }
        _byKey[key] = entry
        table.insert(_list, entry)
        if #_list > MAX_ENTRIES then
            local old = table.remove(_list, 1)
            _byKey[old.source .. "\0" .. old.message] = nil
        end

        warn("[RobloxSpy] " .. source .. ": " .. message)
        notify(entry)
        return true
    end

    -- Runs fn with a traceback on failure; the error is recorded under source.
    function Errors.guard(source, fn, ...)
        local args = table.pack(...)
        local ok, res = xpcall(function() return fn(table.unpack(args, 1, args.n)) end, function(e)
            local tb = (debug and debug.traceback) and debug.traceback("", 2) or ""
            return tostring(e) .. (tb ~= "" and ("\n" .. tb) or "")
        end)
        if not ok then Errors.add(source, res) end
        return ok, res
    end

    -- Also catch RobloxSpy errors that escape every pcall (they reach the
    -- F9 console): LogService errors that mention RobloxSpy are recorded.
    local _logConn
    function Errors.watchConsole()
        if _logConn then return end
        pcall(function()
            local LogService = game:GetService("LogService")
            _logConn = LogService.MessageOut:Connect(function(msg, msgType)
                if msgType ~= Enum.MessageType.MessageError then return end
                msg = tostring(msg)
                if msg:find("[RobloxSpy]", 1, true) then return end -- our own warn()
                local low = msg:lower()
                if low:find("robloxspy", 1, true) or low:find("rspy", 1, true) then
                    Errors.add("Console", msg)
                end
            end)
        end)
    end

    function Errors.stopConsole()
        if _logConn then pcall(function() _logConn:Disconnect() end) end
        _logConn = nil
    end

    function Errors.list()
        return _list
    end

    function Errors.count()
        return #_list
    end

    function Errors.clear()
        _list = {}
        _byKey = {}
        notify(nil)
    end

    -- fn(entry) — entry is nil when the journal was cleared
    function Errors.subscribe(fn)
        table.insert(_listeners, fn)
    end

    function Errors.toText()
        local lines = { "RobloxSpy — Error journal (" .. #_list .. ")" }
        for _, e in ipairs(_list) do
            table.insert(lines, string.format("[%s] x%d  %s: %s",
                os.date("%H:%M:%S", e.last), e.count, e.source, e.message))
        end
        return table.concat(lines, "\n")
    end

    -- pcall wrapper that records failures: Errors.try("source", fn, ...)
    function Errors.try(source, fn, ...)
        local result = table.pack(pcall(fn, ...))
        if not result[1] then
            Errors.add(source, result[2])
            return false, result[2]
        end
        return table.unpack(result, 1, result.n)
    end
    _G._RSPY.Errors = Errors
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/serializer.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/serializer.lua
        Value-to-code serializer

        Converts any Roblox/Lua value into a reproducible Lua code string.
        Used by Remote Spy for R2S (Remote-to-Script) code generation,
        and by Session Manager for JSON export.
    ]]

    local I18n = _G._RSPY.I18n

    local Serializer = {}

    -- ── INSTANCE PATH ────────────────────────────────────────────────
    -- Builds the shortest valid Lua path to reach an Instance.

    local function getInstancePath(inst)
        if not inst or not inst.Parent then
            return "nil --[[ destroyed/nil instance ]]"
        end

        local parts = {}
        local current = inst
        local maxDepth = 50

        while current and current ~= game and maxDepth > 0 do
            maxDepth = maxDepth - 1
            local name = current.Name

            -- Check if it's a service
            if current.Parent == game then
                local ok, svc = pcall(function()
                    return game:GetService(current.ClassName)
                end)
                if ok and svc == current then
                    table.insert(parts, 1, 'game:GetService("' .. current.ClassName .. '")')
                    return table.concat(parts, "")
                end
            end

            -- Valid Lua identifier?
            if name:match("^[%a_][%w_]*$") and not name:match("^%d") then
                table.insert(parts, 1, "." .. name)
            else
                -- Needs bracket notation
                table.insert(parts, 1, '["' .. name:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"]')
            end

            current = current.Parent
        end

        if #parts == 0 then return "game" end

        local path = table.concat(parts, "")
        -- Remove leading dot
        if path:sub(1, 1) == "." then
            path = "game." .. path:sub(2)
        else
            path = "game" .. path
        end

        return path
    end

    Serializer.getInstancePath = getInstancePath

    -- ── TYPE SERIALIZERS ─────────────────────────────────────────────

    local typeHandlers = {}

    typeHandlers["nil"] = function()
        return "nil"
    end

    typeHandlers["boolean"] = function(v)
        return tostring(v)
    end

    typeHandlers["number"] = function(v)
        if v ~= v then return "0/0" end            -- NaN
        if v == math.huge then return "math.huge" end
        if v == -math.huge then return "-math.huge" end
        -- Integer check
        if v == math.floor(v) and math.abs(v) < 2^53 then
            return tostring(v)
        end
        return string.format("%.14g", v)
    end

    typeHandlers["string"] = function(v)
        -- Use long brackets if it contains both quote types or newlines
        if v:find("\n") and not v:find("%]%]") then
            return "[[" .. v .. "]]"
        end
        -- Escape and quote
        local escaped = v:gsub('\\', '\\\\')
                         :gsub('"', '\\"')
                         :gsub('\n', '\\n')
                         :gsub('\r', '\\r')
                         :gsub('\t', '\\t')
                         :gsub('\0', '\\0')
        -- Replace non-printable
        escaped = escaped:gsub('[%z\1-\31\127-\255]', function(c)
            return string.format('\\%d', string.byte(c))
        end)
        return '"' .. escaped .. '"'
    end

    typeHandlers["Instance"] = function(v)
        local ok, path = pcall(getInstancePath, v)
        if ok then return path end
        return 'nil --[[ Instance: ' .. tostring(v) .. ' ]]'
    end

    typeHandlers["EnumItem"] = function(v)
        return tostring(v) -- e.g. Enum.KeyCode.W
    end

    typeHandlers["Enum"] = function(v)
        return tostring(v)
    end

    -- Roblox value types
    -- Declared first: the constructors below reference the table itself
    -- (a `local x = { … x … }` initializer can't see its own local).
    local robloxConstructors
    robloxConstructors = {
        Vector3 = function(v)
            if v == Vector3.zero then return "Vector3.zero" end
            if v == Vector3.one then return "Vector3.one" end
            return string.format("Vector3.new(%s, %s, %s)",
                typeHandlers["number"](v.X),
                typeHandlers["number"](v.Y),
                typeHandlers["number"](v.Z))
        end,

        Vector2 = function(v)
            if v == Vector2.zero then return "Vector2.zero" end
            return string.format("Vector2.new(%s, %s)",
                typeHandlers["number"](v.X),
                typeHandlers["number"](v.Y))
        end,

        CFrame = function(v)
            if v == CFrame.identity then return "CFrame.identity" end
            local comps = { v:GetComponents() }
            local strs = {}
            for _, c in ipairs(comps) do
                table.insert(strs, typeHandlers["number"](c))
            end
            return "CFrame.new(" .. table.concat(strs, ", ") .. ")"
        end,

        Color3 = function(v)
            -- Check common colors
            if v == Color3.new(1, 1, 1) then return "Color3.new(1, 1, 1)" end
            if v == Color3.new(0, 0, 0) then return "Color3.new(0, 0, 0)" end
            return string.format("Color3.new(%s, %s, %s)",
                typeHandlers["number"](v.R),
                typeHandlers["number"](v.G),
                typeHandlers["number"](v.B))
        end,

        BrickColor = function(v)
            return 'BrickColor.new("' .. tostring(v) .. '")'
        end,

        UDim2 = function(v)
            return string.format("UDim2.new(%s, %s, %s, %s)",
                typeHandlers["number"](v.X.Scale),
                typeHandlers["number"](v.X.Offset),
                typeHandlers["number"](v.Y.Scale),
                typeHandlers["number"](v.Y.Offset))
        end,

        UDim = function(v)
            return string.format("UDim.new(%s, %s)",
                typeHandlers["number"](v.Scale),
                typeHandlers["number"](v.Offset))
        end,

        Ray = function(v)
            return string.format("Ray.new(%s, %s)",
                robloxConstructors.Vector3(v.Origin),
                robloxConstructors.Vector3(v.Direction))
        end,

        Region3 = function(v)
            local cf = v.CFrame
            local sz = v.Size
            local min = cf.Position - sz / 2
            local max = cf.Position + sz / 2
            return string.format("Region3.new(%s, %s)",
                robloxConstructors.Vector3(min),
                robloxConstructors.Vector3(max))
        end,

        NumberRange = function(v)
            if v.Min == v.Max then
                return string.format("NumberRange.new(%s)", typeHandlers["number"](v.Min))
            end
            return string.format("NumberRange.new(%s, %s)",
                typeHandlers["number"](v.Min),
                typeHandlers["number"](v.Max))
        end,

        NumberSequenceKeypoint = function(v)
            return string.format("NumberSequenceKeypoint.new(%s, %s, %s)",
                typeHandlers["number"](v.Time),
                typeHandlers["number"](v.Value),
                typeHandlers["number"](v.Envelope))
        end,

        ColorSequenceKeypoint = function(v)
            return string.format("ColorSequenceKeypoint.new(%s, %s)",
                typeHandlers["number"](v.Time),
                robloxConstructors.Color3(v.Value))
        end,

        NumberSequence = function(v)
            local kps = {}
            for _, kp in ipairs(v.Keypoints) do
                table.insert(kps, robloxConstructors.NumberSequenceKeypoint(kp))
            end
            return "NumberSequence.new({" .. table.concat(kps, ", ") .. "})"
        end,

        ColorSequence = function(v)
            local kps = {}
            for _, kp in ipairs(v.Keypoints) do
                table.insert(kps, robloxConstructors.ColorSequenceKeypoint(kp))
            end
            return "ColorSequence.new({" .. table.concat(kps, ", ") .. "})"
        end,

        Rect = function(v)
            return string.format("Rect.new(%s, %s, %s, %s)",
                typeHandlers["number"](v.Min.X),
                typeHandlers["number"](v.Min.Y),
                typeHandlers["number"](v.Max.X),
                typeHandlers["number"](v.Max.Y))
        end,

        PhysicalProperties = function(v)
            return string.format("PhysicalProperties.new(%s, %s, %s, %s, %s)",
                typeHandlers["number"](v.Density),
                typeHandlers["number"](v.Friction),
                typeHandlers["number"](v.Elasticity),
                typeHandlers["number"](v.FrictionWeight),
                typeHandlers["number"](v.ElasticityWeight))
        end,

        Font = function(v)
            return string.format('Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)',
                tostring(v.Family),
                tostring(v.Weight.Name),
                tostring(v.Style.Name))
        end,

        Axes = function(v)
            local axes = {}
            if v.X then table.insert(axes, "Enum.Axis.X") end
            if v.Y then table.insert(axes, "Enum.Axis.Y") end
            if v.Z then table.insert(axes, "Enum.Axis.Z") end
            return "Axes.new(" .. table.concat(axes, ", ") .. ")"
        end,

        Faces = function(v)
            local faces = {}
            if v.Top then table.insert(faces, "Enum.NormalId.Top") end
            if v.Bottom then table.insert(faces, "Enum.NormalId.Bottom") end
            if v.Left then table.insert(faces, "Enum.NormalId.Left") end
            if v.Right then table.insert(faces, "Enum.NormalId.Right") end
            if v.Front then table.insert(faces, "Enum.NormalId.Front") end
            if v.Back then table.insert(faces, "Enum.NormalId.Back") end
            return "Faces.new(" .. table.concat(faces, ", ") .. ")"
        end,

        TweenInfo = function(v)
            return string.format("TweenInfo.new(%s, %s, %s, %s, %s, %s)",
                typeHandlers["number"](v.Time),
                tostring(v.EasingStyle),
                tostring(v.EasingDirection),
                typeHandlers["number"](v.RepeatCount),
                tostring(v.Reverses),
                typeHandlers["number"](v.DelayTime))
        end,

        PathWaypoint = function(v)
            return string.format("PathWaypoint.new(%s, %s)",
                robloxConstructors.Vector3(v.Position),
                tostring(v.Action))
        end,
    }

    -- ── TABLE SERIALIZER ─────────────────────────────────────────────

    local function serializeTable(tbl, indent, seen)
        seen = seen or {}
        indent = indent or 1

        if seen[tbl] then
            return '"<circular reference>"'
        end
        seen[tbl] = true

        local tabs = string.rep("    ", indent)
        local closeTabs = string.rep("    ", indent - 1)
        local parts = {}
        local arrayLen = #tbl
        local isArray = arrayLen > 0

        -- Check if pure array
        local isPureArray = true
        local count = 0
        for _ in pairs(tbl) do
            count = count + 1
        end
        isPureArray = isArray and count == arrayLen

        if isPureArray then
            -- Serialize as array
            for i, v in ipairs(tbl) do
                table.insert(parts, tabs .. Serializer.serialize(v, indent, seen))
            end
        else
            -- Mixed or dictionary
            -- Array part first
            for i = 1, arrayLen do
                table.insert(parts, tabs .. Serializer.serialize(tbl[i], indent, seen))
            end
            -- Dictionary part
            for k, v in pairs(tbl) do
                if type(k) ~= "number" or k < 1 or k > arrayLen or k ~= math.floor(k) then
                    local keyStr
                    if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                        keyStr = k
                    else
                        keyStr = "[" .. Serializer.serialize(k, indent, seen) .. "]"
                    end
                    table.insert(parts, tabs .. keyStr .. " = " .. Serializer.serialize(v, indent, seen))
                end
            end
        end

        seen[tbl] = nil

        if #parts == 0 then return "{}" end
        if #parts <= 3 and not table.concat(parts):find("\n") then
            -- Inline short tables
            local inline = {}
            for _, p in ipairs(parts) do
                table.insert(inline, p:match("^%s*(.-)%s*$"))
            end
            local result = "{ " .. table.concat(inline, ", ") .. " }"
            if #result < 80 then return result end
        end

        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. closeTabs .. "}"
    end

    -- ── MAIN SERIALIZE ───────────────────────────────────────────────

    function Serializer.serialize(value, indent, seen)
        indent = indent or 1
        local t = typeof(value)

        -- Primitives
        if typeHandlers[t] then
            return typeHandlers[t](value)
        end

        -- Roblox types
        if robloxConstructors[t] then
            local ok, result = pcall(robloxConstructors[t], value)
            if ok then return result end
            return '"<' .. t .. ': serialization failed>"'
        end

        -- Tables
        if t == "table" then
            return serializeTable(value, indent, seen or {})
        end

        -- Functions
        if t == "function" then
            local info = ""
            if debug and debug.getinfo then
                local ok, dbg = pcall(debug.getinfo, value)
                if ok and dbg then
                    info = dbg.source or "?"
                    if dbg.currentline then info = info .. ":" .. dbg.currentline end
                end
            end
            return '"<function: ' .. info .. '>"'
        end

        -- Userdata / thread / other
        return '"<' .. t .. ': ' .. tostring(value):gsub('"', '\\"') .. '>"'
    end

    -- ── R2S CODE GENERATION ──────────────────────────────────────────
    -- Generates a complete, runnable Lua script that replays a remote call.

    function Serializer.generateR2S(remote, method, args)
        local lines = {}

        -- Header
        local T = (I18n and I18n.T) or function(k) return k end
        table.insert(lines, T("code_r2s"))
        table.insert(lines, "-- Remote: " .. (remote and remote.Name or "?"))
        table.insert(lines, "-- Method: " .. (method or "?"))
        table.insert(lines, T("code_generated", os.date("%Y-%m-%d %H:%M:%S")))
        table.insert(lines, "")

        -- Remote path
        local remotePath = Serializer.serialize(remote)
        table.insert(lines, "local remote = " .. remotePath)
        table.insert(lines, "")

        -- Args
        -- args.n (table.pack) keeps nil holes: FireServer("a", nil, 5) has 3 args
        local argCount = args and (args.n or #args) or 0
        if argCount > 0 then
            for i = 1, argCount do
                local varName = "arg" .. i
                table.insert(lines, "local " .. varName .. " = " .. Serializer.serialize(args[i], 1))
            end
            table.insert(lines, "")

            -- Call
            local argNames = {}
            for i = 1, argCount do
                table.insert(argNames, "arg" .. i)
            end

            if method == "FireServer" then
                table.insert(lines, "remote:FireServer(" .. table.concat(argNames, ", ") .. ")")
            elseif method == "InvokeServer" then
                table.insert(lines, "local result = remote:InvokeServer(" .. table.concat(argNames, ", ") .. ")")
                table.insert(lines, "print(\"Return:\", result)")
            else
                table.insert(lines, "remote:" .. method .. "(" .. table.concat(argNames, ", ") .. ")")
            end
        else
            if method == "FireServer" then
                table.insert(lines, "remote:FireServer()")
            elseif method == "InvokeServer" then
                table.insert(lines, "local result = remote:InvokeServer()")
                table.insert(lines, "print(\"Return:\", result)")
            else
                table.insert(lines, "remote:" .. method .. "()")
            end
        end

        return table.concat(lines, "\n")
    end

    -- ── JSON-SAFE SERIALIZER ─────────────────────────────────────────
    -- For session storage. Converts to JSON-compatible tables.

    function Serializer.toJSON(value)
        local t = typeof(value)

        if t == "nil" then return nil end
        if t == "boolean" or t == "number" then return value end
        if t == "string" then return value end

        if t == "Instance" then
            return {
                __type = "Instance",
                class = value.ClassName,
                name = value.Name,
                path = getInstancePath(value),
            }
        end

        if t == "Vector3" then
            return { __type = "Vector3", x = value.X, y = value.Y, z = value.Z }
        end

        if t == "CFrame" then
            return { __type = "CFrame", components = { value:GetComponents() } }
        end

        if t == "Color3" then
            return { __type = "Color3", r = value.R, g = value.G, b = value.B }
        end

        if t == "EnumItem" then
            return { __type = "EnumItem", value = tostring(value) }
        end

        if t == "table" then
            local result = {}
            for k, v in pairs(value) do
                local key = type(k) == "number" and k or tostring(k)
                result[key] = Serializer.toJSON(v)
            end
            return result
        end

        -- Fallback
        return { __type = t, repr = tostring(value) }
    end

    -- ── COMPACT ONE-LINE SUMMARY ─────────────────────────────────────
    -- For log display: short, max ~120 chars.

    -- Serializes every argument (nil holes kept) → { {index, type, value} }
    function Serializer.serializeArgs(args)
        local out = {}
        local count = args and (args.n or #args) or 0
        for i = 1, count do
            local v = args[i]
            local ok, res = pcall(Serializer.serialize, v, 1)
            table.insert(out, { index = i, type = typeof(v), value = ok and res or tostring(v) })
        end
        return out
    end

    function Serializer.summarize(args, maxLen)
        maxLen = maxLen or 120
        local count = args and (args.n or #args) or 0
        if count == 0 then return "()" end

        local parts = {}
        for i = 1, count do
            local arg = args[i]
            local t = typeof(arg)
            local s
            if t == "string" then
                s = '"' .. (arg:sub(1, 30)) .. (#arg > 30 and "…" or "") .. '"'
            elseif t == "Instance" then
                s = arg.Name .. " [" .. arg.ClassName .. "]"
            elseif t == "table" then
                local n = 0
                for _ in pairs(arg) do n = n + 1 end
                s = "{" .. n .. " entries}"
            elseif t == "number" or t == "boolean" then
                s = tostring(arg)
            elseif t == "nil" then
                s = "nil"
            elseif t == "Vector3" then
                s = string.format("V3(%.1f,%.1f,%.1f)", arg.X, arg.Y, arg.Z)
            elseif t == "CFrame" then
                s = string.format("CF(%.1f,%.1f,%.1f)", arg.Position.X, arg.Position.Y, arg.Position.Z)
            elseif t == "Color3" then
                s = string.format("C3(%.2f,%.2f,%.2f)", arg.R, arg.G, arg.B)
            elseif t == "EnumItem" then
                s = tostring(arg)
            else
                s = "<" .. t .. ">"
            end
            table.insert(parts, s)
        end

        local result = "(" .. table.concat(parts, ", ") .. ")"
        if #result > maxLen then
            result = result:sub(1, maxLen - 1) .. "…"
        end
        return result
    end
    _G._RSPY.Serializer = Serializer
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/hooks.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/hooks.lua
        Remote call interception engine (v1.1.0)

        Captures:
          • outgoing  FireServer / InvokeServer          (__namecall or hookfunction)
          • result    values returned by InvokeServer     (optional)
          • incoming  OnClientEvent                       (listener, never steals)
          • clientinvoke  OnClientInvoke callbacks        (optional, getcallbackvalue)
          • bindable  BindableEvent:Fire / BindableFunction:Invoke (optional)

        CRITICAL RULES (each one fixed a real bug — never regress):
          1. No ":" method call inside the __namecall hook before the original
             is called: it overwrites the namecall method (lobbies break).
             Type checks use .ClassName only.
          2. Never filter with checkcaller() inside the hook (always true there).
          3. The hook only queues captures; processing + publishing run in a
             Heartbeat loop owned by the executor thread.
          4. The hookfunction fallback calls the TRUE original, never the
             hooked function (infinite recursion).
          5. OnClientEvent is listened to only once the game already listens
             (the first listener receives the queued server messages).
          6. "..." is captured with table.pack before any nested function.
    ]]

    local Compat = _G._RSPY.Compat
    local Serializer = _G._RSPY.Serializer
    local Errors = _G._RSPY.Errors

    local Hooks = {}

    -- ── STATE ────────────────────────────────────────────────────────
    local _started           = false
    local _unloaded          = false        -- true → hooks are pure pass-through
    local _strategy          = "none"       -- "namecall" | "hookfunc" | "none"
    local _callbacks         = {}
    local _resultCallbacks   = {}
    local _callId            = 0
    local _captureSeq        = 0            -- links an InvokeServer to its result
    local _originalNamecall  = nil
    local _hookedFunctions   = {}           -- { target = hookedFn, original = fn, method = name }
    local _incomingConns     = {}           -- every connection we own
    local _scannedRemotes    = {}           -- remotes already listened (OnClientEvent)
    local _processing        = false        -- recursion guard (replaces checkcaller)
    local _queue             = {}           -- raw captures waiting to be processed
    local _drainConn         = nil          -- Heartbeat connection draining _queue

    -- Options
    local _paused            = false
    local _logIncoming       = true
    local _captureReturns    = false        -- off by default: wraps InvokeServer in pcall
    local _captureClientInvoke = false
    local _spyBindables      = false
    local _floodLimit        = 30           -- max logged calls per remote per second (0 = no limit)

    -- Filters / rules
    local _blockedRemotes    = {}           -- [remote] = true  (ignored: not logged)
    local _dropRemotes       = {}           -- [remote] = true  (call cancelled)
    local _ignorePaths       = {}           -- [fullName] = true (per-game saved rules)
    local _dropPaths         = {}           -- [fullName] = true
    local _typeFilter        = nil

    -- Anti-flood
    local _rate              = {}           -- [remote] = { second, count }
    local _floodSkipped      = {}           -- [remote] = skipped since last logged call
    local _floodTotal        = 0

    -- OnClientInvoke wrappers
    local _clientInvokeWraps = {}           -- [remote] = { original = fn, wrapper = fn }

    -- ── HELPERS ──────────────────────────────────────────────────────
    local Players = game:GetService("Players")

    local FIRE_METHODS = {
        FireServer = "FireServer", fireServer = "FireServer",
        InvokeServer = "InvokeServer", invokeServer = "InvokeServer",
    }
    local BINDABLE_METHODS = {
        Fire = "Fire", fire = "Fire",
        Invoke = "Invoke", invoke = "Invoke",
    }

    -- Classes captured by the spy (checked with .ClassName: safe inside hooks)
    local REMOTE_CLASSES = {
        RemoteEvent = true,
        RemoteFunction = true,
        UnreliableRemoteEvent = true,
    }
    local BINDABLE_CLASSES = {
        BindableEvent = true,
        BindableFunction = true,
    }

    local function getClass(obj)
        if typeof(obj) ~= "Instance" then return nil end
        local cls = nil
        pcall(function() cls = obj.ClassName end)
        return cls
    end

    local function isRemoteInstance(obj)
        return REMOTE_CLASSES[getClass(obj)] == true
    end

    local function isCapturable(obj)
        local cls = getClass(obj)
        return REMOTE_CLASSES[cls] == true or BINDABLE_CLASSES[cls] == true
    end

    local function fullName(obj)
        local ok, name = pcall(function() return obj:GetFullName() end)
        return ok and name or tostring(obj)
    end

    local function generateCallId()
        _callId = _callId + 1
        return _callId
    end

    local function track(conn)
        if conn then table.insert(_incomingConns, conn) end
        return conn
    end

    -- ── EVENT PUBLISHING ─────────────────────────────────────────────
    local function publish(event)
        for _, cb in ipairs(_callbacks) do
            local ok, err = pcall(cb, event)
            if not ok then Errors.add("Hooks.callback", err) end
        end
    end

    local function publishResult(event)
        for _, cb in ipairs(_resultCallbacks) do
            local ok, err = pcall(cb, event)
            if not ok then Errors.add("Hooks.resultCallback", err) end
        end
    end

    -- Applies saved per-game path rules to a remote (runs in OUR thread)
    local function applyPathRules(remote)
        local name = fullName(remote)
        if _ignorePaths[name] then _blockedRemotes[remote] = true end
        if _dropPaths[name] then _dropRemotes[remote] = true end
    end

    -- Anti-flood: returns false when this call must not be logged
    local function allowByRate(remote)
        if _floodLimit <= 0 then return true end
        local sec = math.floor(os.clock())
        local r = _rate[remote]
        if not r or r[1] ~= sec then
            r = { sec, 0 }
            _rate[remote] = r
        end
        r[2] = r[2] + 1
        if r[2] > _floodLimit then
            _floodSkipped[remote] = (_floodSkipped[remote] or 0) + 1
            _floodTotal = _floodTotal + 1
            return false
        end
        return true
    end

    local function buildEvent(c, eventType, remoteType)
        local remote = c.remote
        local remotePath = ""
        local ok1, path = pcall(Serializer.getInstancePath, remote)
        remotePath = ok1 and path or tostring(remote)

        local serializedArgs = {}
        local ok2, sArgs = pcall(Serializer.serializeArgs, c.args or {})
        if ok2 then serializedArgs = sArgs end

        local name = "???"
        pcall(function() name = remote.Name end)

        local skipped = 0
        if eventType ~= "result" then
            skipped = _floodSkipped[remote] or 0
            _floodSkipped[remote] = nil
        end

        return {
            id             = generateCallId(),
            captureId      = c.captureId,
            type           = eventType,
            method         = c.method,
            remote         = remote,
            remoteName     = name,
            remotePath     = remotePath,
            remoteFullName = fullName(remote),
            remoteType     = remoteType or getClass(remote) or "Unknown",
            args           = c.args or {},
            serializedArgs = serializedArgs,
            r2s            = "",
            callingScript  = c.callingScript,
            timestamp      = c.time or os.clock(),
            blocked        = _dropRemotes[remote] == true,
            floodSkipped   = skipped,
        }
    end

    local function processCapture(c)
        if _paused then return end
        local remote = c.remote
        if typeof(remote) ~= "Instance" then return end

        -- Result of an InvokeServer: attached to its call, never a new row
        if c.kind == "result" then
            local ev = buildEvent(c, "result")
            publishResult(ev)
            return
        end

        if _blockedRemotes[remote] then return end
        if c.kind == "incoming" or c.kind == "clientinvoke" then
            if not isRemoteInstance(remote) then return end
        elseif not isCapturable(remote) then
            return
        end
        if _typeFilter and getClass(remote) ~= _typeFilter then return end
        if not allowByRate(remote) then return end

        local eventType = (c.kind == "incoming" and "incoming")
            or (c.kind == "clientinvoke" and "clientinvoke")
            or (c.kind == "bindable" and "bindable")
            or "outgoing"
        local ev = buildEvent(c, eventType)

        if eventType == "outgoing" or eventType == "bindable" then
            local ok3, code = pcall(Serializer.generateR2S, remote, c.method, c.args)
            if ok3 then ev.r2s = code end
        end

        publish(ev)
    end

    -- ── CAPTURE QUEUE ────────────────────────────────────────────────
    local function enqueue(kind, remote, method, args, callingScript, captureId)
        if _paused or _unloaded then return end
        if #_queue > 4000 then return end -- safety cap
        _queue[#_queue + 1] = {
            kind = kind, remote = remote, method = method,
            args = args, callingScript = callingScript,
            captureId = captureId, time = os.clock(),
        }
    end

    local function drainQueue()
        if #_queue == 0 then return end
        local batch = _queue
        _queue = {}
        for i = 1, #batch do
            local ok, err = pcall(processCapture, batch[i])
            if not ok then Errors.add("Hooks.process", err) end
        end
    end

    local function startDrain()
        if _drainConn then return end
        _drainConn = game:GetService("RunService").Heartbeat:Connect(drainQueue)
    end

    -- Shared capture logic (called from inside the hooks — no ":" calls here)
    local function captureCall(self, normalizedMethod, kind, args)
        local captureId = nil
        _processing = true
        pcall(function()
            _captureSeq = _captureSeq + 1
            captureId = _captureSeq
            local callingScript = nil
            local fn = Compat.getGlobal("getcallingscript")
            if fn then
                local okS, scr = pcall(fn)
                if okS then callingScript = scr end
            end
            enqueue(kind, self, normalizedMethod, args, callingScript, captureId)
        end)
        _processing = false
        return captureId
    end

    -- Calls the original and, if enabled, captures what InvokeServer returned
    local function callWithResult(original, self, captureId, ...)
        local res = table.pack(pcall(original, self, ...))
        if not res[1] then
            error(res[2], 0) -- same error the game would have received
        end
        enqueue("result", self, "InvokeServer", table.pack(table.unpack(res, 2, res.n)), nil, captureId)
        return table.unpack(res, 2, res.n)
    end

    -- ── STRATEGY 1: __namecall HOOK ──────────────────────────────────
    local function installNamecallHook()
        local hookmetamethod    = Compat.getGlobal("hookmetamethod")
        local getnamecallmethod = Compat.getGlobal("getnamecallmethod")
        local setnamecallmethod = Compat.getGlobal("setnamecallmethod")
        local newcclosure       = Compat.getGlobal("newcclosure")

        if not hookmetamethod or not getnamecallmethod then
            return false
        end

        local function namecallHook(self, ...)
            if _unloaded then
                return _originalNamecall(self, ...)
            end

            local method = getnamecallmethod()

            if not _processing and typeof(self) == "Instance" then
                local normalized = FIRE_METHODS[method]
                local kind = "outgoing"
                if not normalized and _spyBindables then
                    normalized = BINDABLE_METHODS[method]
                    kind = "bindable"
                end

                if normalized then
                    local cls = nil
                    pcall(function() cls = self.ClassName end) -- __index, not __namecall
                    local valid = (kind == "outgoing" and REMOTE_CLASSES[cls])
                        or (kind == "bindable" and BINDABLE_CLASSES[cls])

                    if valid then
                        local captureId = captureCall(self, normalized, kind, table.pack(...))

                        if kind == "outgoing" and _dropRemotes[self] then
                            return nil -- call cancelled by the user
                        end

                        -- Safety net: restore the method in case anything changed it
                        if setnamecallmethod then
                            pcall(setnamecallmethod, method)
                        end

                        if normalized == "InvokeServer" and _captureReturns then
                            return callWithResult(_originalNamecall, self, captureId, ...)
                        end
                    end
                end
            end

            return _originalNamecall(self, ...)
        end

        local wrappedHook = namecallHook
        if newcclosure then
            local ok, wrapped = pcall(newcclosure, namecallHook)
            if ok and wrapped then wrappedHook = wrapped end
        end

        -- Save the original BEFORE hooking: some executors return nil
        local preOriginal = nil
        pcall(function()
            local mt = Compat.getRawMetatable(game)
            if mt then preOriginal = rawget(mt, "__namecall") end
        end)
        _originalNamecall = preOriginal

        local ok, original = pcall(hookmetamethod, game, "__namecall", wrappedHook)
        if not ok then
            Errors.add("Hooks.namecall", "hookmetamethod failed: " .. tostring(original))
            return false
        end

        _originalNamecall = original or preOriginal
        if not _originalNamecall then
            Errors.add("Hooks.namecall", "hookmetamethod returned no original __namecall")
            return false
        end
        _strategy = "namecall"
        print("[RobloxSpy] ✓ __namecall hook installed")
        return true
    end

    -- ── STRATEGY 2: hookfunction FALLBACK ────────────────────────────
    local function installFunctionHooks()
        local hookfunction = Compat.getGlobal("hookfunction") or Compat.getGlobal("replaceclosure")
        local newcclosure  = Compat.getGlobal("newcclosure")
        if not hookfunction then return false end

        local function hookMethod(className, methodName, kind)
            local temp = nil
            pcall(function() temp = Instance.new(className) end)
            if not temp then return end

            local origMethod = nil
            pcall(function() origMethod = temp[methodName] end)
            pcall(function() temp:Destroy() end)
            if not origMethod then return end

            local original = nil -- the TRUE original, never origMethod after hooking

            local function hookFn(self, ...)
                if _unloaded or not original then
                    return (original or origMethod)(self, ...)
                end
                local valid = false
                if not _processing then
                    local cls = getClass(self)
                    valid = (kind == "outgoing" and REMOTE_CLASSES[cls])
                        or (kind == "bindable" and _spyBindables and BINDABLE_CLASSES[cls])
                end
                if valid then
                    local captureId = captureCall(self, methodName, kind, table.pack(...))
                    if kind == "outgoing" and _dropRemotes[self] then
                        return nil
                    end
                    if methodName == "InvokeServer" and _captureReturns then
                        return callWithResult(original, self, captureId, ...)
                    end
                end
                return original(self, ...)
            end

            local wrappedHook = hookFn
            if newcclosure then
                local ok2, wrapped = pcall(newcclosure, hookFn)
                if ok2 and wrapped then wrappedHook = wrapped end
            end

            -- Keep a clean copy first: some executors' hookfunction returns nil
            local clone = nil
            pcall(function()
                local cf = Compat.getGlobal("clonefunction") or Compat.getGlobal("clonefunc")
                if cf then clone = cf(origMethod) end
            end)

            local ok3, orig = pcall(hookfunction, origMethod, wrappedHook)
            if ok3 then
                original = orig or clone
                if original then
                    table.insert(_hookedFunctions, { target = origMethod, original = original, method = methodName })
                else
                    -- Hook installed but no way to call the original: neutralise it
                    _unloaded = true
                    Errors.add("Hooks.hookfunction", "no original returned for " .. methodName)
                end
            end
        end

        hookMethod("RemoteEvent", "FireServer", "outgoing")
        hookMethod("UnreliableRemoteEvent", "FireServer", "outgoing")
        hookMethod("RemoteFunction", "InvokeServer", "outgoing")
        hookMethod("BindableEvent", "Fire", "bindable")
        hookMethod("BindableFunction", "Invoke", "bindable")

        if #_hookedFunctions > 0 and not _unloaded then
            _strategy = "hookfunc"
            print("[RobloxSpy] ✓ hookfunction hooks installed (" .. #_hookedFunctions .. " methods)")
            return true
        end
        return false
    end

    -- ── INCOMING EVENTS / CLIENT INVOKES SCANNER ─────────────────────
    -- When nothing listens to a RemoteEvent yet, Roblox hands the queued
    -- server messages to the FIRST OnClientEvent connection. We therefore
    -- only listen once the game itself already listens.

    local _candidates   = {}   -- [RemoteEvent] = firstSeenClock
    local _functions    = {}   -- [RemoteFunction] = true (OnClientInvoke candidates)
    local _scanThread   = nil

    local function gameIsListening(remote)
        local getconnections = Compat.getGlobal("getconnections")
            or Compat.getGlobal("get_signal_cons")
        if getconnections then
            local ok, conns = pcall(getconnections, remote.OnClientEvent)
            if ok and type(conns) == "table" then
                return #conns > 0
            end
        end
        local seen = _candidates[remote]
        return seen ~= nil and (os.clock() - seen) > 10
    end

    local function tryListen(remote)
        if _scannedRemotes[remote] or not _logIncoming then return end
        if not remote.Parent then _candidates[remote] = nil; return end
        if not gameIsListening(remote) then return end

        _scannedRemotes[remote] = true
        _candidates[remote] = nil
        pcall(function()
            track(remote.OnClientEvent:Connect(function(...)
                enqueue("incoming", remote, "OnClientEvent", table.pack(...))
            end))
        end)
    end

    -- Wraps an existing OnClientInvoke callback (never creates one)
    local function tryWrapClientInvoke(remote)
        if not _captureClientInvoke then return end
        local getcallbackvalue = Compat.getGlobal("getcallbackvalue")
        if not getcallbackvalue then return end
        if not remote.Parent then _functions[remote] = nil; return end

        local okCb, current = pcall(getcallbackvalue, remote, "OnClientInvoke")
        if not okCb or type(current) ~= "function" then return end

        local wrap = _clientInvokeWraps[remote]
        if wrap and wrap.wrapper == current then return end -- still ours

        local original = current
        local wrapper = function(...)
            enqueue("clientinvoke", remote, "OnClientInvoke", table.pack(...))
            return original(...)
        end
        local okSet = pcall(function() remote.OnClientInvoke = wrapper end)
        if okSet then
            _clientInvokeWraps[remote] = { original = original, wrapper = wrapper }
        end
    end

    local function restoreClientInvokes()
        for remote, w in pairs(_clientInvokeWraps) do
            pcall(function()
                local getcallbackvalue = Compat.getGlobal("getcallbackvalue")
                local current = getcallbackvalue and getcallbackvalue(remote, "OnClientInvoke")
                if current == w.wrapper then
                    remote.OnClientInvoke = w.original
                end
            end)
        end
        _clientInvokeWraps = {}
    end

    local function addCandidate(obj)
        local cls = getClass(obj)
        if not REMOTE_CLASSES[cls] then return end
        applyPathRules(obj)
        if cls == "RemoteFunction" then
            _functions[obj] = true
        elseif not _scannedRemotes[obj] and not _candidates[obj] then
            _candidates[obj] = os.clock()
        end
    end

    local function scanForRemotes(container)
        local ok, descendants = pcall(function() return container:GetDescendants() end)
        if not ok then return end
        for i, obj in ipairs(descendants) do
            addCandidate(obj)
            if i % 5000 == 0 then task.wait() end
        end
    end

    local function startIncomingScanner()
        local containers = {}
        pcall(function() table.insert(containers, game:GetService("ReplicatedStorage")) end)
        pcall(function() table.insert(containers, game:GetService("Workspace")) end)
        pcall(function()
            local pl = Players.LocalPlayer
            if pl then table.insert(containers, pl) end
        end)

        for _, c in ipairs(containers) do
            pcall(function()
                track(c.DescendantAdded:Connect(addCandidate))
            end)
        end

        if not _scanThread then
            _scanThread = task.spawn(function()
                for _, c in ipairs(containers) do scanForRemotes(c) end
                while _started and not _unloaded do
                    for remote in pairs(_candidates) do
                        pcall(tryListen, remote)
                    end
                    if _captureClientInvoke then
                        for remote in pairs(_functions) do
                            pcall(tryWrapClientInvoke, remote)
                        end
                    end
                    task.wait(2)
                end
                _scanThread = nil
            end)
        end
    end

    -- ── PUBLIC API ───────────────────────────────────────────────────

    function Hooks.subscribe(callback)
        table.insert(_callbacks, callback)
        return #_callbacks
    end

    function Hooks.unsubscribe(id)
        if id and id <= #_callbacks then
            table.remove(_callbacks, id)
        end
    end

    -- callback(resultEvent) — resultEvent.captureId links it to the call
    function Hooks.onResult(callback)
        table.insert(_resultCallbacks, callback)
    end

    function Hooks.start()
        if _started then return true end
        _unloaded = false

        print("[RobloxSpy] Installing hooks...")
        print("[RobloxSpy] " .. Compat.report())

        startDrain()
        _started = true

        local success = installNamecallHook()
        if not success then
            warn("[RobloxSpy] __namecall hook unavailable, trying hookfunction...")
            success = installFunctionHooks()
        end

        pcall(startIncomingScanner)

        if not success then
            _strategy = "none"
            Errors.add("Hooks.start", "No hooking method available — outgoing calls will NOT be captured (incoming only)")
            return false
        end

        print("[RobloxSpy] ✓ Hooks active (strategy: " .. _strategy .. ")")
        return true
    end

    -- Light stop (teleport): stops listening, hooks stay pass-through-ready
    function Hooks.stop()
        _started = false
        for _, conn in ipairs(_incomingConns) do
            pcall(function() conn:Disconnect() end)
        end
        _incomingConns = {}
        _scannedRemotes = {}
        _candidates = {}
        _functions = {}
        _queue = {}
        if _drainConn then pcall(function() _drainConn:Disconnect() end); _drainConn = nil end
        _paused = true
    end

    -- Full unload: restores the original __namecall / functions / callbacks.
    -- Even if restoring fails, _unloaded makes every hook a pure pass-through.
    function Hooks.unload()
        _unloaded = true
        Hooks.stop()
        restoreClientInvokes()

        if _strategy == "namecall" and _originalNamecall then
            pcall(function()
                local hookmetamethod = Compat.getGlobal("hookmetamethod")
                if hookmetamethod then hookmetamethod(game, "__namecall", _originalNamecall) end
            end)
        elseif _strategy == "hookfunc" then
            local hookfunction = Compat.getGlobal("hookfunction") or Compat.getGlobal("replaceclosure")
            for _, h in ipairs(_hookedFunctions) do
                pcall(function()
                    if hookfunction then hookfunction(h.target, h.original) end
                end)
            end
        end
        _hookedFunctions = {}
        _callbacks = {}
        _resultCallbacks = {}
        _strategy = "none"
    end

    function Hooks.isUnloaded() return _unloaded end

    function Hooks.pause() _paused = true end
    function Hooks.resume() _paused = false end
    function Hooks.isPaused() return _paused end
    function Hooks.isActive() return _started end
    function Hooks.getStrategy() return _strategy end
    function Hooks.getQueueSize() return #_queue end
    function Hooks.getCallCount() return _callId end
    function Hooks.getFloodSkipped() return _floodTotal end

    function Hooks.blockRemote(remote)
        if typeof(remote) == "Instance" then _blockedRemotes[remote] = true end
    end
    function Hooks.unblockRemote(remote)
        if typeof(remote) == "Instance" then _blockedRemotes[remote] = nil end
    end
    function Hooks.isBlocked(remote)
        return _blockedRemotes[remote] == true
    end

    -- Ignore = hide from logs (calls still reach the server)
    function Hooks.ignoreRemote(remote) Hooks.blockRemote(remote) end
    function Hooks.unignoreRemote(remote) Hooks.unblockRemote(remote) end

    -- Drop = really cancel the call (it never reaches the server)
    function Hooks.dropRemote(remote)
        if typeof(remote) == "Instance" then _dropRemotes[remote] = true end
    end
    function Hooks.undropRemote(remote)
        if typeof(remote) == "Instance" then _dropRemotes[remote] = nil end
    end
    function Hooks.isDropped(remote)
        return _dropRemotes[remote] == true
    end

    -- Per-game saved rules (full names, applied as remotes are discovered)
    function Hooks.setPathRules(ignoreList, dropList)
        _ignorePaths, _dropPaths = {}, {}
        for _, p in ipairs(ignoreList or {}) do _ignorePaths[p] = true end
        for _, p in ipairs(dropList or {}) do _dropPaths[p] = true end
    end
    function Hooks.getFullName(remote)
        return fullName(remote)
    end

    -- Options
    function Hooks.setLogIncoming(enabled) _logIncoming = enabled and true or false end
    function Hooks.getLogIncoming() return _logIncoming end
    function Hooks.setCaptureReturns(enabled) _captureReturns = enabled and true or false end
    function Hooks.getCaptureReturns() return _captureReturns end
    function Hooks.setCaptureClientInvoke(enabled)
        _captureClientInvoke = enabled and true or false
        if not _captureClientInvoke then restoreClientInvokes() end
    end
    function Hooks.getCaptureClientInvoke() return _captureClientInvoke end
    function Hooks.canCaptureClientInvoke() return Compat.getGlobal("getcallbackvalue") ~= nil end
    function Hooks.setSpyBindables(enabled) _spyBindables = enabled and true or false end
    function Hooks.getSpyBindables() return _spyBindables end
    function Hooks.setFloodLimit(n) _floodLimit = math.max(0, tonumber(n) or 30) end
    function Hooks.getFloodLimit() return _floodLimit end

    function Hooks.setTypeFilter(filterType) _typeFilter = filterType end
    function Hooks.getTypeFilter() return _typeFilter end
    _G._RSPY.Hooks = Hooks
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: core/session.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — core/session.lua
        Session manager

        Records all remote activity per game session.
        Persists to disk as JSON files for cross-session search.
        Each session = one game join → leave cycle.
    ]]

    local Compat = _G._RSPY.Compat

    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")

    local Session = {}

    -- ── STATE ────────────────────────────────────────────────────────
    local _currentSession = nil
    local _saveInterval = 30    -- seconds between auto-saves
    local _maxEntries = 5000    -- per session, to prevent memory bloat
    local _autoSaveThread = nil

    local SESSION_DIR = "RobloxSpy/sessions"

    -- ── SESSION STRUCTURE ────────────────────────────────────────────
    --[[
    {
        id          = "uuid",
        gameId      = number,
        placeId     = number,
        gameName    = string,
        startTime   = number (os.time),
        endTime     = number? (nil until ended),
        playerName  = string,
        playerId    = number,
        executor    = string,
        entries     = {
            {
                t     = number (relative time from start, in ms),
                type  = "fire" | "invoke" | "incoming" | "return" | "block",
                remote = string (name),
                class  = string (ClassName),
                path   = string (full path),
                args   = string (summarized),
                caller = string? (script path),
            }
        },
        stats = {
            totalCalls     = number,
            uniqueRemotes  = number,
            blockedCalls   = number,
        }
    }
    ]]

    -- ── SESSION LIFECYCLE ────────────────────────────────────────────

    function Session.start()
        if _currentSession then
            Session.stop() -- end previous session
        end

        local player = Players.LocalPlayer
        local gameId = game.GameId
        local placeId = game.PlaceId

        -- Generate a short ID
        local id = string.format("%s_%d_%s",
            os.date("%Y%m%d_%H%M%S"),
            placeId,
            tostring(math.random(1000, 9999))
        )

        _currentSession = {
            id         = id,
            gameId     = gameId,
            placeId    = placeId,
            gameName   = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or "Unknown",
            startTime  = os.time(),
            endTime    = nil,
            playerName = player and player.Name or "?",
            playerId   = player and player.UserId or 0,
            executor   = Compat.ExecutorName or "Unknown",
            entries    = {},
            stats      = {
                totalCalls    = 0,
                uniqueRemotes = 0,
                blockedCalls  = 0,
            },
            _remoteSet = {}, -- internal: track unique remote names
            _startClock = os.clock(),
        }

        -- Safely fetch game name
        pcall(function()
            local MPS = game:GetService("MarketplaceService")
            local info = MPS:GetProductInfo(placeId)
            if info and info.Name then
                _currentSession.gameName = info.Name
            end
        end)

        -- Start auto-save
        Session._startAutoSave()

        print("[RobloxSpy:Session] Started: " .. id)
        return _currentSession
    end

    function Session.stop()
        if not _currentSession then return end

        _currentSession.endTime = os.time()

        -- Final save
        Session.save()

        -- Stop auto-save
        if _autoSaveThread then
            pcall(function() task.cancel(_autoSaveThread) end)
            _autoSaveThread = nil
        end

        print("[RobloxSpy:Session] Ended: " .. _currentSession.id
            .. " (" .. #_currentSession.entries .. " entries)")

        local ended = _currentSession
        _currentSession = nil
        return ended
    end

    -- ── RECORDING ────────────────────────────────────────────────────

    function Session.record(event)
        if not _currentSession then return end
        if #_currentSession.entries >= _maxEntries then return end

        local relativeTime = math.floor((os.clock() - _currentSession._startClock) * 1000)

        local entryType = "fire"
        if event.method == "InvokeServer" then
            entryType = "invoke"
        elseif event.method == "OnClientEvent" then
            entryType = "incoming"
        elseif event.type == "clientinvoke" then
            entryType = "clientinvoke"
        elseif event.type == "bindable" then
            entryType = "bindable"
        end
        if event.blocked then
            entryType = "block"
        end

        local remoteName = ""
        local remoteClass = ""
        local remotePath = ""
        pcall(function() remoteName = event.remote.Name end)
        pcall(function() remoteClass = event.remote.ClassName end)
        pcall(function()
            -- Lightweight path (no full serializer dependency to avoid circular require)
            local parts = {}
            local cur = event.remote
            local depth = 0
            while cur and cur ~= game and depth < 20 do
                table.insert(parts, 1, cur.Name)
                cur = cur.Parent
                depth = depth + 1
            end
            remotePath = "game." .. table.concat(parts, ".")
        end)

        local callerStr = nil
        local callerObj = event.callingScript or event.caller
        if callerObj then
            pcall(function() callerStr = callerObj:GetFullName() end)
        end

        -- Summarize args (lightweight, no full serialize)
        local argsSummary = ""
        pcall(function()
            local argParts = {}
            for i = 1, (event.args.n or #event.args) do
                local arg = event.args[i]
                local t = typeof(arg)
                if t == "string" then
                    local s = arg:sub(1, 40)
                    table.insert(argParts, '"' .. s .. (arg:len() > 40 and "…" or "") .. '"')
                elseif t == "Instance" then
                    table.insert(argParts, arg.Name)
                elseif t == "table" then
                    local n = 0; for _ in pairs(arg) do n = n + 1 end
                    table.insert(argParts, "{" .. n .. "}")
                elseif t == "number" or t == "boolean" then
                    table.insert(argParts, tostring(arg))
                elseif t == "nil" then
                    table.insert(argParts, "nil")
                else
                    table.insert(argParts, "<" .. t .. ">")
                end
                if i >= 6 then
                    table.insert(argParts, "...")
                    break
                end
            end
            argsSummary = table.concat(argParts, ", ")
        end)

        local entry = {
            t      = relativeTime,
            type   = entryType,
            remote = remoteName,
            class  = remoteClass,
            path   = remotePath,
            args   = argsSummary,
            caller = callerStr,
            -- Full R2S line(s), used by the "export as script" feature
            code   = (type(event.r2s) == "string" and event.r2s ~= "") and event.r2s:sub(1, 3000) or nil,
        }

        table.insert(_currentSession.entries, entry)

        -- Update stats
        _currentSession.stats.totalCalls = _currentSession.stats.totalCalls + 1
        if event.blocked then
            _currentSession.stats.blockedCalls = _currentSession.stats.blockedCalls + 1
        end
        if not _currentSession._remoteSet[remoteName] then
            _currentSession._remoteSet[remoteName] = true
            _currentSession.stats.uniqueRemotes = _currentSession.stats.uniqueRemotes + 1
        end
    end

    -- ── PERSISTENCE ──────────────────────────────────────────────────

    function Session.save()
        if not _currentSession then return false end
        if not Compat.has("writefile") then return false end

        -- Prepare serializable copy (strip internal fields)
        local data = {
            id         = _currentSession.id,
            gameId     = _currentSession.gameId,
            placeId    = _currentSession.placeId,
            gameName   = _currentSession.gameName,
            startTime  = _currentSession.startTime,
            endTime    = _currentSession.endTime,
            playerName = _currentSession.playerName,
            playerId   = _currentSession.playerId,
            executor   = _currentSession.executor,
            entries    = _currentSession.entries,
            stats      = _currentSession.stats,
        }

        local ok, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if not ok then
            warn("[RobloxSpy:Session] JSON encode failed:", json)
            return false
        end

        Compat.ensureFolder(SESSION_DIR)
        local path = SESSION_DIR .. "/" .. _currentSession.id .. ".json"
        local writeOk, writeErr = Compat.writeFile(path, json)
        if not writeOk then
            warn("[RobloxSpy:Session] Save failed:", writeErr)
            return false
        end

        return true
    end

    function Session._startAutoSave()
        _autoSaveThread = task.spawn(function()
            while _currentSession do
                task.wait(_saveInterval)
                if _currentSession then
                    Session.save()
                end
            end
        end)
    end

    -- ── LOADING PAST SESSIONS ────────────────────────────────────────

    function Session.listSessions()
        if not Compat.has("listfiles") then return {} end

        Compat.ensureFolder(SESSION_DIR)
        local files = Compat.listFiles(SESSION_DIR)
        local sessions = {}

        for _, filePath in ipairs(files) do
            if filePath:match("%.json$") then
                -- Read just the metadata (first pass: quick parse)
                local data = Compat.readFile(filePath)
                if data then
                    local ok, parsed = pcall(function()
                        return HttpService:JSONDecode(data)
                    end)
                    if ok and parsed then
                        table.insert(sessions, {
                            id         = parsed.id,
                            gameName   = parsed.gameName,
                            placeId    = parsed.placeId,
                            startTime  = parsed.startTime,
                            endTime    = parsed.endTime,
                            totalCalls = parsed.stats and parsed.stats.totalCalls or 0,
                            uniqueRemotes = parsed.stats and parsed.stats.uniqueRemotes or 0,
                            executor   = parsed.executor,
                            playerName = parsed.playerName,
                            entryCount = parsed.entries and #parsed.entries or 0,
                            isCurrent  = _currentSession ~= nil and parsed.id == _currentSession.id,
                            filePath   = filePath,
                        })
                    end
                end
            end
        end

        -- Sort by start time (newest first)
        table.sort(sessions, function(a, b) return (a.startTime or 0) > (b.startTime or 0) end)
        return sessions
    end

    function Session.loadSession(idOrPath)
        if not Compat.has("readfile") then return nil end

        local path = idOrPath
        if not path:match("%.json$") then
            path = SESSION_DIR .. "/" .. idOrPath .. ".json"
        end

        local data = Compat.readFile(path)
        if not data then return nil end

        local ok, parsed = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if ok then return parsed end
        return nil
    end

    function Session.deleteSession(idOrPath)
        local path = idOrPath
        if not path:match("%.json$") then
            path = SESSION_DIR .. "/" .. idOrPath .. ".json"
        end
        return Compat.deleteFile(path)
    end

    -- ── SEARCH ───────────────────────────────────────────────────────

    function Session.searchCurrent(query)
        if not _currentSession then return {} end
        return Session._searchEntries(_currentSession.entries, query)
    end

    function Session.searchSession(sessionId, query)
        local session = Session.loadSession(sessionId)
        if not session then return {} end
        return Session._searchEntries(session.entries, query)
    end

    function Session._searchEntries(entries, query)
        local results = {}
        local q = query:lower()

        for i, entry in ipairs(entries) do
            local match = false
            if entry.remote and entry.remote:lower():find(q, 1, true) then match = true end
            if entry.args and entry.args:lower():find(q, 1, true) then match = true end
            if entry.path and entry.path:lower():find(q, 1, true) then match = true end
            if entry.caller and entry.caller:lower():find(q, 1, true) then match = true end
            if entry.type and entry.type:lower() == q then match = true end

            if match then
                table.insert(results, { index = i, entry = entry })
            end
        end

        return results
    end

    -- Search every saved session at once → { {session=meta, matches={...}} }
    function Session.searchAll(query, maxPerSession)
        local out = {}
        if not query or query == "" then return out end
        for _, meta in ipairs(Session.listSessions()) do
            local data = Session.loadSession(meta.filePath or meta.id)
            if data and data.entries then
                local hits = Session._searchEntries(data.entries, query)
                if #hits > 0 then
                    local trimmed = {}
                    for i = 1, math.min(#hits, maxPerSession or 50) do trimmed[i] = hits[i] end
                    table.insert(out, { session = meta, matches = trimmed, total = #hits })
                end
            end
        end
        return out
    end

    -- Human-readable dump of any session table (current or loaded)
    function Session.toText(data)
        if not data then return "" end
        local lines = {
            "RobloxSpy — Session " .. tostring(data.id),
            "Game: " .. tostring(data.gameName) .. " (PlaceId " .. tostring(data.placeId) .. ")",
            "Player: " .. tostring(data.playerName) .. " · Executor: " .. tostring(data.executor),
            "Start: " .. (data.startTime and os.date("%Y-%m-%d %H:%M:%S", data.startTime) or "?")
                .. " · End: " .. (data.endTime and os.date("%Y-%m-%d %H:%M:%S", data.endTime) or "-"),
            string.rep("=", 60),
        }
        for _, e in ipairs(data.entries or {}) do
            table.insert(lines, string.format("[%7.2fs] %-8s %s  (%s)", (e.t or 0) / 1000, tostring(e.type):upper(), tostring(e.remote), tostring(e.path)))
            if e.args and e.args ~= "" then table.insert(lines, "           args: " .. e.args) end
            if e.caller then table.insert(lines, "           caller: " .. e.caller) end
        end
        return table.concat(lines, "\n")
    end

    -- Rebuilds a session as ONE replayable script: every outgoing call in
    -- order, with the original delays (capped) between them.
    function Session.toR2SScript(data, maxDelay)
        if not data then return "" end
        maxDelay = maxDelay or 5
        local lines = {
            "-- RobloxSpy — Session replay script",
            "-- Game: " .. tostring(data.gameName) .. " (PlaceId " .. tostring(data.placeId) .. ")",
            "-- Recorded: " .. (data.startTime and os.date("%Y-%m-%d %H:%M:%S", data.startTime) or "?"),
            "-- ⚠ Review before running: calls are replayed exactly as recorded.",
            "",
        }
        local lastT, n = nil, 0
        for _, e in ipairs(data.entries or {}) do
            if e.code and (e.type == "fire" or e.type == "invoke" or e.type == "block" or e.type == "bindable") then
                if lastT then
                    local gap = math.min(maxDelay, math.max(0, ((e.t or 0) - lastT) / 1000))
                    if gap >= 0.03 then
                        table.insert(lines, string.format("task.wait(%.2f)", gap))
                    end
                end
                lastT = e.t or 0
                n = n + 1
                table.insert(lines, string.format("-- [%d] %s  (%.2fs)", n, tostring(e.remote), (e.t or 0) / 1000))
                -- do … end keeps each call's locals separate (200-local limit)
                table.insert(lines, "do")
                for line in tostring(e.code):gmatch("[^\n]+") do
                    if not line:match("^%s*%-%-") then
                        table.insert(lines, "    " .. line)
                    end
                end
                table.insert(lines, "end")
                table.insert(lines, "")
            end
        end
        if n == 0 then
            table.insert(lines, "-- (no replayable outgoing calls in this session)")
        end
        return table.concat(lines, "\n")
    end

    -- ── CURRENT SESSION ACCESS ───────────────────────────────────────

    function Session.getCurrent()
        return _currentSession
    end

    function Session.getEntries()
        if not _currentSession then return {} end
        return _currentSession.entries
    end

    function Session.getEntryCount()
        if not _currentSession then return 0 end
        return #_currentSession.entries
    end

    function Session.getStats()
        if not _currentSession then return {} end
        return _currentSession.stats
    end

    function Session.getDuration()
        if not _currentSession then return 0 end
        return os.time() - _currentSession.startTime
    end

    -- ── EXPORT ───────────────────────────────────────────────────────

    function Session.exportCurrent(format)
        if not _currentSession then return nil end
        format = format or "json"

        if format == "json" then
            local ok, json = pcall(function()
                return HttpService:JSONEncode({
                    id         = _currentSession.id,
                    gameName   = _currentSession.gameName,
                    placeId    = _currentSession.placeId,
                    startTime  = _currentSession.startTime,
                    entries    = _currentSession.entries,
                    stats      = _currentSession.stats,
                })
            end)
            return ok and json or nil
        elseif format == "csv" then
            local lines = { "time_ms,type,remote,class,args,caller" }
            for _, e in ipairs(_currentSession.entries) do
                local row = string.format('%d,"%s","%s","%s","%s","%s"',
                    e.t or 0,
                    e.type or "",
                    (e.remote or ""):gsub('"', '""'),
                    e.class or "",
                    (e.args or ""):gsub('"', '""'),
                    (e.caller or ""):gsub('"', '""')
                )
                table.insert(lines, row)
            end
            return table.concat(lines, "\n")
        end

        return nil
    end
    _G._RSPY.Session = Session
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: gui/theme.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — gui/theme.lua
        Color theme & typography constants
    ]]

    local I18n = _G._RSPY.I18n
    local Config = _G._RSPY.Config

    local Theme = {}

    -- ── PALETTE ─────────────────────────────────────────────────────

    Theme.Colors = {
        -- Backgrounds
        BgDark       = Color3.fromRGB(14, 14, 18),
        BgPrimary    = Color3.fromRGB(22, 22, 28),
        BgSecondary  = Color3.fromRGB(28, 28, 36),
        BgTertiary   = Color3.fromRGB(35, 35, 44),
        BgHover      = Color3.fromRGB(42, 42, 52),
        BgSelected   = Color3.fromRGB(45, 45, 58),

        -- Accent
        Accent       = Color3.fromRGB(75, 130, 255),
        AccentHover  = Color3.fromRGB(95, 148, 255),
        AccentDim    = Color3.fromRGB(50, 90, 180),

        -- Text
        TextPrimary   = Color3.fromRGB(220, 220, 235),
        TextSecondary = Color3.fromRGB(150, 150, 168),
        TextMuted     = Color3.fromRGB(100, 100, 118),
        TextAccent    = Color3.fromRGB(130, 175, 255),

        -- Semantic
        Success      = Color3.fromRGB(80, 200, 120),
        Warning      = Color3.fromRGB(240, 180, 50),
        Error        = Color3.fromRGB(220, 70, 70),
        Info         = Color3.fromRGB(75, 130, 255),

        -- Remote types
        FireServer    = Color3.fromRGB(255, 140, 60),
        InvokeServer  = Color3.fromRGB(130, 100, 255),
        OnClientEvent = Color3.fromRGB(60, 200, 160),
        ClientInvoke  = Color3.fromRGB(240, 110, 190),
        Bindable      = Color3.fromRGB(150, 200, 70),
        Blocked       = Color3.fromRGB(220, 70, 70),
        Watched       = Color3.fromRGB(255, 210, 60),

        -- Borders
        Border       = Color3.fromRGB(55, 55, 65),
        BorderLight  = Color3.fromRGB(70, 70, 82),

        -- Scrollbar
        ScrollBar    = Color3.fromRGB(80, 80, 95),
    }

    -- ── ACCENT THEMES ──────────────────────────────────────────────
    -- Applied at startup and when changed in Settings (UI is rebuilt).

    Theme.Accents = {
        { id = "blue",   color = Color3.fromRGB(75, 130, 255) },
        { id = "purple", color = Color3.fromRGB(150, 95, 255) },
        { id = "green",  color = Color3.fromRGB(50, 190, 120) },
        { id = "red",    color = Color3.fromRGB(230, 75, 85) },
        { id = "orange", color = Color3.fromRGB(245, 145, 45) },
    }

    local function lighten(c, f)
        return Color3.new(math.min(1, c.R + (1 - c.R) * f), math.min(1, c.G + (1 - c.G) * f), math.min(1, c.B + (1 - c.B) * f))
    end
    local function darken(c, f)
        return Color3.new(c.R * (1 - f), c.G * (1 - f), c.B * (1 - f))
    end

    function Theme.applyAccent(id)
        for _, a in ipairs(Theme.Accents) do
            if a.id == id then
                Theme.Colors.Accent = a.color
                Theme.Colors.AccentHover = lighten(a.color, 0.15)
                Theme.Colors.AccentDim = darken(a.color, 0.3)
                Theme.Colors.TextAccent = lighten(a.color, 0.35)
                Theme.Colors.Info = a.color
                Theme.AccentId = id
                return true
            end
        end
        return false
    end

    -- ── TYPOGRAPHY ──────────────────────────────────────────────────

    Theme.Fonts = {
        Title    = Enum.Font.GothamBold,
        Heading  = Enum.Font.GothamBold,
        Body     = Enum.Font.Gotham,
        Medium   = Enum.Font.GothamMedium,
        Code     = Enum.Font.Code,
    }

    Theme.TextSizes = {
        Title   = 16,
        Heading = 14,
        Body    = 12,
        Small   = 11,
        Tiny    = 10,
        Code    = 12,
    }

    -- Text scale (Small / Normal / Large) — applied before the UI is built
    local BASE_SIZES = {}
    for k, v in pairs(Theme.TextSizes) do BASE_SIZES[k] = v end
    Theme.TextScales = { small = 0.9, normal = 1, large = 1.2 }

    function Theme.applyTextScale(id)
        local f = Theme.TextScales[id] or 1
        for k, v in pairs(BASE_SIZES) do
            Theme.TextSizes[k] = math.floor(v * f + 0.5)
        end
        Theme.TextScaleId = Theme.TextScales[id] and id or "normal"
    end

    -- ── SPACING ─────────────────────────────────────────────────────

    Theme.Spacing = {
        XS = 2,
        SM = 4,
        MD = 8,
        LG = 12,
        XL = 16,
    }

    Theme.CornerRadius = {
        SM = UDim.new(0, 4),
        MD = UDim.new(0, 6),
        LG = UDim.new(0, 8),
        XL = UDim.new(0, 12),
        Full = UDim.new(0.5, 0),
    }

    -- ── HELPERS ─────────────────────────────────────────────────────

    function Theme.getRemoteColor(entryType)
        if entryType == "fire" then return Theme.Colors.FireServer end
        if entryType == "invoke" then return Theme.Colors.InvokeServer end
        if entryType == "incoming" then return Theme.Colors.OnClientEvent end
        if entryType == "block" then return Theme.Colors.Blocked end
        if entryType == "clientinvoke" then return Theme.Colors.ClientInvoke end
        if entryType == "bindable" then return Theme.Colors.Bindable end
        return Theme.Colors.TextSecondary
    end

    function Theme.getRemoteLabel(entryType)
        local T = I18n.T
        if entryType == "fire" then return T("lbl_fire") end
        if entryType == "invoke" then return T("lbl_invoke") end
        if entryType == "incoming" then return T("lbl_incoming") end
        if entryType == "block" then return T("lbl_blocked") end
        if entryType == "return" then return T("lbl_return") end
        if entryType == "clientinvoke" then return T("lbl_clientinvoke") end
        if entryType == "bindable" then return T("lbl_bindable") end
        return "?"
    end

    -- Saved preferences
    Theme.applyAccent(Config.get("accent") or "blue")
    Theme.applyTextScale(Config.get("textScale") or "normal")
    _G._RSPY.Theme = Theme
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: gui/icons.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — gui/icons.lua
        Vector-style icons drawn with plain Frames (no emoji, no image assets)

        Emoji render differently on iPhone / Android / Windows and are missing
        on some executors' fonts. These icons are built from Frames, UIStroke
        and UICorner, so they look identical everywhere and take any color.

        Icons.draw(name, parent, size, color, bg) → Frame (container)
          name : close | maximize | restore | minimize | logo | spy | explorer |
                 network | scripts | history | settings | errors | check |
                 copy | ignore | star
          size : pixels (square)
          bg   : background color behind the icon (used for "holes")
    ]]

    local Icons = {}

    local function new(class, props, parent)
        local o = Instance.new(class)
        for k, v in pairs(props) do
            pcall(function() o[k] = v end)
        end
        o.Parent = parent
        return o
    end

    -- Filled bar, centered at (cx, cy) in 0..1 coordinates of the container
    local function bar(parent, cx, cy, w, h, rot, color)
        return new("Frame", {
            Name = "Bar",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(cx, 0, cy, 0),
            Size = UDim2.new(w, 0, 0, h),
            Rotation = rot or 0,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }, parent)
    end

    -- Bar with a pixel width and a relative height (vertical bars)
    local function vbar(parent, cx, cy, wPx, h, color)
        return new("Frame", {
            Name = "VBar",
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(cx, 0, cy, 0),
            Size = UDim2.new(0, wPx, h, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        }, parent)
    end

    -- Circle outline (ring) or filled circle
    local function circle(parent, cx, cy, d, color, thickness, filled)
        local f = new("Frame", {
            Name = "Circle",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(cx, 0, cy, 0),
            Size = UDim2.new(d, 0, d, 0),
            BackgroundColor3 = color,
            BackgroundTransparency = filled and 0 or 1,
            BorderSizePixel = 0,
        }, parent)
        new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
        if not filled then
            new("UIStroke", { Color = color, Thickness = thickness or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
        end
        return f
    end

    -- Square outline
    local function square(parent, cx, cy, d, color, thickness, bg)
        local f = new("Frame", {
            Name = "Square",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(cx, 0, cy, 0),
            Size = UDim2.new(d, 0, d, 0),
            BackgroundColor3 = bg or color,
            BackgroundTransparency = bg and 0 or 1,
            BorderSizePixel = 0,
        }, parent)
        new("UICorner", { CornerRadius = UDim.new(0, 2) }, f)
        new("UIStroke", { Color = color, Thickness = thickness or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
        return f
    end

    local DRAW = {}

    DRAW.close = function(c, s, color)
        local t = math.max(2, math.floor(s / 7))
        bar(c, 0.5, 0.5, 0.78, t, 45, color)
        bar(c, 0.5, 0.5, 0.78, t, -45, color)
    end

    DRAW.maximize = function(c, s, color)
        square(c, 0.5, 0.5, 0.6, color, 2)
    end

    DRAW.restore = function(c, s, color, bg)
        square(c, 0.58, 0.42, 0.46, color, 2)
        local front = square(c, 0.42, 0.58, 0.46, color, 2, bg or Color3.fromRGB(50, 50, 60)) -- hides the back one
        front.Name = "Hole"
    end

    DRAW.minimize = function(c, s, color)
        bar(c, 0.5, 0.62, 0.6, math.max(2, math.floor(s / 7)), 0, color)
    end

    -- Two stacked sheets
    DRAW.copy = function(c, s, color, bg)
        square(c, 0.6, 0.4, 0.5, color, 1.5)
        local front = square(c, 0.4, 0.6, 0.5, color, 1.5, bg or Color3.fromRGB(35, 35, 44))
        front.Name = "Hole"
    end

    -- Circle with a slash ("ignore / mute")
    DRAW.ignore = function(c, s, color)
        circle(c, 0.5, 0.5, 0.8, color, 1.5)
        bar(c, 0.5, 0.5, 0.8, math.max(2, math.floor(s / 8)), -45, color)
    end

    -- Star outline approximation: two crossed squares (watchlist)
    DRAW.star = function(c, s, color)
        local a = square(c, 0.5, 0.5, 0.56, color, 0, nil)
        a.BackgroundTransparency = 0
        local b = square(c, 0.5, 0.5, 0.56, color, 0, nil)
        b.BackgroundTransparency = 0
        b.Rotation = 45
    end

    DRAW.check = function(c, s, color)
        local t = math.max(2, math.floor(s / 7))
        bar(c, 0.36, 0.6, 0.32, t, 45, color)
        bar(c, 0.6, 0.48, 0.55, t, -50, color)
    end

    -- Magnifying glass (reopen button / brand)
    DRAW.logo = function(c, s, color)
        circle(c, 0.42, 0.42, 0.52, color, math.max(2, math.floor(s / 9)))
        bar(c, 0.74, 0.74, 0.34, math.max(3, math.floor(s / 7)), 45, color)
    end

    -- Radar: ring + inner ring + dot
    DRAW.spy = function(c, s, color)
        circle(c, 0.5, 0.5, 0.9, color, 2)
        circle(c, 0.5, 0.5, 0.45, color, 1.5)
        circle(c, 0.5, 0.5, 0.18, color, 0, true)
    end

    -- Tree: trunk + three branches
    DRAW.explorer = function(c, s, color)
        local t = math.max(2, math.floor(s / 8))
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.22, 0, 0.12, 0),
            Size = UDim2.new(0, t, 0.72, 0), BackgroundColor3 = color, BorderSizePixel = 0 }, c)
        bar(c, 0.55, 0.18, 0.62, t, 0, color)
        bar(c, 0.6, 0.5, 0.5, t, 0, color)
        bar(c, 0.6, 0.82, 0.5, t, 0, color)
    end

    -- Signal bars
    DRAW.network = function(c, s, color)
        local w = math.max(2, math.floor(s / 5))
        vbar(c, 0.22, 0.9, w, 0.35, color)
        vbar(c, 0.5, 0.9, w, 0.6, color)
        vbar(c, 0.78, 0.9, w, 0.85, color)
    end

    -- Code brackets "</>" (Code font: no emoji involved)
    DRAW.scripts = function(c, s, color)
        new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "</>",
            TextColor3 = color,
            Font = Enum.Font.Code,
            TextScaled = true,
        }, c)
    end

    -- Clock
    DRAW.history = function(c, s, color)
        local t = math.max(2, math.floor(s / 8))
        circle(c, 0.5, 0.5, 0.88, color, 2)
        new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.52, 0),
            Size = UDim2.new(0, t, 0.3, 0), BackgroundColor3 = color, BorderSizePixel = 0 }, c)
        new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.48, 0, 0.5, 0),
            Size = UDim2.new(0.24, 0, 0, t), BackgroundColor3 = color, BorderSizePixel = 0 }, c)
    end

    -- Gear: 4 crossing teeth + filled wheel + hole
    DRAW.settings = function(c, s, color, bg)
        local t = math.max(3, math.floor(s / 4.5))
        for _, r in ipairs({ 0, 45, 90, 135 }) do
            bar(c, 0.5, 0.5, 0.92, t, r, color)
        end
        circle(c, 0.5, 0.5, 0.66, color, 0, true)
        local hole = circle(c, 0.5, 0.5, 0.28, bg or Color3.fromRGB(25, 25, 32), 0, true)
        hole.Name = "Hole" -- keeps the background color on recolor
    end

    -- Warning: ring + "!"
    DRAW.errors = function(c, s, color)
        circle(c, 0.5, 0.5, 0.88, color, 2)
        local t = math.max(2, math.floor(s / 7))
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.22, 0),
            Size = UDim2.new(0, t, 0.34, 0), BackgroundColor3 = color, BorderSizePixel = 0 }, c)
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.72, 0),
            Size = UDim2.new(0, t, 0, t), BackgroundColor3 = color, BorderSizePixel = 0 }, c)
    end

    function Icons.has(name)
        return DRAW[name] ~= nil
    end

    function Icons.draw(name, parent, size, color, bg)
        size = size or 16
        color = color or Color3.fromRGB(220, 220, 235)
        local container = new("Frame", {
            Name = "Icon_" .. tostring(name),
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        }, parent)
        local fn = DRAW[name]
        if fn then
            local ok, err = pcall(fn, container, size, color, bg)
            if not ok then warn("[RobloxSpy] icon '" .. tostring(name) .. "': " .. tostring(err)) end
        end
        return container
    end

    -- Recolors every part of an icon (hover states, active tab…)
    function Icons.recolor(container, color)
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("UIStroke") then
                d.Color = color
            elseif d:IsA("TextLabel") then
                d.TextColor3 = color
            elseif d:IsA("Frame") and d.BackgroundTransparency == 0 and d.Name ~= "Hole" then
                d.BackgroundColor3 = color
            end
        end
    end
    _G._RSPY.Icons = Icons
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: gui/framework.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — gui/framework.lua
        Custom GUI Framework (zero dependencies)

        Lightweight ScreenGui-based UI system.
        PC + Mobile responsive. Draggable windows.
        Component-driven architecture.
    ]]

    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local I18n = _G._RSPY.I18n
    local Config = _G._RSPY.Config
    local Theme = _G._RSPY.Theme
    local Icons = _G._RSPY.Icons
    local T = I18n.T

    local Framework = {}
    Framework.__index = Framework

    -- ── DETECTION ────────────────────────────────────────────────────
    local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    -- ── CONSTANTS ────────────────────────────────────────────────────
    local TWEEN_SPEED = 0.2
    local TWEEN_EASE = Enum.EasingStyle.Quad
    local CORNER_RADIUS = UDim.new(0, 8)
    local SHADOW_SIZE = 4
    local MIN_WINDOW_SIZE = Vector2.new(340, 240)
    local MOBILE_PADDING = 8

    -- ── CORE SCREENGUI ──────────────────────────────────────────────

    local _screenGui = nil
    local _zIndex = 10

    local function getScreenGui()
        if _screenGui and _screenGui.Parent then return _screenGui end

        local player = Players.LocalPlayer
        if not player then return nil end

        _screenGui = Instance.new("ScreenGui")
        _screenGui.Name = "RobloxSpyGUI"
        _screenGui.ResetOnSpawn = false
        _screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        _screenGui.IgnoreGuiInset = true
        _screenGui.DisplayOrder = 999

        -- Try gethui/syn protect, fall back to PlayerGui
        local parent
        pcall(function()
            if gethui then parent = gethui() end
        end)
        pcall(function()
            if not parent and syn and syn.protect_gui then
                syn.protect_gui(_screenGui)
                parent = player:FindFirstChild("PlayerGui")
            end
        end)
        if not parent then
            parent = player:FindFirstChild("PlayerGui")
        end
        if parent then
            _screenGui.Parent = parent
        end

        return _screenGui
    end

    -- ── UTILITY ─────────────────────────────────────────────────────

    local function nextZ()
        _zIndex = _zIndex + 1
        return _zIndex
    end

    local function tween(obj, props, duration, style, dir)
        duration = duration or TWEEN_SPEED
        style = style or TWEEN_EASE
        dir = dir or Enum.EasingDirection.Out
        return TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
    end

    local function applyCorner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = radius or CORNER_RADIUS
        c.Parent = obj
        return c
    end

    local function applyStroke(obj, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Color3.fromRGB(60, 60, 70)
        s.Thickness = thickness or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = obj
        return s
    end

    local function applyShadow(obj, size)
        -- Fake shadow via offset dark frame behind
        size = size or SHADOW_SIZE
        local shadow = Instance.new("Frame")
        shadow.Name = "_Shadow"
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.7
        shadow.BorderSizePixel = 0
        shadow.Position = UDim2.new(0, size, 0, size)
        shadow.Size = UDim2.new(1, 0, 1, 0)
        shadow.ZIndex = obj.ZIndex - 1
        shadow.Parent = obj.Parent
        applyCorner(shadow, CORNER_RADIUS)
        return shadow
    end

    local function applyPadding(obj, top, right, bottom, left)
        local p = Instance.new("UIPadding")
        p.PaddingTop = UDim.new(0, top or 8)
        p.PaddingRight = UDim.new(0, right or 8)
        p.PaddingBottom = UDim.new(0, bottom or 8)
        p.PaddingLeft = UDim.new(0, left or 8)
        p.Parent = obj
        return p
    end

    local function create(class, props, children)
        local inst = Instance.new(class)
        if props then
            for k, v in pairs(props) do
                if k ~= "Parent" then
                    pcall(function() inst[k] = v end)
                end
            end
        end
        if children then
            for _, child in ipairs(children) do
                child.Parent = inst
            end
        end
        if props and props.Parent then
            inst.Parent = props.Parent
        end
        return inst
    end

    -- ── SCREEN CLAMPING ─────────────────────────────────────────────
    -- Keeps a GuiObject fully inside the screen (PC + mobile, any resolution).

    local function getViewportSize()
        local sg = _screenGui
        if sg and sg.AbsoluteSize.X > 0 then return sg.AbsoluteSize end
        local cam = workspace.CurrentCamera
        return cam and cam.ViewportSize or Vector2.new(1280, 720)
    end

    -- Converts the frame to plain offset positioning (AnchorPoint 0,0)
    -- so clamping math is exact whatever its previous anchor/scale was.
    local function toOffsetPosition(frame)
        local abs = frame.AbsolutePosition
        local parentAbs = Vector2.new(0, 0)
        pcall(function() parentAbs = frame.Parent.AbsolutePosition end)
        frame.AnchorPoint = Vector2.new(0, 0)
        frame.Position = UDim2.fromOffset(abs.X - parentAbs.X, abs.Y - parentAbs.Y)
    end

    local function clampToScreen(frame, margin)
        if not frame or not frame.Parent then return end
        margin = margin or 4
        local vp = getViewportSize()
        local size = frame.AbsoluteSize

        -- If bigger than the screen, shrink it first
        local maxW, maxH = vp.X - margin * 2, vp.Y - margin * 2
        if size.X > maxW or size.Y > maxH then
            frame.Size = UDim2.fromOffset(math.min(size.X, maxW), math.min(size.Y, maxH))
            size = Vector2.new(math.min(size.X, maxW), math.min(size.Y, maxH))
        end

        toOffsetPosition(frame)
        local pos = frame.Position
        local x = math.clamp(pos.X.Offset, margin, math.max(margin, vp.X - size.X - margin))
        local y = math.clamp(pos.Y.Offset, margin, math.max(margin, vp.Y - size.Y - margin))
        frame.Position = UDim2.fromOffset(x, y)
    end

    -- Stores a connection in an owner list so it can be disconnected later
    -- (v1.1.0: global connections used to leak on every UI rebuild)
    local function own(conns, conn)
        if conns and conn then table.insert(conns, conn) end
        return conn
    end

    -- Re-clamp automatically when the screen rotates / resizes
    local function keepOnScreen(frame, margin, conns)
        local function reclamp()
            task.defer(function() pcall(clampToScreen, frame, margin) end)
        end
        pcall(function()
            own(conns, getScreenGui():GetPropertyChangedSignal("AbsoluteSize"):Connect(reclamp))
        end)
        own(conns, frame:GetPropertyChangedSignal("Visible"):Connect(reclamp))
        reclamp()
    end

    -- ── DRAGGING ────────────────────────────────────────────────────
    -- • Active = true on the handle + frame: the drag is SUNK by the GUI,
    --   so the camera / character / game never receive it.
    -- • Only the input that started the drag moves the frame (a second
    --   finger on the joystick on mobile can't hijack it).
    -- • Position is clamped so the frame never leaves the screen.
    -- Returns a function wasDragged() → true if the last press moved > 6px
    -- (lets buttons ignore the click that ends a drag).

    local function makeDraggable(frame, handle, margin, conns)
        handle = handle or frame
        pcall(function() handle.Active = true end)
        pcall(function() frame.Active = true end)

        local dragging = false
        local dragInput = nil
        local dragStart, startPos
        local moved = false

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragInput = input
                dragStart = input.Position
                toOffsetPosition(frame)
                startPos = frame.Position

                local conn
                conn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        dragInput = nil
                        pcall(function() conn:Disconnect() end)
                    end
                end)
            end
        end)

        handle.InputEnded:Connect(function(input)
            if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                dragInput = nil
            end
        end)

        own(conns, UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
            local isOurTouch = input.UserInputType == Enum.UserInputType.Touch and input == dragInput
            if not (isMouse or isOurTouch) then return end

            local delta = input.Position - dragStart
            if delta.Magnitude > 6 then moved = true end

            local vp = getViewportSize()
            local size = frame.AbsoluteSize
            local m = margin or 4
            local x = math.clamp(startPos.X.Offset + delta.X, m, math.max(m, vp.X - size.X - m))
            local y = math.clamp(startPos.Y.Offset + delta.Y, m, math.max(m, vp.Y - size.Y - m))
            frame.Position = UDim2.fromOffset(x, y)
        end))

        return function() return moved end
    end

    -- ── RESIZING ────────────────────────────────────────────────────

    local function makeResizable(frame, minSize, conns)
        minSize = minSize or MIN_WINDOW_SIZE

        local handle = create("Frame", {
            Name = "ResizeHandle",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundTransparency = 1,
            Active = true, -- sink input: resizing must not move the camera
            ZIndex = 50,
            Parent = frame,
        })

        -- Visual grip: three diagonal dots (drawn, no glyph)
        for i = 0, 2 do
            create("Frame", {
                Size = UDim2.new(0, 3, 0, 3),
                Position = UDim2.new(1, -6 - i * 5, 1, -6),
                BackgroundColor3 = Color3.fromRGB(100, 100, 110),
                BorderSizePixel = 0,
                Parent = handle,
            })
            if i > 0 then
                create("Frame", {
                    Size = UDim2.new(0, 3, 0, 3),
                    Position = UDim2.new(1, -6, 1, -6 - i * 5),
                    BackgroundColor3 = Color3.fromRGB(100, 100, 110),
                    BorderSizePixel = 0,
                    Parent = handle,
                })
            end
        end

        local resizing = false
        local resizeStart, startSize

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                toOffsetPosition(frame)
                startSize = frame.AbsoluteSize
            end
        end)

        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)

        own(conns, UserInputService.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - resizeStart
                local vp = getViewportSize()
                local pos = frame.AbsolutePosition
                -- never grow past the screen edge
                local maxW = math.max(minSize.X, vp.X - pos.X - 4)
                local maxH = math.max(minSize.Y, vp.Y - pos.Y - 4)
                local newW = math.clamp(startSize.X + delta.X, minSize.X, maxW)
                local newH = math.clamp(startSize.Y + delta.Y, minSize.Y, maxH)
                frame.Size = UDim2.new(0, newW, 0, newH)
            end
        end))
    end

    -- ── WINDOW CLASS ────────────────────────────────────────────────

    local Window = {}
    Window.__index = Window

    function Framework.createWindow(config)
        config = config or {}
        local title = config.Title or "RobloxSpy"
        local size = config.Size or (IS_MOBILE
            and UDim2.new(0.9, 0, 0.62, 0)
            or UDim2.new(0, 520, 0, 360))
        -- Centered via AnchorPoint so any size stays on screen
        local position = config.Position or UDim2.new(0.5, 0, 0.5, 0)

        local screenGui = getScreenGui()
        if not screenGui then return nil end

        local self = setmetatable({}, Window)
        self._tabs = {}
        self._activeTab = nil
        self._visible = true
        self._minimized = false
        self._connections = {}

        -- Main container
        self.Frame = create("Frame", {
            Name = "SpyWindow",
            Active = true, -- clicks/drags on the window never reach the game
            Size = size,
            Position = position,
            AnchorPoint = config.Position and Vector2.new(0, 0) or Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(22, 22, 28),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = screenGui,
        })
        applyCorner(self.Frame)
        applyStroke(self.Frame, Color3.fromRGB(55, 55, 65), 1)

        -- Title bar
        self.TitleBar = create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Color3.fromRGB(28, 28, 36),
            BorderSizePixel = 0,
            Parent = self.Frame,
        })
        applyCorner(self.TitleBar, UDim.new(0, 8))
        -- Bottom corners flat (only top rounded)
        create("Frame", {
            Name = "TitleFlat",
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = Color3.fromRGB(28, 28, 36),
            BorderSizePixel = 0,
            Parent = self.TitleBar,
        })

        -- Logo + title text
        local logo = Icons.draw("logo", self.TitleBar, 16, Theme.Colors.Accent)
        logo.Position = UDim2.new(0, 10, 0.5, -8)

        self.TitleLabel = create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -150, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(220, 220, 230),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = self.TitleBar,
        })

        -- Window controls (maximize, minimize, close) — drawn icons
        local btnSize = IS_MOBILE and 30 or 26
        local controlsFrame = create("Frame", {
            Name = "Controls",
            Size = UDim2.new(0, btnSize * 3 + 12, 0, btnSize),
            Position = UDim2.new(1, -(btnSize * 3 + 18), 0.5, -btnSize / 2),
            BackgroundTransparency = 1,
            Parent = self.TitleBar,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = controlsFrame,
        })

        local NEUTRAL = Color3.fromRGB(50, 50, 60)
        local NEUTRAL_HOVER = Color3.fromRGB(70, 70, 82)
        local ICON_COLOR = Color3.fromRGB(200, 200, 212)

        local function controlButton(name, iconName, bg, order)
            local b = create("TextButton", {
                Name = name,
                Size = UDim2.new(0, btnSize, 0, btnSize),
                BackgroundColor3 = bg,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = order,
                Parent = controlsFrame,
            })
            applyCorner(b, UDim.new(0, 6))
            local icon = Icons.draw(iconName, b, math.floor(btnSize * 0.5), ICON_COLOR, bg)
            icon.AnchorPoint = Vector2.new(0.5, 0.5)
            icon.Position = UDim2.new(0.5, 0, 0.5, 0)
            return b, icon
        end

        local maxBtn, maxIcon = controlButton("Maximize", "maximize", NEUTRAL, 1)
        local minBtn = controlButton("Minimize", "minimize", NEUTRAL, 2)
        local closeBtn, closeIcon = controlButton("Close", "close", Color3.fromRGB(180, 50, 50), 3)
        Icons.recolor(closeIcon, Color3.fromRGB(255, 255, 255))
        self.MaxButton = maxBtn
        self._maxIcon = maxIcon
        self._iconColor = ICON_COLOR

        -- Tab bar (scrolls horizontally when tabs don't fit).
        -- Mobile: at the bottom, within thumb reach (can be turned off).
        self._bottomTabs = IS_MOBILE and Config.get("mobileBottomTabs") ~= false
        local TAB_H = IS_MOBILE and 40 or 32
        local STATUS_H = 22
        self._tabHeight = TAB_H

        self.TabBar = create("ScrollingFrame", {
            Name = "TabBar",
            Size = UDim2.new(1, 0, 0, TAB_H),
            Position = self._bottomTabs and UDim2.new(0, 0, 1, -(TAB_H + STATUS_H)) or UDim2.new(0, 0, 0, 36),
            BackgroundColor3 = Color3.fromRGB(25, 25, 32),
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.X,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            Parent = self.Frame,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.TabBar,
        })
        applyPadding(self.TabBar, 3, 4, 3, 4)

        -- Content area (between title/tab bar and status bar)
        self.Content = create("Frame", {
            Name = "Content",
            Size = self._bottomTabs and UDim2.new(1, 0, 1, -(36 + TAB_H + STATUS_H))
                or UDim2.new(1, 0, 1, -(36 + TAB_H + STATUS_H)),
            Position = self._bottomTabs and UDim2.new(0, 0, 0, 36) or UDim2.new(0, 0, 0, 36 + TAB_H),
            BackgroundColor3 = Color3.fromRGB(18, 18, 24),
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = self.Frame,
        })

        -- Status bar
        self.StatusBar = create("Frame", {
            Name = "StatusBar",
            Size = UDim2.new(1, 0, 0, STATUS_H),
            Position = UDim2.new(0, 0, 1, -STATUS_H),
            BackgroundColor3 = Color3.fromRGB(25, 25, 32),
            BorderSizePixel = 0,
            Parent = self.Frame,
        })
        self.StatusLabel = create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = T("status_ready"),
            TextColor3 = Color3.fromRGB(120, 120, 135),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = self.StatusBar,
        })

        -- Drag & Resize (connections owned by the window → no leak on rebuild)
        makeDraggable(self.Frame, self.TitleBar, nil, self._connections)
        if not IS_MOBILE then
            makeResizable(self.Frame, nil, self._connections)
        end
        keepOnScreen(self.Frame, nil, self._connections)
        own(self._connections, self.Frame:GetPropertyChangedSignal("Size"):Connect(function()
            task.defer(function() pcall(clampToScreen, self.Frame) end)
        end))

        -- Button handlers
        maxBtn.Activated:Connect(function() self:toggleMaximize() end)
        minBtn.Activated:Connect(function() self:toggleMinimize() end)
        closeBtn.Activated:Connect(function() self:hide() end)

        -- Hover effects
        local function hoverBtn(btn, normalColor, hoverColor)
            btn.MouseEnter:Connect(function()
                tween(btn, { BackgroundColor3 = hoverColor }, 0.15):Play()
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, { BackgroundColor3 = normalColor }, 0.15):Play()
            end)
        end
        hoverBtn(minBtn, NEUTRAL, NEUTRAL_HOVER)
        hoverBtn(maxBtn, NEUTRAL, NEUTRAL_HOVER)
        hoverBtn(closeBtn, Color3.fromRGB(180, 50, 50), Color3.fromRGB(220, 60, 60))

        -- Tooltips
        Framework.tooltip(maxBtn, T("tip_maximize"))
        Framework.tooltip(minBtn, T("tip_minimize"))
        Framework.tooltip(closeBtn, T("tip_close"))

        -- Saved transparency
        self:setTransparency(tonumber(Config.get("windowTransparency")) or 0)

        Framework._mainWindow = self

        return self
    end

    -- ── WINDOW METHODS ──────────────────────────────────────────────

    function Window:addTab(name, icon)
        local iconSize = IS_MOBILE and 18 or 13
        local tabBtn = create("TextButton", {
            Name = "Tab_" .. name,
            Size = IS_MOBILE and UDim2.new(0, 46, 1, 0) or UDim2.new(0, 0, 1, 0),
            AutomaticSize = IS_MOBILE and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            BackgroundTransparency = 0.5,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = #self._tabs + 1,
            Parent = self.TabBar,
        })
        applyCorner(tabBtn, UDim.new(0, 6))

        local inner = create("Frame", {
            Name = "Inner",
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = IS_MOBILE and Vector2.new(0.5, 0) or Vector2.new(0, 0),
            Position = IS_MOBILE and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = tabBtn,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = inner,
        })
        if not IS_MOBILE then applyPadding(inner, 0, 9, 0, 9) end

        local iconFrame = nil
        if icon and Icons.has(icon) then
            iconFrame = Icons.draw(icon, inner, iconSize, Color3.fromRGB(140, 140, 155), Color3.fromRGB(30, 30, 38))
            iconFrame.LayoutOrder = 1
        end

        local label = create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(140, 140, 155),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            Visible = not IS_MOBILE, -- mobile: icon only
            LayoutOrder = 2,
            Parent = inner,
        })

        -- Active indicator (accent line)
        local indicator = create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0.6, 0, 0, 2),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = self._bottomTabs and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0.5, 0, 1, -2),
            BackgroundColor3 = Theme.Colors.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = tabBtn,
        })

        if IS_MOBILE then Framework.tooltip(tabBtn, name) end

        local contentFrame = create("Frame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.Content,
        })

        local tab = {
            name = name,
            button = tabBtn,
            label = label,
            icon = iconFrame,
            indicator = indicator,
            content = contentFrame,
        }
        table.insert(self._tabs, tab)

        tabBtn.Activated:Connect(function()
            self:switchTab(name)
        end)

        if #self._tabs == 1 then
            self:switchTab(name)
        end

        return contentFrame
    end

    function Window:switchTab(name)
        for _, tab in ipairs(self._tabs) do
            local isActive = (tab.name == name)
            tab.content.Visible = isActive
            local fg = isActive and Color3.fromRGB(225, 225, 240) or Color3.fromRGB(140, 140, 155)
            tab.button.BackgroundTransparency = isActive and 0 or 0.5
            tab.button.BackgroundColor3 = isActive and Color3.fromRGB(42, 42, 54) or Color3.fromRGB(30, 30, 38)
            tab.label.TextColor3 = fg
            tab.indicator.Visible = isActive
            if tab.icon then
                Icons.recolor(tab.icon, isActive and Theme.Colors.Accent or fg)
            end
            if isActive then self._activeTab = tab end
        end
        if self._onTabChanged then pcall(self._onTabChanged, name) end
    end

    function Window:getActiveTabName()
        return self._activeTab and self._activeTab.name
    end

    function Window:setStatus(text, color)
        self.StatusLabel.Text = text or ""
        self.StatusLabel.TextColor3 = color or Color3.fromRGB(120, 120, 135)
    end

    -- 0 = opaque … 0.5 = very transparent (window background only)
    function Window:setTransparency(t)
        t = math.clamp(tonumber(t) or 0, 0, 0.6)
        self._bgTransparency = t
        if self._visible then self.Frame.BackgroundTransparency = t end
        self.Content.BackgroundTransparency = t
    end

    function Window:show()
        self._visible = true
        self.Frame.Visible = true
        tween(self.Frame, { BackgroundTransparency = self._bgTransparency or 0 }, 0.2):Play()
        if self._toggleBtn then self._toggleBtn.Visible = false end
        Framework.setUnread(0)
    end

    function Window:hide()
        self._visible = false
        local t = tween(self.Frame, { BackgroundTransparency = 1 }, 0.2)
        t:Play()
        t.Completed:Wait()
        if not self._visible then -- re-opened during the fade
            self.Frame.Visible = false
            if self._toggleBtn then self._toggleBtn.Visible = true end
        end
    end

    function Window:toggle()
        if self._visible then self:hide() else self:show() end
    end

    function Window:isVisible()
        return self._visible == true
    end

    function Window:toggleMinimize()
        if self._maximized then self:toggleMaximize(false) end
        self._minimized = not self._minimized
        if self._minimized then
            self._savedSize = self.Frame.Size
            tween(self.Frame, { Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 36) }, 0.2):Play()
            self.Content.Visible = false
            self.TabBar.Visible = false
            self.StatusBar.Visible = false
        else
            self.Content.Visible = true
            self.TabBar.Visible = true
            self.StatusBar.Visible = true
            tween(self.Frame, { Size = self._savedSize }, 0.2):Play()
        end
    end

    local function setMaxIcon(self, iconName)
        if not self.MaxButton then return end
        if self._maxIcon then self._maxIcon:Destroy() end
        local size = math.floor(self.MaxButton.AbsoluteSize.X * 0.5)
        if size < 8 then size = IS_MOBILE and 15 or 13 end
        local icon = Icons.draw(iconName, self.MaxButton, size, self._iconColor, Color3.fromRGB(50, 50, 60))
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        self._maxIcon = icon
    end

    -- Fill (almost) the whole screen, or restore the previous size/position.
    function Window:toggleMaximize(force)
        local want = (force == nil) and not self._maximized or force
        if want == self._maximized then return end
        if self._minimized then self:toggleMinimize() end

        if want then
            toOffsetPosition(self.Frame)
            self._preMaxSize = self.Frame.Size
            self._preMaxPos = self.Frame.Position
            local vp = getViewportSize()
            local m = IS_MOBILE and 6 or 16
            self._maximized = true
            self.Frame.Position = UDim2.fromOffset(m, m)
            self.Frame.Size = UDim2.fromOffset(vp.X - m * 2, vp.Y - m * 2)
            setMaxIcon(self, "restore")
        else
            self._maximized = false
            if self._preMaxSize then self.Frame.Size = self._preMaxSize end
            if self._preMaxPos then self.Frame.Position = self._preMaxPos end
            setMaxIcon(self, "maximize")
            task.defer(function() pcall(clampToScreen, self.Frame) end)
        end
    end

    function Window:isMaximized()
        return self._maximized == true
    end

    function Window:destroy()
        for _, conn in ipairs(self._connections) do
            pcall(function() conn:Disconnect() end)
        end
        self._connections = {}
        if self._toggleBtn then pcall(function() self._toggleBtn:Destroy() end) end
        self._toggleBtn = nil
        if self.Frame then
            self.Frame:Destroy()
        end
        if Framework._mainWindow == self then Framework._mainWindow = nil end
    end

    -- ── KEYBIND (PC) ────────────────────────────────────────────────
    -- Shows / hides the window with a key (default RightShift).
    -- Ignored while typing in a TextBox (gameProcessed).

    function Framework.bindToggleKey(window, keyName)
        if window._keyConn then
            pcall(function() window._keyConn:Disconnect() end)
            window._keyConn = nil
        end
        local key = nil
        pcall(function() key = Enum.KeyCode[keyName] end)
        if not key then return false end
        window._keyConn = own(window._connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.KeyCode == key then
                task.spawn(function() window:toggle() end)
            end
        end))
        return true
    end

    -- Waits for the next key press (for the "change keybind" button)
    function Framework.captureKey(callback)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                conn:Disconnect()
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    pcall(callback, input.KeyCode.Name)
                else
                    pcall(callback, nil)
                end
            end
        end)
        return conn
    end

    -- ── TOGGLE BUTTON (floating, to reopen) ─────────────────────────

    local _unread = 0
    local _badge, _badgeLabel, _pulseStroke = nil, nil, nil

    function Framework.setUnread(n)
        _unread = math.max(0, n or 0)
        if _badge then
            _badge.Visible = _unread > 0
            _badgeLabel.Text = _unread > 99 and "99+" or tostring(_unread)
        end
    end

    function Framework.bumpUnread()
        local w = Framework._mainWindow
        if w and not w._visible then
            Framework.setUnread(_unread + 1)
        end
    end

    function Framework.createToggleButton(window)
        local screenGui = getScreenGui()
        if not screenGui then return nil end
        if window._toggleBtn then return window._toggleBtn end

        local size = IS_MOBILE and 50 or 40
        local btn = create("TextButton", {
            Name = "SpyToggle",
            Visible = not window._visible,
            ZIndex = 50,
            Size = UDim2.new(0, size, 0, size),
            Position = IS_MOBILE and UDim2.new(0, 10, 0.4, 0) or UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromRGB(24, 24, 32),
            AutoButtonColor = false,
            Text = "",
            Parent = screenGui,
        })
        applyCorner(btn, UDim.new(0.5, 0))
        _pulseStroke = applyStroke(btn, Theme.Colors.Accent, 2)

        local icon = Icons.draw("logo", btn, math.floor(size * 0.5), Theme.Colors.Accent)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.ZIndex = 51

        -- Unread events badge
        _badge = create("Frame", {
            Name = "Badge",
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 4, 0, -4),
            BackgroundColor3 = Color3.fromRGB(220, 60, 70),
            Visible = false,
            ZIndex = 53,
            Parent = btn,
        })
        applyCorner(_badge, UDim.new(0.5, 0))
        applyPadding(_badge, 0, 4, 0, 4)
        _badgeLabel = create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "0",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            ZIndex = 54,
            Parent = _badge,
        })
        Framework.setUnread(_unread)

        -- Gentle pulse while there are unread events
        task.spawn(function()
            while btn.Parent do
                if _unread > 0 and btn.Visible then
                    tween(_pulseStroke, { Thickness = 4, Transparency = 0.5 }, 0.6):Play()
                    task.wait(0.6)
                    tween(_pulseStroke, { Thickness = 2, Transparency = 0 }, 0.6):Play()
                    task.wait(0.6)
                else
                    task.wait(0.5)
                end
            end
        end)

        local wasDragged = makeDraggable(btn, btn, 6, window._connections)
        keepOnScreen(btn, 6, window._connections)
        Framework.tooltip(btn, T("tip_reopen"))

        window._toggleBtn = btn

        btn.Activated:Connect(function()
            if wasDragged and wasDragged() then return end
            window:toggle()
        end)

        return btn
    end

    -- ── TOOLTIPS ────────────────────────────────────────────────────
    -- PC: hover 0.45 s. Mobile: long press 0.5 s (the press then does NOT
    -- trigger the button, so a long press never deletes/fires anything).

    local _tip = nil

    local function showTip(text, anchor)
        local sg = getScreenGui()
        if not sg or not text or text == "" then return end
        if not _tip or not _tip.Parent then
            _tip = create("TextLabel", {
                Name = "Tooltip",
                Size = UDim2.new(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = Color3.fromRGB(12, 12, 16),
                TextColor3 = Color3.fromRGB(230, 230, 240),
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextWrapped = false,
                ZIndex = 300,
                Visible = false,
                Parent = sg,
            })
            applyCorner(_tip, UDim.new(0, 5))
            applyStroke(_tip, Color3.fromRGB(70, 70, 85), 1)
            applyPadding(_tip, 4, 7, 4, 7)
        end
        _tip.Text = text
        local vp = getViewportSize()
        local pos = anchor.AbsolutePosition
        local x = math.clamp(pos.X, 4, math.max(4, vp.X - 260))
        local y = pos.Y + anchor.AbsoluteSize.Y + 6
        if y > vp.Y - 30 then y = pos.Y - 28 end
        _tip.Position = UDim2.fromOffset(x, y)
        _tip.Visible = true
    end

    local function hideTip()
        if _tip then _tip.Visible = false end
    end

    function Framework.tooltip(obj, text)
        if not obj or not text then return end
        if IS_MOBILE then
            local pressId = 0
            obj.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch then return end
                pressId = pressId + 1
                local my = pressId
                task.delay(0.5, function()
                    if my ~= pressId then return end
                    if input.UserInputState == Enum.UserInputState.End then return end
                    showTip(text, obj)
                    -- swallow the release so the long press doesn't click
                    pcall(function() obj.Interactable = false end)
                    task.delay(1.6, hideTip)
                end)
            end)
            obj.InputEnded:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Touch then return end
                pressId = pressId + 1
                task.delay(0.05, function() pcall(function() obj.Interactable = true end) end)
            end)
        else
            local hoverId = 0
            obj.MouseEnter:Connect(function()
                hoverId = hoverId + 1
                local my = hoverId
                task.delay(0.45, function()
                    if my == hoverId then showTip(text, obj) end
                end)
            end)
            obj.MouseLeave:Connect(function()
                hoverId = hoverId + 1
                hideTip()
            end)
        end
    end

    -- ── EMPTY STATE ─────────────────────────────────────────────────
    -- Centered hint shown when a list is empty (caller toggles .Visible)

    function Framework.emptyState(parent, text, iconName)
        local holder = create("Frame", {
            Name = "EmptyState",
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
            LayoutOrder = -1,
            Parent = parent,
        })
        if iconName and Icons.has(iconName) then
            local ic = Icons.draw(iconName, holder, 26, Color3.fromRGB(90, 90, 105), Color3.fromRGB(18, 18, 24))
            ic.AnchorPoint = Vector2.new(0.5, 0)
            ic.Position = UDim2.new(0.5, 0, 0, 14)
        end
        create("TextLabel", {
            Name = "Text",
            Size = UDim2.new(1, -20, 0, 36),
            Position = UDim2.new(0, 10, 0, 46),
            BackgroundTransparency = 1,
            Text = text,
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(110, 110, 125),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            Parent = holder,
        })
        return holder
    end

    -- ── MODAL ───────────────────────────────────────────────────────
    -- Simple dialog over the window content.
    -- buttons = { { text, color, callback }, ... }

    function Framework.modal(window, title, lines, buttons)
        local parent = window and window.Frame or getScreenGui()
        if not parent then return end

        local overlay = create("TextButton", {
            Name = "Modal",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.35,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 100,
            Parent = parent,
        })
        local box = create("Frame", {
            Size = UDim2.new(0.9, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(26, 26, 34),
            ZIndex = 101,
            Parent = overlay,
        })
        create("UISizeConstraint", { MaxSize = Vector2.new(460, 2000), Parent = box })
        applyCorner(box, UDim.new(0, 10))
        applyStroke(box, Theme.Colors.Accent, 1)
        applyPadding(box, 12, 14, 12, 14)
        create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })

        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Color3.fromRGB(235, 235, 245),
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            ZIndex = 102,
            Parent = box,
        })

        -- Scrollable body so long notes fit on small phones
        local body = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, math.min(260, #lines * 34 + 10)),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            ZIndex = 102,
            Parent = box,
        })
        create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })
        for i, line in ipairs(lines) do
            create("TextLabel", {
                Size = UDim2.new(1, -6, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = line,
                TextWrapped = true,
                TextColor3 = Color3.fromRGB(190, 190, 205),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                ZIndex = 103,
                Parent = body,
            })
        end

        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            ZIndex = 102,
            Parent = box,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = row,
        })
        local function close() pcall(function() overlay:Destroy() end) end
        for _, b in ipairs(buttons or { { T("ok"), Theme.Colors.Accent } }) do
            local btn = create("TextButton", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = b[2] or Theme.Colors.Accent,
                Text = b[1],
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                ZIndex = 103,
                Parent = row,
            })
            applyCorner(btn, UDim.new(0, 6))
            applyPadding(btn, 0, 12, 0, 12)
            btn.Activated:Connect(function()
                close()
                if b[3] then pcall(b[3]) end
            end)
        end
        return overlay, close
    end

    -- ── NOTIFICATIONS (toast) ───────────────────────────────────────
    -- kind: "success" | "error" | "warning" | "info"

    local _toastY = 0

    function Framework.notify(text, kind, duration)
        local screenGui = getScreenGui()
        if not screenGui then
            print("[RobloxSpy] " .. tostring(text))
            return
        end
        local colors = {
            success = Color3.fromRGB(80, 200, 120),
            error   = Color3.fromRGB(220, 70, 70),
            warning = Color3.fromRGB(240, 180, 50),
            info    = Color3.fromRGB(75, 130, 255),
        }
        local icons = { success = "✅", error = "⛔", warning = "⚠️", info = "ℹ️" }
        local color = colors[kind or "info"] or colors.info

        local toast = create("TextLabel", {
            Name = "Toast",
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.new(0, 0, 0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(0.5, 0, 0, 12 + _toastY),
            BackgroundColor3 = Color3.fromRGB(24, 24, 30),
            Text = (icons[kind or "info"] or "") .. "  " .. tostring(text),
            TextColor3 = Color3.fromRGB(230, 230, 240),
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            ZIndex = 200,
            Parent = screenGui,
        })
        applyCorner(toast, UDim.new(0, 8))
        applyStroke(toast, color, 1)
        applyPadding(toast, 4, 12, 4, 12)

        _toastY = _toastY + 36
        task.delay(duration or 2.5, function()
            _toastY = math.max(0, _toastY - 36)
            pcall(function()
                local t = tween(toast, { TextTransparency = 1, BackgroundTransparency = 1 }, 0.25)
                t:Play()
                t.Completed:Wait()
                toast:Destroy()
            end)
        end)
    end

    -- Copy helper with visible feedback (works on every executor or says why not)
    function Framework.copy(text, label)
        local fn
        pcall(function() fn = setclipboard or toclipboard or (Clipboard and Clipboard.set) end)
        if not fn then
            Framework.notify(T("n_no_clip"), "error")
            return false
        end
        local ok, err = pcall(fn, tostring(text or ""))
        if ok then
            Framework.notify(T("n_copied", label or "Text"), "success")
        else
            Framework.notify(T("n_copy_fail", tostring(err)), "error")
        end
        return ok
    end

    -- ── SCROLLING FRAME HELPER ──────────────────────────────────────

    function Framework.createScrollFrame(parent, config)
        config = config or {}
        local scroll = create("ScrollingFrame", {
            Name = config.Name or "Scroll",
            Size = config.Size or UDim2.new(1, 0, 1, 0),
            Position = config.Position or UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = IS_MOBILE and 8 or 5,
            ScrollBarImageColor3 = Color3.fromRGB(95, 95, 115),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = parent,
        })

        create("UIListLayout", {
            Padding = UDim.new(0, config.Padding or 2),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroll,
        })

        if config.InnerPadding then
            applyPadding(scroll, config.InnerPadding, config.InnerPadding, config.InnerPadding, config.InnerPadding)
        end

        return scroll
    end

    -- ── EXPORT UTILS ────────────────────────────────────────────────

    Framework.IS_MOBILE = IS_MOBILE
    Framework.create = create
    Framework.tween = tween
    Framework.applyCorner = applyCorner
    Framework.applyStroke = applyStroke
    Framework.applyPadding = applyPadding
    Framework.makeDraggable = makeDraggable
    Framework.clampToScreen = clampToScreen
    function Framework.getMainWindow() return Framework._mainWindow end
    Framework.keepOnScreen = keepOnScreen
    Framework.own = own
    Framework.Icons = Icons
    Framework.getScreenGui = getScreenGui
    _G._RSPY.Framework = Framework
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: gui/components/log-entry.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — gui/components/log-entry.lua
        Single remote call log row for the spy feed (v1.1.0)

        The whole row is clickable (opens the detail panel).
        Action buttons (drawn icons): copy R2S · ignore remote · delete row
        Buttons use .Activated (works with mouse AND touch on every executor).

        Extra row states:
          LogEntry.setCount(row, n)      → "×n" badge (grouped identical calls)
          LogEntry.setReturned(row, on)  → "↩" mark (server answered the Invoke)
          LogEntry.setWatched(row, on)   → star + gold stripe (watchlist)
          LogEntry.setAlert(row, on)     → highlighted background (keyword alert)
    ]]

    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Icons = _G._RSPY.Icons
    local I18n = _G._RSPY.I18n
    local T = I18n.T

    local create = Framework.create
    local applyCorner = Framework.applyCorner

    local LogEntry = {}

    local IS_MOBILE = Framework.IS_MOBILE
    local ROW_HEIGHT = IS_MOBILE and 44 or 34
    local BTN = IS_MOBILE and 34 or 26

    local function actionButton(parent, name, iconName, color, order, tip)
        local btn = create("TextButton", {
            Name = name,
            Size = UDim2.new(0, BTN, 0, BTN - 2),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.65,
            AutoButtonColor = true,
            Text = "",
            LayoutOrder = order,
            ZIndex = 5,
            Parent = parent,
        })
        applyCorner(btn, Theme.CornerRadius.SM)
        local icon = Icons.draw(iconName, btn, math.floor(BTN * 0.5), Color3.fromRGB(235, 235, 245), Theme.Colors.BgPrimary)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.ZIndex = 6
        if tip then Framework.tooltip(btn, tip) end
        return btn
    end

    function LogEntry.new(parent, data, callbacks)
        --[[
            data = { t, type, remote, class, args, path?, caller?, index }
            callbacks = { onSelect, onCopy, onBlock, onDelete }
        ]]
        callbacks = callbacks or {}

        local color = Theme.getRemoteColor(data.type)
        local label = Theme.getRemoteLabel(data.type)

        local row = create("TextButton", {
            Name = "Entry_" .. tostring(data.index or 0),
            Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
            BackgroundColor3 = Theme.Colors.BgPrimary,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = data.index or 0,
            Parent = parent,
        })
        applyCorner(row, Theme.CornerRadius.SM)

        local stripe = create("Frame", {
            Name = "Stripe",
            Size = UDim2.new(0, 3, 1, -8),
            Position = UDim2.new(0, 2, 0, 4),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = row,
        })
        applyCorner(stripe, UDim.new(0, 2))

        local normalBg = Theme.Colors.BgPrimary
        row.MouseEnter:Connect(function()
            Framework.tween(row, { BackgroundColor3 = Theme.Colors.BgHover }, 0.1):Play()
        end)
        row.MouseLeave:Connect(function()
            Framework.tween(row, { BackgroundColor3 = row:GetAttribute("AlertBg") and Color3.fromRGB(60, 45, 20) or normalBg }, 0.1):Play()
        end)

        local badge = create("TextLabel", {
            Name = "Badge",
            Size = UDim2.new(0, 56, 0, 16),
            Position = UDim2.new(0, 9, 0.5, -8),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.8,
            Text = label,
            TextColor3 = color,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        applyCorner(badge, Theme.CornerRadius.SM)

        create("TextLabel", {
            Name = "Time",
            Size = UDim2.new(0, 42, 1, 0),
            Position = UDim2.new(0, 68, 0, 0),
            BackgroundTransparency = 1,
            Text = string.format("%.1fs", (data.t or 0) / 1000),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })

        local actionsW = BTN * 3 + 10
        local textW = -(110 + actionsW + 8)

        create("TextLabel", {
            Name = "RemoteName",
            Size = UDim2.new(1, textW - 74, 0, 16), -- room for the markers
            Position = UDim2.new(0, 110, 0, IS_MOBILE and 5 or 3),
            BackgroundTransparency = 1,
            Text = data.remote or "?",
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })

        create("TextLabel", {
            Name = "Args",
            Size = UDim2.new(1, textW, 0, 13),
            Position = UDim2.new(0, 110, 0, IS_MOBILE and 24 or 18),
            BackgroundTransparency = 1,
            Text = data.args or "",
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })

        -- Right-side markers: "↩" returned, "×n" count, star (watch)
        local markers = create("Frame", {
            Name = "Markers",
            Size = UDim2.new(0, 70, 0, 16),
            Position = UDim2.new(1, -(actionsW + 76), 0, IS_MOBILE and 5 or 3),
            BackgroundTransparency = 1,
            Parent = row,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = markers,
        })
        local function pill(name, text, c, order)
            local p = create("TextLabel", {
                Name = name,
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = c,
                BackgroundTransparency = 0.75,
                Text = text,
                TextColor3 = c,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                Visible = false,
                LayoutOrder = order,
                Parent = markers,
            })
            applyCorner(p, Theme.CornerRadius.SM)
            Framework.applyPadding(p, 0, 4, 0, 4)
            return p
        end
        pill("Returned", "↩", Theme.Colors.InvokeServer, 1)
        pill("Count", "×1", Theme.Colors.TextSecondary, 2)
        local star = Icons.draw("star", markers, 10, Theme.Colors.Watched)
        star.Name = "Watched"
        star.Visible = false
        star.LayoutOrder = 3

        local actionsFrame = create("Frame", {
            Name = "Actions",
            Size = UDim2.new(0, actionsW, 0, BTN),
            Position = UDim2.new(1, -(actionsW + 4), 0.5, -BTN / 2),
            BackgroundTransparency = 1,
            ZIndex = 5,
            Parent = row,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 3),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = actionsFrame,
        })

        local copyBtn   = actionButton(actionsFrame, "Copy",   "copy",   Theme.Colors.Accent, 1, T("tip_copy_r2s"))
        local blockBtn  = actionButton(actionsFrame, "Ignore", "ignore", Theme.Colors.Warning, 2, T("tip_ignore"))
        local deleteBtn = actionButton(actionsFrame, "Delete", "close",  Theme.Colors.Error, 3, T("tip_delete"))

        -- Guard: a button press must not also open the detail panel
        local buttonPressed = false
        local function guarded(fn)
            return function()
                buttonPressed = true
                task.delay(0.15, function() buttonPressed = false end)
                if fn then
                    local ok, err = pcall(fn, data, row)
                    if not ok then
                        Framework.notify(T("n_action_fail", tostring(err)), "error")
                    end
                end
            end
        end

        copyBtn.Activated:Connect(guarded(callbacks.onCopy))
        blockBtn.Activated:Connect(guarded(callbacks.onBlock))
        deleteBtn.Activated:Connect(guarded(callbacks.onDelete))

        row.Activated:Connect(function()
            task.defer(function()
                if buttonPressed then return end
                if callbacks.onSelect then
                    local ok, err = pcall(callbacks.onSelect, data, row)
                    if not ok then
                        Framework.notify(T("n_action_fail", tostring(err)), "error")
                    end
                end
            end)
        end)

        return row
    end

    local function marker(row, name)
        local m = row and row:FindFirstChild("Markers")
        return m and m:FindFirstChild(name)
    end

    function LogEntry.setCount(row, n)
        local p = marker(row, "Count")
        if not p then return end
        p.Text = "×" .. tostring(n)
        p.Visible = (n or 1) > 1
    end

    function LogEntry.setReturned(row, on)
        local p = marker(row, "Returned")
        if p then p.Visible = on and true or false end
    end

    function LogEntry.setWatched(row, on)
        local p = marker(row, "Watched")
        if p then p.Visible = on and true or false end
        local stripe = row and row:FindFirstChild("Stripe")
        if stripe and on then stripe.BackgroundColor3 = Theme.Colors.Watched end
    end

    function LogEntry.setAlert(row, on)
        if not row then return end
        row:SetAttribute("AlertBg", on and true or nil)
        row.BackgroundColor3 = on and Color3.fromRGB(60, 45, 20) or Theme.Colors.BgPrimary
    end

    LogEntry.ROW_HEIGHT = ROW_HEIGHT
    _G._RSPY.LogEntry = LogEntry
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: gui/components/search-bar.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — gui/components/search-bar.lua
        Reusable search/filter bar
    ]]

    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Icons = _G._RSPY.Icons

    local create = Framework.create
    local applyCorner = Framework.applyCorner

    local SearchBar = {}

    function SearchBar.new(parent, config)
        config = config or {}

        local bar = create("Frame", {
            Name = config.Name or "SearchBar",
            Size = config.Size or UDim2.new(1, 0, 0, 32),
            Position = config.Position or UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            LayoutOrder = config.LayoutOrder or 0,
            Parent = parent,
        })
        applyCorner(bar, Theme.CornerRadius.MD)

        -- Search icon (drawn magnifier)
        local icon = Icons.draw("logo", bar, 13, Theme.Colors.TextMuted)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 10, 0.5, 0)

        -- Text input
        local input = create("TextBox", {
            Name = "Input",
            Size = UDim2.new(1, -70, 1, -6),
            Position = UDim2.new(0, 30, 0, 3),
            BackgroundTransparency = 1,
            PlaceholderText = config.Placeholder or "Search...",
            PlaceholderColor3 = Theme.Colors.TextMuted,
            Text = "",
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = bar,
        })

        -- Clear button
        local clearBtn = create("TextButton", {
            Name = "Clear",
            Size = UDim2.new(0, 28, 0, 24),
            Position = UDim2.new(1, -32, 0.5, -12),
            BackgroundColor3 = Theme.Colors.BgTertiary,
            Text = "",
            Visible = false,
            Parent = bar,
        })
        applyCorner(clearBtn, Theme.CornerRadius.SM)
        local x = Icons.draw("close", clearBtn, 10, Theme.Colors.TextSecondary)
        x.AnchorPoint = Vector2.new(0.5, 0.5)
        x.Position = UDim2.new(0.5, 0, 0.5, 0)

        -- Events
        local onChange = config.OnChange

        input:GetPropertyChangedSignal("Text"):Connect(function()
            local text = input.Text
            clearBtn.Visible = (text ~= "")
            if onChange then
                onChange(text)
            end
        end)

        clearBtn.Activated:Connect(function()
            input.Text = ""
        end)

        return {
            Frame = bar,
            Input = input,
            getText = function() return input.Text end,
            setText = function(_, t) input.Text = t end,
            clear = function() input.Text = "" end,
        }
    end
    _G._RSPY.SearchBar = SearchBar
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: utils/search.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — utils/search.lua
        Cross-module search utilities
    ]]

    local Search = {}

    function Search.fuzzyMatch(query, text)
        if not query or query == "" then return true end
        if not text then return false end
        query = query:lower()
        text = text:lower()
        return text:find(query, 1, true) ~= nil
    end

    function Search.multiFieldMatch(query, fields)
        if not query or query == "" then return true end
        query = query:lower()
        for _, field in ipairs(fields) do
            if field and tostring(field):lower():find(query, 1, true) then
                return true
            end
        end
        return false
    end

    function Search.highlightMatch(text, query)
        -- Returns text with match wrapped (for RichText)
        if not query or query == "" then return text end
        local lower = text:lower()
        local qLower = query:lower()
        local start = lower:find(qLower, 1, true)
        if not start then return text end
        local finish = start + #qLower - 1
        return text:sub(1, start - 1)
            .. '<font color="#4B82FF"><b>' .. text:sub(start, finish) .. '</b></font>'
            .. text:sub(finish + 1)
    end
    _G._RSPY.Search = Search
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: modules/remote-spy.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — modules/remote-spy.lua
        Main Remote Spy module (v1.1.0)

        Wires Hooks → Session → GUI together.
        • Live feed with filters, search, grouping of identical calls (×N)
        • Detail panel: info, stats, arguments (+ diff with previous call),
          InvokeServer return values, R2S / replay code, actions
        • Keyword alerts, watchlist, per-game ignore / block lists
    ]]

    local Compat = _G._RSPY.Compat
    local Serializer = _G._RSPY.Serializer
    local Hooks = _G._RSPY.Hooks
    local Session = _G._RSPY.Session
    local Errors = _G._RSPY.Errors
    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Icons = _G._RSPY.Icons
    local LogEntry = _G._RSPY.LogEntry
    local SearchBar = _G._RSPY.SearchBar
    local I18n = _G._RSPY.I18n
    local Config = _G._RSPY.Config

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
    _G._RSPY.RemoteSpy = RemoteSpy
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: modules/explorer.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — modules/explorer.lua
        In-game Instance Explorer (DarkDEX-style)

        • Live game tree (services + nil instances), lazy expand
        • Deep search across the whole game (Enter / debounced)
        • Properties panel with live editing (bool / number / string / Color3 / Vector3)
        • Attributes + CollectionService tags
        • Actions: copy path, copy as code, teleport, view source,
          clone, destroy (client side), refresh
    ]]

    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Serializer = _G._RSPY.Serializer
    local Compat = _G._RSPY.Compat
    local I18n = _G._RSPY.I18n

    local T = I18n.T
    local create = Framework.create
    local applyCorner = Framework.applyCorner
    local applyPadding = Framework.applyPadding

    local Players = game:GetService("Players")

    local Explorer = {}

    local _treeScroll = nil
    local _propsScroll = nil
    local _propsHeader = nil
    local _selectedInstance = nil
    local _expandedNodes = {}  -- [Instance] = true
    local _rowCache = {}     -- [key] = { frame, arrow, label, inst } (v1.1.0 row cache)
    local _seen = {}         -- keys used during the current pass
    local _extraRows = {}    -- info / warning labels (recreated each pass)
    local _selectedKey = nil
    local _searchText = ""
    local _searchResults = nil -- flat list when a deep search is active
    local _rebuildQueued = false
    local _onViewSource = nil  -- set by init: function(scriptInstance)

    local MAX_ROWS = 1500
    local MAX_SEARCH_RESULTS = 300

    -- ── CLASS ICONS ─────────────────────────────────────────────────

    local CLASS_ICONS = {
        Folder          = "📁",
        Part            = "🟦",
        MeshPart        = "🔷",
        UnionOperation  = "🔶",
        Model           = "📦",
        Script          = "📜",
        LocalScript     = "📄",
        ModuleScript    = "📘",
        RemoteEvent     = "📡",
        RemoteFunction  = "📞",
        UnreliableRemoteEvent = "📶",
        BindableEvent   = "🔔",
        BindableFunction = "🔗",
        ScreenGui       = "🖥",
        Frame           = "⬜",
        ScrollingFrame  = "📜",
        TextLabel       = "🏷",
        TextButton      = "🔘",
        TextBox         = "⌨",
        ImageLabel      = "🖼",
        ImageButton     = "🖲",
        Sound           = "🔊",
        Animation       = "🎬",
        Animator        = "🎞",
        Tool            = "🔧",
        Camera          = "📷",
        Humanoid        = "🧍",
        Player          = "👤",
        SpawnLocation   = "⭐",
        StringValue     = "💬",
        IntValue        = "🔢",
        NumberValue     = "🔢",
        BoolValue       = "✅",
        ObjectValue     = "🔗",
        CFrameValue     = "🧭",
        Vector3Value    = "📐",
        Attachment      = "📌",
        Weld            = "🔩",
        WeldConstraint  = "🔩",
        Motor6D         = "⚙",
        ParticleEmitter = "✨",
        PointLight      = "💡",
        SpotLight       = "🔦",
        Decal           = "🎨",
        Texture         = "🧱",
        ProximityPrompt = "👆",
        ClickDetector   = "🖱",
        Workspace       = "🌍",
        Lighting        = "💡",
        ReplicatedStorage = "📦",
        ReplicatedFirst = "🚀",
        StarterGui      = "🖥",
        StarterPack     = "🎒",
        StarterPlayer   = "🧑",
        Players         = "👥",
        Teams           = "🏁",
        Team            = "🚩",
        SoundService    = "🎵",
        Chat            = "💭",
        TextChatService = "💭",
        CoreGui         = "🛡",
    }

    local function getIcon(inst)
        if not inst then return "❓" end
        local ok, cls = pcall(function() return inst.ClassName end)
        if not ok then return "❓" end
        return CLASS_ICONS[cls] or "⚪"
    end

    local function safeName(inst)
        local ok, n = pcall(function() return inst.Name end)
        return ok and tostring(n) or "?"
    end

    -- Virtual root holding getnilinstances()
    local NIL_ROOT = { __virtual = "nil" }

    local function getChildrenOf(node)
        if node == NIL_ROOT then
            local list = {}
            pcall(function()
                local fn = Compat.getGlobal("getnilinstances")
                if fn then list = fn() end
            end)
            return list
        end
        local children = {}
        pcall(function() children = node:GetChildren() end)
        return children
    end

    -- ── BUILD UI ────────────────────────────────────────────────────

    local function toolButton(parent, text, color, order)
        local b = create("TextButton", {
            Size = UDim2.new(0, 0, 0, 22),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = color or Theme.Colors.BgTertiary,
            BackgroundTransparency = 0.4,
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

    function Explorer.setViewSourceHandler(fn)
        _onViewSource = fn
    end

    function Explorer.buildUI(tabContent)
        -- New tab content (UI rebuild): previous rows died with the old window
        _rowCache = {}
        _extraRows = {}
        _selectedKey = nil

        -- Split: left = tree, right = properties
        local leftPanel = create("Frame", {
            Name = "TreePanel",
            Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, -2, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.Colors.BgDark,
            BorderSizePixel = 0,
            Parent = tabContent,
        })

        local rightPanel = create("Frame", {
            Name = "PropsPanel",
            Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.5, -2) or UDim2.new(0.5, -2, 1, 0),
            Position = Framework.IS_MOBILE and UDim2.new(0, 0, 0.5, 2) or UDim2.new(0.5, 2, 0, 0),
            BackgroundColor3 = Theme.Colors.BgDark,
            BorderSizePixel = 0,
            Parent = tabContent,
        })

        -- Tree search bar + refresh
        local treeSearch = create("Frame", {
            Name = "TreeSearch",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            Parent = leftPanel,
        })

        local searchInput = create("TextBox", {
            Size = UDim2.new(1, -40, 1, -4),
            Position = UDim2.new(0, 4, 0, 2),
            BackgroundTransparency = 1,
            PlaceholderText = T("ex_search"),
            PlaceholderColor3 = Theme.Colors.TextMuted,
            Text = "",
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = treeSearch,
        })

        local refreshBtn = create("TextButton", {
            Size = UDim2.new(0, 30, 0, 22),
            Position = UDim2.new(1, -34, 0, 3),
            BackgroundColor3 = Theme.Colors.BgTertiary,
            Text = "🔄",
            TextSize = 12,
            Parent = treeSearch,
        })
        applyCorner(refreshBtn, Theme.CornerRadius.SM)

        -- Debounced deep search
        local searchToken = 0
        local function runSearch()
            searchToken = searchToken + 1
            local myToken = searchToken
            task.delay(0.35, function()
                if myToken ~= searchToken then return end
                _searchText = searchInput.Text:lower()
                Explorer._doSearch()
                Explorer._rebuildTree()
            end)
        end
        searchInput:GetPropertyChangedSignal("Text"):Connect(runSearch)
        searchInput.FocusLost:Connect(function(enter) if enter then runSearch() end end)

        refreshBtn.Activated:Connect(function()
            Explorer._doSearch()
            Explorer._rebuildTree()
            if _selectedInstance then Explorer._showProperties(_selectedInstance) end
        end)

        -- Tree scroll
        _treeScroll = Framework.createScrollFrame(leftPanel, {
            Name = "TreeScroll",
            Size = UDim2.new(1, 0, 1, -28),
            Position = UDim2.new(0, 0, 0, 28),
            Padding = 1,
        })

        -- Props header (breadcrumb)
        _propsHeader = create("TextLabel", {
            Name = "PropsHeader",
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            Text = "  " .. T("ex_props"),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Heading,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = rightPanel,
        })

        -- Props scroll
        _propsScroll = Framework.createScrollFrame(rightPanel, {
            Name = "PropsScroll",
            Size = UDim2.new(1, 0, 1, -26),
            Position = UDim2.new(0, 0, 0, 26),
            Padding = 2,
            InnerPadding = 3,
        })

        create("TextLabel", {
            Name = "Hint",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = T("ex_select"),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Small,
            Parent = _propsScroll,
        })

        Explorer._rebuildTree()
        if _selectedInstance then
            pcall(Explorer._showProperties, _selectedInstance)
        end
    end

    -- ── DEEP SEARCH ─────────────────────────────────────────────────

    function Explorer._doSearch()
        if _searchText == "" then
            _searchResults = nil
            return
        end
        local results = {}
        local q = _searchText
        local ok, all = pcall(function() return game:GetDescendants() end)
        if ok then
            for i, inst in ipairs(all) do
                local okN, hit = pcall(function()
                    return inst.Name:lower():find(q, 1, true) or inst.ClassName:lower():find(q, 1, true)
                end)
                if okN and hit then
                    table.insert(results, inst)
                    if #results >= MAX_SEARCH_RESULTS then break end
                end
                if i % 4000 == 0 then task.wait() end -- keep the game smooth
            end
        end
        _searchResults = results
    end

    -- ── TREE RENDERING ──────────────────────────────────────────────

    -- v1.1.0: rows are CACHED and reused. A rebuild only updates order /
    -- indent / text of existing rows instead of destroying and recreating up
    -- to 1,500 frames on every click (much faster on big games / mobile).


    local function rowKey(inst, showPath)
        return showPath and ("s:" .. tostring(inst)) or inst
    end

    local function paintSelection(cached, selected)
        if not cached then return end
        cached.frame.BackgroundColor3 = selected and Theme.Colors.BgSelected or Theme.Colors.BgDark
        cached.frame.BackgroundTransparency = selected and 0 or 1
        cached.label.TextColor3 = selected and Theme.Colors.TextAccent or Theme.Colors.TextPrimary
    end

    -- Selecting only repaints two rows (no rebuild)
    local function selectInstance(inst, key)
        if _selectedKey and _rowCache[_selectedKey] then
            paintSelection(_rowCache[_selectedKey], false)
        end
        _selectedInstance = inst
        _selectedKey = key
        paintSelection(_rowCache[key], true)
    end

    function Explorer._rebuildTree()
        if not _treeScroll then return end

        _seen = {}
        for _, lbl in ipairs(_extraRows) do
            if lbl and lbl.Parent then lbl:Destroy() end
        end
        _extraRows = {}

        local order = 0

        if _searchResults then
            local info = create("TextLabel", {
                Name = "SearchInfo",
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = T("ex_results", #_searchResults),
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Body,
                TextSize = Theme.TextSizes.Tiny,
                LayoutOrder = 0,
                Parent = _treeScroll,
            })
            table.insert(_extraRows, info)
            for _, inst in ipairs(_searchResults) do
                order = order + 1
                Explorer._renderRow(inst, 0, order, true)
            end
        else
            local roots = {}
            local serviceNames = {
                "Workspace", "Players", "Lighting", "MaterialService", "ReplicatedFirst",
                "ReplicatedStorage", "ServerScriptService", "ServerStorage",
                "StarterGui", "StarterPack", "StarterPlayer", "Teams",
                "SoundService", "Chat", "TextChatService", "LocalizationService", "TestService",
            }
            for _, name in ipairs(serviceNames) do
                local ok, svc = pcall(function() return game:GetService(name) end)
                if ok and svc then table.insert(roots, svc) end
            end
            if Compat.has("getnilinstances") then
                table.insert(roots, NIL_ROOT)
            end

            for _, root in ipairs(roots) do
                order = Explorer._renderNode(root, 0, order)
                if order >= MAX_ROWS then
                    local warnLbl = create("TextLabel", {
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        Text = T("ex_too_many", MAX_ROWS),
                        TextColor3 = Theme.Colors.Warning,
                        Font = Theme.Fonts.Body,
                        TextSize = Theme.TextSizes.Tiny,
                        LayoutOrder = order + 1,
                        Parent = _treeScroll,
                    })
                    table.insert(_extraRows, warnLbl)
                    break
                end
            end
        end

        -- Drop rows that are no longer displayed (collapsed / destroyed instances)
        for key, cached in pairs(_rowCache) do
            if not _seen[key] then
                pcall(function() cached.frame:Destroy() end)
                _rowCache[key] = nil
            end
        end
    end

    function Explorer._renderRow(inst, depth, order, showPath)
        local isNil = (inst == NIL_ROOT)
        local children = isNil and { 1 } or getChildrenOf(inst)
        local hasChildren = #children > 0
        local isExpanded = _expandedNodes[inst] == true
        local key = rowKey(inst, showPath)
        _seen[key] = true

        local cached = _rowCache[key]
        if not cached then
            local row = create("Frame", {
                Name = "Node",
                Size = UDim2.new(1, 0, 0, Framework.IS_MOBILE and 26 or 20),
                BackgroundColor3 = Theme.Colors.BgDark,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = _treeScroll,
            })
            local arrow = create("TextButton", {
                Size = UDim2.new(0, Framework.IS_MOBILE and 22 or 16, 1, 0),
                BackgroundTransparency = 1,
                Text = " ",
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = 10,
                Parent = row,
            })
            local label = create("TextButton", {
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Body,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
            cached = { frame = row, arrow = arrow, label = label, inst = inst }
            _rowCache[key] = cached

            row.MouseEnter:Connect(function()
                if _selectedKey ~= key then
                    row.BackgroundTransparency = 0
                    row.BackgroundColor3 = Theme.Colors.BgHover
                end
            end)
            row.MouseLeave:Connect(function()
                if _selectedKey ~= key then
                    row.BackgroundTransparency = 1
                end
            end)

            local function toggleExpand()
                _expandedNodes[inst] = not _expandedNodes[inst]
                Explorer._rebuildTree()
            end

            label.Activated:Connect(function()
                if inst == NIL_ROOT then toggleExpand() return end
                selectInstance(inst, key)
                Explorer._showProperties(inst)
            end)
            arrow.Activated:Connect(function()
                if showPath then return end
                if inst == NIL_ROOT or #getChildrenOf(inst) > 0 then toggleExpand() end
            end)
        end

        -- Refresh what may have changed since last pass
        local indent = depth * 12
        local arrowW = Framework.IS_MOBILE and 22 or 16
        cached.frame.LayoutOrder = order
        cached.arrow.Position = UDim2.new(0, indent, 0, 0)
        cached.arrow.Text = (hasChildren and not showPath) and (isExpanded and "▼" or "▶") or " "
        cached.label.Size = UDim2.new(1, -(indent + arrowW + 4), 1, 0)
        cached.label.Position = UDim2.new(0, indent + arrowW + 2, 0, 0)

        local text
        if isNil then
            text = "🕳 " .. T("ex_nil")
        else
            text = getIcon(inst) .. " " .. safeName(inst)
            if showPath then
                local okP, full = pcall(function() return inst:GetFullName() end)
                if okP then text = text .. "   ·  " .. full end
            end
        end
        cached.label.Text = text

        local isSelected = (_selectedInstance == inst)
        if isSelected then _selectedKey = key end
        paintSelection(cached, isSelected)

        return children, hasChildren, isExpanded
    end

    function Explorer._renderNode(inst, depth, order)
        if not inst then return order end
        if order >= MAX_ROWS then return order end

        order = order + 1
        local _, hasChildren, isExpanded = Explorer._renderRow(inst, depth, order, false)

        if isExpanded and hasChildren then
            local children = getChildrenOf(inst)
            table.sort(children, function(a, b)
                return safeName(a):lower() < safeName(b):lower()
            end)
            for _, child in ipairs(children) do
                order = Explorer._renderNode(child, depth + 1, order)
                if order >= MAX_ROWS then break end
            end
        end

        return order
    end

    -- Expands every ancestor so an instance becomes visible in the tree
    function Explorer.reveal(inst)
        if typeof(inst) ~= "Instance" then return end
        local cur = inst.Parent
        while cur and cur ~= game do
            _expandedNodes[cur] = true
            cur = cur.Parent
        end
        _selectedInstance = inst
        _searchResults = nil
        Explorer._rebuildTree()
        Explorer._showProperties(inst)
    end

    -- ── PROPERTIES PANEL ────────────────────────────────────────────

    local COMMON_PROPS = {
        "Archivable", "Parent",
        -- BasePart
        "Anchored", "CanCollide", "CanTouch", "CanQuery", "Massless", "Transparency",
        "Size", "Position", "Orientation", "CFrame", "Color", "BrickColor", "Material",
        "Reflectance", "CastShadow", "Locked",
        -- Model
        "PrimaryPart", "WorldPivot",
        -- Values
        "Value",
        -- GUI
        "Text", "TextColor3", "TextSize", "BackgroundColor3", "BackgroundTransparency",
        "Visible", "Enabled", "ZIndex", "AnchorPoint", "Image", "Active",
        -- Humanoid
        "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "HipHeight",
        "DisplayName", "RigType", "PlatformStand", "Sit",
        -- Player
        "UserId", "AccountAge", "Team", "TeamColor", "Neutral",
        -- Sound
        "SoundId", "Volume", "Playing", "Looped", "PlaybackSpeed", "TimePosition",
        -- Light / Effects
        "Brightness", "Range", "Shadows", "Rate", "Lifetime",
        -- Lighting
        "ClockTime", "Ambient", "FogEnd", "GlobalShadows",
        -- Prompts / detectors
        "ActionText", "ObjectText", "HoldDuration", "MaxActivationDistance", "KeyboardKeyCode",
        -- Scripts
        "Disabled", "RunContext",
        -- Tools
        "RequiresHandle", "CanBeDropped", "ToolTip",
        -- Camera
        "FieldOfView", "CameraType", "CameraSubject",
    }

    local EDITABLE = { boolean = true, number = true, string = true, Color3 = true, Vector3 = true }

    local function formatValue(val)
        local t = typeof(val)
        if t == "Instance" then
            local ok, full = pcall(function() return val:GetFullName() end)
            return ok and full or tostring(val)
        elseif t == "Vector3" then
            return string.format("%.2f, %.2f, %.2f", val.X, val.Y, val.Z)
        elseif t == "Color3" then
            return string.format("%d, %d, %d", val.R * 255, val.G * 255, val.B * 255)
        elseif t == "number" then
            if val % 1 == 0 then return tostring(val) end
            return string.format("%.3f", val)
        end
        local s = tostring(val)
        if #s > 120 then s = s:sub(1, 120) .. "…" end
        return s
    end

    local function parseValue(t, text)
        if t == "number" then return tonumber(text) end
        if t == "string" then return text end
        if t == "Vector3" or t == "Color3" then
            local nums = {}
            for n in tostring(text):gmatch("[-%d%.]+") do table.insert(nums, tonumber(n)) end
            if #nums < 3 then return nil end
            if t == "Vector3" then return Vector3.new(nums[1], nums[2], nums[3]) end
            return Color3.fromRGB(nums[1], nums[2], nums[3])
        end
        return nil
    end

    local function codePath(inst)
        local ok, path = pcall(Serializer.getInstancePath, inst)
        if ok and path then return path end
        local okF, full = pcall(function() return inst:GetFullName() end)
        return okF and full or "nil"
    end

    function Explorer._showProperties(inst)
        if not _propsScroll or not inst then return end

        for _, c in ipairs(_propsScroll:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end

        pcall(function()
            _propsHeader.Text = "  " .. getIcon(inst) .. " " .. inst:GetFullName()
        end)

        local order = 0
        local function nextOrder() order = order + 1; return order end

        local function sectionTitle(text)
            create("TextLabel", {
                Size = UDim2.new(1, -4, 0, 18),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Colors.TextAccent,
                Font = Theme.Fonts.Heading,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = nextOrder(),
                Parent = _propsScroll,
            })
        end

        local function addPropRow(name, value, color, editable, setter)
            local row = create("Frame", {
                Size = UDim2.new(1, -4, 0, 20),
                BackgroundColor3 = (order % 2 == 0) and Theme.Colors.BgSecondary or Theme.Colors.BgDark,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                Parent = _propsScroll,
            })

            create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Colors.TextSecondary,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })

            local vt = typeof(value)
            if editable and vt == "boolean" then
                local b = create("TextButton", {
                    Size = UDim2.new(0, 44, 0, 16),
                    Position = UDim2.new(0.4, 4, 0.5, -8),
                    BackgroundColor3 = value and Theme.Colors.Success or Theme.Colors.BgTertiary,
                    Text = value and "true" or "false",
                    TextColor3 = Theme.Colors.TextPrimary,
                    Font = Theme.Fonts.Code,
                    TextSize = Theme.TextSizes.Tiny,
                    Parent = row,
                })
                applyCorner(b, Theme.CornerRadius.SM)
                b.Activated:Connect(function()
                    local newVal = not value
                    local ok, err = pcall(setter, newVal)
                    if ok then
                        value = newVal
                        b.Text = value and "true" or "false"
                        b.BackgroundColor3 = value and Theme.Colors.Success or Theme.Colors.BgTertiary
                        Framework.notify(T("n_prop_set", name, tostring(value)), "success", 1.5)
                    else
                        Framework.notify(T("n_prop_fail", name, tostring(err)), "error")
                    end
                end)
            elseif editable and EDITABLE[vt] then
                local box = create("TextBox", {
                    Size = UDim2.new(0.58, 0, 1, -2),
                    Position = UDim2.new(0.4, 4, 0, 1),
                    BackgroundColor3 = Theme.Colors.BgPrimary,
                    BackgroundTransparency = 0.4,
                    Text = formatValue(value),
                    ClearTextOnFocus = false,
                    TextColor3 = color or Theme.Colors.TextPrimary,
                    Font = Theme.Fonts.Code,
                    TextSize = Theme.TextSizes.Tiny,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })
                applyCorner(box, Theme.CornerRadius.SM)
                box.FocusLost:Connect(function(enter)
                    if not enter then box.Text = formatValue(value) return end
                    local parsed = parseValue(vt, box.Text)
                    if parsed == nil then box.Text = formatValue(value) return end
                    local ok, err = pcall(setter, parsed)
                    if ok then
                        value = parsed
                        Framework.notify(T("n_prop_set", name, formatValue(parsed)), "success", 1.5)
                    else
                        Framework.notify(T("n_prop_fail", name, tostring(err)), "error")
                    end
                    box.Text = formatValue(value)
                end)
            else
                create("TextBox", {
                    Size = UDim2.new(0.58, 0, 1, 0),
                    Position = UDim2.new(0.4, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = formatValue(value),
                    TextEditable = false,
                    ClearTextOnFocus = false,
                    TextColor3 = color or Theme.Colors.TextPrimary,
                    Font = Theme.Fonts.Code,
                    TextSize = Theme.TextSizes.Tiny,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })
            end
            return row
        end

        -- ── Actions ──
        local actions = create("Frame", {
            Size = UDim2.new(1, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
            Parent = _propsScroll,
        })
        create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -3, 0, 24),
            CellPadding = UDim2.new(0, 4, 0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = actions,
        })

        local bPath  = toolButton(actions, T("ex_copy_path"), Theme.Colors.Accent, 1)
        local bCode  = toolButton(actions, T("ex_copy_code"), Theme.Colors.Accent, 2)
        bPath.AutomaticSize = Enum.AutomaticSize.None
        bCode.AutomaticSize = Enum.AutomaticSize.None

        bPath.Activated:Connect(function()
            local okF, full = pcall(function() return inst:GetFullName() end)
            Framework.copy(okF and full or codePath(inst), T("c_path"))
        end)
        bCode.Activated:Connect(function()
            Framework.copy("local instance = " .. codePath(inst), T("c_code"))
        end)

        local isPart, isModel, isScript = false, false, false
        pcall(function()
            isPart = inst:IsA("BasePart")
            isModel = inst:IsA("Model")
            isScript = inst:IsA("LuaSourceContainer")
        end)

        if isPart or isModel then
            local bTp = toolButton(actions, T("ex_tp"), Theme.Colors.Success, 3)
            bTp.AutomaticSize = Enum.AutomaticSize.None
            bTp.Activated:Connect(function()
                local ok = pcall(function()
                    local char = Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local cf = isPart and inst.CFrame or inst:GetPivot()
                    hrp.CFrame = cf + Vector3.new(0, 4, 0)
                end)
                Framework.notify(ok and T("n_tp_ok", safeName(inst)) or T("n_tp_fail"), ok and "success" or "error")
            end)
        end

        if isScript then
            local bSrc = toolButton(actions, T("ex_view_src"), Theme.Colors.Info, 4)
            bSrc.AutomaticSize = Enum.AutomaticSize.None
            bSrc.Activated:Connect(function()
                if _onViewSource then _onViewSource(inst) end
            end)
        end

        local bClone = toolButton(actions, T("ex_clone"), Theme.Colors.BgTertiary, 5)
        bClone.AutomaticSize = Enum.AutomaticSize.None
        bClone.Activated:Connect(function()
            local ok, err = pcall(function()
                local c = inst:Clone()
                c.Parent = inst.Parent
            end)
            Framework.notify(ok and T("n_cloned", safeName(inst)) or tostring(err), ok and "success" or "error")
            Explorer._rebuildTree()
        end)

        local bDestroy = toolButton(actions, T("ex_destroy"), Theme.Colors.Error, 6)
        bDestroy.AutomaticSize = Enum.AutomaticSize.None
        bDestroy.Activated:Connect(function()
            local name = safeName(inst)
            local ok, err = pcall(function() inst:Destroy() end)
            Framework.notify(ok and T("n_destroyed", name) or tostring(err), ok and "warning" or "error")
            if ok then
                _selectedInstance = nil
                Explorer._rebuildTree()
                for _, c in ipairs(_propsScroll:GetChildren()) do
                    if c:IsA("GuiObject") then c:Destroy() end
                end
            end
        end)

        -- ── Identity ──
        sectionTitle("ℹ️  " .. T("ex_props"))
        addPropRow("ClassName", inst.ClassName, Theme.Colors.TextAccent)
        addPropRow("Name", inst.Name, nil, true, function(v) inst.Name = v end)
        pcall(function() addPropRow("FullName", inst:GetFullName()) end)

        for _, propName in ipairs(COMMON_PROPS) do
            local ok2, val = pcall(function() return inst[propName] end)
            if ok2 and val ~= nil and typeof(val) ~= "RBXScriptSignal" and typeof(val) ~= "function" then
                addPropRow(propName, val, nil, propName ~= "Parent", function(v) inst[propName] = v end)
            end
        end

        pcall(function() addPropRow(T("ex_children"), #inst:GetChildren()) end)
        pcall(function() addPropRow(T("ex_desc"), #inst:GetDescendants()) end)

        -- ── Attributes ──
        local okA, attrs = pcall(function() return inst:GetAttributes() end)
        if okA and attrs and next(attrs) then
            sectionTitle(T("ex_attrs"))
            local names = {}
            for k in pairs(attrs) do table.insert(names, k) end
            table.sort(names)
            for _, k in ipairs(names) do
                addPropRow("@" .. k, attrs[k], Theme.Colors.Warning, true, function(v) inst:SetAttribute(k, v) end)
            end
        end

        -- ── Tags ──
        local okT, tags = pcall(function()
            return game:GetService("CollectionService"):GetTags(inst)
        end)
        if okT and tags and #tags > 0 then
            sectionTitle(T("ex_tags"))
            addPropRow("Tags", table.concat(tags, ", "), Theme.Colors.OnClientEvent)
        end
    end
    _G._RSPY.Explorer = Explorer
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: modules/network-monitor.lua
-- ══════════════════════════════════════════════════════════════
do
    --[[
        RobloxSpy — modules/network-monitor.lua
        Live network traffic dashboard

        Shows real-time stats: calls/sec, top remotes,
        bandwidth estimate, traffic graph.
    ]]

    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Hooks = _G._RSPY.Hooks
    local Session = _G._RSPY.Session
    local I18n = _G._RSPY.I18n
    local T = I18n.T

    local RunService = game:GetService("RunService")

    local create = Framework.create
    local applyCorner = Framework.applyCorner
    local applyPadding = Framework.applyPadding

    local NetworkMonitor = {}

    -- ── STATE ────────────────────────────────────────────────────────
    local _updateConn = nil
    local _callHistory = {}     -- ring buffer of { time = os.clock(), method = string }
    local _historySize = 300    -- ~5 minutes at 1/sec
    local _remoteCounts = {}    -- [remoteName] = count
    local _statsLabels = {}
    local _graphBars = {}
    local _graphValues = {}     -- last 60 values for mini graph
    local GRAPH_WIDTH = 60

    -- ── BUILD UI ────────────────────────────────────────────────────

    function NetworkMonitor.buildUI(tabContent)
        local scroll = Framework.createScrollFrame(tabContent, {
            Name = "NetMonScroll",
            Padding = 6,
            InnerPadding = 8,
        })

        -- ── Stats cards row ──
        local statsRow = create("Frame", {
            Name = "StatsRow",
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = scroll,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = statsRow,
        })

        local function makeStatCard(name, label, value, color)
            local card = create("Frame", {
                Name = name,
                Size = UDim2.new(0, 120, 0, 56),
                BackgroundColor3 = Theme.Colors.BgSecondary,
                BorderSizePixel = 0,
                Parent = statsRow,
            })
            applyCorner(card, Theme.CornerRadius.MD)

            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                Position = UDim2.new(0, 8, 0, 4),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Medium,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })

            local valLabel = create("TextLabel", {
                Name = "Value",
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 8, 0, 20),
                BackgroundTransparency = 1,
                Text = value,
                TextColor3 = color or Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Heading,
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card,
            })

            _statsLabels[name] = valLabel
            return card
        end

        makeStatCard("totalCalls", T("net_total"), "0", Theme.Colors.Accent)
        makeStatCard("callsSec", T("net_cps"), "0", Theme.Colors.Success)
        makeStatCard("uniqueRemotes", T("net_unique"), "0", Theme.Colors.Warning)
        makeStatCard("blocked", T("net_blocked"), "0", Theme.Colors.Error)

        -- ── Mini traffic graph ──
        local graphFrame = create("Frame", {
            Name = "Graph",
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Parent = scroll,
        })
        applyCorner(graphFrame, Theme.CornerRadius.MD)

        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 8, 0, 2),
            BackgroundTransparency = 1,
            Text = T("net_traffic"),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = graphFrame,
        })

        local barsContainer = create("Frame", {
            Name = "Bars",
            Size = UDim2.new(1, -16, 0, 54),
            Position = UDim2.new(0, 8, 0, 20),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = graphFrame,
        })

        -- Pre-create bar frames
        for i = 1, GRAPH_WIDTH do
            local bar = create("Frame", {
                Name = "Bar" .. i,
                Size = UDim2.new(1 / GRAPH_WIDTH, -1, 0, 1),
                Position = UDim2.new((i - 1) / GRAPH_WIDTH, 0, 1, -1),
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Theme.Colors.Accent,
                BorderSizePixel = 0,
                Parent = barsContainer,
            })
            applyCorner(bar, UDim.new(0, 1))
            _graphBars[i] = bar
        end

        for i = 1, GRAPH_WIDTH do
            _graphValues[i] = 0
        end

        -- ── Top remotes list ──
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = T("net_top") .. "  ·  " .. T("net_click_hint"),
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Heading,
            TextSize = Theme.TextSizes.Body,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            Parent = scroll,
        })

        _statsLabels._topList = create("Frame", {
            Name = "TopList",
            Size = UDim2.new(1, 0, 0, 200),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            LayoutOrder = 3,
            ClipsDescendants = true,
            Parent = scroll,
        })
        applyCorner(_statsLabels._topList, Theme.CornerRadius.MD)
        create("UIListLayout", {
            Padding = UDim.new(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = _statsLabels._topList,
        })

        -- Start update loop
        NetworkMonitor._startUpdates()
    end

    -- ── DATA TRACKING ───────────────────────────────────────────────

    function NetworkMonitor.recordCall(event)
        table.insert(_callHistory, {
            time = os.clock(),
            method = event.method,
        })

        -- Trim old entries (older than 5 min)
        local cutoff = os.clock() - 300
        while #_callHistory > 0 and _callHistory[1].time < cutoff do
            table.remove(_callHistory, 1)
        end

        -- Track per-remote count
        local name = ""
        pcall(function() name = event.remote.Name end)
        _remoteCounts[name] = (_remoteCounts[name] or 0) + 1
    end

    -- ── UPDATE LOOP ─────────────────────────────────────────────────

    function NetworkMonitor._startUpdates()
        if _updateConn then return end

        local lastUpdate = 0
        _updateConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if now - lastUpdate < 1 then return end
            lastUpdate = now

            NetworkMonitor._updateStats()
            NetworkMonitor._updateGraph()
            NetworkMonitor._updateTopRemotes()
        end)
    end

    function NetworkMonitor._updateStats()
        local stats = Session.getStats()
        if not stats then return end

        -- Calls per second (last 5 seconds)
        local now = os.clock()
        local recentCount = 0
        for i = #_callHistory, 1, -1 do
            if now - _callHistory[i].time <= 5 then
                recentCount = recentCount + 1
            else
                break
            end
        end
        local cps = math.floor(recentCount / 5 * 10) / 10

        if _statsLabels.totalCalls then
            _statsLabels.totalCalls.Text = tostring(stats.totalCalls or 0)
        end
        if _statsLabels.callsSec then
            _statsLabels.callsSec.Text = string.format("%.1f", cps)
        end
        if _statsLabels.uniqueRemotes then
            _statsLabels.uniqueRemotes.Text = tostring(stats.uniqueRemotes or 0)
        end
        if _statsLabels.blocked then
            _statsLabels.blocked.Text = tostring(stats.blockedCalls or 0)
        end
    end

    function NetworkMonitor._updateGraph()
        -- Shift left
        for i = 1, GRAPH_WIDTH - 1 do
            _graphValues[i] = _graphValues[i + 1]
        end

        -- Current second calls
        local now = os.clock()
        local count = 0
        for i = #_callHistory, 1, -1 do
            if now - _callHistory[i].time <= 1 then
                count = count + 1
            else
                break
            end
        end
        _graphValues[GRAPH_WIDTH] = count

        -- Find max for scaling
        local maxVal = 1
        for _, v in ipairs(_graphValues) do
            if v > maxVal then maxVal = v end
        end

        -- Update bars
        for i = 1, GRAPH_WIDTH do
            local bar = _graphBars[i]
            if bar then
                local h = math.max(1, (_graphValues[i] / maxVal) * 50)
                bar.Size = UDim2.new(1 / GRAPH_WIDTH, -1, 0, h)

                -- Color intensity
                local ratio = _graphValues[i] / maxVal
                if ratio > 0.8 then
                    bar.BackgroundColor3 = Theme.Colors.Error
                elseif ratio > 0.5 then
                    bar.BackgroundColor3 = Theme.Colors.Warning
                else
                    bar.BackgroundColor3 = Theme.Colors.Accent
                end
            end
        end
    end

    function NetworkMonitor._updateTopRemotes()
        local topList = _statsLabels._topList
        if not topList then return end

        -- Clear old rows
        for _, c in ipairs(topList:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end

        -- Sort remotes by count
        local sorted = {}
        for name, count in pairs(_remoteCounts) do
            table.insert(sorted, { name = name, count = count })
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)

        if #sorted == 0 then
            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = T("empty_network"),
                TextWrapped = true,
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Body,
                TextSize = Theme.TextSizes.Small,
                Parent = topList,
            })
            return
        end

        -- Show top 10 — click a row to filter the Remote Spy feed on it
        for i = 1, math.min(10, #sorted) do
            local item = sorted[i]
            local row = create("TextButton", {
                Size = UDim2.new(1, 0, 0, Framework.IS_MOBILE and 26 or 20),
                BackgroundColor3 = (i % 2 == 0) and Theme.Colors.BgTertiary or Theme.Colors.BgSecondary,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                AutoButtonColor = true,
                Text = "",
                LayoutOrder = i,
                Parent = topList,
            })
            row.Activated:Connect(function()
                if NetworkMonitor.onRemoteClick then
                    pcall(NetworkMonitor.onRemoteClick, item.name)
                end
            end)

            create("TextLabel", {
                Size = UDim2.new(0, 24, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text = "#" .. i,
                TextColor3 = Theme.Colors.TextMuted,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                BackgroundTransparency = 1,
                Text = item.name,
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Body,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })

            create("TextLabel", {
                Size = UDim2.new(0.25, 0, 1, 0),
                Position = UDim2.new(0.75, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(item.count),
                TextColor3 = Theme.Colors.TextAccent,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Small,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
        end
    end

    function NetworkMonitor.stop()
        if _updateConn then
            _updateConn:Disconnect()
            _updateConn = nil
        end
    end
    _G._RSPY.NetworkMonitor = NetworkMonitor
end

-- ══════════════════════════════════════════════════════════════
-- MODULE: modules/script-viewer.lua
-- ══════════════════════════════════════════════════════════════
do
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

    local Framework = _G._RSPY.Framework
    local Theme = _G._RSPY.Theme
    local Compat = _G._RSPY.Compat
    local Config = _G._RSPY.Config
    local I18n = _G._RSPY.I18n
    local Errors = _G._RSPY.Errors

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
    _G._RSPY.ScriptViewer = ScriptViewer
end

-- ══════════════════════════════════════════════════════════════
-- INIT: init.lua
-- ══════════════════════════════════════════════════════════════
do
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


    -- Attempt module loading (works in Studio / file-based setups)
    Compat     = _G._RSPY.Compat
    Config     = _G._RSPY.Config
    I18n       = _G._RSPY.I18n
    Errors     = _G._RSPY.Errors
    if Errors and Errors.watchConsole then pcall(Errors.watchConsole) end
    Serializer = _G._RSPY.Serializer
    Hooks      = _G._RSPY.Hooks
    Session    = _G._RSPY.Session
    Framework  = _G._RSPY.Framework
    Theme      = _G._RSPY.Theme
    Icons      = _G._RSPY.Icons
    RemoteSpy      = _G._RSPY.RemoteSpy
    Explorer       = _G._RSPY.Explorer
    NetworkMonitor = _G._RSPY.NetworkMonitor
    ScriptViewer   = _G._RSPY.ScriptViewer
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

end
