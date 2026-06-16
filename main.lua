-- lib
class = require("lib.middleclass")
slab = require("lib.slab")

-- utils
local time_format_utils = require("utils.time_format_utils")
local color_utils = require("utils.color_utils")
local save_utils = require("utils.save_utils")
local sound_utils = require("utils.sound_utils")
local timer_utils = require("utils.timer_utils")

-- other requires
local data = require("data")

-- assets
local alttp_font_gui = love.graphics.newFont("fonts/RetGanon.ttf", 26)

---@type love.Source
local sound_adventure_finish
---@type love.Source
local sound_pet_finish
---@type love.Source
local sound_press
---@type love.Source
local sound_set_timer
---@type love.Source
local sound_cancel_timer

-- variables
local enable_debug_keybinds = true

local pet_finish_text = "-"
local adventure_finish_text = "-"
local status_text = ""

-- constants
local LABEL_TEXT_COLOR = {color_utils.unpack_color_rgb_255({r = 255, g = 255, b = 255, a = 255})}
local LABEL_WIDTH = 450

local BUTTON_HEIGHT = 50
local BUTTON_COLOR = {color_utils.unpack_color_rgb_255({r = 139, g = 104, b = 227, a = 255})}
local BUTTON_HOVER_COLOR = {color_utils.unpack_color_rgb_255({r = 104, g = 122, b = 227, a = 255})}
local BUTTON_PRESS_COLOR = {color_utils.unpack_color_rgb_255({r = 230, g = 122, b = 219, a = 255})}

local SECTION_HEIGHT = 30
local SECTION_COLOR = {color_utils.unpack_color_rgb_255({r = 238, g = 143, b = 255, a = 255})}

local BUTTON_PARAMS = {
    
    W = LABEL_WIDTH,
    H = BUTTON_HEIGHT,
    Color = BUTTON_COLOR,
    HoverColor = BUTTON_HOVER_COLOR,
    PressColor = BUTTON_PRESS_COLOR,

}

local SECTION_PARAMS = {

    W = LABEL_WIDTH,
    H = SECTION_HEIGHT,
    Color = SECTION_COLOR,
    Disabled = true

}

local WINDOW_1_PARAMS = {

    W = LABEL_WIDTH,
    H = SCREEN_HEIGHT,

    AutoSizeWindow = false,
    AutoSizeWindowW = false,
    AutoSizeWindowH = false,
    AllowResize = false,
    AutoSizeContent = false,

    Border = 0,
    Rounding = 0,

    X = -3,
    Y = 0,

    ConstrainPosition = true,
    CanObstruct = false,

}

local WINDOW_2_PARAMS = {

    W = LABEL_WIDTH,
    H = SCREEN_HEIGHT,

    AutoSizeWindow = false,
    AutoSizeWindowW = false,
    AutoSizeWindowH = false,
    AllowResize = false,
    AutoSizeContent = false,

    Border = 0,
    Rounding = 0,

    X = LABEL_WIDTH,
    Y = 0,

    ConstrainPosition = true,
    CanObstruct = false,

}

local STYLE_PARAMS = {

    WindowBackgroundColor = {color_utils.unpack_color_rgb_255({r = 182, g = 143, b = 255, a = 255})},
    TextColor = LABEL_TEXT_COLOR,
    ButtonDisabledTextColor = LABEL_TEXT_COLOR,

}

---@param text string
local function section(text)
    
    return slab.Button(text, SECTION_PARAMS)
    
end

---@param text string
local function button(text)

    local state = slab.Button(text, BUTTON_PARAMS)
    if (state) then

        sound_utils.play_sound("press")

    end
    
    return state

end

local function window_1()

    ---@type AdventureType
    local selected_adventure
    local start_pet = false

    local stop_adventure = false
    local stop_pet = false

    slab.PushFont(alttp_font_gui)
    slab.BeginWindow("window_1", WINDOW_1_PARAMS)

    section("adventures:")
    for _, adventure in ipairs(data.ADVENTURES) do

        local button_text = string.format("%s > Lv %d < %s", adventure.title, adventure.level, time_format_utils.format_seconds(adventure.duration))
        if (button(button_text)) then
            
            selected_adventure = adventure

        end

    end

    stop_adventure = button("[stop adventure timer]")

    section("petting:")
    start_pet = button("> start pet timer <")
    stop_pet = button("[stop pet timer]")

    section("status:")
    section(adventure_finish_text)
    section(pet_finish_text)
    section("timers:")
    section("adventure timer: " .. timer_utils.format("adventure"))
    section("pet timer: " .. timer_utils.format("pet"))

    if (stop_adventure) then
        
        timer_utils.cancel_timer("adventure")
        adventure_finish_text = "-"

        status_text = "interrupt adventure"

    end

    if (stop_pet) then
        
        timer_utils.cancel_timer("pet")
        pet_finish_text = "-"
        
        status_text = "interrupt pet"

    end

    if (start_pet and timer_utils.is_paused("pet")) then
        
        pet_finish_text = "pet not finished"
        status_text = "copied pet command to clipboard"

        timer_utils.set_time("pet", data.PET_TIME + data.TIMER_ADD_TIME)
        timer_utils.unpause("pet")

        love.system.setClipboardText(data.PET_COMMAND)

    end

    if (selected_adventure and timer_utils.is_paused("adventure")) then
        
        adventure_finish_text = "on adventure: " .. selected_adventure.title
        status_text = "copied adventure command to clipboard"

        timer_utils.set_time("adventure", selected_adventure.duration + data.TIMER_ADD_TIME)
        timer_utils.unpause("adventure")

        love.system.setClipboardText(selected_adventure.command)

    end

    slab.PopFont()
    slab.EndWindow()
    
end

local function window_2()

    local do_sound_test = false
    local should_reload_sfx = false

    slab.BeginWindow("window_2", WINDOW_2_PARAMS)
    slab.PushFont(alttp_font_gui)

    section("other:")
    should_reload_sfx = button("reload sound effects")
    do_sound_test = button("sound test")

    section(status_text)
    section("----------------------------------")
    section("program created by thewindcarriesmeaway")
    section("feel free to distribute and modify")
    section("version 1.1")

    -- TODO: TRIGGER SOUND TEST
    if (do_sound_test) then

        status_text = "SOUND TEST BAYBEEEEEEE TURN UP DA VOLUME!!"

    end

    if (should_reload_sfx) then
        
        status_text = "attempt sfx reload"
        sound_utils.reload_sfx()

    end
    
    slab.PopFont()
    slab.EndWindow()
    
end

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

    love.filesystem.mount(love.filesystem.getSaveDirectory(), "save")
    love.filesystem.createDirectory("user_audio")

    love.window.setIcon(love.image.newImageData("icon.png"))
    love.window.setTitle("Collect Fumos! bot helper v1.1")

    sound_utils.reload_sfx()

    love.graphics.setBackgroundColor(color_utils.unpack_color_rgb_255({r = 182, g = 143, b = 255, a = 255}))
    slab.Initialize()

    slab_style = slab.GetStyle()
    for entry, value in pairs(STYLE_PARAMS) do
        
        slab_style[entry] = value

    end

    timer_utils.init_timers()

    --[[
    cancel_timer(timer_pet)
    cancel_timer(timer_adventure)
    cancel_timer(timer_sound_test) 

    timer_pet.timeout_func = pet_timer_timeout
    timer_adventure.timeout_func = adventure_timer_timeout
    timer_sound_test.timeout_func = sound_test_timer_timeout

    load_save()
    ]]
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

function love.update(dt)

    slab.Update(dt)
    timer_utils.update_timers(dt)

    window_1()
    window_2()

end

function love.draw()
    
    slab.Draw()
    
end