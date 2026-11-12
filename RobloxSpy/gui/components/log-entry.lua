--[[
    RobloxSpy — gui/components/log-entry.lua
    Single remote call log row for the spy feed

    The whole row is clickable (opens the detail panel).
    Action buttons: 📋 copy R2S · 🔇 ignore remote · 🗑 delete row
    Buttons use .Activated (works with mouse AND touch on every executor).
]]

local Framework = require(script.Parent.Parent.framework)
local Theme = require(script.Parent.Parent.theme)
local I18n = require(script.Parent.Parent.Parent.core.i18n)
local T = I18n.T

local create = Framework.create
local applyCorner = Framework.applyCorner

local LogEntry = {}

local ROW_HEIGHT = 34

local function actionButton(parent, name, icon, color, order)
    local btn = create("TextButton", {
        Name = name,
        Size = UDim2.new(0, 26, 0, 24),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.65,
        AutoButtonColor = true,
        Text = icon,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Theme.Fonts.Body,
        LayoutOrder = order,
        ZIndex = 5,
        Parent = parent,
    })
    applyCorner(btn, Theme.CornerRadius.SM)
    return btn
end

function LogEntry.new(parent, data, callbacks)
    --[[
        data = {
            t       = number (ms),
            type    = "fire" | "invoke" | "incoming" | "block",
            remote  = string,
            class   = string,
            args    = string,
            path    = string?,
            caller  = string?,
            index   = number,
        }
        callbacks = {
            onSelect  = function(data),   -- row clicked → details
            onCopy    = function(data),
            onBlock   = function(data),   -- ignore this remote
            onDelete  = function(data, row),
        }
    ]]
    callbacks = callbacks or {}

    local color = Theme.getRemoteColor(data.type)
    local label = Theme.getRemoteLabel(data.type)

    -- Row = TextButton so the whole line is clickable
    local row = create("TextButton", {
        Name = "Entry_" .. tostring(data.index or 0),
        Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
        BackgroundColor3 = Theme.Colors.BgPrimary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = data.index or 0,
        Parent = parent,
    })
    applyCorner(row, Theme.CornerRadius.SM)

    -- Colored left stripe
    local stripe = create("Frame", {
        Name = "Stripe",
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 2, 0, 4),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = row,
    })
    applyCorner(stripe, UDim.new(0, 2))

    -- Hover effect
    row.MouseEnter:Connect(function()
        Framework.tween(row, { BackgroundColor3 = Theme.Colors.BgHover }, 0.1):Play()
    end)
    row.MouseLeave:Connect(function()
        Framework.tween(row, { BackgroundColor3 = Theme.Colors.BgPrimary }, 0.1):Play()
    end)

    -- Type badge
    local badge = create("TextLabel", {
        Name = "Badge",
        Size = UDim2.new(0, 52, 0, 16),
        Position = UDim2.new(0, 9, 0.5, -8),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.8,
        Text = label,
        TextColor3 = color,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        Parent = row,
    })
    applyCorner(badge, Theme.CornerRadius.SM)

    -- Timestamp
    local timeStr = string.format("%.1fs", (data.t or 0) / 1000)
    create("TextLabel", {
        Name = "Time",
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(0, 64, 0, 0),
        BackgroundTransparency = 1,
        Text = timeStr,
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    -- Remote name
    create("TextLabel", {
        Name = "RemoteName",
        Size = UDim2.new(1, -196, 0, 15),
        Position = UDim2.new(0, 104, 0, 3),
        BackgroundTransparency = 1,
        Text = data.remote or "?",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    -- Args summary
    create("TextLabel", {
        Name = "Args",
        Size = UDim2.new(1, -196, 0, 13),
        Position = UDim2.new(0, 104, 0, 18),
        BackgroundTransparency = 1,
        Text = data.args or "",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    -- Action buttons (right side)
    local actionsFrame = create("Frame", {
        Name = "Actions",
        Size = UDim2.new(0, 86, 0, 24),
        Position = UDim2.new(1, -90, 0.5, -12),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = row,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 3),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actionsFrame,
    })

    local copyBtn   = actionButton(actionsFrame, "Copy",   "📋", Theme.Colors.Accent, 1)
    local blockBtn  = actionButton(actionsFrame, "Ignore", "🔇", Theme.Colors.Warning, 2)
    local deleteBtn = actionButton(actionsFrame, "Delete", "🗑", Theme.Colors.Error, 3)

    -- Guard: a button press must not also open the detail panel
    local buttonPressed = false
    local function guarded(fn)
        return function()
            buttonPressed = true
            task.delay(0.15, function() buttonPressed = false end)
            if fn then
                local ok, err = pcall(fn, data, row)
                if not ok then
                    Framework.notify(T("n_action_fail", tostring(err)), "error")
                end
            end
        end
    end

    copyBtn.Activated:Connect(guarded(callbacks.onCopy))
    blockBtn.Activated:Connect(guarded(callbacks.onBlock))
    deleteBtn.Activated:Connect(guarded(callbacks.onDelete))

    row.Activated:Connect(function()
        task.defer(function()
            if buttonPressed then return end
            if callbacks.onSelect then
                local ok, err = pcall(callbacks.onSelect, data, row)
                if not ok then
                    Framework.notify(T("n_action_fail", tostring(err)), "error")
                end
            end
        end)
    end)

    return row
end

return LogEntry
