--[[
    RobloxSpy — core/config.lua
    Persistent user settings (language, auto-save, export folder...)

    Stored in RobloxSpy/config/settings.json when the executor can
    write files; otherwise kept in memory for the current run only.
]]

local Compat = require(script.Parent.compat)

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

return Config
