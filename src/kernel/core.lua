local Kernel = {}
local Scheduler = require("src.kernel.scheduler")
local WM = require("src.kernel.wm")
local VFS = require("src.kernel.vfs")
local Input = require("src.kernel.input")

function Kernel.init()
    VFS.init()
    WM.init()
    
    -- Spawn initial processes
    -- Scheduler.spawn("Terminal", TerminalApp.run)
end

function Kernel.update(dt)
    Scheduler.update(dt)
    WM.update(dt)
end

function Kernel.draw()
    WM.draw()
end

function Kernel.textinput(t)
    Input.textinput(t)
    -- Also pass to focused window canvas if needed
    local canvas = WM.getTargetCanvas()
    if canvas then
        -- We can't easily "push" text input to a canvas without a process handling it
        -- The process needs to poll or receive events
    end
end

function Kernel.keypressed(key)
    Input.keypressed(key)
end

function Kernel.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function Kernel.mousereleased(x, y, button)
    Input.mousereleased(x, y, button)
end

return Kernel
