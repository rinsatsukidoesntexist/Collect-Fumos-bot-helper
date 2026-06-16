-- not very good but should do for now
local global_state = require("global_state")

local random_image_utils = {}

local function remove_equal_items(array_a, array_b)

    local result = {}

    local dict_a = {}
    local dict_b = {}

    for _, v in ipairs(array_a) do
        
        dict_a[v] = true

    end

    for _, v in ipairs(array_b) do

        if (not dict_a[v]) then
            
            table.insert(result, v)

        end

    end

    return result
    
end

local function get_random_path()
    
    local items = love.filesystem.getDirectoryItems("images/random")

    if (#global_state.seen_images == #items) then
        
        local last = global_state.seen_images[#global_state.seen_images]
        global_state.seen_images = {}

        if (last) then
            
            -- a tiny amount of pattern fuckery to remove the full path. lol!!
            table.insert(global_state.seen_images, last:match("([^/]+)$"))

        end

    end

    local new_items = remove_equal_items(global_state.seen_images, items)
    local index = love.math.random(1, #new_items)
    table.insert(global_state.seen_images, new_items[index])

    return "images/random/" .. new_items[index]
    
end

function random_image_utils.pick_one()

    return get_random_path()
    
end

return random_image_utils