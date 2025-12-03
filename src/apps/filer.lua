local Filer = {}

Filer.currentPath = "home"
Filer.items = {}
Filer.selectedIndex = 1
Filer.scrollOffset = 0

function Filer.init()
    Filer.refresh()
end

function Filer.refresh()
    Filer.items = sys.listFiles(Filer.currentPath)
    
    -- Add parent directory option if not root
    if Filer.currentPath ~= "" and Filer.currentPath ~= "home" then
        table.insert(Filer.items, 1, {name = "..", type = "directory", size = 0})
    end
    
    Filer.selectedIndex = 1
end

function Filer.update(dt)
    -- Handle scrolling?
end

function Filer.draw()
    -- Draw Header
    sys.graphics.setColor(0.8, 0.8, 0.8)
    sys.graphics.rectangle("fill", 0, 0, 500, 30)
    sys.graphics.setColor(0, 0, 0)
    sys.graphics.print("Path: /" .. Filer.currentPath, 10, 8)
    
    -- Draw Items
    local y = 40
    for i, item in ipairs(Filer.items) do
        if y > 330 then break end
        
        -- Selection Highlight
        if i == Filer.selectedIndex then
            sys.graphics.setColor(0.3, 0.3, 0.8, 0.3)
            sys.graphics.rectangle("fill", 5, y, 490, 20)
        end
        
        -- Icon
        sys.graphics.setColor(0, 0, 0)
        local icon = item.type == "directory" and "[DIR]" or "[FILE]"
        sys.graphics.print(icon, 10, y + 2)
        
        -- Name
        sys.graphics.print(item.name, 70, y + 2)
        
        -- Size
        if item.type == "file" then
            sys.graphics.print(item.size .. " B", 400, y + 2)
        end
        
        y = y + 22
    end
end

function Filer.mousepressed(x, y, button)
    -- Check clicks on items
    local ix = 10
    local iy = 40
    for i, item in ipairs(Filer.items) do
        if x >= ix - 5 and x <= ix + 85 and y >= iy - 5 and y <= iy + 65 then
            if Filer.selectedIndex == i then
                -- Double click
                if item.type == "directory" then
                    if item.name == ".." then
                        -- Go up
                        Filer.currentPath = Filer.currentPath:match("(.+)/[^/]+$") or ""
                        if Filer.currentPath == "" then Filer.currentPath = "home" end -- Prevent going above home for now
                    else
                        -- Enter directory
                        if Filer.currentPath == "" then
                            Filer.currentPath = item.name
                        else
                            Filer.currentPath = Filer.currentPath .. "/" .. item.name
                        end
                    end
                    Filer.refresh()
                    Filer.selectedIndex = 1
                else
                    -- Open file
                    if item.name:match("%.lua$") then
                        sys.spawn(item.name, Filer.currentPath .. "/" .. item.name)
                    else
                        sys.spawn("Editor", "src/apps/editor.lua") -- TODO: Pass file path
                    end
                end
            else
                Filer.selectedIndex = i
            end
            return
        end
        
        iy = iy + 22
    end
    
    Filer.selectedIndex = nil
end

function Filer.run()
    local win = sys.createWindow("Filer", 400, 100, 500, 350)
    
    Filer.init()
    
    while true do
        local dt = coroutine.yield()
        dt = dt or 0
        
        Filer.update(dt)
        
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0.9, 0.9, 0.9, 1)
        Filer.draw()
        sys.setCanvas()
    end
end

function Filer.keypressed(key)
    if key == "f5" then
        Filer.refresh()
    elseif key == "up" then
        if Filer.selectedIndex > 1 then Filer.selectedIndex = Filer.selectedIndex - 1 end
    elseif key == "down" then
        if Filer.selectedIndex < #Filer.items then Filer.selectedIndex = Filer.selectedIndex + 1 end
    elseif key == "return" then
        -- Enter/Open
        local item = Filer.items[Filer.selectedIndex]
        if item then
            if item.type == "directory" then
                if item.name == ".." then
                    Filer.currentPath = Filer.currentPath:match("(.+)/[^/]+$") or ""
                    if Filer.currentPath == "" then Filer.currentPath = "home" end
                else
                     if Filer.currentPath == "" then
                        Filer.currentPath = item.name
                    else
                        Filer.currentPath = Filer.currentPath .. "/" .. item.name
                    end
                end
                Filer.refresh()
                Filer.selectedIndex = 1
            else
                sys.print("Opening file: " .. item.name)
            end
        end
    end
end

return Filer
