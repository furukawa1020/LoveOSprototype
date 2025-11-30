local Input = {}
local WM = require("src.kernel.wm")

function Input.textinput(t)
    local win = WM.getFocusedWindow()
    if win and win.process and win.process.handler and win.process.handler.textinput then
        win.process.handler.textinput(t)
    end
end

function Input.keypressed(key)
    -- Global shortcuts
    if key == "f1" then
        -- Open start menu?
    end
    
    local win = WM.getFocusedWindow()
    if win and win.process and win.process.handler and win.process.handler.keypressed then
        win.process.handler.keypressed(key)
    end
end

function Input.mousepressed(x, y, button)
    -- WM handles window focus/drag first
    if WM.mousepressed(x, y, button) then return end
    
    -- If WM didn't consume it (e.g. click on content), pass to app?
    -- WM.mousepressed already returns true if it handled it (including content click)
    -- But WM doesn't pass it to the app logic yet.
    
    local win = WM.getFocusedWindow()
    if win and win.process and win.process.handler and win.process.handler.mousepressed then
        -- Transform coordinates to window space?
        -- For now pass global coords, app handles it (Filer does)
        win.process.handler.mousepressed(x, y, button)
    end
end

function Input.mousereleased(x, y, button)
    WM.mousereleased(x, y, button)
    -- Pass to app?
end

return Input
