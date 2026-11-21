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

return Icons
