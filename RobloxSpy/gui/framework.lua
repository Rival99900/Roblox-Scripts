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

-- Re-clamp automatically when the screen rotates / resizes
local function keepOnScreen(frame, margin)
    local function reclamp()
        task.defer(function() pcall(clampToScreen, frame, margin) end)
    end
    pcall(function()
        getScreenGui():GetPropertyChangedSignal("AbsoluteSize"):Connect(reclamp)
    end)
    frame:GetPropertyChangedSignal("Visible"):Connect(reclamp)
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

local function makeDraggable(frame, handle, margin)
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

    UserInputService.InputChanged:Connect(function(input)
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
    end)

    return function() return moved end
end

-- ── RESIZING ────────────────────────────────────────────────────

local function makeResizable(frame, minSize)
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

    -- Visual grip dots
    create("TextLabel", {
        Text = "⋮⋮",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(100, 100, 110),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = handle,
    })

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

    UserInputService.InputChanged:Connect(function(input)
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
    end)
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

    -- Title text
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -124, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    -- Window controls (minimize, close)
    local controlsFrame = create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 102, 0, 28),
        Position = UDim2.new(1, -110, 0, 4),
        BackgroundTransparency = 1,
        Parent = self.TitleBar,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 4),
        Parent = controlsFrame,
    })

    -- Maximize button (fills the screen, click again to restore)
    local maxBtn = create("TextButton", {
        Name = "Maximize",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "⛶",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = controlsFrame,
    })
    applyCorner(maxBtn, UDim.new(0, 6))
    self.MaxButton = maxBtn

    -- Minimize button
    local minBtn = create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = "─",
        TextColor3 = Color3.fromRGB(180, 180, 190),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = controlsFrame,
    })
    applyCorner(minBtn, UDim.new(0, 6))

    -- Close button
    local closeBtn = create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Color3.fromRGB(180, 50, 50),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = controlsFrame,
    })
    applyCorner(closeBtn, UDim.new(0, 6))

    -- Tab bar
    self.TabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
        Parent = self.Frame,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 2),
        Parent = self.TabBar,
    })
    applyPadding(self.TabBar, 0, 4, 0, 4)

    -- Content area
    self.Content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -68),
        Position = UDim2.new(0, 0, 0, 68),
        BackgroundColor3 = Color3.fromRGB(18, 18, 24),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Frame,
    })

    -- Status bar
    self.StatusBar = create("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
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
        Parent = self.StatusBar,
    })

    -- Drag & Resize
    makeDraggable(self.Frame, self.TitleBar)
    if not IS_MOBILE then
        makeResizable(self.Frame)
    end
    keepOnScreen(self.Frame)
    -- Also re-clamp when the window is resized (size presets, minimize…)
    self.Frame:GetPropertyChangedSignal("Size"):Connect(function()
        task.defer(function() pcall(clampToScreen, self.Frame) end)
    end)

    -- Button handlers
    maxBtn.Activated:Connect(function()
        self:toggleMaximize()
    end)
    minBtn.MouseButton1Click:Connect(function()
        self:toggleMinimize()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        self:hide()
    end)

    -- Hover effects
    local function hoverBtn(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = hoverColor }, 0.15):Play()
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = normalColor }, 0.15):Play()
        end)
    end
    hoverBtn(minBtn, Color3.fromRGB(50, 50, 60), Color3.fromRGB(70, 70, 80))
    hoverBtn(maxBtn, Color3.fromRGB(50, 50, 60), Color3.fromRGB(70, 70, 80))

    Framework._mainWindow = self
    hoverBtn(closeBtn, Color3.fromRGB(180, 50, 50), Color3.fromRGB(220, 60, 60))

    return self
end

-- ── WINDOW METHODS ──────────────────────────────────────────────

function Window:addTab(name, icon)
    local tabBtn = create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        BackgroundTransparency = 0.5,
        -- Mobile: icon only (6 tabs must fit on a phone screen)
        Text = IS_MOBILE and (icon or name) or ((icon or "") .. " " .. name),
        TextColor3 = Color3.fromRGB(140, 140, 155),
        Font = Enum.Font.GothamMedium,
        TextSize = IS_MOBILE and 15 or 11,
        Parent = self.TabBar,
    })
    applyCorner(tabBtn, UDim.new(0, 6))
    applyPadding(tabBtn, 3, 8, 3, 8)

    local contentFrame = create("Frame", {
        Name = "TabContent_" .. name,
        Size = UDim2.new(1, 0, 1, -22), -- leave room for status bar
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Content,
    })

    local tab = {
        name = name,
        button = tabBtn,
        content = contentFrame,
    }

    table.insert(self._tabs, tab)

    tabBtn.MouseButton1Click:Connect(function()
        self:switchTab(name)
    end)

    -- First tab becomes active
    if #self._tabs == 1 then
        self:switchTab(name)
    end

    return contentFrame
end

function Window:switchTab(name)
    for _, tab in ipairs(self._tabs) do
        local isActive = (tab.name == name)
        tab.content.Visible = isActive
        if isActive then
            self._activeTab = tab
            tab.button.BackgroundTransparency = 0
            tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            tab.button.TextColor3 = Color3.fromRGB(220, 220, 235)
        else
            tab.button.BackgroundTransparency = 0.5
            tab.button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
            tab.button.TextColor3 = Color3.fromRGB(140, 140, 155)
        end
    end
end

function Window:setStatus(text, color)
    self.StatusLabel.Text = text or ""
    self.StatusLabel.TextColor3 = color or Color3.fromRGB(120, 120, 135)
end

function Window:show()
    self._visible = true
    self.Frame.Visible = true
    tween(self.Frame, { BackgroundTransparency = 0 }, 0.2):Play()
    -- Hide the reopen button while the window is open
    if self._toggleBtn then self._toggleBtn.Visible = false end
end

function Window:hide()
    self._visible = false
    local t = tween(self.Frame, { BackgroundTransparency = 1 }, 0.2)
    t:Play()
    t.Completed:Wait()
    self.Frame.Visible = false
    -- Show the small reopen button
    if self._toggleBtn then self._toggleBtn.Visible = true end
end

function Window:toggleMinimize()
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
        if self.MaxButton then self.MaxButton.Text = "❐" end
    else
        self._maximized = false
        if self._preMaxSize then self.Frame.Size = self._preMaxSize end
        if self._preMaxPos then self.Frame.Position = self._preMaxPos end
        if self.MaxButton then self.MaxButton.Text = "⛶" end
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
    if self.Frame then
        self.Frame:Destroy()
    end
end

-- ── TOGGLE BUTTON (floating, to reopen) ─────────────────────────

function Framework.createToggleButton(window)
    local screenGui = getScreenGui()
    if not screenGui then return nil end

    if window._toggleBtn then return window._toggleBtn end

    local btn = create("TextButton", {
        Name = "SpyToggle",
        Visible = not window._visible, -- only shown once the window is closed
        ZIndex = 50,
        Size = IS_MOBILE and UDim2.new(0, 44, 0, 44) or UDim2.new(0, 36, 0, 36),
        Position = IS_MOBILE
            and UDim2.new(0, 10, 0.4, 0)
            or UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(75, 130, 255),
        Text = "🔍",
        TextSize = IS_MOBILE and 20 or 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = screenGui,
    })
    applyCorner(btn, UDim.new(0.5, 0))
    applyStroke(btn, Color3.fromRGB(100, 150, 255), 1)

    -- Draggable (PC + mobile) so it never blocks the game UI
    local wasDragged = makeDraggable(btn, btn, 6)
    keepOnScreen(btn, 6)

    window._toggleBtn = btn

    btn.Activated:Connect(function()
        if wasDragged and wasDragged() then return end -- end of a drag, not a click
        if window._visible then
            window:hide()
        else
            window:show()
        end
    end)

    return btn
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
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95),
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
Framework.getScreenGui = getScreenGui

return Framework
