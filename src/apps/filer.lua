local Filer = {}
local VFS = require("src.kernel.vfs")
local WM = require("src.kernel.wm")

Filer.currentPath = "/"
Filer.items = {}
Filer.selectedItem = nil
Filer.scrollOffset = 0

function Filer.init()
    Filer.refresh()
end

function Filer.refresh()
    Filer.items = VFS.listFiles(Filer.currentPath)
    -- Sort: Directories first, then files
    table.sort(Filer.items, function(a, b)
        if a.type == b.type then
            return a.name < b.name
        else
            return a.type == "directory"
        end
    end)
end

function Filer.update(dt)
    -- Handle scrolling?
end

function Filer.draw()
    love.graphics.clear(1, 1, 1) -- White background
    
    -- Header (Path)
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", 0, 0, 640, 30)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Path: " .. Filer.currentPath, 10, 8)
    
    -- Items
    local y = 40
    local x = 10
    for i, item in ipairs(Filer.items) do
        -- Icon
        if item.type == "directory" then
            love.graphics.setColor(1, 0.8, 0.4) -- Folder color
            love.graphics.rectangle("fill", x, y, 40, 30)
        else
            love.graphics.setColor(0.8, 0.8, 0.8) -- File color
            love.graphics.rectangle("fill", x + 5, y, 30, 40)
        end
        
        -- Selection
        if Filer.selectedItem == i then
            love.graphics.setColor(0, 0, 1, 0.3)
            love.graphics.rectangle("fill", x - 5, y - 5, 90, 70)
        end
        
        -- Name
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(item.name, x - 5, y + 45, 90, "center")
        
        x = x + 100
        if x > 550 then
            x = 10
            y = y + 80
        end
    end
end

function Filer.mousepressed(x, y, button)
    -- Check clicks on items
    local ix = 10
    local iy = 40
    for i, item in ipairs(Filer.items) do
        if x >= ix - 5 and x <= ix + 85 and y >= iy - 5 and y <= iy + 65 then
            if Filer.selectedItem == i then
                -- Double click
                if item.type == "directory" then
                    if item.name == ".." then
                        -- Go up (naive implementation)
                        Filer.currentPath = "/" -- Reset to root for now
                    else
                        -- Enter directory (naive)
                        if Filer.currentPath == "/" then
                            Filer.currentPath = "/" .. item.name
                        else
                            Filer.currentPath = Filer.currentPath .. "/" .. item.name
                        end
                    end
                    Filer.refresh()
                    Filer.selectedItem = nil
                else
                    -- Open file
                    -- TODO: Launch Editor
                    print("Opening file: " .. item.name)
                end
            else
                Filer.selectedItem = i
            end
            return
        end
        
        ix = ix + 100
        if ix > 550 then
            ix = 10
            iy = iy + 80
        end
    end
    
    Filer.selectedItem = nil
end

function Filer.run()
    local WM = require("src.kernel.wm")
    local Scheduler = require("src.kernel.scheduler")
    -- Create Window
    local process = Scheduler.getCurrentProcess()
    local win = WM.createWindow(process, "Filer", 50, 50, 600, 400)
    
    Filer.init()
    
    while true do
        local dt = coroutine.yield()
        
        Filer.update(dt)
        
        love.graphics.setCanvas(win.canvas)
        Filer.draw()
        love.graphics.setCanvas()
    end
end

function Filer.keypressed(key)
    if key == "f5" then
        Filer.refresh()
    end
end

return Filer
