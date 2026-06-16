---@type {[string] : {default_path: string}}
local AUDIO_TABLE = {

    pet = {
        default_path = "sounds/pet.ogg",
    },
    adventure = {
        default_path = "sounds/adventure.ogg",
    },
    press = {
        default_path = "sounds/press.ogg",
    },
    set_timer = {
        default_path = "sounds/set_timer.ogg"
    },
    cancel_timer = {
        default_path = "sounds/cancel_timer.ogg"
    }

}

---@type {[string]: love.Source}
local loaded_sounds = {}
local sound_utils = {}

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

function sound_utils.reload_sfx()

    loaded_sounds = {}

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

        loaded_sounds[name] = source
 
    end
    
end

---@param name string
function sound_utils.play_sound(name)

    local sound = loaded_sounds[name]
    if (not sound) then
        
        print(string.format("cant play sound [%s], doesnt exist", name))
        return

    end
    sound:play()
    
end

---@return love.Source[]
function sound_utils.get_sounds_table()
    
    local t = {}
    for _, source in pairs(loaded_sounds) do
        
        table.insert(t, source)

    end

    return t

end

return sound_utils