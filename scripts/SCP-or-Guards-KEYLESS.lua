--[[
    ================================================================
    SCP vs Guards — Universal Script
    Game: https://www.roblox.com/games/98590766682303/SCP-vs-Guards
    UI:   Rayfield
    Features:
      - ESP (Players + Bots, Team-aware)
      - Silent Aim (hooks fireWeapon.FireServer)
      - Infinite Ammo (via getgc)
      - Noclip / Fly (PC & Mobile) / WalkSpeed
      - Full Bright / Reset
    ================================================================
]]

-- ======================= LOAD RAYFIELD =======================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ========================= SERVICES ==========================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- =========================== CONFIG ==========================
local Config = {
    -- ESP
    ESP = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTeamCheck = true,
    -- Aim
    SilentAim = false,
    SilentAimFOV = 200,
    ShowFOV = false,
    -- Ammo
    InfiniteAmmo = false,
    -- Movement
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = 16,
}

-- ======================== TEAM HELPERS =======================
-- The game splits players into a Guard/SCP team and stores bots
-- in Workspace.ScpBots and Workspace.GuardBots (per the logs).
local function getOwnSide()
    if LocalPlayer.Team then
        local n = LocalPlayer.Team.Name:lower()
        if n:find("guard") then return "guard" end
        if n:find("scp")   then return "scp"   end
    end
    return nil
end

local function isSameTeam(model)
    if not Config.ESPTeamCheck then return false end
    local mySide = getOwnSide()
    if not mySide then return false end

    -- Players
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and plr.Team then
        return plr.Team == LocalPlayer.Team
    end

    -- Bots (folder detection, works even if no Team on the model)
    if model.Parent then
        local folder = model.Parent.Name
        if folder == "GuardBots" and mySide == "guard" then return true end
        if folder == "ScpBots"   and mySide == "scp"   then return true end
    end
    return false
end

local function getAllCharacters()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                list[#list + 1] = plr.Character
            end
        end
    end
    for _, folderName in ipairs({ "ScpBots", "GuardBots" }) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        list[#list + 1] = model
                    end
                end
            end
        end
    end
    return list
end

local function getEnemies()
    local out = {}
    for _, char in ipairs(getAllCharacters()) do
        if not isSameTeam(char) then
            out[#out + 1] = char
        end
    end
    return out
end

local function getClosestEnemyToPosition(worldPos)
    local closest, bestDist = nil, math.huge
    for _, char in ipairs(getEnemies()) do
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = (hrp.Position - worldPos).Magnitude
            if d < bestDist then
                closest, bestDist = char, d
            end
        end
    end
    return closest
end

-- ============================= ESP ===========================
local espCache = {}

local function createESP(model)
    if espCache[model] then return end
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Filled    = false
    box.Visible   = false

    local name = Drawing.new("Text")
    name.Size    = 14
    name.Center  = true
    name.Outline = true
    name.Visible = false

    local hp = Drawing.new("Square")
    hp.Thickness = 1
    hp.Filled    = true
    hp.Visible   = false

    local dist = Drawing.new("Text")
    dist.Size    = 12
    dist.Center  = true
    dist.Outline = true
    dist.Visible = false

    espCache[model] = { box = box, name = name, health = hp, distance = dist }
end

local function removeESP(model)
    local data = espCache[model]
    if data then
        for _, d in pairs(data) do d:Remove() end
        espCache[model] = nil
    end
end

local function updateESP()
    for _, char in ipairs(getAllCharacters()) do
        if not espCache[char] then createESP(char) end
        local data = espCache[char]
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")

        local show = Config.ESP and hrp and hum and not isSameTeam(char)
        if not show then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        local top    = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
        local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        if top.Z <= 0 or bottom.Z <= 0 then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        local h = math.abs(bottom.Y - top.Y)
        local w = h * 0.55
        local x = top.X - w / 2
        local y = top.Y

        -- Box (color follows team color when available)
        if Config.ESPBox then
            data.box.Visible  = true
            data.box.Size     = Vector2.new(w, h)
            data.box.Position = Vector2.new(x, y)
            local plr = Players:GetPlayerFromCharacter(char)
            if plr and plr.Team then
                data.box.Color = plr.Team.TeamColor.Color
            else
                data.box.Color = Color3.fromRGB(255, 100, 100)
            end
        else
            data.box.Visible = false
        end

        -- Name
        if Config.ESPName then
            data.name.Visible  = true
            data.name.Text     = char.Name
            data.name.Position = Vector2.new(x + w / 2, y - 16)
        else
            data.name.Visible = false
        end

        -- Health bar
        if Config.ESPHealth then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            data.health.Visible  = true
            data.health.Size     = Vector2.new(2, h * ratio)
            data.health.Position = Vector2.new(x - 5, y + (h - h * ratio))
            data.health.Color    = Color3.fromRGB(255 * (1 - ratio), 255 * ratio, 0)
        else
            data.health.Visible = false
        end

        -- Distance
        if Config.ESPDistance then
            local d = (Camera.CFrame.Position - hrp.Position).Magnitude
            data.distance.Visible  = true
            data.distance.Text     = string.format("[%d]", math.floor(d))
            data.distance.Position = Vector2.new(x + w / 2, y + h + 2)
        else
            data.distance.Visible = false
        end
    end

    -- Cleanup dead references (collect first, then remove)
    local dead = {}
    for model in pairs(espCache) do
        if not model.Parent then dead[#dead + 1] = model end
    end
    for _, model in ipairs(dead) do removeESP(model) end
end

-- ========================= FOV CIRCLE ========================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.NumSides  = 60
fovCircle.Filled    = false
fovCircle.Color     = Color3.fromRGB(255, 255, 255)
fovCircle.Visible   = false

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = Config.ShowFOV and Config.SilentAim
    fovCircle.Radius  = Config.SilentAimFOV
    if fovCircle.Visible then
        local m = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(m.X, m.Y)
    end
end)

-- ========================= SILENT AIM ========================
-- The client fires `fireWeapon` on GlobalWeaponEvents with:
--     (Vector3 hitPosition, emptyTable)
-- The server then broadcasts `weaponFired` with start/end positions,
-- which confirms the server does a raycast from the shooter to that
-- position. So by rewriting `args[1]` toward an enemy head, we get a
-- clean silent aim (no camera snapping, no client-side red flags).
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()

    if method == "FireServer"
       and Config.SilentAim
       and type(self) == "userdata"
       and self.Name == "fireWeapon" then

        local args = { ... }
        if typeof(args[1]) == "Vector3" then
            local target = getClosestEnemyToPosition(args[1])
            if target then
                local aim = target:FindFirstChild("Head")
                         or target:FindFirstChild("HumanoidRootPart")
                if aim then
                    args[1] = aim.Position
                end
            end
        end
        return oldNamecall(self, table.unpack(args))
    end

    return oldNamecall(self, ...)
end)

-- ==================== INFINITE AMMO (getgc) ===================
-- Ammo is not in the fireWeapon args -> it's stored client-side.
-- We scan the garbage collector for tables containing typical ammo
-- keys and force them to a huge value. This covers most Roblox
-- weapon frameworks that keep a local stats table.
local ammoCache = nil

local function applyInfiniteAmmo()
    if not getgc then return end
    if not ammoCache then
        ammoCache = getgc({ "MagAmmo", "Ammo", "CurrentAmmo", "Clip", "MaxAmmo" })
    end
    if applygc then
        applygc(ammoCache, {
            MagAmmo = 9999,
            Ammo = 9999,
            CurrentAmmo = 9999,
            Clip = 9999,
            MaxAmmo = 9999,
        })
    end
end

-- Re-scan on respawn / weapon change because tables get rebuilt.
LocalPlayer.CharacterAdded:Connect(function()
    ammoCache = nil
    task.wait(1.5)
    if Config.InfiniteAmmo then applyInfiniteAmmo() end
end)

RunService.Heartbeat:Connect(function()
    if Config.InfiniteAmmo then
        applyInfiniteAmmo()
    end
end)

-- ============================ NOCLIP =========================
RunService.Stepped:Connect(function()
    if not Config.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- ============================= FLY ===========================
local flyBV, flyBG, flyConn

local function stopFly()
    if flyBV   then flyBV:Destroy()      flyBV   = nil end
    if flyBG   then flyBG:Destroy()      flyBG   = nil end
    if flyConn then flyConn:Disconnect() flyConn = nil end
end

local function startFly()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent   = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P          = 1e4
    flyBG.Parent    = hrp

    flyConn = RunService.Heartbeat:Connect(function()
        if not Config.Fly or not flyBV or not flyBV.Parent then return end
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir * Config.FlySpeed
        flyBG.CFrame   = cam
    end)
end

-- ========================== RAYFIELD UI ======================
local Window = Rayfield:CreateWindow({
    Name            = "SCP vs Guards",
    LoadingTitle    = "SCP vs Guards",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "ScpVsGuards",
        FileName   = "config",
    },
    KeySystem = false,
})

-- --- Visuals ---
local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({ Name = "ESP",            CurrentValue = false, Flag = "ESP",          Callback = function(v) Config.ESP = v end })
VisualTab:CreateToggle({ Name = "ESP Team Check", CurrentValue = true,  Flag = "ESPTeamCheck", Callback = function(v) Config.ESPTeamCheck = v end })
VisualTab:CreateToggle({ Name = "ESP Box",        CurrentValue = true,  Flag = "ESPBox",       Callback = function(v) Config.ESPBox = v end })
VisualTab:CreateToggle({ Name = "ESP Name",       CurrentValue = true,  Flag = "ESPName",      Callback = function(v) Config.ESPName = v end })
VisualTab:CreateToggle({ Name = "ESP Health",     CurrentValue = true,  Flag = "ESPHealth",    Callback = function(v) Config.ESPHealth = v end })
VisualTab:CreateToggle({ Name = "ESP Distance",   CurrentValue = true,  Flag = "ESPDistance",  Callback = function(v) Config.ESPDistance = v end })

-- --- Combat ---
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({
    Name = "Silent Aim", CurrentValue = false, Flag = "SilentAim",
    Callback = function(v) Config.SilentAim = v end
})
CombatTab:CreateSlider({
    Name = "FOV", Range = {10, 800}, Increment = 10, Suffix = "px",
    CurrentValue = 200, Flag = "FOV",
    Callback = function(v) Config.SilentAimFOV = v end
})
CombatTab:CreateToggle({
    Name = "Show FOV", CurrentValue = false, Flag = "ShowFOV",
    Callback = function(v) Config.ShowFOV = v end
})
CombatTab:CreateToggle({
    Name = "Infinite Ammo", CurrentValue = false, Flag = "InfiniteAmmo",
    Callback = function(v)
        Config.InfiniteAmmo = v
        if v then
            ammoCache = nil
            applyInfiniteAmmo()
        end
    end
})

-- --- Movement ---
local MoveTab = Window:CreateTab("Movement", 4483362458)
MoveTab:CreateToggle({
    Name = "Noclip", CurrentValue = false, Flag = "Noclip",
    Callback = function(v) Config.Noclip = v end
})
MoveTab:CreateToggle({
    Name = "Fly", CurrentValue = false, Flag = "Fly",
    Callback = function(v)
        Config.Fly = v
        if v then startFly() else stopFly() end
    end
})
MoveTab:CreateSlider({
    Name = "Fly Speed", Range = {10, 300}, Increment = 5, Suffix = "studs/s",
    CurrentValue = 50, Flag = "FlySpeed",
    Callback = function(v) Config.FlySpeed = v end
})
MoveTab:CreateSlider({
    Name = "WalkSpeed", Range = {16, 500}, Increment = 1, Suffix = "studs/s",
    CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(v)
        Config.WalkSpeed = v
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

-- --- Misc ---
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateToggle({
    Name = "Full Bright", CurrentValue = false, Flag = "FullBright",
    Callback = function(v)
        if v then
            Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness     = 3
            Lighting.FogEnd         = 1e9
            Lighting.GlobalShadows  = false
        else
            Lighting.Ambient        = Color3.fromRGB(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Brightness     = 2
        end
    end
})
MiscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
    end
})
MiscTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Rayfield:Destroy()
        for model in pairs(espCache) do removeESP(model) end
        fovCircle:Remove()
        stopFly()
    end
})

-- Kick the ESP updater
RunService.RenderStepped:Connect(updateESP)

Rayfield:Notify({
    Title    = "SCP vs Guards",
    Content  = "Loaded — join a round to test",
    Duration = 5,
    Image    = 4483362458,
})
