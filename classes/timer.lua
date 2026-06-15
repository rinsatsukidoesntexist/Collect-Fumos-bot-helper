---@class Timer
---@field time number
---@field paused boolean
---@field timeout_func function
---@overload fun(time: number, timeout_func?: function): Timer
local Timer = class("Timer")

local time_format_utils = require("utils.time_format_utils")

-- TODO: add ontimeout function, run it on end
function Timer:initialize(time, timeout_func)

    self.time = time or 0
    self.paused = false
    self.timeout_func = timeout_func

end

---@param dt number
function Timer:update(dt)

    if (self.paused) then return end

    local previous_time = self.time
    self.time = math.max(self.time - dt, 0)
    
    if (previous_time <= 0) then return end
    if (self.time > 0) then return end

    print("timeout!")
    if (self.timeout_func) then
        
        self:timeout_func()

    end

end

function Timer:pause()

    self.paused = true
    
end

function Timer:unpause()

    self.paused = false
    
end

---@param time number
function Timer:set_time(time)

    self.time = time
    
end

---@return string
function Timer:format()

    return time_format_utils.format_seconds(self.time)

end

return Timer