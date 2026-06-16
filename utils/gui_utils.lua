-- requires
local global_state = require("global_state")
local data = require("data")

local color_utils = require("utils.color_utils")
local sound_utils = require("utils.sound_utils")
local timer_utils = require("utils.timer_utils")
local time_format_utils = require("utils.time_format_utils")
local sound_test_utils = require("utils.sound_test_utils")

-- assets
local alttp_font_gui = love.graphics.newFont("fonts/RetGanon.ttf", 26)

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

local gui_utils = {}

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

function gui_utils.do_window_1()

    ---@type AdventureType
    local selected_adventure
    local start_pet = false

    local stop_adventure = false
    local stop_pet = false

    slab.PushFont(alttp_font_gui)
    slab.BeginWindow("window_1", WINDOW_1_PARAMS)

    section("adventures:")
    for _, adventure in ipairs(data.adventures) do

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
    section(global_state.adventure_finish_text)
    section(global_state.pet_finish_text)
    section("timers:")
    section("adventure timer: " .. timer_utils.format("adventure"))
    section("pet timer: " .. timer_utils.format("pet"))

    if (stop_adventure) then
        
        timer_utils.cancel_timer("adventure")
        global_state.adventure_finish_text = "-"

        global_state.status_text = "interrupt adventure"

    end

    if (stop_pet) then
        
        timer_utils.cancel_timer("pet")
        global_state.pet_finish_text = "-"
        
        global_state.status_text = "interrupt pet"

    end

    if (start_pet and timer_utils.is_paused("pet")) then
        
        global_state.pet_finish_text = "pet not finished"
        global_state.status_text = "copied pet command to clipboard"

        timer_utils.set_time("pet", data.pet_time + data.timer_add_time)
        timer_utils.unpause("pet")

        love.system.setClipboardText(data.pet_command)

    end

    if (selected_adventure and timer_utils.is_paused("adventure")) then
        
        global_state.adventure_finish_text = "on adventure: " .. selected_adventure.title
        global_state.status_text = "copied adventure command to clipboard"

        timer_utils.set_time("adventure", selected_adventure.duration + data.timer_add_time)
        timer_utils.unpause("adventure")

        love.system.setClipboardText(selected_adventure.command)

    end

    slab.PopFont()
    slab.EndWindow()
    
end

function gui_utils.do_window_2()

    local image_w, image_h = global_state.random_image:getDimensions()

    local image_scale_x = (SCREEN_WIDTH / 2) / image_w
    local image_scale_y = 450 / image_h

    local do_sound_test = false
    local should_reload_sfx = false
    local borderless_toggle = false

    local sound_test_text = sound_test_utils.is_in_progress() and "sound test (busy)" or "sound test"

    slab.BeginWindow("window_2", WINDOW_2_PARAMS)
    slab.PushFont(alttp_font_gui)

    section("other:")
    should_reload_sfx = button("reload sound effects")
    do_sound_test = button(sound_test_text)
    borderless_toggle = button("toggle borderless")

    section(global_state.status_text)
    section("press ESC to quit")
    section("----------------------------------")
    section("program created by thewindcarriesmeaway")
    section("feel free to distribute and modify")
    section("version 1.1")

    slab.Image("random_image", {Path = global_state.random_image_path, ScaleX = image_scale_x, ScaleY = image_scale_y})

    if (do_sound_test and not sound_test_utils.is_in_progress()) then

        global_state.status_text = "SOUND TEST BAYBEEEEEEE TURN UP DA VOLUME!!"
        sound_test_utils.start_sound_test()
        timer_utils.set_time("sound_test", 0.01)
        timer_utils.unpause("sound_test")

    end

    if (should_reload_sfx) then
        
        global_state.status_text = "attempt sfx reload"
        sound_utils.reload_sfx()

    end

    if (borderless_toggle) then
        
        global_state.borderless = not global_state.borderless
        love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {borderless = global_state.borderless})

    end
    
    slab.PopFont()
    slab.EndWindow()
    
end

function gui_utils.init_visuals()

    love.graphics.setBackgroundColor(color_utils.unpack_color_rgb_255({r = 182, g = 143, b = 255, a = 255}))

    local slab_style = slab.GetStyle()
    for entry, value in pairs(STYLE_PARAMS) do
        
        slab_style[entry] = value

    end
    
end

return gui_utils