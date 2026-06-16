local Timer = require("classes.timer")
local sound_utils = require("utils.sound_utils")

local sounds_table = {}
local sounds_index = 0

-- just like luau huh!!
---@type {[string] : Timer}
local timers = {}
local timer_utils = {}

---@param timer Timer
local function pet_timer_timeout(timer)
    
    print("pet finish")
    timer:pause()

    sound_utils.play_sound("pet")
    pet_finish_text = "pet finished!!!"

end

---@param timer Timer
local function adventure_timer_timeout(timer)
    
    print("adventure finish")
    timer:pause()

    sound_utils.play_sound("adventure")
    adventure_finish_text = "adventure finished!!!"

end

---@param timer Timer
local function sound_test_timer_timeout(timer)
    
    print("sound test")
    --[[
    sounds_index = sounds_index + 1

    local sound = sounds_table[sounds_index]
    if (not sound) then
        
        timer:pause()
        sounds_index = 0
        return

    end

    sound:play()
    timer:set_time(1)
    timer:unpause()
    ]]

end

---@param name string
---@return Timer?
local function get_timer(name)

    local timer = timers[name]
    if (not timer) then print(string.format("cant cancel timer [%s], it doesnt exist", name)) return end

    return timer
    
end

---@param name string
function timer_utils.cancel_timer(name)

    local timer = get_timer(name)
    if (not timer) then return end

    print("cancel: " .. name)
    timer:pause()
    timer:set_time(0)
    
end

---@param name string
function timer_utils.pause(name)

    local timer = get_timer(name)
    if (not timer) then return end

    timer:pause()
    
end

---@param name string
function timer_utils.unpause(name)

    local timer = get_timer(name)
    if (not timer) then return end

    timer:unpause()
    
end

---@param name string
---@return boolean?
function timer_utils.is_paused(name)

    local timer = get_timer(name)
    if (not timer) then return end

    return timer.paused
    
end

---@param name string
---@param time number
function timer_utils.set_time(name, time)

    local timer = get_timer(name)
    if (not timer) then return end

    timer:set_time(time)
    
end

---@param name string
---@return string?
function timer_utils.format(name)

    local timer = get_timer(name)
    if (not timer) then return end

    return timer:format()
    
end

---@param name string
---@return number?
function timer_utils.get_duration(name)

    local timer = get_timer(name)
    if (not timer) then return end

    return timer.time
    
end

function timer_utils.init_timers()

    timers = {

        adventure = Timer(0, adventure_timer_timeout),
        pet = Timer(0, pet_timer_timeout),
        sound_test = Timer(0, sound_test_timer_timeout),

    }
    
    for name, _ in pairs(timers) do
        
        timer_utils.cancel_timer(name)

    end

end

---@param dt number
function timer_utils.update_timers(dt)

    for _, timer in pairs(timers) do
        
        timer:update(dt)

    end
    
end

return timer_utils