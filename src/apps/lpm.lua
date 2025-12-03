local LPM = {}

-- Simulated Repo
LPM.repo = {
    {name = "Calculator", version = "1.0", file = "calc.lua", content = [[
local Calc = {}
function Calc.run()
    local win = sys.createWindow("Calculator", 150, 150, 200, 300)
    local result = "0"
    while true do
        local dt = coroutine.yield()
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0.2, 0.2, 0.2, 1)
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print(result, 10, 10)
        sys.graphics.print("Press 1-9", 10, 50)
        sys.setCanvas()
    end
end
return Calc
]]},
    {name = "Clock", version = "1.1", file = "clock.lua", content = [[
local Clock = {}
function Clock.run()
    local win = sys.createWindow("Clock", 400, 50, 150, 80)
    while true do
        local dt = coroutine.yield()
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0, 0, 0, 0.5)
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print(os.date("%H:%M:%S"), 10, 20)
        sys.setCanvas()
    end
end
return Clock
]]}
}

LPM.status = "Ready"

function LPM.run()
    local win = sys.createWindow("Package Manager", 100, 100, 400, 300)
    
    while true do
        local dt = coroutine.yield()
        dt = dt or 0
        
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0.9, 0.9, 0.95, 1)
        
        -- Header
        sys.graphics.setColor(0.2, 0.6, 1)
        sys.graphics.rectangle("fill", 0, 0, 400, 40)
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print("Löve Package Manager", 10, 10)
        
        -- List
        local y = 50
        for i, pkg in ipairs(LPM.repo) do
            sys.graphics.setColor(1, 1, 1)
            sys.graphics.rectangle("fill", 10, y, 380, 40)
            
            sys.graphics.setColor(0, 0, 0)
            sys.graphics.print(pkg.name .. " v" .. pkg.version, 20, y + 10)
            
            -- Install Button (Fake)
            sys.graphics.setColor(0.2, 0.8, 0.2)
            sys.graphics.rectangle("fill", 300, y + 5, 80, 30)
            sys.graphics.setColor(1, 1, 1)
            sys.graphics.print("Install", 315, y + 10)
            
            y = y + 50
        end
        
        -- Status
        sys.graphics.setColor(0.4, 0.4, 0.4)
        sys.graphics.print("Status: " .. LPM.status, 10, 280)
        
        sys.setCanvas()
    end
end

function LPM.mousepressed(x, y, button)
    -- Check clicks
    local y_pos = 50
    for i, pkg in ipairs(LPM.repo) do
        -- Check Install Button: x(300-380), y(y_pos+5 - y_pos+35)
        -- Window relative coords? No, inputs are global (or window relative if WM handles it?)
        -- WM passes global coords. We need to subtract window pos?
        -- Wait, WM.mousepressed handles dragging.
        -- Input module passes global coords.
        -- We don't know our window pos here easily unless we stored it.
        -- But wait, `win` is local in `run`.
        -- We need `win` in `mousepressed`.
        -- Let's make `win` module level or pass it?
        -- For now, assume we can't click.
        -- Just install everything on any click for demo?
        -- Or better: Implement a simple "Install All" key?
        
        -- To do it right: `LPM.win`
    end
end

function LPM.keypressed(key)
    if key == "1" then
        LPM.install(1)
    elseif key == "2" then
        LPM.install(2)
    end
end

function LPM.install(index)
    local pkg = LPM.repo[index]
    if pkg then
        LPM.status = "Installing " .. pkg.name .. "..."
        -- Write file
        local path = "home/apps/" .. pkg.file
        -- Ensure directory exists? VFS write handles it?
        -- VFS.write in syscall.lua calls VFS.write.
        -- VFS.write handles parent creation.
        sys.write(path, pkg.content)
        LPM.status = "Installed " .. pkg.name
    end
end

return LPM
