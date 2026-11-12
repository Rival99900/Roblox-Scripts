--[[
    RobloxSpy — modules/network-monitor.lua
    Live network traffic dashboard

    Shows real-time stats: calls/sec, top remotes,
    bandwidth estimate, traffic graph.
]]

local Framework = require(script.Parent.Parent.gui.framework)
local Theme = require(script.Parent.Parent.gui.theme)
local Hooks = require(script.Parent.Parent.core.hooks)
local Session = require(script.Parent.Parent.core.session)
local I18n = require(script.Parent.Parent.core.i18n)
local T = I18n.T

local RunService = game:GetService("RunService")

local create = Framework.create
local applyCorner = Framework.applyCorner
local applyPadding = Framework.applyPadding

local NetworkMonitor = {}

-- ── STATE ────────────────────────────────────────────────────────
local _updateConn = nil
local _callHistory = {}     -- ring buffer of { time = os.clock(), method = string }
local _historySize = 300    -- ~5 minutes at 1/sec
local _remoteCounts = {}    -- [remoteName] = count
local _statsLabels = {}
local _graphBars = {}
local _graphValues = {}     -- last 60 values for mini graph
local GRAPH_WIDTH = 60

-- ── BUILD UI ────────────────────────────────────────────────────

function NetworkMonitor.buildUI(tabContent)
    local scroll = Framework.createScrollFrame(tabContent, {
        Name = "NetMonScroll",
        Padding = 6,
        InnerPadding = 8,
    })

    -- ── Stats cards row ──
    local statsRow = create("Frame", {
        Name = "StatsRow",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Parent = scroll,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        Parent = statsRow,
    })

    local function makeStatCard(name, label, value, color)
        local card = create("Frame", {
            Name = name,
            Size = UDim2.new(0, 120, 0, 56),
            BackgroundColor3 = Theme.Colors.BgSecondary,
            BorderSizePixel = 0,
            Parent = statsRow,
        })
        applyCorner(card, Theme.CornerRadius.MD)

        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 8, 0, 4),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Medium,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })

        local valLabel = create("TextLabel", {
            Name = "Value",
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 8, 0, 20),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = color or Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Heading,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })

        _statsLabels[name] = valLabel
        return card
    end

    makeStatCard("totalCalls", T("net_total"), "0", Theme.Colors.Accent)
    makeStatCard("callsSec", T("net_cps"), "0", Theme.Colors.Success)
    makeStatCard("uniqueRemotes", T("net_unique"), "0", Theme.Colors.Warning)
    makeStatCard("blocked", T("net_blocked"), "0", Theme.Colors.Error)

    -- ── Mini traffic graph ──
    local graphFrame = create("Frame", {
        Name = "Graph",
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = scroll,
    })
    applyCorner(graphFrame, Theme.CornerRadius.MD)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 8, 0, 2),
        BackgroundTransparency = 1,
        Text = T("net_traffic"),
        TextColor3 = Theme.Colors.TextMuted,
        Font = Theme.Fonts.Medium,
        TextSize = Theme.TextSizes.Tiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = graphFrame,
    })

    local barsContainer = create("Frame", {
        Name = "Bars",
        Size = UDim2.new(1, -16, 0, 54),
        Position = UDim2.new(0, 8, 0, 20),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = graphFrame,
    })

    -- Pre-create bar frames
    for i = 1, GRAPH_WIDTH do
        local bar = create("Frame", {
            Name = "Bar" .. i,
            Size = UDim2.new(1 / GRAPH_WIDTH, -1, 0, 1),
            Position = UDim2.new((i - 1) / GRAPH_WIDTH, 0, 1, -1),
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Theme.Colors.Accent,
            BorderSizePixel = 0,
            Parent = barsContainer,
        })
        applyCorner(bar, UDim.new(0, 1))
        _graphBars[i] = bar
    end

    for i = 1, GRAPH_WIDTH do
        _graphValues[i] = 0
    end

    -- ── Top remotes list ──
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = T("net_top"),
        TextColor3 = Theme.Colors.TextPrimary,
        Font = Theme.Fonts.Heading,
        TextSize = Theme.TextSizes.Body,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = scroll,
    })

    _statsLabels._topList = create("Frame", {
        Name = "TopList",
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = Theme.Colors.BgSecondary,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        ClipsDescendants = true,
        Parent = scroll,
    })
    applyCorner(_statsLabels._topList, Theme.CornerRadius.MD)
    create("UIListLayout", {
        Padding = UDim.new(0, 1),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = _statsLabels._topList,
    })

    -- Start update loop
    NetworkMonitor._startUpdates()
end

-- ── DATA TRACKING ───────────────────────────────────────────────

function NetworkMonitor.recordCall(event)
    table.insert(_callHistory, {
        time = os.clock(),
        method = event.method,
    })

    -- Trim old entries (older than 5 min)
    local cutoff = os.clock() - 300
    while #_callHistory > 0 and _callHistory[1].time < cutoff do
        table.remove(_callHistory, 1)
    end

    -- Track per-remote count
    local name = ""
    pcall(function() name = event.remote.Name end)
    _remoteCounts[name] = (_remoteCounts[name] or 0) + 1
end

-- ── UPDATE LOOP ─────────────────────────────────────────────────

function NetworkMonitor._startUpdates()
    if _updateConn then return end

    local lastUpdate = 0
    _updateConn = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastUpdate < 1 then return end
        lastUpdate = now

        NetworkMonitor._updateStats()
        NetworkMonitor._updateGraph()
        NetworkMonitor._updateTopRemotes()
    end)
end

function NetworkMonitor._updateStats()
    local stats = Session.getStats()
    if not stats then return end

    -- Calls per second (last 5 seconds)
    local now = os.clock()
    local recentCount = 0
    for i = #_callHistory, 1, -1 do
        if now - _callHistory[i].time <= 5 then
            recentCount = recentCount + 1
        else
            break
        end
    end
    local cps = math.floor(recentCount / 5 * 10) / 10

    if _statsLabels.totalCalls then
        _statsLabels.totalCalls.Text = tostring(stats.totalCalls or 0)
    end
    if _statsLabels.callsSec then
        _statsLabels.callsSec.Text = string.format("%.1f", cps)
    end
    if _statsLabels.uniqueRemotes then
        _statsLabels.uniqueRemotes.Text = tostring(stats.uniqueRemotes or 0)
    end
    if _statsLabels.blocked then
        _statsLabels.blocked.Text = tostring(stats.blockedCalls or 0)
    end
end

function NetworkMonitor._updateGraph()
    -- Shift left
    for i = 1, GRAPH_WIDTH - 1 do
        _graphValues[i] = _graphValues[i + 1]
    end

    -- Current second calls
    local now = os.clock()
    local count = 0
    for i = #_callHistory, 1, -1 do
        if now - _callHistory[i].time <= 1 then
            count = count + 1
        else
            break
        end
    end
    _graphValues[GRAPH_WIDTH] = count

    -- Find max for scaling
    local maxVal = 1
    for _, v in ipairs(_graphValues) do
        if v > maxVal then maxVal = v end
    end

    -- Update bars
    for i = 1, GRAPH_WIDTH do
        local bar = _graphBars[i]
        if bar then
            local h = math.max(1, (_graphValues[i] / maxVal) * 50)
            bar.Size = UDim2.new(1 / GRAPH_WIDTH, -1, 0, h)

            -- Color intensity
            local ratio = _graphValues[i] / maxVal
            if ratio > 0.8 then
                bar.BackgroundColor3 = Theme.Colors.Error
            elseif ratio > 0.5 then
                bar.BackgroundColor3 = Theme.Colors.Warning
            else
                bar.BackgroundColor3 = Theme.Colors.Accent
            end
        end
    end
end

function NetworkMonitor._updateTopRemotes()
    local topList = _statsLabels._topList
    if not topList then return end

    -- Clear old rows
    for _, c in ipairs(topList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    -- Sort remotes by count
    local sorted = {}
    for name, count in pairs(_remoteCounts) do
        table.insert(sorted, { name = name, count = count })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    -- Show top 10
    for i = 1, math.min(10, #sorted) do
        local item = sorted[i]
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundColor3 = (i % 2 == 0) and Theme.Colors.BgTertiary or Theme.Colors.BgSecondary,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            LayoutOrder = i,
            Parent = topList,
        })

        create("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            BackgroundTransparency = 1,
            Text = "#" .. i,
            TextColor3 = Theme.Colors.TextMuted,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Tiny,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = row,
        })

        create("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = item.name,
            TextColor3 = Theme.Colors.TextPrimary,
            Font = Theme.Fonts.Body,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })

        create("TextLabel", {
            Size = UDim2.new(0.25, 0, 1, 0),
            Position = UDim2.new(0.75, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(item.count),
            TextColor3 = Theme.Colors.TextAccent,
            Font = Theme.Fonts.Code,
            TextSize = Theme.TextSizes.Small,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = row,
        })
    end
end

function NetworkMonitor.stop()
    if _updateConn then
        _updateConn:Disconnect()
        _updateConn = nil
    end
end

return NetworkMonitor
