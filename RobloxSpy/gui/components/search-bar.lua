--[[
    RobloxSpy — gui/components/search-bar.lua
    Reusable search/filter bar
]]

local Framework = require(script.Parent.Parent.framework)
local Theme = require(script.Parent.Parent.theme)

local create = Framework.create
local applyCorner = Framework.applyCorner

local SearchBar = {}

function SearchBar.new(parent, config)
    config = config or {}

    local bar = create("Frame", {
        Name = config.Name or "SearchBar",
        Size = config.Size or UDim2.new(1, 0, 0, 32),
        Position = config.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        LayoutOrder = config.LayoutOrder or 0,
        Parent = parent,
    })
    applyCorner(bar, Theme.CornerRadius.MD)

    -- Search icon
    create("TextLabel", {
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        TextSize = 12,
        Parent = bar,
    })

    -- Text input
    local input = create("TextBox", {
        Name = "Input",
        Size = UDim2.new(1, -70, 1, -6),
        Position = UDim2.new(0, 30, 0, 3),
        BackgroundTransparency = 1,
        PlaceholderText = config.Placeholder or "Search...",
        PlaceholderColor3 = Theme.Colors.TextMuted,
        Text = "",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Body,
        TextSize = Theme.TextSizes.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = bar,
    })

    -- Clear button
    local clearBtn = create("TextButton", {
        Name = "Clear",
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -32, 0.5, -12),
        BackgroundColor3 = Theme.Colors.BgTertiary,
        Text = "✕",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Body,
        TextSize = 10,
        Visible = false,
        Parent = bar,
    })
    applyCorner(clearBtn, Theme.CornerRadius.SM)

    -- Events
    local onChange = config.OnChange

    input:GetPropertyChangedSignal("Text"):Connect(function()
        local text = input.Text
        clearBtn.Visible = (text ~= "")
        if onChange then
            onChange(text)
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        input.Text = ""
    end)

    return {
        Frame = bar,
        Input = input,
        getText = function() return input.Text end,
        setText = function(_, t) input.Text = t end,
        clear = function() input.Text = "" end,
    }
end

return SearchBar
