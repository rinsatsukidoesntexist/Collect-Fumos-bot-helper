---@alias ColorRgb255 {r: number, g: number, b: number, a: number}

local color_utils = {}

---@param color ColorRgb255
---@return number, number, number, number
function color_utils.unpack_color_rgb_255(color)

    return color.r/255, color.g/255, color.b/255, color.a/255
    
end


return color_utils