local ENTRIES = {
    close_timestamp = "number",
    adventure = "number",
    pet = "number",
    pet_pause = "boolean",
    adventure_pause = "boolean",
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
            
            print(string.format("[%s] is not a valid entry, discard this", entry))
            return false

        end

        local expected_type = ENTRIES[entry]
        if (type(value) ~= expected_type) then
            
            print(string.format("[%s] has an invalid type, expected [%s], got [%s]", entry, expected_type, type(value)))
            return false

        end

    end

    for entry, _ in pairs(ENTRIES) do
        
        if (type(save[entry]) == "nil") then
            
            print(string.format("field [%s] is missing", entry))
            return false

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