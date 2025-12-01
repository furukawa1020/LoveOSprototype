local Settings = {}

Settings.colors = {
    {name = "Midnight", color = {0.1, 0.1, 0.2}},
    {name = "Forest", color = {0.1, 0.2, 0.1}},
    {name = "Ocean", color = {0.1, 0.2, 0.4}},
    {name = "Sunset", color = {0.4, 0.2, 0.1}},
    {name = "Plum", color = {0.3, 0.1, 0.3}}
}

function Settings.run()
    local win = sys.createWindow("Control Panel", 200, 150, 400, 300)
    
    while true do
        local dt = coroutine.yield()
        
        sys.setCanvas(win.canvas)
        Settings.draw()
        sys.setCanvas()
    end
end

function Settings.draw()
    sys.graphics.clear(0.95, 0.95, 0.95, 1)
    
    sys.graphics.setColor(0, 0, 0)
    sys.graphics.print("Wallpaper Color:", 20, 20)
    
    local x, y = 20, 50
    for i, item in ipairs(Settings.colors) do
        sys.graphics.setColor(item.color)
        sys.graphics.rectangle("fill", x, y, 60, 40, 5)
        
        sys.graphics.setColor(0, 0, 0)
        sys.graphics.rectangle("line", x, y, 60, 40, 5)
        sys.graphics.print(item.name, x, y + 45)
        
        x = x + 80
        if x > 300 then
            x = 20
            y = y + 80
        end
    end
    
    sys.graphics.setColor(0, 0, 0)
    sys.graphics.print("System Info:", 20, 180)
    sys.graphics.print("LöveOS v0.1 (Proto)", 20, 200)
    sys.graphics.print("User: " .. (sys.user.current().name or "Unknown"), 20, 220)
end

function Settings.mousepressed(x, y, button)
    local sx, sy = 20, 50
    for i, item in ipairs(Settings.colors) do
        if x >= sx and x <= sx + 60 and y >= sy and y <= sy + 40 then
            -- Apply setting
            -- We need a syscall to set registry? 
            -- Or just IPC to a registry service?
            -- For now, let's assume we can access Registry via syscall or similar.
            -- Wait, we haven't exposed Registry via syscall.
            -- We should probably add sys.registry.set?
            -- Or just direct file write? No, sandboxed.
            -- Let's add sys.registry interface.
            if sys.registry then
                sys.registry.set("wallpaperColor", item.color)
                sys.notify("Settings", "Wallpaper changed to " .. item.name, "info")
            else
                sys.print("Error: Registry syscall not available")
            end
            return
        end
        
        sx = sx + 80
        if sx > 300 then
            sx = 20
            sy = sy + 80
        end
    end
end

return Settings
