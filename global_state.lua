local global_state = {}

global_state.pet_finish_text = "-"
global_state.adventure_finish_text = "-"

global_state.status_text = ""

global_state.borderless = false
global_state.random_image_path = ""

-- these two variables fucking stink
---@type love.Image
global_state.random_image = nil
global_state.seen_images = {}

return global_state