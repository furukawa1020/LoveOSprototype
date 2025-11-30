local WM = {}
local windows = {}
local focusedWindow = nil

WM.wallpaper = nil

function WM.init()
    -- Create a simple gradient wallpaper or load one
    WM.wallpaper = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setCanvas(WM.wallpaper)
    -- Retro grid background
    love.graphics.clear(0.1, 0.1, 0.2)
    love.graphics.setColor(0.2, 0.2, 0.3)
    local w, h = love.graphics.getDimensions()
    for x = 0, w, 40 do love.graphics.line(x, 0, x, h) end
    for y = 0, h, 40 do love.graphics.line(0, y, w, y) end
    love.graphics.setCanvas()
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
        focusedWindow.x = mx - focusedWindow.dragOffsetX
        focusedWindow.y = my - focusedWindow.dragOffsetY
    end
end

function WM.draw()
    -- Draw Wallpaper
    love.graphics.setColor(1, 1, 1)
    if WM.wallpaper then love.graphics.draw(WM.wallpaper, 0, 0) end
    
    -- Draw Windows
    for _, win in ipairs(windows) do
        -- Shadow
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", win.x + 5, win.y + 5, win.w, win.h + 25)
        
        -- Window Frame
        if win == focusedWindow then
            love.graphics.setColor(0.8, 0.8, 0.9) -- Active
        else
            love.graphics.setColor(0.5, 0.5, 0.6) -- Inactive
        end
        love.graphics.rectangle("fill", win.x, win.y - 25, win.w, 25) -- Title bar
        
        -- Title
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(win.title, win.x + 5, win.y - 20)
        
        -- Content
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(win.canvas, win.x, win.y)
        
        -- Border
        love.graphics.setColor(0.8, 0.8, 0.9)
        love.graphics.rectangle("line", win.x, win.y, win.w, win.h)
    end
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

return WM
