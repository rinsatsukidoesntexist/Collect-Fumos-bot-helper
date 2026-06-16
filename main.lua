-- lib
class = require("lib.middleclass")
slab = require("lib.slab")

-- utils
local time_format_utils = require("utils.time_format_utils")
local color_utils = require("utils.color_utils")
local save_utils = require("utils.save_utils")
local sound_utils = require("utils.sound_utils")

-- classes
local Timer = require("classes.timer")

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

-- instances
local timer_pet = Timer(0)
local timer_adventure = Timer(0)
local timer_sound_test = Timer(0)

-- variables
local enable_debug_keybinds = true

local pet_finish_text = "-"
local adventure_finish_text = "-"
local status_text = ""

local sound_test_index = 0

local timers = {timer_pet, timer_adventure, timer_sound_test}

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

-- TODO: REDO SOUND TEST SHIT
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

---@param timer Timer
local function cancel_timer(timer)

    print("so lame! cancel!")
    timer:pause()
    timer:set_time(0)
    
end

---@param prefix string
---@return string?
local function get_file_with_prefix(prefix)

    local items = love.filesystem.getDirectoryItems("user_audio")
    for _, file_name in ipairs(items) do

        if (file_name:sub(1, #prefix) == prefix) then

            return "user_audio/" .. file_name

        end

    end

end

---@param path string
---@return love.Source?
local function attempt_load_source(path)
    
    local ok, source = pcall(function()
        
        return love.audio.newSource(path, "static")
    
    end)

    if (not ok) then
        
        print(string.format("failed to load audio source path [%s], %s", path, source))
        return nil

    end

    return source

end

local function reload_sfx()

    sounds = {}

    for name, entry in pairs(AUDIO_TABLE) do
        
        local source
        local user_defined_path = get_file_with_prefix(name)

        if (user_defined_path) then
            
            print("attempt to use user defined source for " .. name)
            source = attempt_load_source(user_defined_path)

        end

        if (not source) then
            
            print("use default for " .. name)
            source = love.audio.newSource(entry.default_path, "static")

        end

        sounds[name] = source
 
    end
    
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
    section("adventure timer: " .. timer_adventure:format())
    section("pet timer: " .. timer_pet:format())

    if (stop_adventure) then
        
        cancel_timer(timer_adventure)
        adventure_finish_text = "-"

        status_text = "interrupt adventure"

    end

    if (stop_pet) then
        
        cancel_timer(timer_pet)
        pet_finish_text = "-"
        
        status_text = "interrupt pet"

    end

    if (start_pet and timer_pet.paused) then
        
        pet_finish_text = "pet not finished"
        status_text = "copied pet command to clipboard"

        timer_pet:set_time(data.PET_TIME + data.TIMER_ADD_TIME)
        timer_pet:unpause()

        love.system.setClipboardText(data.PET_COMMAND)

    end

    if (selected_adventure and timer_adventure.paused) then
        
        adventure_finish_text = "on adventure: " .. selected_adventure.title
        status_text = "copied adventure command to clipboard"

        timer_adventure:set_time(selected_adventure.duration + data.TIMER_ADD_TIME)
        timer_adventure:unpause()

        love.system.setClipboardText(selected_adventure.command)

    end

    slab.PopFont()
    slab.EndWindow()
    
end

local function window_2()

    local do_sound_test = false
    local should_reload_sfx = false
    --local change_adv_sfx = false
    --local change_pet_sfx = false

    slab.BeginWindow("window_2", WINDOW_2_PARAMS)
    slab.PushFont(alttp_font_gui)

    section("other:")
    --change_adv_sfx = button("change adventure sound effect")
    --change_pet_sfx = button("change pet sound effect")
    should_reload_sfx = button("reload sound effects")
    do_sound_test = button("sound test")

    section(status_text)
    section("----------------------------------")
    section("program created by thewindcarriesmeaway")
    section("feel free to distribute and modify")
    section("version 1.1")

    if (do_sound_test and sound_test_index == 0) then
        
        timer_sound_test:set_time(0.1)
        timer_sound_test:unpause()

        status_text = "SOUND TEST BAYBEEEEEEE TURN UP DA VOLUME!!"

    end

    if (should_reload_sfx and sound_test_index == 0) then
        
        status_text = "attempt sfx reload"
        reload_sfx()

    end

    --[[
    if (change_adv_sfx) then
        
        status_text = "change adventure sfx"

    elseif (change_pet_sfx) then
        
        status_text = "change pet sfx"

    end
    ]]
    
    slab.PopFont()
    slab.EndWindow()
    
end

local function load_save()

    local saved_data = save_utils.get_save()
    local is_valid = save_utils.sanity_check_save(saved_data)
    if (not is_valid) then 
        
        status_text = "failed to load save"
        return
    
    end

    print("actually load save now")
    local current_time = os.time()
    local closed_at = saved_data.close_timestamp
    local delta = current_time - closed_at

    -- 0.01 is a small hack to make the timer timeout immediately when opening the app. if its 0 it doesn't check for timeout
    timer_pet.time = math.max(saved_data.pet - delta, 0.01)
    timer_adventure.time = math.max(saved_data.adventure - delta, 0.01)

    timer_pet.paused = saved_data.pet_pause
    timer_adventure.paused = saved_data.adventure_pause

    adventure_finish_text = saved_data.status_message_adventure
    pet_finish_text = saved_data.status_message_pet
    
end

function love.load()

    love.filesystem.mount(love.filesystem.getSaveDirectory(), "save")
    love.filesystem.createDirectory("user_audio")

    love.window.setIcon(love.image.newImageData("icon.png"))
    love.window.setTitle("Collect Fumos! bot helper v1.1")

    reload_sfx()

    love.graphics.setBackgroundColor(color_utils.unpack_color_rgb_255({r = 182, g = 143, b = 255, a = 255}))
    slab.Initialize()

    slab_style = slab.GetStyle()
    for entry, value in pairs(STYLE_PARAMS) do
        
        slab_style[entry] = value

    end

    cancel_timer(timer_pet)
    cancel_timer(timer_adventure)
    cancel_timer(timer_sound_test) 

    timer_pet.timeout_func = pet_timer_timeout
    timer_adventure.timeout_func = adventure_timer_timeout
    timer_sound_test.timeout_func = sound_test_timer_timeout

    load_save()
    
end

function love.quit()

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
        
        timer_adventure.time = 3

    end

    if (key == "2") then
        
        timer_pet.time = 3

    end
    
end

function love.update(dt)

    slab.Update(dt)
    for _, timer in ipairs(timers) do
        
        timer:update(dt)

    end

    window_1()
    window_2()

end

function love.draw()
    
    slab.Draw()
    
end