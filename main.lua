-- lib
class = require("lib.middleclass")
slab = require("lib.slab")

-- utils
local time_format_utils = require("utils.time_format_utils")
local color_utils = require("utils.color_utils")
local save_utils = require("utils.save_utils")
local sound_utils = require("utils.sound_utils")
local timer_utils = require("utils.timer_utils")
local gui_utils = require("utils.gui_utils")

-- other requires
local data = require("data")
local global_state = require("global_state")

-- assets
local alttp_font_gui = love.graphics.newFont("fonts/RetGanon.ttf", 26)

-- variables
local enable_debug_keybinds = true

-- constants
-- local CONST = 67.67

-- TODO: move to save utils
local function load_save()

    local saved_data = save_utils.get_save()
    local is_valid = save_utils.sanity_check_save(saved_data)
    if (not is_valid or not saved_data) then 
        
        status_text = "failed to load save"
        return
    
    end

    print("actually load save now")
    local current_time = os.time()
    local closed_at = saved_data.close_timestamp
    local delta = current_time - closed_at

    -- 0.01 is a small hack to make the timer timeout immediately when opening the app. if its 0 it doesn't check for timeout
    timer_utils.set_time("pet", math.max(saved_data.pet - delta, 0.01))
    timer_utils.set_time("adventure", math.max(saved_data.adventure - delta, 0.01))

    if (not saved_data.pet_pause) then
        
        timer_utils.unpause("pet")

    end

    if (not saved_data.adventure_pause) then
        
        timer_utils.unpause("adventure")

    end

    adventure_finish_text = saved_data.status_message_adventure
    pet_finish_text = saved_data.status_message_pet
    
end

function love.load()

    slab.Initialize()

    love.filesystem.mount(love.filesystem.getSaveDirectory(), "save")
    love.filesystem.createDirectory("user_audio")

    love.window.setIcon(love.image.newImageData("icon.png"))
    love.window.setTitle("Collect Fumos! bot helper v1.1")

    gui_utils.init_visuals()
    sound_utils.reload_sfx()
    timer_utils.init_timers()
    -- TODO: call load save

end

function love.update(dt)

    slab.Update(dt)
    timer_utils.update_timers(dt)

    gui_utils.do_window_1()
    gui_utils.do_window_2()

end

function love.draw()
    
    slab.Draw()
    
end

-- TODO: move to save utils
function love.quit()

    if true then return end

    local save = love.filesystem.newFile("save.lua")
    local close_timestamp = os.time()
    save:open("w")

    -- pointless stuff
    save:write("-- YES- the save files are stored in plain text. what's the issue?\n\n\n")
    for i = 1, love.math.random(30, 70) do
        
        local phrase_index = love.math.random(1, #data.SAVE_PHRASES)
        save:write(string.format("-- %s\n", data.SAVE_PHRASES[phrase_index]))

    end

    -- actual saving below
    save:write("local save = {}\n")

    save:write("save.close_timestamp = " .. close_timestamp .. "\n") -- why the fuck is format not working with close_timestamp??? fuck you lua

    save:write(string.format("save.adventure = %d\n", timer_adventure.time))
    save:write(string.format("save.pet = %d\n", timer_pet.time))
    save:write(string.format("save.adventure_pause = %s\n", tostring(timer_adventure.paused)))
    save:write(string.format("save.pet_pause = %s\n", tostring(timer_pet.paused)))
    save:write(string.format("save.status_message_adventure = \"%s\"\n", adventure_finish_text))
    save:write(string.format("save.status_message_pet = \"%s\"\n", pet_finish_text))
    save:write("return save")

    save:close()
    
end

function love.keypressed(key)

    if (not enable_debug_keybinds) then return end
    if (key == "1") then
        
        timer_utils.set_time("adventure", 2)

    end

    if (key == "2") then
        
        timer_utils.set_time("pet", 2)

    end
    
end