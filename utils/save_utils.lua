local ENTRIES = {
    close_timestamp = "number",
    adventure = "number",
    pet = "number",
    pet_pause = "boolean",
    adventure_pause = "boolean",
    status_message_adventure = "string",
    status_message_pet = "string",
}

local TYPE_TO_DEFAULT = {
    number = 0,
    boolean = false,
    string = "-",
}

local save_utils = {}

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

return save_utils