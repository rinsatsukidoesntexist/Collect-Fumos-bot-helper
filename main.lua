-- "clean code" is a bydo psyop btw
-- BLAST OFF AND STRIKE THE EVIL BYDO EMPIRE!!!

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
-- local my_image = love.graphics.newImage("patchouli_boobs.png")

-- variables
local enable_debug_keybinds = true

-- constants
-- local CONST = 67.67

function love.load()

    slab.Initialize()

    love.filesystem.mount(love.filesystem.getSaveDirectory(), "save")
    love.filesystem.createDirectory("user_audio")

    gui_utils.init_visuals()
    sound_utils.reload_sfx()
    timer_utils.init_timers()

    save_utils.load_save()

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

function love.quit()

    save_utils.write_save_file()
    
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