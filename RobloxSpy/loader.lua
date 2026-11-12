--[[
    RobloxSpy — Remote Loader
    Downloads the single-file bundle (dist/RobloxSpy-bundle.lua) and runs it.

    Usage:
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/refs/heads/main/RobloxSpy/loader.lua"))()

    Created by Rival960 with the help of Claude
    Version: 1.0.0 | Status: untested in-game
]]

local BRANCH = "refs/heads/main"
local URL = "https://raw.githubusercontent.com/Rival99900/Roblox-Scripts/"
    .. BRANCH .. "/RobloxSpy/dist/RobloxSpy-bundle.lua"

local ok, err = pcall(function()
    local source = game:HttpGet(URL)
    if not source or #source < 100 then
        error("Empty or invalid response from GitHub")
    end
    local fn, compileErr = loadstring(source, "@RobloxSpy-bundle")
    if not fn then
        error("Compile error: " .. tostring(compileErr))
    end
    fn()
end)

if not ok then
    warn("[RobloxSpy] Loader failed: " .. tostring(err))
end
