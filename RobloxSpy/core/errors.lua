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

return Errors
