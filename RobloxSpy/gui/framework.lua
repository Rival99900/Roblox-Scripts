--[[
    RobloxSpy — gui/framework.lua
    Custom GUI Framework (zero dependencies)

    Lightweight ScreenGui-based UI system.
    PC + Mobile responsive. Draggable windows.
    Component-driven architecture.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local I18n = require(script.Parent.Parent.core.i18n)
local Config = require(script.Parent.Parent.core.config)
local Theme = require(script.Parent.theme)
local Icons = require(script.Parent.icons)
local T = I18n.T

local Framework = {}
Framework.__index = Framework

-- ── DETECTION ────────────────────────────────────────────────────
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ── CONSTANTS ────────────────────────────────────────────────────
local TWEEN_SPEED = 0.2
local TWEEN_EASE = Enum.EasingStyle.Quad
local CORNER_RADIUS = UDim.new(0, 8)
local SHADOW_SIZE = 4
local MIN_WINDOW_SIZE = Vector2.new(340, 240)
local MOBILE_PADDING = 8

-- ── CORE SCREENGUI ──────────────────────────────────────────────

local _screenGui = nil
local _zIndex = 10

local function getScreenGui()
    if _screenGui and _screenGui.Parent then return _screenGui end

    local player = Players.LocalPlayer
    if not player then return nil end

    _screenGui = Instance.new("ScreenGui")
    _screenGui.Name = "RobloxSpyGUI"
    _screenGui.ResetOnSpawn = false
    _screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _screenGui.IgnoreGuiInset = true
    _screenGui.DisplayOrder = 999

    -- Try gethui/syn protect, fall back to PlayerGui
    local parent
    pcall(function()
        if gethui then parent = gethui() end
    end)
    pcall(function()
        if not parent and syn and syn.protect_gui then
            syn.protect_gui(_screenGui)
            parent = player:FindFirstChild("PlayerGui")
        end
    end)
    if not parent then
        parent = player:FindFirstChild("PlayerGui")
    end
    if parent then
        _screenGui.Parent = parent
    end

    return _screenGui
end

-- ── UTILITY ─────────────────────────────────────────────────────

local function nextZ()
    _zIndex = _zIndex + 1
    return _zIndex
end

local function tween(obj, props, duration, style, dir)
    duration = duration or TWEEN_SPEED
    style = style or TWEEN_EASE
    dir = dir or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(duration, style, dir), props)
end

local function applyCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or CORNER_RADIUS
    c.Parent = obj
    return c
end

local function applyStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function applyShadow(obj, size)
    -- Fake shadow via offset dark frame behind
    size = size or SHADOW_SIZE
    local shadow = Instance.new("Frame")
    shadow.Name = "_Shadow"
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    shadow.Position = UDim2.new(0, size, 0, size)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.ZIndex = obj.ZIndex - 1
    shadow.Parent = obj.Parent
    applyCorner(shadow, CORNER_RADIUS)
    return shadow
end

local function applyPadding(obj, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 8)
    p.PaddingRight = UDim.new(0, right or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft = UDim.new(0, left or 8)
    p.Parent = obj
    return p
end

local function create(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- ── SCREEN CLAMPING ─────────────────────────────────────────────
-- Keeps a GuiObject fully inside the screen (PC + mobile, any resolution).

local function getViewportSize()
    local sg = _screenGui
    if sg and sg.AbsoluteSize.X > 0 then return sg.AbsoluteSize end
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

-- Converts the frame to plain offset positioning (AnchorPoint 0,0)
-- so clamping math is exact whatever its previous anchor/scale was.
local function toOffsetPosition(frame)
    local abs = frame.AbsolutePosition
    local parentAbs = Vector2.new(0, 0)
    pcall(function() parentAbs = frame.Parent.AbsolutePosition end)
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.Position = UDim2.fromOffset(abs.X - parentAbs.X, abs.Y - parentAbs.Y)
end

local function clampToScreen(frame, margin)
    if not frame or not frame.Parent then return end
    margin = margin or 4
    local vp = getViewportSize()
    local size = frame.AbsoluteSize

    -- If bigger than the screen, shrink it first
    local maxW, maxH = vp.X - margin * 2, vp.Y - margin * 2
    if size.X > maxW or size.Y > maxH then
        frame.Size = UDim2.fromOffset(math.min(size.X, maxW), math.min(size.Y, maxH))
        size = Vector2.new(math.min(size.X, maxW), math.min(size.Y, maxH))
    end

    toOffsetPosition(frame)
    local pos = frame.Position
    local x = math.clamp(pos.X.Offset, margin, math.max(margin, vp.X - size.X - margin))
    local y = math.clamp(pos.Y.Offset, margin, math.max(margin, vp.Y - size.Y - margin))
    frame.Position = UDim2.fromOffset(x, y)
end

-- Stores a connection in an owner list so it can be disconnected later
-- (v1.1.0: global connections used to leak on every UI rebuild)
local function own(conns, conn)
    if conns and conn then table.insert(conns, conn) end
    return conn
end

-- Re-clamp automatically when the screen rotates / resizes
local function keepOnScreen(frame, margin, conns)
    local function reclamp()
        task.defer(function() pcall(clampToScreen, frame, margin) end)
    end
    pcall(function()
        own(conns, getScreenGui():GetPropertyChangedSignal("AbsoluteSize"):Connect(reclamp))
    end)
    own(conns, frame:GetPropertyChangedSignal("Visible"):Connect(reclamp))
    reclamp()
end

-- ── DRAGGING ────────────────────────────────────────────────────
-- • Active = true on the handle + frame: the drag is SUNK by the GUI,
--   so the camera / character / game never receive it.
-- • Only the input that started the drag moves the frame (a second
--   finger on the joystick on mobile can't hijack it).
-- • Position is clamped so the frame never leaves the screen.
-- Returns a function wasDragged() → true if the last press moved > 6px
-- (lets buttons ignore the click that ends a drag).

local function makeDraggable(frame, handle, margin, conns)
    handle = handle or frame
    pcall(function() handle.Active = true end)
    pcall(function() frame.Active = true end)

    local dragging = false
    local dragInput = nil
    local dragStart, startPos
    local moved = false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragInput = input
            dragStart = input.Position
            toOffsetPosition(frame)
            startPos = frame.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                    pcall(function() conn:Disconnect() end)
                end
            end)
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInput = nil
        end
    end)

    own(conns, UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local isOurTouch = input.UserInputType == Enum.UserInputType.Touch and input == dragInput
        if not (isMouse or isOurTouch) then return end

        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then moved = true end

        local vp = getViewportSize()
        local size = frame.AbsoluteSize
        local m = margin or 4
        local x = math.clamp(startPos.X.Offset + delta.X, m, math.max(m, vp.X - size.X - m))
        local y = math.clamp(startPos.Y.Offset + delta.Y, m, math.max(m, vp.Y - size.Y - m))
        frame.Position = UDim2.fromOffset(x, y)
    end))

    return function() return moved end
end

-- ── RESIZING ────────────────────────────────────────────────────

local function makeResizable(frame, minSize, conns)
    minSize = minSize or MIN_WINDOW_SIZE

    local handle = create("Frame", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Active = true, -- sink input: resizing must not move the camera
        ZIndex = 50,
        Parent = frame,
    })

    -- Visual grip: three diagonal dots (drawn, no glyph)
    for i = 0, 2 do
        create("Frame", {
            Size = UDim2.new(0, 3, 0, 3),
            Position = UDim2.new(1, -6 - i * 5, 1, -6),
            BackgroundColor3 = Color3.fromRGB(100, 100, 110),
            BorderSizePixel = 0,
            Parent = handle,
        })
        if i > 0 then
            create("Frame", {
                Size = UDim2.new(0, 3, 0, 3),
                Position = UDim2.new(1, -6, 1, -6 - i * 5),
                BackgroundColor3 = Color3.fromRGB(100, 100, 110),
                BorderSizePixel = 0,
                Parent = handle,
            })
        end
    end

    local resizing = false
    local resizeStart, startSize

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            toOffsetPosition(frame)
            startSize = frame.AbsoluteSize
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    own(conns, UserInputService.InputChanged:Connect(function(input)
        if not resizing then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - resizeStart
            local vp = getViewportSize()
            local pos = frame.AbsolutePosition
            -- never grow past the screen edge
            local maxW = math.max(minSize.X, vp.X - pos.X - 4)
            local maxH = math.max(minSize.Y, vp.Y - pos.Y - 4)
            local newW = math.clamp(startSize.X + delta.X, minSize.X, maxW)
            local newH = math.clamp(startSize.Y + delta.Y, minSize.Y, maxH)
            frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end))
end

-- ── WINDOW CLASS ────────────────────────────────────────────────

local Window = {}
Window.__index = Window

function Framework.createWindow(config)
    config = config or {}
    local title = config.Title or "RobloxSpy"
    local size = config.Size or (IS_MOBILE
        and UDim2.new(0.9, 0, 0.62, 0)
        or UDim2.new(0, 520, 0, 360))
    -- Centered via AnchorPoint so any size stays on screen
    local position = config.Position or UDim2.new(0.5, 0, 0.5, 0)

    local screenGui = getScreenGui()
    if not screenGui then return nil end

    local self = setmetatable({}, Window)
    self._tabs = {}
    self._activeTab = nil
    self._visible = true
    self._minimized = false
    self._connections = {}

    -- Main container
    self.Frame = create("Frame", {
        Name = "SpyWindow",
        Active = true, -- clicks/drags on the window never reach the game
        Size = size,
        Position = position,
        AnchorPoint = config.Position and Vector2.new(0, 0) or Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    applyCorner(self.Frame)
    applyStroke(self.Frame, Color3.fromRGB(55, 55, 65), 1)

    -- Title bar
    self.TitleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
        Parent = self.Frame,
    })
    applyCorner(self.TitleBar, UDim.new(0, 8))
    -- Bottom corners flat (only top rounded)
    create("Frame", {
        Name = "TitleFlat",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Color3.fromRGB(28, 28, 36),
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    })

    -- Logo + title text
    local logo = Icons.draw("logo", self.TitleBar, 16, Theme.Colors.Accent)
    logo.Position = UDim2.new(0, 10, 0.5, -8)

    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.TitleBar,
    })

    -- Window controls (maximize, minimize, close) — drawn icons
    local btnSize = IS_MOBILE and 30 or 26
    local controlsFrame = create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, btnSize * 3 + 12, 0, btnSize),
        Position = UDim2.new(1, -(btnSize * 3 + 18), 0.5, -btnSize / 2),
        BackgroundTransparency = 1,
        Parent = self.TitleBar,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = controlsFrame,
    })

    local NEUTRAL = Color3.fromRGB(50, 50, 60)
    local NEUTRAL_HOVER = Color3.fromRGB(70, 70, 82)
    local ICON_COLOR = Color3.fromRGB(200, 200, 212)

    local function controlButton(name, iconName, bg, order)
        local b = create("TextButton", {
            Name = name,
            Size = UDim2.new(0, btnSize, 0, btnSize),
            BackgroundColor3 = bg,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = order,
            Parent = controlsFrame,
        })
        applyCorner(b, UDim.new(0, 6))
        local icon = Icons.draw(iconName, b, math.floor(btnSize * 0.5), ICON_COLOR, bg)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        return b, icon
    end

    local maxBtn, maxIcon = controlButton("Maximize", "maximize", NEUTRAL, 1)
    local minBtn = controlButton("Minimize", "minimize", NEUTRAL, 2)
    local closeBtn, closeIcon = controlButton("Close", "close", Color3.fromRGB(180, 50, 50), 3)
    Icons.recolor(closeIcon, Color3.fromRGB(255, 255, 255))
    self.MaxButton = maxBtn
    self._maxIcon = maxIcon
    self._iconColor = ICON_COLOR

    -- Tab bar (scrolls horizontally when tabs don't fit).
    -- Mobile: at the bottom, within thumb reach (can be turned off).
    self._bottomTabs = IS_MOBILE and Config.get("mobileBottomTabs") ~= false
    local TAB_H = IS_MOBILE and 40 or 32
    local STATUS_H = 22
    self._tabHeight = TAB_H

    self.TabBar = create("ScrollingFrame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, TAB_H),
        Position = self._bottomTabs and UDim2.new(0, 0, 1, -(TAB_H + STATUS_H)) or UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        Parent = self.Frame,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabBar,
    })
    applyPadding(self.TabBar, 3, 4, 3, 4)

    -- Content area (between title/tab bar and status bar)
    self.Content = create("Frame", {
        Name = "Content",
        Size = self._bottomTabs and UDim2.new(1, 0, 1, -(36 + TAB_H + STATUS_H))
            or UDim2.new(1, 0, 1, -(36 + TAB_H + STATUS_H)),
        Position = self._bottomTabs and UDim2.new(0, 0, 0, 36) or UDim2.new(0, 0, 0, 36 + TAB_H),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Frame,
    })

    -- Status bar
    self.StatusBar = create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, STATUS_H),
        Position = UDim2.new(0, 0, 1, -STATUS_H),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
        Parent = self.Frame,
    })
    self.StatusLabel = create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = T("status_ready"),
        TextColor3 = Color3.fromRGB(120, 120, 135),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.StatusBar,
    })

    -- Drag & Resize (connections owned by the window → no leak on rebuild)
    makeDraggable(self.Frame, self.TitleBar, nil, self._connections)
    if not IS_MOBILE then
        makeResizable(self.Frame, nil, self._connections)
    end
    keepOnScreen(self.Frame, nil, self._connections)
    own(self._connections, self.Frame:GetPropertyChangedSignal("Size"):Connect(function()
        task.defer(function() pcall(clampToScreen, self.Frame) end)
    end))

    -- Button handlers
    maxBtn.Activated:Connect(function() self:toggleMaximize() end)
    minBtn.Activated:Connect(function() self:toggleMinimize() end)
    closeBtn.Activated:Connect(function() self:hide() end)

    -- Hover effects
    local function hoverBtn(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = hoverColor }, 0.15):Play()
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = normalColor }, 0.15):Play()
        end)
    end
    hoverBtn(minBtn, NEUTRAL, NEUTRAL_HOVER)
    hoverBtn(maxBtn, NEUTRAL, NEUTRAL_HOVER)
    hoverBtn(closeBtn, Color3.fromRGB(180, 50, 50), Color3.fromRGB(220, 60, 60))

    -- Tooltips
    Framework.tooltip(maxBtn, T("tip_maximize"))
    Framework.tooltip(minBtn, T("tip_minimize"))
    Framework.tooltip(closeBtn, T("tip_close"))

    -- Saved transparency
    self:setTransparency(tonumber(Config.get("windowTransparency")) or 0)

    Framework._mainWindow = self

    return self
end

-- ── WINDOW METHODS ──────────────────────────────────────────────

function Window:addTab(name, icon)
    local iconSize = IS_MOBILE and 18 or 13
    local tabBtn = create("TextButton", {
        Name = "Tab_" .. name,
        Size = IS_MOBILE and UDim2.new(0, 46, 1, 0) or UDim2.new(0, 0, 1, 0),
        AutomaticSize = IS_MOBILE and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = #self._tabs + 1,
        Parent = self.TabBar,
    })
    applyCorner(tabBtn, UDim.new(0, 6))

    local inner = create("Frame", {
        Name = "Inner",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = IS_MOBILE and Vector2.new(0.5, 0) or Vector2.new(0, 0),
        Position = IS_MOBILE and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = tabBtn,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = inner,
    })
    if not IS_MOBILE then applyPadding(inner, 0, 9, 0, 9) end

    local iconFrame = nil
    if icon and Icons.has(icon) then
        iconFrame = Icons.draw(icon, inner, iconSize, Color3.fromRGB(140, 140, 155), Color3.fromRGB(30, 30, 38))
        iconFrame.LayoutOrder = 1
    end

    local label = create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.fromRGB(140, 140, 155),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        Visible = not IS_MOBILE, -- mobile: icon only
        LayoutOrder = 2,
        Parent = inner,
    })

    -- Active indicator (accent line)
    local indicator = create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0.6, 0, 0, 2),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = self._bottomTabs and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0.5, 0, 1, -2),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = tabBtn,
    })

    if IS_MOBILE then Framework.tooltip(tabBtn, name) end

    local contentFrame = create("Frame", {
        Name = "TabContent_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Content,
    })

    local tab = {
        name = name,
        button = tabBtn,
        label = label,
        icon = iconFrame,
        indicator = indicator,
        content = contentFrame,
    }
    table.insert(self._tabs, tab)

    tabBtn.Activated:Connect(function()
        self:switchTab(name)
    end)

    if #self._tabs == 1 then
        self:switchTab(name)
    end

    return contentFrame
end

function Window:switchTab(name)
    for _, tab in ipairs(self._tabs) do
        local isActive = (tab.name == name)
        tab.content.Visible = isActive
        local fg = isActive and Color3.fromRGB(225, 225, 240) or Color3.fromRGB(140, 140, 155)
        tab.button.BackgroundTransparency = isActive and 0 or 0.5
        tab.button.BackgroundColor3 = isActive and Color3.fromRGB(42, 42, 54) or Color3.fromRGB(30, 30, 38)
        tab.label.TextColor3 = fg
        tab.indicator.Visible = isActive
        if tab.icon then
            Icons.recolor(tab.icon, isActive and Theme.Colors.Accent or fg)
        end
        if isActive then self._activeTab = tab end
    end
    if self._onTabChanged then pcall(self._onTabChanged, name) end
end

function Window:getActiveTabName()
    return self._activeTab and self._activeTab.name
end

function Window:setStatus(text, color)
    self.StatusLabel.Text = text or ""
    self.StatusLabel.TextColor3 = color or Color3.fromRGB(120, 120, 135)
end

-- 0 = opaque … 0.5 = very transparent (window background only)
function Window:setTransparency(t)
    t = math.clamp(tonumber(t) or 0, 0, 0.6)
    self._bgTransparency = t
    if self._visible then self.Frame.BackgroundTransparency = t end
    self.Content.BackgroundTransparency = t
end

function Window:show()
    self._visible = true
    self.Frame.Visible = true
    tween(self.Frame, { BackgroundTransparency = self._bgTransparency or 0 }, 0.2):Play()
    if self._toggleBtn then self._toggleBtn.Visible = false end
    Framework.setUnread(0)
end

function Window:hide()
    self._visible = false
    local t = tween(self.Frame, { BackgroundTransparency = 1 }, 0.2)
    t:Play()
    t.Completed:Wait()
    if not self._visible then -- re-opened during the fade
        self.Frame.Visible = false
        if self._toggleBtn then self._toggleBtn.Visible = true end
    end
end

function Window:toggle()
    if self._visible then self:hide() else self:show() end
end

function Window:isVisible()
    return self._visible == true
end

function Window:toggleMinimize()
    if self._maximized then self:toggleMaximize(false) end
    self._minimized = not self._minimized
    if self._minimized then
        self._savedSize = self.Frame.Size
        tween(self.Frame, { Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 36) }, 0.2):Play()
        self.Content.Visible = false
        self.TabBar.Visible = false
        self.StatusBar.Visible = false
    else
        self.Content.Visible = true
        self.TabBar.Visible = true
        self.StatusBar.Visible = true
        tween(self.Frame, { Size = self._savedSize }, 0.2):Play()
    end
end

local function setMaxIcon(self, iconName)
    if not self.MaxButton then return end
    if self._maxIcon then self._maxIcon:Destroy() end
    local size = math.floor(self.MaxButton.AbsoluteSize.X * 0.5)
    if size < 8 then size = IS_MOBILE and 15 or 13 end
    local icon = Icons.draw(iconName, self.MaxButton, size, self._iconColor, Color3.fromRGB(50, 50, 60))
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    self._maxIcon = icon
end

-- Fill (almost) the whole screen, or restore the previous size/position.
function Window:toggleMaximize(force)
    local want = (force == nil) and not self._maximized or force
    if want == self._maximized then return end
    if self._minimized then self:toggleMinimize() end

    if want then
        toOffsetPosition(self.Frame)
        self._preMaxSize = self.Frame.Size
        self._preMaxPos = self.Frame.Position
        local vp = getViewportSize()
        local m = IS_MOBILE and 6 or 16
        self._maximized = true
        self.Frame.Position = UDim2.fromOffset(m, m)
        self.Frame.Size = UDim2.fromOffset(vp.X - m * 2, vp.Y - m * 2)
        setMaxIcon(self, "restore")
    else
        self._maximized = false
        if self._preMaxSize then self.Frame.Size = self._preMaxSize end
        if self._preMaxPos then self.Frame.Position = self._preMaxPos end
        setMaxIcon(self, "maximize")
        task.defer(function() pcall(clampToScreen, self.Frame) end)
    end
end

function Window:isMaximized()
    return self._maximized == true
end

function Window:destroy()
    for _, conn in ipairs(self._connections) do
        pcall(function() conn:Disconnect() end)
    end
    self._connections = {}
    if self._toggleBtn then pcall(function() self._toggleBtn:Destroy() end) end
    self._toggleBtn = nil
    if self.Frame then
        self.Frame:Destroy()
    end
    if Framework._mainWindow == self then Framework._mainWindow = nil end
end

-- ── KEYBIND (PC) ────────────────────────────────────────────────
-- Shows / hides the window with a key (default RightShift).
-- Ignored while typing in a TextBox (gameProcessed).

function Framework.bindToggleKey(window, keyName)
    if window._keyConn then
        pcall(function() window._keyConn:Disconnect() end)
        window._keyConn = nil
    end
    local key = nil
    pcall(function() key = Enum.KeyCode[keyName] end)
    if not key then return false end
    window._keyConn = own(window._connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == key then
            task.spawn(function() window:toggle() end)
        end
    end))
    return true
end

-- Waits for the next key press (for the "change keybind" button)
function Framework.captureKey(callback)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            conn:Disconnect()
            if input.KeyCode ~= Enum.KeyCode.Escape then
                pcall(callback, input.KeyCode.Name)
            else
                pcall(callback, nil)
            end
        end
    end)
    return conn
end

-- ── TOGGLE BUTTON (floating, to reopen) ─────────────────────────

local _unread = 0
local _badge, _badgeLabel, _pulseStroke = nil, nil, nil

function Framework.setUnread(n)
    _unread = math.max(0, n or 0)
    if _badge then
        _badge.Visible = _unread > 0
        _badgeLabel.Text = _unread > 99 and "99+" or tostring(_unread)
    end
end

function Framework.bumpUnread()
    local w = Framework._mainWindow
    if w and not w._visible then
        Framework.setUnread(_unread + 1)
    end
end

function Framework.createToggleButton(window)
    local screenGui = getScreenGui()
    if not screenGui then return nil end
    if window._toggleBtn then return window._toggleBtn end

    local size = IS_MOBILE and 50 or 40
    local btn = create("TextButton", {
        Name = "SpyToggle",
        Visible = not window._visible,
        ZIndex = 50,
        Size = UDim2.new(0, size, 0, size),
        Position = IS_MOBILE and UDim2.new(0, 10, 0.4, 0) or UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(24, 24, 32),
        AutoButtonColor = false,
        Text = "",
        Parent = screenGui,
    })
    applyCorner(btn, UDim.new(0.5, 0))
    _pulseStroke = applyStroke(btn, Theme.Colors.Accent, 2)

    local icon = Icons.draw("logo", btn, math.floor(size * 0.5), Theme.Colors.Accent)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.ZIndex = 51

    -- Unread events badge
    _badge = create("Frame", {
        Name = "Badge",
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 4, 0, -4),
        BackgroundColor3 = Color3.fromRGB(220, 60, 70),
        Visible = false,
        ZIndex = 53,
        Parent = btn,
    })
    applyCorner(_badge, UDim.new(0.5, 0))
    applyPadding(_badge, 0, 4, 0, 4)
    _badgeLabel = create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "0",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 54,
        Parent = _badge,
    })
    Framework.setUnread(_unread)

    -- Gentle pulse while there are unread events
    task.spawn(function()
        while btn.Parent do
            if _unread > 0 and btn.Visible then
                tween(_pulseStroke, { Thickness = 4, Transparency = 0.5 }, 0.6):Play()
                task.wait(0.6)
                tween(_pulseStroke, { Thickness = 2, Transparency = 0 }, 0.6):Play()
                task.wait(0.6)
            else
                task.wait(0.5)
            end
        end
    end)

    local wasDragged = makeDraggable(btn, btn, 6, window._connections)
    keepOnScreen(btn, 6, window._connections)
    Framework.tooltip(btn, T("tip_reopen"))

    window._toggleBtn = btn

    btn.Activated:Connect(function()
        if wasDragged and wasDragged() then return end
        window:toggle()
    end)

    return btn
end

-- ── TOOLTIPS ────────────────────────────────────────────────────
-- PC: hover 0.45 s. Mobile: long press 0.5 s (the press then does NOT
-- trigger the button, so a long press never deletes/fires anything).

local _tip = nil

local function showTip(text, anchor)
    local sg = getScreenGui()
    if not sg or not text or text == "" then return end
    if not _tip or not _tip.Parent then
        _tip = create("TextLabel", {
            Name = "Tooltip",
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.XY,
            BackgroundColor3 = Color3.fromRGB(12, 12, 16),
            TextColor3 = Color3.fromRGB(230, 230, 240),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextWrapped = false,
            ZIndex = 300,
            Visible = false,
            Parent = sg,
        })
        applyCorner(_tip, UDim.new(0, 5))
        applyStroke(_tip, Color3.fromRGB(70, 70, 85), 1)
        applyPadding(_tip, 4, 7, 4, 7)
    end
    _tip.Text = text
    local vp = getViewportSize()
    local pos = anchor.AbsolutePosition
    local x = math.clamp(pos.X, 4, math.max(4, vp.X - 260))
    local y = pos.Y + anchor.AbsoluteSize.Y + 6
    if y > vp.Y - 30 then y = pos.Y - 28 end
    _tip.Position = UDim2.fromOffset(x, y)
    _tip.Visible = true
end

local function hideTip()
    if _tip then _tip.Visible = false end
end

function Framework.tooltip(obj, text)
    if not obj or not text then return end
    if IS_MOBILE then
        local pressId = 0
        obj.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            pressId = pressId + 1
            local my = pressId
            task.delay(0.5, function()
                if my ~= pressId then return end
                if input.UserInputState == Enum.UserInputState.End then return end
                showTip(text, obj)
                -- swallow the release so the long press doesn't click
                pcall(function() obj.Interactable = false end)
                task.delay(1.6, hideTip)
            end)
        end)
        obj.InputEnded:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            pressId = pressId + 1
            task.delay(0.05, function() pcall(function() obj.Interactable = true end) end)
        end)
    else
        local hoverId = 0
        obj.MouseEnter:Connect(function()
            hoverId = hoverId + 1
            local my = hoverId
            task.delay(0.45, function()
                if my == hoverId then showTip(text, obj) end
            end)
        end)
        obj.MouseLeave:Connect(function()
            hoverId = hoverId + 1
            hideTip()
        end)
    end
end

-- ── EMPTY STATE ─────────────────────────────────────────────────
-- Centered hint shown when a list is empty (caller toggles .Visible)

function Framework.emptyState(parent, text, iconName)
    local holder = create("Frame", {
        Name = "EmptyState",
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundTransparency = 1,
        LayoutOrder = -1,
        Parent = parent,
    })
    if iconName and Icons.has(iconName) then
        local ic = Icons.draw(iconName, holder, 26, Color3.fromRGB(90, 90, 105), Color3.fromRGB(18, 18, 24))
        ic.AnchorPoint = Vector2.new(0.5, 0)
        ic.Position = UDim2.new(0.5, 0, 0, 14)
    end
    create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 46),
        BackgroundTransparency = 1,
        Text = text,
        TextWrapped = true,
        TextColor3 = Color3.fromRGB(110, 110, 125),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = holder,
    })
    return holder
end

-- ── MODAL ───────────────────────────────────────────────────────
-- Simple dialog over the window content.
-- buttons = { { text, color, callback }, ... }

function Framework.modal(window, title, lines, buttons)
    local parent = window and window.Frame or getScreenGui()
    if not parent then return end

    local overlay = create("TextButton", {
        Name = "Modal",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.35,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100,
        Parent = parent,
    })
    local box = create("Frame", {
        Size = UDim2.new(0.9, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(26, 26, 34),
        ZIndex = 101,
        Parent = overlay,
    })
    create("UISizeConstraint", { MaxSize = Vector2.new(460, 2000), Parent = box })
    applyCorner(box, UDim.new(0, 10))
    applyStroke(box, Theme.Colors.Accent, 1)
    applyPadding(box, 12, 14, 12, 14)
    create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(235, 235, 245),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        ZIndex = 102,
        Parent = box,
    })

    -- Scrollable body so long notes fit on small phones
    local body = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, math.min(260, #lines * 34 + 10)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        ZIndex = 102,
        Parent = box,
    })
    create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })
    for i, line in ipairs(lines) do
        create("TextLabel", {
            Size = UDim2.new(1, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = line,
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(190, 190, 205),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
            ZIndex = 103,
            Parent = body,
        })
    end

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        ZIndex = 102,
        Parent = box,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
        Parent = row,
    })
    local function close() pcall(function() overlay:Destroy() end) end
    for _, b in ipairs(buttons or { { T("ok"), Theme.Colors.Accent } }) do
        local btn = create("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = b[2] or Theme.Colors.Accent,
            Text = b[1],
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            ZIndex = 103,
            Parent = row,
        })
        applyCorner(btn, UDim.new(0, 6))
        applyPadding(btn, 0, 12, 0, 12)
        btn.Activated:Connect(function()
            close()
            if b[3] then pcall(b[3]) end
        end)
    end
    return overlay, close
end

-- ── NOTIFICATIONS (toast) ───────────────────────────────────────
-- kind: "success" | "error" | "warning" | "info"

local _toastY = 0

function Framework.notify(text, kind, duration)
    local screenGui = getScreenGui()
    if not screenGui then
        print("[RobloxSpy] " .. tostring(text))
        return
    end
    local colors = {
        success = Color3.fromRGB(80, 200, 120),
        error   = Color3.fromRGB(220, 70, 70),
        warning = Color3.fromRGB(240, 180, 50),
        info    = Color3.fromRGB(75, 130, 255),
    }
    local icons = { success = "✅", error = "⛔", warning = "⚠️", info = "ℹ️" }
    local color = colors[kind or "info"] or colors.info

    local toast = create("TextLabel", {
        Name = "Toast",
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0.5, 0, 0, 12 + _toastY),
        BackgroundColor3 = Color3.fromRGB(24, 24, 30),
        Text = (icons[kind or "info"] or "") .. "  " .. tostring(text),
        TextColor3 = Color3.fromRGB(230, 230, 240),
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        ZIndex = 200,
        Parent = screenGui,
    })
    applyCorner(toast, UDim.new(0, 8))
    applyStroke(toast, color, 1)
    applyPadding(toast, 4, 12, 4, 12)

    _toastY = _toastY + 36
    task.delay(duration or 2.5, function()
        _toastY = math.max(0, _toastY - 36)
        pcall(function()
            local t = tween(toast, { TextTransparency = 1, BackgroundTransparency = 1 }, 0.25)
            t:Play()
            t.Completed:Wait()
            toast:Destroy()
        end)
    end)
end

-- Copy helper with visible feedback (works on every executor or says why not)
function Framework.copy(text, label)
    local fn
    pcall(function() fn = setclipboard or toclipboard or (Clipboard and Clipboard.set) end)
    if not fn then
        Framework.notify(T("n_no_clip"), "error")
        return false
    end
    local ok, err = pcall(fn, tostring(text or ""))
    if ok then
        Framework.notify(T("n_copied", label or "Text"), "success")
    else
        Framework.notify(T("n_copy_fail", tostring(err)), "error")
    end
    return ok
end

-- ── SCROLLING FRAME HELPER ──────────────────────────────────────

function Framework.createScrollFrame(parent, config)
    config = config or {}
    local scroll = create("ScrollingFrame", {
        Name = config.Name or "Scroll",
        Size = config.Size or UDim2.new(1, 0, 1, 0),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = IS_MOBILE and 8 or 5,
        ScrollBarImageColor3 = Color3.fromRGB(95, 95, 115),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, config.Padding or 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroll,
    })

    if config.InnerPadding then
        applyPadding(scroll, config.InnerPadding, config.InnerPadding, config.InnerPadding, config.InnerPadding)
    end

    return scroll
end

-- ── EXPORT UTILS ────────────────────────────────────────────────

Framework.IS_MOBILE = IS_MOBILE
Framework.create = create
Framework.tween = tween
Framework.applyCorner = applyCorner
Framework.applyStroke = applyStroke
Framework.applyPadding = applyPadding
Framework.makeDraggable = makeDraggable
Framework.clampToScreen = clampToScreen
function Framework.getMainWindow() return Framework._mainWindow end
Framework.keepOnScreen = keepOnScreen
Framework.own = own
Framework.Icons = Icons
Framework.getScreenGui = getScreenGui

return Framework
