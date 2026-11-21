--[[
    RobloxSpy — gui/components/log-entry.lua
    Single remote call log row for the spy feed (v1.1.0)

    The whole row is clickable (opens the detail panel).
    Action buttons (drawn icons): copy R2S · ignore remote · delete row
    Buttons use .Activated (works with mouse AND touch on every executor).

    Extra row states:
      LogEntry.setCount(row, n)      → "×n" badge (grouped identical calls)
      LogEntry.setReturned(row, on)  → "↩" mark (server answered the Invoke)
      LogEntry.setWatched(row, on)   → star + gold stripe (watchlist)
      LogEntry.setAlert(row, on)     → highlighted background (keyword alert)
]]

local Framework = require(script.Parent.Parent.framework)
local Theme = require(script.Parent.Parent.theme)
local Icons = require(script.Parent.Parent.icons)
local I18n = require(script.Parent.Parent.Parent.core.i18n)
local T = I18n.T

local create = Framework.create
local applyCorner = Framework.applyCorner

local LogEntry = {}

local IS_MOBILE = Framework.IS_MOBILE
local ROW_HEIGHT = IS_MOBILE and 44 or 34
local BTN = IS_MOBILE and 34 or 26

local function actionButton(parent, name, iconName, color, order, tip)
    local btn = create("TextButton", {
        Name = name,
        Size = UDim2.new(0, BTN, 0, BTN - 2),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.65,
        AutoButtonColor = true,
        Text = "",
        LayoutOrder = order,
        ZIndex = 5,
        Parent = parent,
    })
    applyCorner(btn, Theme.CornerRadius.SM)
    local icon = Icons.draw(iconName, btn, math.floor(BTN * 0.5), Color3.fromRGB(235, 235, 245), Theme.Colors.BgPrimary)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.ZIndex = 6
    if tip then Framework.tooltip(btn, tip) end
    return btn
end

function LogEntry.new(parent, data, callbacks)
    --[[
        data = { t, type, remote, class, args, path?, caller?, index }
        callbacks = { onSelect, onCopy, onBlock, onDelete }
    ]]
    callbacks = callbacks or {}

    local color = Theme.getRemoteColor(data.type)
    local label = Theme.getRemoteLabel(data.type)

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

    local stripe = create("Frame", {
        Name = "Stripe",
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 2, 0, 4),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = row,
    })
    applyCorner(stripe, UDim.new(0, 2))

    local normalBg = Theme.Colors.BgPrimary
    row.MouseEnter:Connect(function()
        Framework.tween(row, { BackgroundColor3 = Theme.Colors.BgHover }, 0.1):Play()
    end)
    row.MouseLeave:Connect(function()
        Framework.tween(row, { BackgroundColor3 = row:GetAttribute("AlertBg") and Color3.fromRGB(60, 45, 20) or normalBg }, 0.1):Play()
    end)

    local badge = create("TextLabel", {
        Name = "Badge",
        Size = UDim2.new(0, 56, 0, 16),
        Position = UDim2.new(0, 9, 0.5, -8),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.8,
        Text = label,
        TextColor3 = color,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    applyCorner(badge, Theme.CornerRadius.SM)

    create("TextLabel", {
        Name = "Time",
        Size = UDim2.new(0, 42, 1, 0),
        Position = UDim2.new(0, 68, 0, 0),
        BackgroundTransparency = 1,
        Text = string.format("%.1fs", (data.t or 0) / 1000),
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local actionsW = BTN * 3 + 10
    local textW = -(110 + actionsW + 8)

    create("TextLabel", {
        Name = "RemoteName",
        Size = UDim2.new(1, textW - 74, 0, 16), -- room for the markers
        Position = UDim2.new(0, 110, 0, IS_MOBILE and 5 or 3),
        BackgroundTransparency = 1,
        Text = data.remote or "?",
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    create("TextLabel", {
        Name = "Args",
        Size = UDim2.new(1, textW, 0, 13),
        Position = UDim2.new(0, 110, 0, IS_MOBILE and 24 or 18),
        BackgroundTransparency = 1,
        Text = data.args or "",
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Code,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })

    -- Right-side markers: "↩" returned, "×n" count, star (watch)
    local markers = create("Frame", {
        Name = "Markers",
        Size = UDim2.new(0, 70, 0, 16),
        Position = UDim2.new(1, -(actionsW + 76), 0, IS_MOBILE and 5 or 3),
        BackgroundTransparency = 1,
        Parent = row,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = markers,
    })
    local function pill(name, text, c, order)
        local p = create("TextLabel", {
            Name = name,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = c,
            BackgroundTransparency = 0.75,
            Text = text,
            TextColor3 = c,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            Visible = false,
            LayoutOrder = order,
            Parent = markers,
        })
        applyCorner(p, Theme.CornerRadius.SM)
        Framework.applyPadding(p, 0, 4, 0, 4)
        return p
    end
    pill("Returned", "↩", Theme.Colors.InvokeServer, 1)
    pill("Count", "×1", Theme.Colors.TextSecondary, 2)
    local star = Icons.draw("star", markers, 10, Theme.Colors.Watched)
    star.Name = "Watched"
    star.Visible = false
    star.LayoutOrder = 3

    local actionsFrame = create("Frame", {
        Name = "Actions",
        Size = UDim2.new(0, actionsW, 0, BTN),
        Position = UDim2.new(1, -(actionsW + 4), 0.5, -BTN / 2),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = row,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 3),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actionsFrame,
    })

    local copyBtn   = actionButton(actionsFrame, "Copy",   "copy",   Theme.Colors.Accent, 1, T("tip_copy_r2s"))
    local blockBtn  = actionButton(actionsFrame, "Ignore", "ignore", Theme.Colors.Warning, 2, T("tip_ignore"))
    local deleteBtn = actionButton(actionsFrame, "Delete", "close",  Theme.Colors.Error, 3, T("tip_delete"))

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

local function marker(row, name)
    local m = row and row:FindFirstChild("Markers")
    return m and m:FindFirstChild(name)
end

function LogEntry.setCount(row, n)
    local p = marker(row, "Count")
    if not p then return end
    p.Text = "×" .. tostring(n)
    p.Visible = (n or 1) > 1
end

function LogEntry.setReturned(row, on)
    local p = marker(row, "Returned")
    if p then p.Visible = on and true or false end
end

function LogEntry.setWatched(row, on)
    local p = marker(row, "Watched")
    if p then p.Visible = on and true or false end
    local stripe = row and row:FindFirstChild("Stripe")
    if stripe and on then stripe.BackgroundColor3 = Theme.Colors.Watched end
end

function LogEntry.setAlert(row, on)
    if not row then return end
    row:SetAttribute("AlertBg", on and true or nil)
    row.BackgroundColor3 = on and Color3.fromRGB(60, 45, 20) or Theme.Colors.BgPrimary
end

LogEntry.ROW_HEIGHT = ROW_HEIGHT

return LogEntry
