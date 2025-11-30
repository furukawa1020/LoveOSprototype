local WM = {}
local windows = {}
local focusedWindow = nil
local Scheduler = require("src.kernel.scheduler")
local Shader = require("src.system.shader")

WM.wallpaper = nil
WM.blurCanvas = nil -- Canvas for blurring background

function WM.init()
    -- Create a simple gradient wallpaper or load one
    WM.wallpaper = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setCanvas(WM.wallpaper)
    -- Dynamic "Löve" Wallpaper
    love.graphics.clear(0.1, 0.1, 0.2)
    -- Draw some abstract shapes
    for i = 1, 50 do
        love.graphics.setColor(math.random()*0.2, math.random()*0.2, math.random()*0.5, 0.5)
        love.graphics.circle("fill", math.random(0, 1280), math.random(0, 720), math.random(50, 200))
    end
    love.graphics.setCanvas()
    
    WM.blurCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function WM.createWindow(process, title, x, y, w, h)
    local win = {
        process = process,
        title = title or "Window",
        x = x or 100,
        y = y or 100,
        w = w or 640,
        h = h or 480,
        canvas = love.graphics.newCanvas(w or 640, h or 480),
        isDragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0
    }
    table.insert(windows, win)
    WM.focus(win)
    return win
end

function WM.focus(win)
    -- Move to end of list (render last = on top)
    for i, w in ipairs(windows) do
        if w == win then
            table.remove(windows, i)
            table.insert(windows, win)
            focusedWindow = win
            break
        end
    end
end

function WM.update(dt)
    -- Handle dragging
    if focusedWindow and focusedWindow.isDragging then
        local mx, my = love.mouse.getPosition()
        -- Capture screen behind window (simplified: just use wallpaper for now for speed)
        -- In a real compositor we'd copy the current screen buffer, but that's expensive in LÖVE without FBO swapping.
        -- We'll just draw a blurred rectangle of the wallpaper color for now to simulate it cheaply.
        
        -- Window Shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", win.x + 10, win.y + 10, win.w, win.h + 30, 10)
        
        -- Window Background (Glass)
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Send uniforms
        Shader.blur:send("screen_size", {love.graphics.getWidth(), love.graphics.getHeight()})
        
        love.graphics.setShader(Shader.blur)
        -- Draw the wallpaper section behind the window
        -- We need to scissor this so we don't draw the whole wallpaper
        love.graphics.setScissor(win.x, win.y - 30, win.w, win.h + 30)
        love.graphics.draw(WM.wallpaper, 0, 0) -- Draw wallpaper at 0,0 (it covers screen), scissor clips it
        love.graphics.setShader()
        love.graphics.setScissor()
        
        -- Tint it white for glass look
        love.graphics.setColor(0.9, 0.9, 0.95, 0.3)
        love.graphics.rectangle("fill", win.x, win.y - 30, win.w, win.h + 30, 8)
        
        -- Title Bar
        if win == focusedWindow then
            love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        end
        love.graphics.rectangle("fill", win.x, win.y - 30, win.w, 30, 8, 8)
        
        -- Title Text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(win.title, win.x + 10, win.y - 22)
        
        -- Window Content
        love.graphics.setColor(1, 1, 1)
        -- Clip content to window body
        love.graphics.setScissor(win.x, win.y, win.w, win.h)
        love.graphics.draw(win.canvas, win.x, win.y)
        love.graphics.setScissor()
        
        -- Border
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("line", win.x, win.y - 30, win.w, win.h + 30, 8)
    end
    
    -- 3. Taskbar (Dock)
    local screenH = love.graphics.getHeight()
    local screenW = love.graphics.getWidth()
    
    -- Bar Background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", 0, screenH - 40, screenW, 40)
    
    -- Start Button (Löve)
    love.graphics.setColor(1, 0.4, 0.6) -- Pink
    love.graphics.print("Löve", 10, screenH - 30)
    
    -- Running Tasks
    local x = 60
    for _, proc in ipairs(Scheduler.processes) do
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x, screenH - 35, 100, 30, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(proc.name, x + 10, screenH - 28)
        x = x + 110
    end
    
    -- Clock
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(os.date("%H:%M"), screenW - 50, screenH - 28)
end

function WM.mousepressed(x, y, button)
    -- Check for clicks on windows (reverse order for top-most first)
    for i = #windows, 1, -1 do
        local win = windows[i]
        -- Title bar click
        if x >= win.x and x <= win.x + win.w and y >= win.y - 25 and y <= win.y then
            WM.focus(win)
            win.isDragging = true
            win.dragOffsetX = x - win.x
            win.dragOffsetY = y - win.y
            return true
        end
        -- Content click
        if x >= win.x and x <= win.x + win.w and y >= win.y and y <= win.y + win.h then
            WM.focus(win)
            -- Pass event to process?
            return true
        end
    end
    return false
end

function WM.mousereleased(x, y, button)
    if focusedWindow then
        focusedWindow.isDragging = false
    end
end

function WM.getTargetCanvas()
    if focusedWindow then return focusedWindow.canvas end
    return nil
end

function WM.getFocusedWindow()
    return focusedWindow
end

return WM
