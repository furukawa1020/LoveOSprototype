local TerminalApp = {}
local WM = require("src.kernel.wm")
local Scheduler = require("src.kernel.scheduler")

-- Reuse existing Terminal logic but redirect drawing to canvas
local Terminal = require("src.system.terminal")

function TerminalApp.run()
    -- Create Window
    local win = WM.createWindow(nil, "Terminal", 50, 50, 640, 480)
    
    -- Initialize Terminal Logic
    Terminal.init()
    
    while true do
        local dt = coroutine.yield()
        
        -- Update Terminal Logic
        Terminal.update(dt)
        
        -- Draw to Window Canvas
        love.graphics.setCanvas(win.canvas)
        love.graphics.clear(0, 0, 0, 1) -- Black background
        
        -- We need to modify Terminal.draw to NOT use fixed coordinates or use a transform
        -- Or we just draw it and let the canvas handle it
        -- Terminal.draw uses 10, 10 offset. That's fine for window content.
        
        Terminal.draw()
        
        love.graphics.setCanvas()
    end
end

return TerminalApp
