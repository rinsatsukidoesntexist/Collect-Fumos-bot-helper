SCREEN_WIDTH, SCREEN_HEIGHT = 900, 850
WINDOW_TITLE = "Collect Fumos! bot helper v1.1"
ICON_PATH = "icon.png"

function love.conf(t)
    
    t.window.width = SCREEN_WIDTH
    t.window.height = SCREEN_HEIGHT
    t.window.title = WINDOW_TITLE
    t.window.icon = ICON_PATH
    t.window.borderless = false

end