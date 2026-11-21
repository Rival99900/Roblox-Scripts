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

local Compat = require(script.Parent.compat)
local Serializer = require(script.Parent.serializer)
local Errors = require(script.Parent.errors)

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

return Hooks
