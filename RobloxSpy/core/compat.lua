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

return Compat
