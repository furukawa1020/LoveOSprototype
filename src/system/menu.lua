local Menu = {}

Menu.isOpen = false
Menu.items = {
    {name = "Terminal", icon = "terminal", action = function() sys.spawn("Terminal", "src/system/terminal.lua") end},
    {name = "Filer", icon = "folder", action = function() sys.spawn("Filer", "src/apps/filer.lua") end},
    {name = "Löve Edit", icon = "edit", action = function() sys.spawn("Löve Edit", "src/apps/editor.lua") end},
    {name = "Chat Client", icon = "chat", action = function() sys.spawn("Chat", "src/apps/chat.lua") end},
    {name = "Task Manager", icon = "task", action = function() sys.spawn("Task Manager", "src/apps/taskmgr.lua") end},
    {name = "Logout", icon = "logout", action = function() 
        -- Reboot to login screen essentially
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        -- Kill all processes? Or just reboot kernel?
        -- For now, let's just spawn Login and let it handle things (maybe overlay)
        -- Ideally we should have a proper session teardown.
        -- Let's just reboot for simplicity.
        love.event.quit("restart")
    end},
    {name = "Shutdown", icon = "power", action = function() love.event.quit() end}
}

function Menu.toggle()
    Menu.isOpen = not Menu.isOpen
end

function Menu.draw(x, y)
    if not Menu.isOpen then return end
    
    local w, h = 200, #Menu.items * 30 + 10
    local mx, my = x, y - h
    
    -- Background
    sys.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    sys.graphics.rectangle("fill", mx, my, w, h, 5)
    sys.graphics.setColor(1, 1, 1, 0.2)
    sys.graphics.rectangle("line", mx, my, w, h, 5)
    
    -- Items
    local iy = my + 5
    for i, item in ipairs(Menu.items) do
        -- Hover effect (simple check, assuming mouse is available globally or passed)
        -- We need mouse coordinates here. WM should pass them or we use love.mouse (kernel space)
        local mouseX, mouseY = love.mouse.getPosition()
        if mouseX >= mx and mouseX <= mx + w and mouseY >= iy and mouseY <= iy + 30 then
            sys.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            sys.graphics.rectangle("fill", mx + 2, iy, w - 4, 28, 3)
        end
        
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print(item.name, mx + 30, iy + 8)
        -- Icon placeholder
        sys.graphics.setColor(0.5, 0.5, 0.5)
        sys.graphics.circle("fill", mx + 15, iy + 14, 5)
        
        iy = iy + 30
    end
end

function Menu.mousepressed(x, y, button)
    if not Menu.isOpen then return false end
    
    local w, h = 200, #Menu.items * 30 + 10
    local mx, my = 0, love.graphics.getHeight() - 40 - h -- Assuming taskbar at bottom
    
    if x >= mx and x <= mx + w and y >= my and y <= my + h then
        local index = math.floor((y - my - 5) / 30) + 1
        if index >= 1 and index <= #Menu.items then
            Menu.items[index].action()
            Menu.isOpen = false
        end
        return true -- Consumed
    end
    
    -- Click outside closes menu
    Menu.isOpen = false
    return false
end

return Menu
