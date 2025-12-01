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
            sys.graphics.setColor(1, 1, 1, 0.2)
            sys.graphics.rectangle("fill", icon.x - 5, icon.y - 5, 70, 80, 5)
        end
        
        -- Icon
        sys.graphics.setColor(1, 1, 1)
        -- Placeholder icon rect
        sys.graphics.rectangle("line", icon.x + 10, icon.y, 40, 40, 5)
        sys.graphics.print(icon.icon, icon.x + 15, icon.y + 15) -- Text as icon for now
        
        -- Label
        sys.graphics.printf(icon.name, icon.x - 10, icon.y + 50, 80, "center")
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
    if icon.type == "dir" then
        -- We need to pass arguments to Filer?
        -- Currently Filer defaults to home.
        -- Let's spawn Filer and maybe IPC it to change dir?
        -- Or just spawn Filer.
        sys.spawn("Filer", "src/apps/filer.lua")
    elseif icon.type == "file" then
        sys.spawn("Löve Edit", "src/apps/editor.lua")
    end
end

return Desktop
