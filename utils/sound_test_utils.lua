-- modular scripting final boss
local sound_utils = require("utils.sound_utils")

local doing_sound_test = false
local sound_test_index = 0
local sounds_table = {}

local sound_test_utils = {}

local function setup()

    sounds_table = sound_utils.get_sounds_table()
    sound_test_index = 0
    
end

function sound_test_utils.is_in_progress()

    return doing_sound_test
    
end

function sound_test_utils.start_sound_test()

    if (doing_sound_test) then return end
    setup()
    doing_sound_test = true
    print("sound test start")
    
end

function sound_test_utils.advance_sound_test()

    sound_test_index = sound_test_index + 1
    local sound = sounds_table[sound_test_index]
    
    if (not sound) then
        
        print("sound test finish")
        doing_sound_test = false
        return

    end
    
    sound:play()

end

return sound_test_utils