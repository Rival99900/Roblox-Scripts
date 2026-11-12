--[[
    RobloxSpy — core/session.lua
    Session manager

    Records all remote activity per game session.
    Persists to disk as JSON files for cross-session search.
    Each session = one game join → leave cycle.
]]

local Compat = require(script.Parent.compat)

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
    elseif event.method:find(":Return") then
        entryType = "return"
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
    if event.caller then
        pcall(function() callerStr = event.caller:GetFullName() end)
    end

    -- Summarize args (lightweight, no full serialize)
    local argsSummary = ""
    pcall(function()
        local argParts = {}
        for i, arg in ipairs(event.args) do
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

return Session
