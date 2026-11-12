--[[
    RobloxSpy — core/hooks.lua
    Remote call interception engine

    Hooks __namecall (preferred) or individual remote functions
    to capture FireServer / InvokeServer / OnClientEvent traffic.

    FIX v2: Replaced checkcaller() guard with _processing flag.
    checkcaller() returns true INSIDE a hookmetamethod closure on
    most executors, which silently skipped every single call.
]]

local Compat   = require(script.Parent.compat)
local Serializer = require(script.Parent.serializer)

local Hooks = {}

-- ── STATE ────────────────────────────────────────────────────────
local _started           = false
local _strategy          = "none"       -- "namecall" | "hookfunc" | "none"
local _callbacks         = {}
local _callId            = 0
local _originalNamecall  = nil
local _hookedFunctions   = {}           -- { original = fn, ... }
local _incomingConns     = {}           -- OnClientEvent connections
local _scannedRemotes    = {}           -- already-scanned remotes
local _processing        = false        -- recursion guard (replaces checkcaller)
local _queue             = {}           -- raw captures waiting to be processed
local _drainConn         = nil          -- Heartbeat connection draining _queue
local _errorShown        = {}           -- avoid console spam

-- Filters
local _paused            = false
local _blockedRemotes    = {}           -- [remote] = true  (ignored: not logged)
local _dropRemotes       = {}           -- [remote] = true  (call cancelled)
local _typeFilter        = nil          -- nil = all, or "RemoteEvent"/"RemoteFunction"

-- ── HELPERS ──────────────────────────────────────────────────────
local Players = game:GetService("Players")

local FIRE_METHODS = {
    FireServer      = true,
    InvokeServer    = true,
    fireServer      = true,
    invokeServer    = true,
}

local function getMethodType(method)
    if method == "FireServer" or method == "fireServer" then
        return "FireServer"
    elseif method == "InvokeServer" or method == "invokeServer" then
        return "InvokeServer"
    end
    return nil
end

-- Classes captured by the spy (checked with .ClassName: safe inside hooks)
local REMOTE_CLASSES = {
    RemoteEvent = true,
    RemoteFunction = true,
    UnreliableRemoteEvent = true,
}

local function isRemoteInstance(obj)
    if typeof(obj) ~= "Instance" then return false end
    local cls = nil
    pcall(function() cls = obj.ClassName end)
    return REMOTE_CLASSES[cls] == true
end

local function getRemoteType(obj)
    if typeof(obj) ~= "Instance" then return "Unknown" end
    local cls = nil
    pcall(function() cls = obj.ClassName end)
    if REMOTE_CLASSES[cls] then return cls end
    return "Unknown"
end

local function generateCallId()
    _callId = _callId + 1
    return _callId
end

-- ── EVENT PUBLISHING ─────────────────────────────────────────────
local function publish(event)
    for _, cb in ipairs(_callbacks) do
        local ok, err = pcall(cb, event)
        if not ok then
            local key = tostring(err)
            if not _errorShown[key] then
                _errorShown[key] = true
                warn("[RobloxSpy] Callback error: " .. key)
            end
        end
    end
end

local function processCall(remote, methodName, args, callingScript)
    if _paused then return end
    if not isRemoteInstance(remote) then return end
    if _blockedRemotes[remote] then return end

    local remoteType = getRemoteType(remote)
    if _typeFilter and remoteType ~= _typeFilter then return end

    local remotePath = ""
    local ok1, path = pcall(function() return Serializer.getInstancePath(remote) end)
    if ok1 then remotePath = path else remotePath = tostring(remote) end

    local serializedArgs = {}
    local ok2, sArgs = pcall(function() return Serializer.serializeArgs(args) end)
    if ok2 then serializedArgs = sArgs end

    local r2s = ""
    local ok3, code = pcall(function() return Serializer.generateR2S(remote, methodName, args) end)
    if ok3 then r2s = code end

    local event = {
        id             = generateCallId(),
        type           = "outgoing",
        method         = methodName,
        remote         = remote,
        remoteName     = (pcall(function() return remote.Name end)) and remote.Name or "???",
        remotePath     = remotePath,
        remoteType     = remoteType,
        args           = args,
        serializedArgs = serializedArgs,
        r2s            = r2s,
        callingScript  = callingScript,
        timestamp      = os.clock(),
        blocked        = _dropRemotes[remote] == true,
    }

    publish(event)
end

local function processIncoming(remote, args)
    if _paused then return end
    if not isRemoteInstance(remote) then return end
    if _blockedRemotes[remote] then return end

    local remotePath = ""
    local ok1, path = pcall(function() return Serializer.getInstancePath(remote) end)
    if ok1 then remotePath = path else remotePath = tostring(remote) end

    local serializedArgs = {}
    local ok2, sArgs = pcall(function() return Serializer.serializeArgs(args or {}) end)
    if ok2 then serializedArgs = sArgs end

    local event = {
        id             = generateCallId(),
        type           = "incoming",
        method         = "OnClientEvent",
        remote         = remote,
        remoteName     = (pcall(function() return remote.Name end)) and remote.Name or "???",
        remotePath     = remotePath,
        remoteType     = "RemoteEvent",
        args           = args or {},
        serializedArgs = serializedArgs,
        r2s            = "-- Incoming event (server → client)",
        callingScript  = nil,
        timestamp      = os.clock(),
        blocked        = false,
    }

    publish(event)
end

-- ── CAPTURE QUEUE ────────────────────────────────────────────────
-- The hooks run inside the GAME's thread (low identity): creating GUI
-- in gethui()/CoreGui or serializing there fails silently. So hooks only
-- push a raw capture; the drain loop below (connected from OUR executor
-- thread) does serialization, session recording and GUI updates.

local function enqueue(kind, remote, method, args, callingScript)
    if _paused then return end
    if #_queue > 2000 then return end -- safety cap
    _queue[#_queue + 1] = {
        kind = kind, remote = remote, method = method,
        args = args, callingScript = callingScript,
    }
end

local function drainQueue()
    if #_queue == 0 then return end
    local batch = _queue
    _queue = {}
    for i = 1, #batch do
        local c = batch[i]
        local ok, err
        if c.kind == "incoming" then
            ok, err = pcall(processIncoming, c.remote, c.args)
        else
            ok, err = pcall(processCall, c.remote, c.method, c.args, c.callingScript)
        end
        if not ok then
            local key = tostring(err)
            if not _errorShown[key] then
                _errorShown[key] = true
                warn("[RobloxSpy] process error: " .. key)
            end
        end
    end
end

local function startDrain()
    if _drainConn then return end
    _drainConn = game:GetService("RunService").Heartbeat:Connect(drainQueue)
end

-- ── STRATEGY 1: __namecall HOOK ──────────────────────────────────
local function installNamecallHook()
    -- Resolve globals directly — more reliable than wrappers in hook context
    local hookmetamethod   = Compat.getGlobal("hookmetamethod")
    local getnamecallmethod = Compat.getGlobal("getnamecallmethod")
    local newcclosure       = Compat.getGlobal("newcclosure")

    if not hookmetamethod or not getnamecallmethod then
        return false
    end

    -- Build the hook function
    local setnamecallmethod = Compat.getGlobal("setnamecallmethod")

    -- CRITICAL RULE: nothing inside this hook may use a ":" method call
    -- (obj:IsA(), obj:GetFullName()...) before the original is called.
    -- A ":" call goes through __namecall again and OVERWRITES the current
    -- namecall method, so the game's FireServer/InvokeServer would silently
    -- become IsA() and never reach the server (lobbies, shops... break).
    -- Only property reads (obj.ClassName) and plain functions are used here.
    local function namecallHook(self, ...)
        local method = getnamecallmethod()

        if not _processing and FIRE_METHODS[method] and typeof(self) == "Instance" then
            local cls = nil
            pcall(function() cls = self.ClassName end) -- __index, not __namecall
            if REMOTE_CLASSES[cls] then
                _processing = true
                local args = table.pack(...)
                pcall(function()
                    local callingScript = nil
                    local fn = Compat.getGlobal("getcallingscript")
                    if fn then
                        local okS, scr = pcall(fn)
                        if okS then callingScript = scr end
                    end
                    enqueue("outgoing", self, getMethodType(method), args, callingScript)
                end)
                _processing = false

                if _dropRemotes[self] then
                    return nil -- call cancelled by the user
                end

                -- Safety net: restore the method in case anything above changed it
                if setnamecallmethod then
                    pcall(setnamecallmethod, method)
                end
            end
        end

        return _originalNamecall(self, ...)
    end

    -- Wrap in newcclosure if available (some executors need it)
    local wrappedHook = namecallHook
    if newcclosure then
        local ok, wrapped = pcall(newcclosure, namecallHook)
        if ok and wrapped then
            wrappedHook = wrapped
        end
    end

    -- Save the original BEFORE hooking: some executors' hookmetamethod
    -- returns nil instead of the old metamethod
    local preOriginal = nil
    pcall(function()
        local mt = Compat.getRawMetatable(game)
        if mt then preOriginal = rawget(mt, "__namecall") end
    end)

    -- _originalNamecall must exist before the first call reaches the hook
    _originalNamecall = preOriginal

    -- Install the hook
    local ok, original = pcall(hookmetamethod, game, "__namecall", wrappedHook)
    if not ok then
        warn("[RobloxSpy] hookmetamethod failed: " .. tostring(original))
        return false
    end

    _originalNamecall = original or preOriginal
    if not _originalNamecall then
        warn("[RobloxSpy] hookmetamethod returned no original __namecall")
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

    if not hookfunction then
        return false
    end

    -- We need temporary instances to get method references
    local tempRE = Instance.new("RemoteEvent")
    local tempRF = Instance.new("RemoteFunction")

    local function hookRemoteMethod(instance, methodName)
        local origMethod = nil
        local ok = pcall(function()
            origMethod = instance[methodName]
        end)
        if not ok or not origMethod then return end

        local original = origMethod -- replaced by the real original below

        local function hookFn(self, ...)
            if not _processing and isRemoteInstance(self) then
                _processing = true
                local args = table.pack(...)
                pcall(function()
                    local callingScript = nil
                    local fn = Compat.getGlobal("getcallingscript")
                    if fn then
                        local okS, scr = pcall(fn)
                        if okS then callingScript = scr end
                    end
                    enqueue("outgoing", self, getMethodType(methodName), args, callingScript)
                end)
                _processing = false

                if _dropRemotes[self] then
                    return nil -- call cancelled by the user
                end
            end

            -- Call the ORIGINAL (returned by hookfunction), never origMethod:
            -- origMethod is now the hooked function → infinite recursion.
            return original(self, ...)
        end

        local wrappedHook = hookFn
        if newcclosure then
            local ok2, wrapped = pcall(newcclosure, hookFn)
            if ok2 and wrapped then wrappedHook = wrapped end
        end

        -- Keep a clean copy first: some executors' hookfunction returns nil
        pcall(function()
            local clone = Compat.getGlobal("clonefunction") or Compat.getGlobal("clonefunc")
            if clone then original = clone(origMethod) end
        end)

        local ok3, orig = pcall(hookfunction, origMethod, wrappedHook)
        if ok3 and (orig or original ~= origMethod) then
            original = orig or original
            original = orig
            table.insert(_hookedFunctions, { original = original, method = methodName })
        end
    end

    hookRemoteMethod(tempRE, "FireServer")
    hookRemoteMethod(tempRF, "InvokeServer")

    pcall(function() tempRE:Destroy() end)
    pcall(function() tempRF:Destroy() end)

    if #_hookedFunctions > 0 then
        _strategy = "hookfunc"
        print("[RobloxSpy] ✓ hookfunction hooks installed (" .. #_hookedFunctions .. " methods)")
        return true
    end

    return false
end

-- ── INCOMING EVENT SCANNER ───────────────────────────────────────
-- IMPORTANT: when nothing listens to a RemoteEvent yet, Roblox queues the
-- server's messages and hands them to the FIRST OnClientEvent connection.
-- If the spy connects before the game, it steals those messages and the
-- game breaks (e.g. joining a lobby never completes). So we only listen to
-- a remote once the game itself is already listening to it.

local _candidates   = {}   -- [remote] = firstSeenClock
local _logIncoming  = true
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
    -- No getconnections: wait long enough that the game has had time to connect
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
        local conn = remote.OnClientEvent:Connect(function(...)
            enqueue("incoming", remote, "OnClientEvent", {...})
        end)
        table.insert(_incomingConns, conn)
    end)
end

local function addCandidate(obj)
    local ok, isRE = pcall(function()
        return obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent"
    end)
    if ok and isRE and not _scannedRemotes[obj] and not _candidates[obj] then
        _candidates[obj] = os.clock()
    end
end

local function scanForRemotes(container)
    local ok, descendants = pcall(function() return container:GetDescendants() end)
    if not ok then return end
    for _, obj in ipairs(descendants) do
        addCandidate(obj)
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
        scanForRemotes(c)
        pcall(function()
            local conn = c.DescendantAdded:Connect(addCandidate)
            table.insert(_incomingConns, conn)
        end)
    end

    -- Re-check candidates regularly (cheap: only remotes not yet listened)
    if not _scanThread then
        _scanThread = task.spawn(function()
            while _started or #_incomingConns > 0 do
                for remote in pairs(_candidates) do
                    pcall(tryListen, remote)
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

function Hooks.start()
    if _started then return true end

    print("[RobloxSpy] Installing hooks...")
    print("[RobloxSpy] " .. Compat.report())

    -- Drain loop runs in OUR thread (connected here, from the executor)
    startDrain()

    -- Try namecall first, then hookfunction fallback
    local success = installNamecallHook()
    if not success then
        warn("[RobloxSpy] __namecall hook unavailable, trying hookfunction...")
        success = installFunctionHooks()
    end

    if not success then
        -- Incoming events don't need hooks: keep logging them anyway
        pcall(startIncomingScanner)
        _started = true
        warn("[RobloxSpy] ⚠ No hooking method available — outgoing calls will NOT be captured (incoming only)")
        warn("[RobloxSpy] Required: hookmetamethod + getnamecallmethod, OR hookfunction")
        return false
    end

    -- Start scanning for incoming events
    pcall(startIncomingScanner)

    _started = true
    print("[RobloxSpy] ✓ Hooks active (strategy: " .. _strategy .. ")")
    return true
end

function Hooks.stop()
    _started = false
    _strategy = "none"

    -- Disconnect incoming event listeners
    for _, conn in ipairs(_incomingConns) do
        pcall(function() conn:Disconnect() end)
    end
    _incomingConns = {}
    _scannedRemotes = {}
    _candidates = {}
    _queue = {}
    if _drainConn then pcall(function() _drainConn:Disconnect() end); _drainConn = nil end

    -- Note: we can't easily unhook __namecall or hookfunction
    -- Setting _started = false + _paused = true effectively stops processing
    _paused = true
end

function Hooks.pause()
    _paused = true
end

function Hooks.resume()
    _paused = false
end

function Hooks.isPaused()
    return _paused
end

function Hooks.isActive()
    return _started
end

function Hooks.getStrategy()
    return _strategy
end

function Hooks.getQueueSize()
    return #_queue
end

function Hooks.getCallCount()
    return _callId
end

function Hooks.blockRemote(remote)
    if typeof(remote) == "Instance" then
        _blockedRemotes[remote] = true
    end
end

function Hooks.unblockRemote(remote)
    if typeof(remote) == "Instance" then
        _blockedRemotes[remote] = nil
    end
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

function Hooks.setLogIncoming(enabled)
    _logIncoming = enabled and true or false
end
function Hooks.getLogIncoming()
    return _logIncoming
end

function Hooks.setTypeFilter(filterType)
    _typeFilter = filterType
end

function Hooks.getTypeFilter()
    return _typeFilter
end

return Hooks
