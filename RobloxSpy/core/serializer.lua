--[[
    RobloxSpy — core/serializer.lua
    Value-to-code serializer

    Converts any Roblox/Lua value into a reproducible Lua code string.
    Used by Remote Spy for R2S (Remote-to-Script) code generation,
    and by Session Manager for JSON export.
]]

local I18n = require(script.Parent.i18n)

local Serializer = {}

-- ── INSTANCE PATH ────────────────────────────────────────────────
-- Builds the shortest valid Lua path to reach an Instance.

local function getInstancePath(inst)
    if not inst or not inst.Parent then
        return "nil --[[ destroyed/nil instance ]]"
    end

    local parts = {}
    local current = inst
    local maxDepth = 50

    while current and current ~= game and maxDepth > 0 do
        maxDepth = maxDepth - 1
        local name = current.Name

        -- Check if it's a service
        if current.Parent == game then
            local ok, svc = pcall(function()
                return game:GetService(current.ClassName)
            end)
            if ok and svc == current then
                table.insert(parts, 1, 'game:GetService("' .. current.ClassName .. '")')
                return table.concat(parts, "")
            end
        end

        -- Valid Lua identifier?
        if name:match("^[%a_][%w_]*$") and not name:match("^%d") then
            table.insert(parts, 1, "." .. name)
        else
            -- Needs bracket notation
            table.insert(parts, 1, '["' .. name:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"]')
        end

        current = current.Parent
    end

    if #parts == 0 then return "game" end

    local path = table.concat(parts, "")
    -- Remove leading dot
    if path:sub(1, 1) == "." then
        path = "game." .. path:sub(2)
    else
        path = "game" .. path
    end

    return path
end

Serializer.getInstancePath = getInstancePath

-- ── TYPE SERIALIZERS ─────────────────────────────────────────────

local typeHandlers = {}

typeHandlers["nil"] = function()
    return "nil"
end

typeHandlers["boolean"] = function(v)
    return tostring(v)
end

typeHandlers["number"] = function(v)
    if v ~= v then return "0/0" end            -- NaN
    if v == math.huge then return "math.huge" end
    if v == -math.huge then return "-math.huge" end
    -- Integer check
    if v == math.floor(v) and math.abs(v) < 2^53 then
        return tostring(v)
    end
    return string.format("%.14g", v)
end

typeHandlers["string"] = function(v)
    -- Use long brackets if it contains both quote types or newlines
    if v:find("\n") and not v:find("%]%]") then
        return "[[" .. v .. "]]"
    end
    -- Escape and quote
    local escaped = v:gsub('\\', '\\\\')
                     :gsub('"', '\\"')
                     :gsub('\n', '\\n')
                     :gsub('\r', '\\r')
                     :gsub('\t', '\\t')
                     :gsub('\0', '\\0')
    -- Replace non-printable
    escaped = escaped:gsub('[%z\1-\31\127-\255]', function(c)
        return string.format('\\%d', string.byte(c))
    end)
    return '"' .. escaped .. '"'
end

typeHandlers["Instance"] = function(v)
    local ok, path = pcall(getInstancePath, v)
    if ok then return path end
    return 'nil --[[ Instance: ' .. tostring(v) .. ' ]]'
end

typeHandlers["EnumItem"] = function(v)
    return tostring(v) -- e.g. Enum.KeyCode.W
end

typeHandlers["Enum"] = function(v)
    return tostring(v)
end

-- Roblox value types
local robloxConstructors = {
    Vector3 = function(v)
        if v == Vector3.zero then return "Vector3.zero" end
        if v == Vector3.one then return "Vector3.one" end
        return string.format("Vector3.new(%s, %s, %s)",
            typeHandlers["number"](v.X),
            typeHandlers["number"](v.Y),
            typeHandlers["number"](v.Z))
    end,

    Vector2 = function(v)
        if v == Vector2.zero then return "Vector2.zero" end
        return string.format("Vector2.new(%s, %s)",
            typeHandlers["number"](v.X),
            typeHandlers["number"](v.Y))
    end,

    CFrame = function(v)
        if v == CFrame.identity then return "CFrame.identity" end
        local comps = { v:GetComponents() }
        local strs = {}
        for _, c in ipairs(comps) do
            table.insert(strs, typeHandlers["number"](c))
        end
        return "CFrame.new(" .. table.concat(strs, ", ") .. ")"
    end,

    Color3 = function(v)
        -- Check common colors
        if v == Color3.new(1, 1, 1) then return "Color3.new(1, 1, 1)" end
        if v == Color3.new(0, 0, 0) then return "Color3.new(0, 0, 0)" end
        return string.format("Color3.new(%s, %s, %s)",
            typeHandlers["number"](v.R),
            typeHandlers["number"](v.G),
            typeHandlers["number"](v.B))
    end,

    BrickColor = function(v)
        return 'BrickColor.new("' .. tostring(v) .. '")'
    end,

    UDim2 = function(v)
        return string.format("UDim2.new(%s, %s, %s, %s)",
            typeHandlers["number"](v.X.Scale),
            typeHandlers["number"](v.X.Offset),
            typeHandlers["number"](v.Y.Scale),
            typeHandlers["number"](v.Y.Offset))
    end,

    UDim = function(v)
        return string.format("UDim.new(%s, %s)",
            typeHandlers["number"](v.Scale),
            typeHandlers["number"](v.Offset))
    end,

    Ray = function(v)
        return string.format("Ray.new(%s, %s)",
            robloxConstructors.Vector3(v.Origin),
            robloxConstructors.Vector3(v.Direction))
    end,

    Region3 = function(v)
        local cf = v.CFrame
        local sz = v.Size
        local min = cf.Position - sz / 2
        local max = cf.Position + sz / 2
        return string.format("Region3.new(%s, %s)",
            robloxConstructors.Vector3(min),
            robloxConstructors.Vector3(max))
    end,

    NumberRange = function(v)
        if v.Min == v.Max then
            return string.format("NumberRange.new(%s)", typeHandlers["number"](v.Min))
        end
        return string.format("NumberRange.new(%s, %s)",
            typeHandlers["number"](v.Min),
            typeHandlers["number"](v.Max))
    end,

    NumberSequenceKeypoint = function(v)
        return string.format("NumberSequenceKeypoint.new(%s, %s, %s)",
            typeHandlers["number"](v.Time),
            typeHandlers["number"](v.Value),
            typeHandlers["number"](v.Envelope))
    end,

    ColorSequenceKeypoint = function(v)
        return string.format("ColorSequenceKeypoint.new(%s, %s)",
            typeHandlers["number"](v.Time),
            robloxConstructors.Color3(v.Value))
    end,

    NumberSequence = function(v)
        local kps = {}
        for _, kp in ipairs(v.Keypoints) do
            table.insert(kps, robloxConstructors.NumberSequenceKeypoint(kp))
        end
        return "NumberSequence.new({" .. table.concat(kps, ", ") .. "})"
    end,

    ColorSequence = function(v)
        local kps = {}
        for _, kp in ipairs(v.Keypoints) do
            table.insert(kps, robloxConstructors.ColorSequenceKeypoint(kp))
        end
        return "ColorSequence.new({" .. table.concat(kps, ", ") .. "})"
    end,

    Rect = function(v)
        return string.format("Rect.new(%s, %s, %s, %s)",
            typeHandlers["number"](v.Min.X),
            typeHandlers["number"](v.Min.Y),
            typeHandlers["number"](v.Max.X),
            typeHandlers["number"](v.Max.Y))
    end,

    PhysicalProperties = function(v)
        return string.format("PhysicalProperties.new(%s, %s, %s, %s, %s)",
            typeHandlers["number"](v.Density),
            typeHandlers["number"](v.Friction),
            typeHandlers["number"](v.Elasticity),
            typeHandlers["number"](v.FrictionWeight),
            typeHandlers["number"](v.ElasticityWeight))
    end,

    Font = function(v)
        return string.format('Font.new("%s", Enum.FontWeight.%s, Enum.FontStyle.%s)',
            tostring(v.Family),
            tostring(v.Weight.Name),
            tostring(v.Style.Name))
    end,

    Axes = function(v)
        local axes = {}
        if v.X then table.insert(axes, "Enum.Axis.X") end
        if v.Y then table.insert(axes, "Enum.Axis.Y") end
        if v.Z then table.insert(axes, "Enum.Axis.Z") end
        return "Axes.new(" .. table.concat(axes, ", ") .. ")"
    end,

    Faces = function(v)
        local faces = {}
        if v.Top then table.insert(faces, "Enum.NormalId.Top") end
        if v.Bottom then table.insert(faces, "Enum.NormalId.Bottom") end
        if v.Left then table.insert(faces, "Enum.NormalId.Left") end
        if v.Right then table.insert(faces, "Enum.NormalId.Right") end
        if v.Front then table.insert(faces, "Enum.NormalId.Front") end
        if v.Back then table.insert(faces, "Enum.NormalId.Back") end
        return "Faces.new(" .. table.concat(faces, ", ") .. ")"
    end,

    TweenInfo = function(v)
        return string.format("TweenInfo.new(%s, %s, %s, %s, %s, %s)",
            typeHandlers["number"](v.Time),
            tostring(v.EasingStyle),
            tostring(v.EasingDirection),
            typeHandlers["number"](v.RepeatCount),
            tostring(v.Reverses),
            typeHandlers["number"](v.DelayTime))
    end,

    PathWaypoint = function(v)
        return string.format("PathWaypoint.new(%s, %s)",
            robloxConstructors.Vector3(v.Position),
            tostring(v.Action))
    end,
}

-- ── TABLE SERIALIZER ─────────────────────────────────────────────

local function serializeTable(tbl, indent, seen)
    seen = seen or {}
    indent = indent or 1

    if seen[tbl] then
        return '"<circular reference>"'
    end
    seen[tbl] = true

    local tabs = string.rep("    ", indent)
    local closeTabs = string.rep("    ", indent - 1)
    local parts = {}
    local arrayLen = #tbl
    local isArray = arrayLen > 0

    -- Check if pure array
    local isPureArray = true
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    isPureArray = isArray and count == arrayLen

    if isPureArray then
        -- Serialize as array
        for i, v in ipairs(tbl) do
            table.insert(parts, tabs .. Serializer.serialize(v, indent, seen))
        end
    else
        -- Mixed or dictionary
        -- Array part first
        for i = 1, arrayLen do
            table.insert(parts, tabs .. Serializer.serialize(tbl[i], indent, seen))
        end
        -- Dictionary part
        for k, v in pairs(tbl) do
            if type(k) ~= "number" or k < 1 or k > arrayLen or k ~= math.floor(k) then
                local keyStr
                if type(k) == "string" and k:match("^[%a_][%w_]*$") then
                    keyStr = k
                else
                    keyStr = "[" .. Serializer.serialize(k, indent, seen) .. "]"
                end
                table.insert(parts, tabs .. keyStr .. " = " .. Serializer.serialize(v, indent, seen))
            end
        end
    end

    seen[tbl] = nil

    if #parts == 0 then return "{}" end
    if #parts <= 3 and not table.concat(parts):find("\n") then
        -- Inline short tables
        local inline = {}
        for _, p in ipairs(parts) do
            table.insert(inline, p:match("^%s*(.-)%s*$"))
        end
        local result = "{ " .. table.concat(inline, ", ") .. " }"
        if #result < 80 then return result end
    end

    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. closeTabs .. "}"
end

-- ── MAIN SERIALIZE ───────────────────────────────────────────────

function Serializer.serialize(value, indent, seen)
    indent = indent or 1
    local t = typeof(value)

    -- Primitives
    if typeHandlers[t] then
        return typeHandlers[t](value)
    end

    -- Roblox types
    if robloxConstructors[t] then
        local ok, result = pcall(robloxConstructors[t], value)
        if ok then return result end
        return '"<' .. t .. ': serialization failed>"'
    end

    -- Tables
    if t == "table" then
        return serializeTable(value, indent, seen or {})
    end

    -- Functions
    if t == "function" then
        local info = ""
        if debug and debug.getinfo then
            local ok, dbg = pcall(debug.getinfo, value)
            if ok and dbg then
                info = dbg.source or "?"
                if dbg.currentline then info = info .. ":" .. dbg.currentline end
            end
        end
        return '"<function: ' .. info .. '>"'
    end

    -- Userdata / thread / other
    return '"<' .. t .. ': ' .. tostring(value):gsub('"', '\\"') .. '>"'
end

-- ── R2S CODE GENERATION ──────────────────────────────────────────
-- Generates a complete, runnable Lua script that replays a remote call.

function Serializer.generateR2S(remote, method, args)
    local lines = {}

    -- Header
    local T = (I18n and I18n.T) or function(k) return k end
    table.insert(lines, T("code_r2s"))
    table.insert(lines, "-- Remote: " .. (remote and remote.Name or "?"))
    table.insert(lines, "-- Method: " .. (method or "?"))
    table.insert(lines, T("code_generated", os.date("%Y-%m-%d %H:%M:%S")))
    table.insert(lines, "")

    -- Remote path
    local remotePath = Serializer.serialize(remote)
    table.insert(lines, "local remote = " .. remotePath)
    table.insert(lines, "")

    -- Args
    if args and #args > 0 then
        for i, arg in ipairs(args) do
            local varName = "arg" .. i
            table.insert(lines, "local " .. varName .. " = " .. Serializer.serialize(arg, 1))
        end
        table.insert(lines, "")

        -- Call
        local argNames = {}
        for i = 1, #args do
            table.insert(argNames, "arg" .. i)
        end

        if method == "FireServer" then
            table.insert(lines, "remote:FireServer(" .. table.concat(argNames, ", ") .. ")")
        elseif method == "InvokeServer" then
            table.insert(lines, "local result = remote:InvokeServer(" .. table.concat(argNames, ", ") .. ")")
            table.insert(lines, "print(\"Return:\", result)")
        else
            table.insert(lines, "remote:" .. method .. "(" .. table.concat(argNames, ", ") .. ")")
        end
    else
        if method == "FireServer" then
            table.insert(lines, "remote:FireServer()")
        elseif method == "InvokeServer" then
            table.insert(lines, "local result = remote:InvokeServer()")
            table.insert(lines, "print(\"Return:\", result)")
        else
            table.insert(lines, "remote:" .. method .. "()")
        end
    end

    return table.concat(lines, "\n")
end

-- ── JSON-SAFE SERIALIZER ─────────────────────────────────────────
-- For session storage. Converts to JSON-compatible tables.

function Serializer.toJSON(value)
    local t = typeof(value)

    if t == "nil" then return nil end
    if t == "boolean" or t == "number" then return value end
    if t == "string" then return value end

    if t == "Instance" then
        return {
            __type = "Instance",
            class = value.ClassName,
            name = value.Name,
            path = getInstancePath(value),
        }
    end

    if t == "Vector3" then
        return { __type = "Vector3", x = value.X, y = value.Y, z = value.Z }
    end

    if t == "CFrame" then
        return { __type = "CFrame", components = { value:GetComponents() } }
    end

    if t == "Color3" then
        return { __type = "Color3", r = value.R, g = value.G, b = value.B }
    end

    if t == "EnumItem" then
        return { __type = "EnumItem", value = tostring(value) }
    end

    if t == "table" then
        local result = {}
        for k, v in pairs(value) do
            local key = type(k) == "number" and k or tostring(k)
            result[key] = Serializer.toJSON(v)
        end
        return result
    end

    -- Fallback
    return { __type = t, repr = tostring(value) }
end

-- ── COMPACT ONE-LINE SUMMARY ─────────────────────────────────────
-- For log display: short, max ~120 chars.

function Serializer.summarize(args, maxLen)
    maxLen = maxLen or 120
    if not args or #args == 0 then return "()" end

    local parts = {}
    for i, arg in ipairs(args) do
        local t = typeof(arg)
        local s
        if t == "string" then
            s = '"' .. (arg:sub(1, 30)) .. (#arg > 30 and "…" or "") .. '"'
        elseif t == "Instance" then
            s = arg.Name .. " [" .. arg.ClassName .. "]"
        elseif t == "table" then
            local n = 0
            for _ in pairs(arg) do n = n + 1 end
            s = "{" .. n .. " entries}"
        elseif t == "number" or t == "boolean" then
            s = tostring(arg)
        elseif t == "nil" then
            s = "nil"
        elseif t == "Vector3" then
            s = string.format("V3(%.1f,%.1f,%.1f)", arg.X, arg.Y, arg.Z)
        elseif t == "CFrame" then
            s = string.format("CF(%.1f,%.1f,%.1f)", arg.Position.X, arg.Position.Y, arg.Position.Z)
        elseif t == "Color3" then
            s = string.format("C3(%.2f,%.2f,%.2f)", arg.R, arg.G, arg.B)
        elseif t == "EnumItem" then
            s = tostring(arg)
        else
            s = "<" .. t .. ">"
        end
        table.insert(parts, s)
    end

    local result = "(" .. table.concat(parts, ", ") .. ")"
    if #result > maxLen then
        result = result:sub(1, maxLen - 1) .. "…"
    end
    return result
end

return Serializer
