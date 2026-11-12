--[[
    RobloxSpy — utils/search.lua
    Cross-module search utilities
]]

local Search = {}

function Search.fuzzyMatch(query, text)
    if not query or query == "" then return true end
    if not text then return false end
    query = query:lower()
    text = text:lower()
    return text:find(query, 1, true) ~= nil
end

function Search.multiFieldMatch(query, fields)
    if not query or query == "" then return true end
    query = query:lower()
    for _, field in ipairs(fields) do
        if field and tostring(field):lower():find(query, 1, true) then
            return true
        end
    end
    return false
end

function Search.highlightMatch(text, query)
    -- Returns text with match wrapped (for RichText)
    if not query or query == "" then return text end
    local lower = text:lower()
    local qLower = query:lower()
    local start = lower:find(qLower, 1, true)
    if not start then return text end
    local finish = start + #qLower - 1
    return text:sub(1, start - 1)
        .. '<font color="#4B82FF"><b>' .. text:sub(start, finish) .. '</b></font>'
        .. text:sub(finish + 1)
end

return Search
