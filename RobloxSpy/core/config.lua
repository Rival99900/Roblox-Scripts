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
        if DEFAULTS[k] ~= nil or k == "language" then
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

function Config.set(key, value)
    _data[key] = value
    Config.save()
end

Config.load()

return Config
