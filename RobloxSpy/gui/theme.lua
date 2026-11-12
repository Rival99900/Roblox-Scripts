--[[
    RobloxSpy — gui/theme.lua
    Color theme & typography constants
]]

local I18n = require(script.Parent.Parent.core.i18n)

local Theme = {}

-- ── PALETTE ─────────────────────────────────────────────────────

Theme.Colors = {
    -- Backgrounds
    BgDark       = Color3.fromRGB(14, 14, 18),
    BgPrimary    = Color3.fromRGB(22, 22, 28),
    BgSecondary  = Color3.fromRGB(28, 28, 36),
    BgTertiary   = Color3.fromRGB(35, 35, 44),
    BgHover      = Color3.fromRGB(42, 42, 52),
    BgSelected   = Color3.fromRGB(45, 45, 58),

    -- Accent
    Accent       = Color3.fromRGB(75, 130, 255),
    AccentHover  = Color3.fromRGB(95, 148, 255),
    AccentDim    = Color3.fromRGB(50, 90, 180),

    -- Text
    TextPrimary   = Color3.fromRGB(220, 220, 235),
    TextSecondary = Color3.fromRGB(150, 150, 168),
    TextMuted     = Color3.fromRGB(100, 100, 118),
    TextAccent    = Color3.fromRGB(130, 175, 255),

    -- Semantic
    Success      = Color3.fromRGB(80, 200, 120),
    Warning      = Color3.fromRGB(240, 180, 50),
    Error        = Color3.fromRGB(220, 70, 70),
    Info         = Color3.fromRGB(75, 130, 255),

    -- Remote types
    FireServer    = Color3.fromRGB(255, 140, 60),
    InvokeServer  = Color3.fromRGB(130, 100, 255),
    OnClientEvent = Color3.fromRGB(60, 200, 160),
    Blocked       = Color3.fromRGB(220, 70, 70),

    -- Borders
    Border       = Color3.fromRGB(55, 55, 65),
    BorderLight  = Color3.fromRGB(70, 70, 82),

    -- Scrollbar
    ScrollBar    = Color3.fromRGB(80, 80, 95),
}

-- ── TYPOGRAPHY ──────────────────────────────────────────────────

Theme.Fonts = {
    Title    = Enum.Font.GothamBold,
    Heading  = Enum.Font.GothamBold,
    Body     = Enum.Font.Gotham,
    Medium   = Enum.Font.GothamMedium,
    Code     = Enum.Font.Code,
}

Theme.TextSizes = {
    Title   = 16,
    Heading = 14,
    Body    = 12,
    Small   = 11,
    Tiny    = 10,
    Code    = 12,
}

-- ── SPACING ─────────────────────────────────────────────────────

Theme.Spacing = {
    XS = 2,
    SM = 4,
    MD = 8,
    LG = 12,
    XL = 16,
}

Theme.CornerRadius = {
    SM = UDim.new(0, 4),
    MD = UDim.new(0, 6),
    LG = UDim.new(0, 8),
    XL = UDim.new(0, 12),
    Full = UDim.new(0.5, 0),
}

-- ── HELPERS ─────────────────────────────────────────────────────

function Theme.getRemoteColor(entryType)
    if entryType == "fire" then return Theme.Colors.FireServer end
    if entryType == "invoke" then return Theme.Colors.InvokeServer end
    if entryType == "incoming" then return Theme.Colors.OnClientEvent end
    if entryType == "block" then return Theme.Colors.Blocked end
    return Theme.Colors.TextSecondary
end

function Theme.getRemoteLabel(entryType)
    local T = I18n.T
    if entryType == "fire" then return T("lbl_fire") end
    if entryType == "invoke" then return T("lbl_invoke") end
    if entryType == "incoming" then return T("lbl_incoming") end
    if entryType == "block" then return T("lbl_blocked") end
    if entryType == "return" then return T("lbl_return") end
    return "?"
end

return Theme
