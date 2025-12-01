local Virus = {}

function Virus.run()
    local win = sys.createWindow("Virus", 300, 300, 300, 200)
    
    sys.setCanvas(win.canvas)
    sys.graphics.clear(1, 0, 0)
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.print("I AM A VIRUS", 100, 80)
    sys.graphics.print("Running infinite loop...", 80, 100)
    sys.setCanvas()
    
    local i = 0
    while true do
        -- Infinite loop WITHOUT yield
        -- This would freeze a cooperative OS
        i = i + 1
        local x = math.sin(i)
        
        -- Burn CPU
        for j=1, 1000 do
            x = x * j
        end
    end
end

return Virus
