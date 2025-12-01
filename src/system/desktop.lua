local Desktop = {}

Desktop.icons = {
    {name = "My Computer", icon = "computer", path = "/", type = "dir", x = 20, y = 20},
    {name = "Home", icon = "home", path = "home", type = "dir", x = 20, y = 100},
    {name = "Trash", icon = "trash", path = "trash", type = "dir", x = 20, y = 180},
    {name = "Readme.txt", icon = "file", path = "readme.txt", type = "file", x = 100, y = 20}
}
Desktop.selected = nil
Desktop.lastClickTime = 0

function Desktop.draw()
    for i, icon in ipairs(Desktop.icons) do
        -- Selection
        if Desktop.selected == i then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.rectangle("fill", icon.x - 5, icon.y - 5, 70, 80, 5)
        end
        
        -- Icon
        love.graphics.setColor(1, 1, 1)
        -- Placeholder icon rect
        love.graphics.rectangle("line", icon.x + 10, icon.y, 40, 40, 5)
        love.graphics.print(icon.icon, icon.x + 15, icon.y + 15) -- Text as icon for now
        
        -- Label
        love.graphics.printf(icon.name, icon.x - 10, icon.y + 50, 80, "center")
    end
end

function Desktop.mousepressed(x, y, button)
    for i, icon in ipairs(Desktop.icons) do
        if x >= icon.x - 5 and x <= icon.x + 65 and y >= icon.y - 5 and y <= icon.y + 75 then
            if Desktop.selected == i then
                -- Double click check
                if love.timer.getTime() - Desktop.lastClickTime < 0.4 then
                    Desktop.open(icon)
                end
            else
                Desktop.selected = i
            end
            Desktop.lastClickTime = love.timer.getTime()
            return true
        end
    end
    Desktop.selected = nil
    return false
end

function Desktop.open(icon)
    local Process = require("src.kernel.process")
    local Scheduler = require("src.kernel.scheduler")
    
    if icon.type == "dir" then
        -- Spawn Filer
        Scheduler.add(Process.new("Filer", "src/apps/filer.lua", true))
    elseif icon.type == "file" then
        Scheduler.add(Process.new("Löve Edit", "src/apps/editor.lua", true))
    end
end

return Desktop
