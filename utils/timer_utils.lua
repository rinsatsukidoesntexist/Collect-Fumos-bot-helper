local Timer = require("classes.timer")
local sound_utils = require("utils.sound_utils")

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
    sound_test_index = sound_test_index + 1

    local sound = sounds[sound_test_index]
    if (not sound) then
        
        timer:pause()
        sound_test_index = 0
        return

    end

    sound:play()
    timer:set_time(1)
    timer:unpause()

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

function timer_utils.pause(name)

    local timer = get_timer(name)
    if (not timer) then return end

    timer:pause()
    
end

function timer_utils.unpause(name)

    local timer = get_timer(name)
    if (not timer) then return end

    timer:unpause()
    
end

function timer_utils.init_timers()

    timers = {
        adventure = Timer(0),
        pet = Timer(0),
        sound_test = Timer(0),
    }
    
    for name, _ in pairs(timers) do
        
        timer_utils.cancel_timer(name)

    end

end

return timer_utils