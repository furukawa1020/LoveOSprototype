local Menu = {}

Menu.isOpen = false
Menu.items = {
    {name = "Terminal", icon = "terminal", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Terminal", "src/system/terminal.lua", true))
    end},
    {name = "Filer", icon = "folder", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Filer", "src/apps/filer.lua", true))
    end},
    {name = "Löve Edit", icon = "edit", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Löve Edit", "src/apps/editor.lua", true))
    end},
    {name = "Chat Client", icon = "chat", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Chat", "src/apps/chat.lua", true))
    end},
    {name = "Task Manager", icon = "task", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Task Manager", "src/apps/taskmgr.lua", true))
    end},
    {name = "Settings", icon = "settings", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Settings", "src/apps/settings.lua", true))
    end},
    {name = "Clock", icon = "clock", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Clock", "src/apps/clock.lua", true))
    end},
    {name = "Paint", icon = "edit", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Paint", "src/apps/paint.lua", true))
    end},
    {name = "Browser", icon = "web", action = function() 
        local Process = require("src.kernel.process")
        local Scheduler = require("src.kernel.scheduler")
        Scheduler.add(Process.new("Browser", "src/apps/browser.lua", true))
    end},
    {name = "Logout", icon = "logout", action = function() 
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
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", mx, my, w, h, 5)
    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("line", mx, my, w, h, 5)
    
    -- Items
    local iy = my + 5
    for i, item in ipairs(Menu.items) do
        -- Hover effect
        local mouseX, mouseY = love.mouse.getPosition()
        if mouseX >= mx and mouseX <= mx + w and mouseY >= iy and mouseY <= iy + 30 then
            love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            love.graphics.rectangle("fill", mx + 2, iy, w - 4, 28, 3)
        end
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(item.name, mx + 30, iy + 8)
        -- Icon placeholder
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.circle("fill", mx + 15, iy + 14, 5)
        
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
