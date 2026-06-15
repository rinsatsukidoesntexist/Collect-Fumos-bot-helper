local time_format_utils = {}

--[[
function time_format_utils.format_seconds(t)

    local hours = math.floor(t / 3600)
    local minutes = math.floor((t % 3600) / 60)
    local seconds = math.floor(t % 60)
    return string.format("%dh %dm %0ds", hours, minutes, seconds)

end
]]

---@param t number
---@return string
function time_format_utils.format_seconds(t)

    local hours = math.floor(t / 3600)
    local minutes = math.floor((t % 3600) / 60)
    local seconds = math.floor(t % 60)

    local buffer = {}

    if (hours > 0) then

        table.insert(buffer, hours .. "h")

    end

    if (minutes > 0) then

        table.insert(buffer, minutes .. "m")

    end

    --if (seconds > 0) then

    table.insert(buffer, seconds .. "s")

    --end

    return table.concat(buffer, " ")

end

return time_format_utils