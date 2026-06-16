---@class Save
---@field close_timestamp number
---@field adventure number
---@field pet number
---@field adventure_pause boolean
---@field pet_pause boolean
---@field status_message_adventure string
---@field status_message_pet string
---@field borderless boolean
---@field seen_images table

local timer_utils = require("utils.timer_utils")

local global_state = require("global_state")

local SAVE_PHRASES = {

    "rin satsuki is watching you.",
    "rin satsuki sees you.",
    "she is here.",
    "8D E1 8C 8E 20 97 D9",

}

local ENTRIES = {

    close_timestamp = "number",
    adventure = "number",
    pet = "number",
    pet_pause = "boolean",
    adventure_pause = "boolean",
    status_message_adventure = "string",
    status_message_pet = "string",
    borderless = "boolean",
    seen_images = "table",

}

local TYPE_TO_DEFAULT = {

    number = 0,
    boolean = false,
    string = "-",
    table = {},

}

local save_utils = {}

function save_utils.write_save_file()

    local save = love.filesystem.newFile("save.lua")
    local close_timestamp = os.time()
    save:open("w")

    -- pointless stuff
    save:write("-- YES- the save files are stored in plain text. what's the issue?\n\n\n")
    for _ = 1, love.math.random(30, 70) do
        
        local phrase_index = love.math.random(1, #SAVE_PHRASES)
        save:write(string.format("-- %s\n", SAVE_PHRASES[phrase_index]))

    end

    local seen_images_str = ""
    for _, str in ipairs(global_state.seen_images) do
        
        seen_images_str = seen_images_str .. string.format("\"%s\",", str)

    end

    -- actual saving below
    save:write("local save = {}\n")

    save:write("save.close_timestamp = " .. close_timestamp .. "\n") -- why the fuck is format not working with close_timestamp??? fuck you lua

    save:write(string.format("save.adventure = %d\n", timer_utils.get_duration("adventure")))
    save:write(string.format("save.pet = %d\n", timer_utils.get_duration("pet")))

    save:write(string.format("save.adventure_pause = %s\n", tostring(timer_utils.is_paused("adventure"))))
    save:write(string.format("save.pet_pause = %s\n", tostring(timer_utils.is_paused("pet"))))

    save:write(string.format("save.status_message_adventure = \"%s\"\n", global_state.adventure_finish_text))
    save:write(string.format("save.status_message_pet = \"%s\"\n", global_state.pet_finish_text))
    save:write(string.format("save.seen_images = {%s}\n", seen_images_str))

    save:write(string.format("save.borderless = %s\n", tostring(global_state.borderless)))

    save:write("return save")

    save:close()

end

---@return Save?
function save_utils.get_save()

    local info = love.filesystem.getInfo("save.lua")
    if (not info) then return end

    print("found save")

    local contents, _ = love.filesystem.read("save.lua")
    if (not contents) then

        print(".read failed!")
        return
    
    end

    -- can luaLS stop yelling at me?
    local fun = load(contents)
    if (not fun) then
        
        print("loadstring failure")
        return

    end

    local ok, save_table = pcall(fun)
    if (not ok) then
        
        print("failed to load save: " .. save_table)
        return

    end

    return save_table

end

---@param save Save?
---@return boolean
-- returns false if the save is fucked, applies corrections if necessary
function save_utils.sanity_check_save(save)

    if (not save) then
        
        print("no save!")
        return false

    end

    for entry, value in pairs(save) do
        
        if (not ENTRIES[entry]) then
            
            -- discard invalid entries
            print(string.format("discard entry [%s]", entry))
            save[entry] = nil

        else

            local expected_type = ENTRIES[entry]
            if (type(value) ~= expected_type) then

                local default = TYPE_TO_DEFAULT[expected_type]

                -- set invalid types to defaults
                print(string.format("entry [%s] has invalid data type, expected [%s] got [%s]\nsetting to default [%s]", entry, expected_type, type(value), tostring(default)))
                save[entry] = default

            end

        end

    end

    for entry, type_str in pairs(ENTRIES) do
        
        if (type(save[entry]) == "nil") then
            
            local default = TYPE_TO_DEFAULT[type_str]
            print(string.format("field [%s] is missing, setting to default [%s]", entry, tostring(default)))

            save[entry] = default

        end

    end

    print("apply corrections")
    print("lets larp.... just this once........")
    save.adventure = math.max(save.adventure, 0)
    save.pet = math.max(save.pet, 0)

    if (save.close_timestamp > os.time()) then
        
        save.close_timestamp = os.time()

    end

    print("valid save, cool!")
    return true
    
end

function save_utils.load_save()

    local saved_data = save_utils.get_save()
    local is_valid = save_utils.sanity_check_save(saved_data)
    if (not is_valid or not saved_data) then 
        
        global_state.status_text = "failed to load save"
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

    global_state.adventure_finish_text = saved_data.status_message_adventure
    global_state.pet_finish_text = saved_data.status_message_pet
    global_state.borderless = saved_data.borderless
    global_state.seen_images = saved_data.seen_images

    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {borderless = global_state.borderless})
    
end

return save_utils