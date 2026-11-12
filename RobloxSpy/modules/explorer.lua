--[[
    RobloxSpy — modules/explorer.lua
    In-game Instance Explorer (DarkDEX-style)

    • Live game tree (services + nil instances), lazy expand
    • Deep search across the whole game (Enter / debounced)
    • Properties panel with live editing (bool / number / string / Color3 / Vector3)
    • Attributes + CollectionService tags
    • Actions: copy path, copy as code, teleport, view source,
      clone, destroy (client side), refresh
]]

local Framework = require(script.Parent.Parent.gui.framework)
local Theme = require(script.Parent.Parent.gui.theme)
local Serializer = require(script.Parent.Parent.core.serializer)
local Compat = require(script.Parent.Parent.core.compat)
local I18n = require(script.Parent.Parent.core.i18n)

local T = I18n.T
local create = Framework.create
local applyCorner = Framework.applyCorner
local applyPadding = Framework.applyPadding

local Players = game:GetService("Players")

local Explorer = {}

local _treeScroll = nil
local _propsScroll = nil
local _propsHeader = nil
local _selectedInstance = nil
local _expandedNodes = {}  -- [Instance] = true
local _treeRows = {}
local _searchText = ""
local _searchResults = nil -- flat list when a deep search is active
local _rebuildQueued = false
local _onViewSource = nil  -- set by init: function(scriptInstance)

local MAX_ROWS = 1500
local MAX_SEARCH_RESULTS = 300

-- ── CLASS ICONS ─────────────────────────────────────────────────

local CLASS_ICONS = {
    Folder          = "📁",
    Part            = "🟦",
    MeshPart        = "🔷",
    UnionOperation  = "🔶",
    Model           = "📦",
    Script          = "📜",
    LocalScript     = "📄",
    ModuleScript    = "📘",
    RemoteEvent     = "📡",
    RemoteFunction  = "📞",
    UnreliableRemoteEvent = "📶",
    BindableEvent   = "🔔",
    BindableFunction = "🔗",
    ScreenGui       = "🖥",
    Frame           = "⬜",
    ScrollingFrame  = "📜",
    TextLabel       = "🏷",
    TextButton      = "🔘",
    TextBox         = "⌨",
    ImageLabel      = "🖼",
    ImageButton     = "🖲",
    Sound           = "🔊",
    Animation       = "🎬",
    Animator        = "🎞",
    Tool            = "🔧",
    Camera          = "📷",
    Humanoid        = "🧍",
    Player          = "👤",
    SpawnLocation   = "⭐",
    StringValue     = "💬",
    IntValue        = "🔢",
    NumberValue     = "🔢",
    BoolValue       = "✅",
    ObjectValue     = "🔗",
    CFrameValue     = "🧭",
    Vector3Value    = "📐",
    Attachment      = "📌",
    Weld            = "🔩",
    WeldConstraint  = "🔩",
    Motor6D         = "⚙",
    ParticleEmitter = "✨",
    PointLight      = "💡",
    SpotLight       = "🔦",
    Decal           = "🎨",
    Texture         = "🧱",
    ProximityPrompt = "👆",
    ClickDetector   = "🖱",
    Workspace       = "🌍",
    Lighting        = "💡",
    ReplicatedStorage = "📦",
    ReplicatedFirst = "🚀",
    StarterGui      = "🖥",
    StarterPack     = "🎒",
    StarterPlayer   = "🧑",
    Players         = "👥",
    Teams           = "🏁",
    Team            = "🚩",
    SoundService    = "🎵",
    Chat            = "💭",
    TextChatService = "💭",
    CoreGui         = "🛡",
}

local function getIcon(inst)
    if not inst then return "❓" end
    local ok, cls = pcall(function() return inst.ClassName end)
    if not ok then return "❓" end
    return CLASS_ICONS[cls] or "⚪"
end

local function safeName(inst)
    local ok, n = pcall(function() return inst.Name end)
    return ok and tostring(n) or "?"
end

-- Virtual root holding getnilinstances()
local NIL_ROOT = { __virtual = "nil" }

local function getChildrenOf(node)
    if node == NIL_ROOT then
        local list = {}
        pcall(function()
            local fn = Compat.getGlobal("getnilinstances")
            if fn then list = fn() end
        end)
        return list
    end
    local children = {}
    pcall(function() children = node:GetChildren() end)
    return children
end

-- ── BUILD UI ────────────────────────────────────────────────────

local function toolButton(parent, text, color, order)
    local b = create("TextButton", {
        Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = color or Theme.Colors.BgTertiary,
        BackgroundTransparency = 0.4,
        Text = text,
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Tiny,
        LayoutOrder = order or 0,
        Parent = parent,
    })
    applyCorner(b, Theme.CornerRadius.SM)
    applyPadding(b, 2, 6, 2, 6)
    return b
end

function Explorer.setViewSourceHandler(fn)
    _onViewSource = fn
end

function Explorer.buildUI(tabContent)
    _treeRows = {}

    -- Split: left = tree, right = properties
    local leftPanel = create("Frame", {
        Name = "TreePanel",
        Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, -2, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Parent = tabContent,
    })

    local rightPanel = create("Frame", {
        Name = "PropsPanel",
        Size = Framework.IS_MOBILE and UDim2.new(1, 0, 0.5, -2) or UDim2.new(0.5, -2, 1, 0),
        Position = Framework.IS_MOBILE and UDim2.new(0, 0, 0.5, 2) or UDim2.new(0.5, 2, 0, 0),
        BackgroundColor3 = Theme.Colors.BgDark,
        BorderSizePixel = 0,
        Parent = tabContent,
    })

    -- Tree search bar + refresh
    local treeSearch = create("Frame", {
        Name = "TreeSearch",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        Parent = leftPanel,
    })

    local searchInput = create("TextBox", {
        Size = UDim2.new(1, -40, 1, -4),
        Position = UDim2.new(0, 4, 0, 2),
        BackgroundTransparency = 1,
        PlaceholderText = T("ex_search"),
        PlaceholderColor3 = Theme.Colors.TextMuted,
        Text = "",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = treeSearch,
    })

    local refreshBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 22),
        Position = UDim2.new(1, -34, 0, 3),
        BackgroundColor3 = Theme.Colors.BgTertiary,
        Text = "🔄",
        TextSize = 12,
        Parent = treeSearch,
    })
    applyCorner(refreshBtn, Theme.CornerRadius.SM)

    -- Debounced deep search
    local searchToken = 0
    local function runSearch()
        searchToken = searchToken + 1
        local myToken = searchToken
        task.delay(0.35, function()
            if myToken ~= searchToken then return end
            _searchText = searchInput.Text:lower()
            Explorer._doSearch()
            Explorer._rebuildTree()
        end)
    end
    searchInput:GetPropertyChangedSignal("Text"):Connect(runSearch)
    searchInput.FocusLost:Connect(function(enter) if enter then runSearch() end end)

    refreshBtn.Activated:Connect(function()
        Explorer._doSearch()
        Explorer._rebuildTree()
        if _selectedInstance then Explorer._showProperties(_selectedInstance) end
    end)

    -- Tree scroll
    _treeScroll = Framework.createScrollFrame(leftPanel, {
        Name = "TreeScroll",
        Size = UDim2.new(1, 0, 1, -28),
        Position = UDim2.new(0, 0, 0, 28),
        Padding = 1,
    })

    -- Props header (breadcrumb)
    _propsHeader = create("TextLabel", {
        Name = "PropsHeader",
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        Text = "  " .. T("ex_props"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = rightPanel,
    })

    -- Props scroll
    _propsScroll = Framework.createScrollFrame(rightPanel, {
        Name = "PropsScroll",
        Size = UDim2.new(1, 0, 1, -26),
        Position = UDim2.new(0, 0, 0, 26),
        Padding = 2,
        InnerPadding = 3,
    })

    create("TextLabel", {
        Name = "Hint",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = T("ex_select"),
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        Parent = _propsScroll,
    })

    Explorer._rebuildTree()
    if _selectedInstance then
        pcall(Explorer._showProperties, _selectedInstance)
    end
end

-- ── DEEP SEARCH ─────────────────────────────────────────────────

function Explorer._doSearch()
    if _searchText == "" then
        _searchResults = nil
        return
    end
    local results = {}
    local q = _searchText
    local ok, all = pcall(function() return game:GetDescendants() end)
    if ok then
        for i, inst in ipairs(all) do
            local okN, hit = pcall(function()
                return inst.Name:lower():find(q, 1, true) or inst.ClassName:lower():find(q, 1, true)
            end)
            if okN and hit then
                table.insert(results, inst)
                if #results >= MAX_SEARCH_RESULTS then break end
            end
            if i % 4000 == 0 then task.wait() end -- keep the game smooth
        end
    end
    _searchResults = results
end

-- ── TREE RENDERING ──────────────────────────────────────────────

function Explorer._rebuildTree()
    if not _treeScroll then return end

    for _, row in ipairs(_treeRows) do
        if row and row.Parent then row:Destroy() end
    end
    _treeRows = {}

    local order = 0

    -- Search mode: flat result list with full paths
    if _searchResults then
        local info = create("TextLabel", {
            Name = "SearchInfo",
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = T("ex_results", #_searchResults),
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Tiny,
            LayoutOrder = 0,
            Parent = _treeScroll,
        })
        table.insert(_treeRows, info)
        for _, inst in ipairs(_searchResults) do
            order = order + 1
            Explorer._renderRow(inst, 0, order, true)
        end
        return
    end

    local roots = {}
    local serviceNames = {
        "Workspace", "Players", "Lighting", "MaterialService", "ReplicatedFirst",
        "ReplicatedStorage", "ServerScriptService", "ServerStorage",
        "StarterGui", "StarterPack", "StarterPlayer", "Teams",
        "SoundService", "Chat", "TextChatService", "LocalizationService", "TestService",
    }
    for _, name in ipairs(serviceNames) do
        local ok, svc = pcall(function() return game:GetService(name) end)
        if ok and svc then table.insert(roots, svc) end
    end
    if Compat.has("getnilinstances") then
        table.insert(roots, NIL_ROOT)
    end

    for _, root in ipairs(roots) do
        order = Explorer._renderNode(root, 0, order)
        if order >= MAX_ROWS then
            local warnLbl = create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = T("ex_too_many", MAX_ROWS),
                TextColor3 = Theme.Colors.Warning,
                Font = Theme.Fonts.Body,
                TextSize = Theme.TextSizes.Tiny,
                LayoutOrder = order + 1,
                Parent = _treeScroll,
            })
            table.insert(_treeRows, warnLbl)
            break
        end
    end
end

function Explorer._renderRow(inst, depth, order, showPath)
    local isNil = (inst == NIL_ROOT)
    local children = isNil and {1} or getChildrenOf(inst)
    local hasChildren = #children > 0
    local isExpanded = _expandedNodes[inst] == true
    local isSelected = (_selectedInstance == inst)

    local row = create("Frame", {
        Name = "Node_" .. order,
        Size = UDim2.new(1, 0, 0, Framework.IS_MOBILE and 24 or 20),
        BackgroundColor3 = isSelected and Theme.Colors.BgSelected or Theme.Colors.BgDark,
        BackgroundTransparency = isSelected and 0 or 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = _treeScroll,
    })

    local indent = depth * 12

    local arrow = create("TextButton", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(0, indent, 0, 0),
        BackgroundTransparency = 1,
        Text = (hasChildren and not showPath) and (isExpanded and "▼" or "▶") or " ",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = 10,
        Parent = row,
    })

    local text
    if isNil then
        text = "🕳 " .. T("ex_nil")
    else
        text = getIcon(inst) .. " " .. safeName(inst)
        if showPath then
            local okP, full = pcall(function() return inst:GetFullName() end)
            if okP then text = text .. "   ·  " .. full end
        end
    end

    local label = create("TextButton", {
        Size = UDim2.new(1, -(indent + 20), 1, 0),
        Position = UDim2.new(0, indent + 18, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = isSelected and Theme.Colors.TextAccent or Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Small,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    row.MouseEnter:Connect(function()
        if _selectedInstance ~= inst then
            row.BackgroundTransparency = 0
            row.BackgroundColor3 = Theme.Colors.BgHover
        end
    end)
    row.MouseLeave:Connect(function()
        if _selectedInstance ~= inst then
            row.BackgroundTransparency = 1
        end
    end)

    label.Activated:Connect(function()
        if isNil then
            _expandedNodes[inst] = not _expandedNodes[inst]
            Explorer._rebuildTree()
            return
        end
        _selectedInstance = inst
        Explorer._rebuildTree()
        Explorer._showProperties(inst)
    end)

    arrow.Activated:Connect(function()
        if hasChildren and not showPath then
            _expandedNodes[inst] = not _expandedNodes[inst]
            Explorer._rebuildTree()
        end
    end)

    table.insert(_treeRows, row)
    return children, hasChildren, isExpanded
end

function Explorer._renderNode(inst, depth, order)
    if not inst then return order end
    if order >= MAX_ROWS then return order end

    order = order + 1
    local _, hasChildren, isExpanded = Explorer._renderRow(inst, depth, order, false)

    if isExpanded and hasChildren then
        local children = getChildrenOf(inst)
        table.sort(children, function(a, b)
            return safeName(a):lower() < safeName(b):lower()
        end)
        for _, child in ipairs(children) do
            order = Explorer._renderNode(child, depth + 1, order)
            if order >= MAX_ROWS then break end
        end
    end

    return order
end

-- Expands every ancestor so an instance becomes visible in the tree
function Explorer.reveal(inst)
    if typeof(inst) ~= "Instance" then return end
    local cur = inst.Parent
    while cur and cur ~= game do
        _expandedNodes[cur] = true
        cur = cur.Parent
    end
    _selectedInstance = inst
    _searchResults = nil
    Explorer._rebuildTree()
    Explorer._showProperties(inst)
end

-- ── PROPERTIES PANEL ────────────────────────────────────────────

local COMMON_PROPS = {
    "Archivable", "Parent",
    -- BasePart
    "Anchored", "CanCollide", "CanTouch", "CanQuery", "Massless", "Transparency",
    "Size", "Position", "Orientation", "CFrame", "Color", "BrickColor", "Material",
    "Reflectance", "CastShadow", "Locked",
    -- Model
    "PrimaryPart", "WorldPivot",
    -- Values
    "Value",
    -- GUI
    "Text", "TextColor3", "TextSize", "BackgroundColor3", "BackgroundTransparency",
    "Visible", "Enabled", "ZIndex", "AnchorPoint", "Image", "Active",
    -- Humanoid
    "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight", "HipHeight",
    "DisplayName", "RigType", "PlatformStand", "Sit",
    -- Player
    "UserId", "AccountAge", "Team", "TeamColor", "Neutral",
    -- Sound
    "SoundId", "Volume", "Playing", "Looped", "PlaybackSpeed", "TimePosition",
    -- Light / Effects
    "Brightness", "Range", "Shadows", "Rate", "Lifetime",
    -- Lighting
    "ClockTime", "Ambient", "FogEnd", "GlobalShadows",
    -- Prompts / detectors
    "ActionText", "ObjectText", "HoldDuration", "MaxActivationDistance", "KeyboardKeyCode",
    -- Scripts
    "Disabled", "RunContext",
    -- Tools
    "RequiresHandle", "CanBeDropped", "ToolTip",
    -- Camera
    "FieldOfView", "CameraType", "CameraSubject",
}

local EDITABLE = { boolean = true, number = true, string = true, Color3 = true, Vector3 = true }

local function formatValue(val)
    local t = typeof(val)
    if t == "Instance" then
        local ok, full = pcall(function() return val:GetFullName() end)
        return ok and full or tostring(val)
    elseif t == "Vector3" then
        return string.format("%.2f, %.2f, %.2f", val.X, val.Y, val.Z)
    elseif t == "Color3" then
        return string.format("%d, %d, %d", val.R * 255, val.G * 255, val.B * 255)
    elseif t == "number" then
        if val % 1 == 0 then return tostring(val) end
        return string.format("%.3f", val)
    end
    local s = tostring(val)
    if #s > 120 then s = s:sub(1, 120) .. "…" end
    return s
end

local function parseValue(t, text)
    if t == "number" then return tonumber(text) end
    if t == "string" then return text end
    if t == "Vector3" or t == "Color3" then
        local nums = {}
        for n in tostring(text):gmatch("[-%d%.]+") do table.insert(nums, tonumber(n)) end
        if #nums < 3 then return nil end
        if t == "Vector3" then return Vector3.new(nums[1], nums[2], nums[3]) end
        return Color3.fromRGB(nums[1], nums[2], nums[3])
    end
    return nil
end

local function codePath(inst)
    local ok, path = pcall(Serializer.getInstancePath, inst)
    if ok and path then return path end
    local okF, full = pcall(function() return inst:GetFullName() end)
    return okF and full or "nil"
end

function Explorer._showProperties(inst)
    if not _propsScroll or not inst then return end

    for _, c in ipairs(_propsScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    pcall(function()
        _propsHeader.Text = "  " .. getIcon(inst) .. " " .. inst:GetFullName()
    end)

    local order = 0
    local function nextOrder() order = order + 1; return order end

    local function sectionTitle(text)
        create("TextLabel", {
            Size = UDim2.new(1, -4, 0, 18),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Colors.TextAccent,
            Font = Theme.Fonts.Heading,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = nextOrder(),
            Parent = _propsScroll,
        })
    end

    local function addPropRow(name, value, color, editable, setter)
        local row = create("Frame", {
            Size = UDim2.new(1, -4, 0, 20),
            BackgroundColor3 = (order % 2 == 0) and Theme.Colors.BgSecondary or Theme.Colors.BgDark,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            Parent = _propsScroll,
        })

        create("TextLabel", {
            Size = UDim2.new(0.4, 0, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.Colors.TextSecondary,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })

        local vt = typeof(value)
        if editable and vt == "boolean" then
            local b = create("TextButton", {
                Size = UDim2.new(0, 44, 0, 16),
                Position = UDim2.new(0.4, 4, 0.5, -8),
                BackgroundColor3 = value and Theme.Colors.Success or Theme.Colors.BgTertiary,
                Text = value and "true" or "false",
                TextColor3 = Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                Parent = row,
            })
            applyCorner(b, Theme.CornerRadius.SM)
            b.Activated:Connect(function()
                local newVal = not value
                local ok, err = pcall(setter, newVal)
                if ok then
                    value = newVal
                    b.Text = value and "true" or "false"
                    b.BackgroundColor3 = value and Theme.Colors.Success or Theme.Colors.BgTertiary
                    Framework.notify(T("n_prop_set", name, tostring(value)), "success", 1.5)
                else
                    Framework.notify(T("n_prop_fail", name, tostring(err)), "error")
                end
            end)
        elseif editable and EDITABLE[vt] then
            local box = create("TextBox", {
                Size = UDim2.new(0.58, 0, 1, -2),
                Position = UDim2.new(0.4, 4, 0, 1),
                BackgroundColor3 = Theme.Colors.BgPrimary,
                BackgroundTransparency = 0.4,
                Text = formatValue(value),
                ClearTextOnFocus = false,
                TextColor3 = color or Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
            applyCorner(box, Theme.CornerRadius.SM)
            box.FocusLost:Connect(function(enter)
                if not enter then box.Text = formatValue(value) return end
                local parsed = parseValue(vt, box.Text)
                if parsed == nil then box.Text = formatValue(value) return end
                local ok, err = pcall(setter, parsed)
                if ok then
                    value = parsed
                    Framework.notify(T("n_prop_set", name, formatValue(parsed)), "success", 1.5)
                else
                    Framework.notify(T("n_prop_fail", name, tostring(err)), "error")
                end
                box.Text = formatValue(value)
            end)
        else
            create("TextBox", {
                Size = UDim2.new(0.58, 0, 1, 0),
                Position = UDim2.new(0.4, 4, 0, 0),
                BackgroundTransparency = 1,
                Text = formatValue(value),
                TextEditable = false,
                ClearTextOnFocus = false,
                TextColor3 = color or Theme.Colors.TextPrimary,
                Font = Theme.Fonts.Code,
                TextSize = Theme.TextSizes.Tiny,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
        end
        return row
    end

    -- ── Actions ──
    local actions = create("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(),
        Parent = _propsScroll,
    })
    create("UIGridLayout", {
        CellSize = UDim2.new(0.5, -3, 0, 24),
        CellPadding = UDim2.new(0, 4, 0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actions,
    })

    local bPath  = toolButton(actions, T("ex_copy_path"), Theme.Colors.Accent, 1)
    local bCode  = toolButton(actions, T("ex_copy_code"), Theme.Colors.Accent, 2)
    bPath.AutomaticSize = Enum.AutomaticSize.None
    bCode.AutomaticSize = Enum.AutomaticSize.None

    bPath.Activated:Connect(function()
        local okF, full = pcall(function() return inst:GetFullName() end)
        Framework.copy(okF and full or codePath(inst), T("c_path"))
    end)
    bCode.Activated:Connect(function()
        Framework.copy("local instance = " .. codePath(inst), T("c_code"))
    end)

    local isPart, isModel, isScript = false, false, false
    pcall(function()
        isPart = inst:IsA("BasePart")
        isModel = inst:IsA("Model")
        isScript = inst:IsA("LuaSourceContainer")
    end)

    if isPart or isModel then
        local bTp = toolButton(actions, T("ex_tp"), Theme.Colors.Success, 3)
        bTp.AutomaticSize = Enum.AutomaticSize.None
        bTp.Activated:Connect(function()
            local ok = pcall(function()
                local char = Players.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local cf = isPart and inst.CFrame or inst:GetPivot()
                hrp.CFrame = cf + Vector3.new(0, 4, 0)
            end)
            Framework.notify(ok and T("n_tp_ok", safeName(inst)) or T("n_tp_fail"), ok and "success" or "error")
        end)
    end

    if isScript then
        local bSrc = toolButton(actions, T("ex_view_src"), Theme.Colors.Info, 4)
        bSrc.AutomaticSize = Enum.AutomaticSize.None
        bSrc.Activated:Connect(function()
            if _onViewSource then _onViewSource(inst) end
        end)
    end

    local bClone = toolButton(actions, T("ex_clone"), Theme.Colors.BgTertiary, 5)
    bClone.AutomaticSize = Enum.AutomaticSize.None
    bClone.Activated:Connect(function()
        local ok, err = pcall(function()
            local c = inst:Clone()
            c.Parent = inst.Parent
        end)
        Framework.notify(ok and T("n_cloned", safeName(inst)) or tostring(err), ok and "success" or "error")
        Explorer._rebuildTree()
    end)

    local bDestroy = toolButton(actions, T("ex_destroy"), Theme.Colors.Error, 6)
    bDestroy.AutomaticSize = Enum.AutomaticSize.None
    bDestroy.Activated:Connect(function()
        local name = safeName(inst)
        local ok, err = pcall(function() inst:Destroy() end)
        Framework.notify(ok and T("n_destroyed", name) or tostring(err), ok and "warning" or "error")
        if ok then
            _selectedInstance = nil
            Explorer._rebuildTree()
            for _, c in ipairs(_propsScroll:GetChildren()) do
                if c:IsA("GuiObject") then c:Destroy() end
            end
        end
    end)

    -- ── Identity ──
    sectionTitle("ℹ️  " .. T("ex_props"))
    addPropRow("ClassName", inst.ClassName, Theme.Colors.TextAccent)
    addPropRow("Name", inst.Name, nil, true, function(v) inst.Name = v end)
    pcall(function() addPropRow("FullName", inst:GetFullName()) end)

    for _, propName in ipairs(COMMON_PROPS) do
        local ok2, val = pcall(function() return inst[propName] end)
        if ok2 and val ~= nil and typeof(val) ~= "RBXScriptSignal" and typeof(val) ~= "function" then
            addPropRow(propName, val, nil, propName ~= "Parent", function(v) inst[propName] = v end)
        end
    end

    pcall(function() addPropRow(T("ex_children"), #inst:GetChildren()) end)
    pcall(function() addPropRow(T("ex_desc"), #inst:GetDescendants()) end)

    -- ── Attributes ──
    local okA, attrs = pcall(function() return inst:GetAttributes() end)
    if okA and attrs and next(attrs) then
        sectionTitle(T("ex_attrs"))
        local names = {}
        for k in pairs(attrs) do table.insert(names, k) end
        table.sort(names)
        for _, k in ipairs(names) do
            addPropRow("@" .. k, attrs[k], Theme.Colors.Warning, true, function(v) inst:SetAttribute(k, v) end)
        end
    end

    -- ── Tags ──
    local okT, tags = pcall(function()
        return game:GetService("CollectionService"):GetTags(inst)
    end)
    if okT and tags and #tags > 0 then
        sectionTitle(T("ex_tags"))
        addPropRow("Tags", table.concat(tags, ", "), Theme.Colors.OnClientEvent)
    end
end

return Explorer
