local Input = {}
local WM = require("src.kernel.wm")

function Input.textinput(t)
    -- Dispatch to focused window's process?
    -- For now, we just let the process handle it if it has focus
    -- But WM needs to know which window has focus
    -- Ideally, we send an event to the process
end

function Input.keypressed(key)
    -- Global shortcuts?
    if key == "f1" then
        -- Open start menu?
    end
end

function Input.mousepressed(x, y, button)
    WM.mousepressed(x, y, button)
end

function Input.mousereleased(x, y, button)
    WM.mousereleased(x, y, button)
end

return Input
