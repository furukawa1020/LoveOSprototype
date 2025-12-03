local TerminalApp = {}

-- Reuse existing Terminal logic but redirect drawing to canvas
local Terminal = require("src.system.terminal")

function TerminalApp.run()
    -- Create Window
    -- Use sys.createWindow which is injected into the environment
    local win = sys.createWindow("Terminal", 50, 50, 640, 480)
    
    -- Initialize Terminal Logic with system interface
    Terminal.init(sys)
    
    while true do
        local dt = coroutine.yield()
        dt = dt or 0
        
        -- Update Terminal Logic
        Terminal.update(dt)
        
        -- Draw to Window Canvas
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0, 0, 0, 1) -- Black background
        
        Terminal.draw()
        
        sys.setCanvas()
    end
end

function TerminalApp.keypressed(key)
    Terminal.keypressed(key)
end

function TerminalApp.textinput(t)
    Terminal.textinput(t)
end

return TerminalApp
