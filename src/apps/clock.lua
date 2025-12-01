local Clock = {}

Clock.timer = 0
Clock.stopwatchRunning = false
Clock.stopwatchTime = 0

function Clock.run()
    local win = sys.createWindow("Clock", 500, 100, 250, 150)
    
    while true do
        local dt = coroutine.yield()
        Clock.update(dt)
        
        sys.setCanvas(win.canvas)
        Clock.draw()
        sys.setCanvas()
    end
end

function Clock.update(dt)
    if Clock.stopwatchRunning then
        Clock.stopwatchTime = Clock.stopwatchTime + dt
    end
end

function Clock.draw()
    sys.graphics.clear(0.1, 0.1, 0.1, 1)
    
    -- Digital Clock
    sys.graphics.setColor(0.2, 1, 0.2)
    local timeStr = os.date("%H:%M:%S")
    -- Scale text? We don't have font scaling syscall yet easily.
    -- Just print it.
    sys.graphics.print(timeStr, 80, 30, 0, 2, 2) -- x, y, r, sx, sy
    
    -- Date
    sys.graphics.setColor(0.7, 0.7, 0.7)
    sys.graphics.print(os.date("%Y-%m-%d"), 85, 60)
    
    -- Stopwatch
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.print(string.format("Stopwatch: %.1f", Clock.stopwatchTime), 20, 100)
    
    -- Button
    sys.graphics.setColor(0.3, 0.3, 0.3)
    sys.graphics.rectangle("fill", 150, 95, 80, 25)
    sys.graphics.setColor(1, 1, 1)
    local btnText = Clock.stopwatchRunning and "Stop" or "Start"
    sys.graphics.print(btnText, 170, 100)
end

function Clock.mousepressed(x, y, button)
    if x >= 150 and x <= 230 and y >= 95 and y <= 120 then
        Clock.stopwatchRunning = not Clock.stopwatchRunning
    end
end

return Clock
