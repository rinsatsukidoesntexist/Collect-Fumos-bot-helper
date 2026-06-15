-- globals
ORIG_SCREEN_WIDTH = 900
ORIG_SCREEN_HEIGHT = 850

-- libs
class = require("lib.middleclass")
slab = require("lib.slab")

-- utils
local time_format_utils = require("utils.time_format_utils")

-- classes
local Timer = require("classes.timer")

-- other requires
local data = require("data")

-- consts
local WINDOW_PARAMS = {
    W = ORIG_SCREEN_WIDTH,
    H = ORIG_SCREEN_HEIGHT,
    AutoSizeWindow = false,
    AutoSizeWindowW = false,
    AutoSizeWindowH = false,
    AllowResize = false,
    Border = 0,
    Rounding = 0,
    X = 49,
    Y = 19,
    ConstrainPosition = true,
}

-- assets
local alttp_font_gui = love.graphics.newFont("fonts/RetGanon.ttf", 26)
local alttp_font_other = love.graphics.newFont("fonts/RetGanon.ttf", 30)

-- variables
local status_message = ""
local pet_message = "-"
local adventure_message = "-"

local sound_adventure_finish = love.audio.newSource("sounds/adventure.ogg", "static")
local sound_pet_finish = love.audio.newSource("sounds/pet.ogg", "static")

local sound_test_wait = 2
local sound_test_enabled = false
local sound_test_index = 0
local sound_test_table = {sound_adventure_finish, sound_pet_finish}

-- instances
local timer_adventure = Timer(0, function()
    
    adventure_message = "adventure finished!!"
    sound_adventure_finish:play()
    
end)

local timer_petting = Timer(0, function()

    pet_message = "pet finished!!"
    sound_pet_finish:play()
    
end)

local timer_sound_test = Timer(sound_test_wait, function(self)

    if (not sound_test_enabled) then return end

    local sfx = sound_test_table[sound_test_index]
    if (not sfx) then 

        sound_test_enabled = false
        self:pause()
        return

    end

    sfx:play()
    self:set_time(sound_test_wait)
    sound_test_index = sound_test_index + 1
    
end)

local function update_timers(dt)

    timer_adventure:update(dt)
    timer_petting:update(dt)
    timer_sound_test:update(dt)
    
end

local function do_gui()

    slab.PushFont(alttp_font_gui)

    local SECTION_BUTTON_PARAMS = {W = 400, H = 30, Color = {0.9, 0.9, 0.9, 1}, Disabled = true}
    local NORMAL_BUTTON_PARAMS = {W = 400, H = 50}

    local TEXT_TIMER_ADVENTURE = "adventure timer: " .. timer_adventure:format()
    local TEXT_TIMER_PETTING = "petting timer: " .. timer_petting:format()

    ---@type AdventureType
    local selected_adventure

    slab.BeginWindow("MyFirstWindow", WINDOW_PARAMS)
	slab.Button("adventures:", SECTION_BUTTON_PARAMS)

    for _, Adventure in ipairs(data.ADVENTURES) do
        
        local button_text = string.format("%s > Lv %d < %s", Adventure.title, Adventure.level, time_format_utils.format_seconds(Adventure.duration))
        if slab.Button(button_text, NORMAL_BUTTON_PARAMS) and timer_adventure.paused then
            
            love.system.setClipboardText(Adventure.command)
            selected_adventure = Adventure
            status_message = "copied adventure command to your clipboard"
            adventure_message = "adventure not finished"

        end

    end

    slab.Separator()
    slab.Button("petting:", SECTION_BUTTON_PARAMS)
    if slab.Button("start pet timer", NORMAL_BUTTON_PARAMS) and timer_petting.paused then
        
        love.system.setClipboardText(data.PET_COMMAND)
        timer_petting:set_time(data.PET_TIME + data.TIMER_ADD_TIME)
        timer_petting:unpause()

        status_message = "copied pet command to your clipboard"
        pet_message = "pet not finished"

    end

    slab.Separator()
    slab.Button("timer control:", SECTION_BUTTON_PARAMS)

    if slab.Button("stop adventure", NORMAL_BUTTON_PARAMS) then
        
        timer_adventure:set_time(0)
        timer_adventure:pause()

        status_message = "stopped adventure timer"
        adventure_message = "-"

    end

    if slab.Button("stop petting", NORMAL_BUTTON_PARAMS) then
        
        timer_petting:set_time(0)
        timer_petting:pause()

        status_message = "stopped pet timer"
        pet_message = "-"

    end

    slab.Separator()
    slab.Button("info:", SECTION_BUTTON_PARAMS)
    slab.Button(TEXT_TIMER_ADVENTURE, SECTION_BUTTON_PARAMS)
    slab.Button(TEXT_TIMER_PETTING, SECTION_BUTTON_PARAMS)
    slab.Button(adventure_message, SECTION_BUTTON_PARAMS)
    slab.Button(pet_message, SECTION_BUTTON_PARAMS)

    slab.Separator()
    slab.Button(status_message, SECTION_BUTTON_PARAMS)

	slab.EndWindow()

    if (selected_adventure) then
        
        timer_adventure:set_time(selected_adventure.duration + data.TIMER_ADD_TIME)
        timer_adventure:unpause()

    end

    slab.PopFont()
    
end

function love.keypressed(key)

    if (key ~= "f1") then return end
    if (sound_test_enabled) then return end
    print("snd test")

    sound_test_index = 1
    sound_test_enabled = true

    timer_sound_test:set_time(0.1)
    timer_sound_test:unpause()

end

function love.load()

    love.window.setIcon(love.image.newImageData("icon.png"))
    love.window.setTitle("Collect Fumos! bot helper v0")

    timer_adventure:pause()
    timer_petting:pause()
    
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.window.setMode(ORIG_SCREEN_WIDTH, ORIG_SCREEN_HEIGHT)
    slab.Initialize()

end

function love.update(dt)

    slab.Update(dt)
    update_timers(dt)
    do_gui()

end

function love.draw()

    slab.Draw()
    
    love.graphics.setColor(1, 1, 1, 1)
    local font = alttp_font_other

    local str_snd_test = "press F1 for sound test"
    local str_copyright = "program created by thewindcarriesmeaway"
    local str_copyright_b = "feel free to distribute and or modify"

    love.graphics.print(str_snd_test, ORIG_SCREEN_WIDTH - 220, 0)
    love.graphics.print(str_copyright, ORIG_SCREEN_WIDTH - 370, 35)
    love.graphics.print(str_copyright_b, ORIG_SCREEN_WIDTH - 330, 70)

end