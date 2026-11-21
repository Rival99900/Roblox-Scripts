--[[
    RobloxSpy — gui/theme.lua
    Color theme & typography constants
]]

local I18n = require(script.Parent.Parent.core.i18n)
local Config = require(script.Parent.Parent.core.config)

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
    ClientInvoke  = Color3.fromRGB(240, 110, 190),
    Bindable      = Color3.fromRGB(150, 200, 70),
    Blocked       = Color3.fromRGB(220, 70, 70),
    Watched       = Color3.fromRGB(255, 210, 60),

    -- Borders
    Border       = Color3.fromRGB(55, 55, 65),
    BorderLight  = Color3.fromRGB(70, 70, 82),

    -- Scrollbar
    ScrollBar    = Color3.fromRGB(80, 80, 95),
}

-- ── ACCENT THEMES ──────────────────────────────────────────────
-- Applied at startup and when changed in Settings (UI is rebuilt).

Theme.Accents = {
    { id = "blue",   color = Color3.fromRGB(75, 130, 255) },
    { id = "purple", color = Color3.fromRGB(150, 95, 255) },
    { id = "green",  color = Color3.fromRGB(50, 190, 120) },
    { id = "red",    color = Color3.fromRGB(230, 75, 85) },
    { id = "orange", color = Color3.fromRGB(245, 145, 45) },
}

local function lighten(c, f)
    return Color3.new(math.min(1, c.R + (1 - c.R) * f), math.min(1, c.G + (1 - c.G) * f), math.min(1, c.B + (1 - c.B) * f))
end
local function darken(c, f)
    return Color3.new(c.R * (1 - f), c.G * (1 - f), c.B * (1 - f))
end

function Theme.applyAccent(id)
    for _, a in ipairs(Theme.Accents) do
        if a.id == id then
            Theme.Colors.Accent = a.color
            Theme.Colors.AccentHover = lighten(a.color, 0.15)
            Theme.Colors.AccentDim = darken(a.color, 0.3)
            Theme.Colors.TextAccent = lighten(a.color, 0.35)
            Theme.Colors.Info = a.color
            Theme.AccentId = id
            return true
        end
    end
    return false
end

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

-- Text scale (Small / Normal / Large) — applied before the UI is built
local BASE_SIZES = {}
for k, v in pairs(Theme.TextSizes) do BASE_SIZES[k] = v end
Theme.TextScales = { small = 0.9, normal = 1, large = 1.2 }

function Theme.applyTextScale(id)
    local f = Theme.TextScales[id] or 1
    for k, v in pairs(BASE_SIZES) do
        Theme.TextSizes[k] = math.floor(v * f + 0.5)
    end
    Theme.TextScaleId = Theme.TextScales[id] and id or "normal"
end

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
    if entryType == "clientinvoke" then return Theme.Colors.ClientInvoke end
    if entryType == "bindable" then return Theme.Colors.Bindable end
    return Theme.Colors.TextSecondary
end

function Theme.getRemoteLabel(entryType)
    local T = I18n.T
    if entryType == "fire" then return T("lbl_fire") end
    if entryType == "invoke" then return T("lbl_invoke") end
    if entryType == "incoming" then return T("lbl_incoming") end
    if entryType == "block" then return T("lbl_blocked") end
    if entryType == "return" then return T("lbl_return") end
    if entryType == "clientinvoke" then return T("lbl_clientinvoke") end
    if entryType == "bindable" then return T("lbl_bindable") end
    return "?"
end

-- Saved preferences
Theme.applyAccent(Config.get("accent") or "blue")
Theme.applyTextScale(Config.get("textScale") or "normal")

return Theme
