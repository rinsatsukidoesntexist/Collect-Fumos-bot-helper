-- "clean code" is a bydo psyop btw
-- BLAST OFF AND STRIKE THE EVIL BYDO EMPIRE!!!

-- lib
class = require("lib.middleclass")
slab = require("lib.slab")

-- utils
local save_utils = require("utils.save_utils")
local sound_utils = require("utils.sound_utils")
local timer_utils = require("utils.timer_utils")
local gui_utils = require("utils.gui_utils")
local random_image_utils = require("utils.random_image_utils")

-- other requires
local global_state = require("global_state")
--local my_cool_module = require("fat_girls")

-- assets
-- local my_image = love.graphics.newImage("patchouli_boobs.png")

-- variables
local enable_debug_keybinds = true

-- constants
-- local CONST = 67.67

function love.load()

    love.filesystem.mount(love.filesystem.getSaveDirectory(), "save")
    love.filesystem.createDirectory("user_audio")

    slab.Initialize()

    gui_utils.init_visuals()
    sound_utils.reload_sfx()
    timer_utils.init_timers()

    save_utils.load_save()

    global_state.random_image_path = random_image_utils.pick_one()
    global_state.random_image = love.graphics.newImage(global_state.random_image_path)

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

    if (key == "escape") then
        
        love.event.quit()
        return

    end

    if (not enable_debug_keybinds) then return end

    if (key == "1") then
        
        timer_utils.set_time("adventure", 2)

    end

    if (key == "2") then
        
        timer_utils.set_time("pet", 2)

    end
    
end