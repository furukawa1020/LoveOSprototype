local Viewer = {}

Viewer.image = nil
Viewer.status = "No Image"

function Viewer.run()
    local win = sys.createWindow("Image Viewer", 150, 100, 600, 450)
    
    -- Try to load default image
    Viewer.loadImage("home/drawing.img")
    
    while true do
        local dt = coroutine.yield()
        
        sys.setCanvas(win.canvas)
        Viewer.draw()
        sys.setCanvas()
    end
end

function Viewer.loadImage(path)
    -- In a real OS, we'd use sys.fs.read or similar.
    -- For now, let's assume we can read the file we saved.
    -- But wait, we saved it as a custom format string in Paint.
    -- We need to parse it back.
    
    -- Mock implementation for now since we don't have full binary IO syscalls yet.
    -- We will just try to load a placeholder or check if file exists.
    
    -- Actually, let's use a simple trick.
    -- Paint saved to "home/drawing.img".
    -- We can't easily read it back into an Image without love.image.newImageData(fileData).
    -- And we don't have fileData exposed.
    
    -- Let's just display a message for now, or use a system icon as a placeholder.
    Viewer.status = "Viewing: " .. path
    -- Viewer.image = ...
end

function Viewer.draw()
    sys.graphics.clear(0.1, 0.1, 0.1, 1)
    
    -- Toolbar
    sys.graphics.setColor(0.2, 0.2, 0.2)
    sys.graphics.rectangle("fill", 0, 0, 600, 40)
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.print("Open", 10, 12)
    
    -- Image Area
    if Viewer.image then
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.draw(Viewer.image, 0, 40)
    else
        sys.graphics.setColor(0.5, 0.5, 0.5)
        sys.graphics.print(Viewer.status, 250, 200)
        sys.graphics.print("(Image loading not fully implemented in proto)", 180, 220)
    end
end

function Viewer.mousepressed(x, y, button)
    if y < 40 and x < 60 then
        -- Open dialog (mock)
        Viewer.status = "Open Dialog..."
    end
end

return Viewer
