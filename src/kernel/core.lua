local Kernel = {}
local Scheduler = require("src.kernel.scheduler")
local WM = require("src.kernel.wm")
local VFS = require("src.kernel.vfs")
local Input = require("src.kernel.input")
local Process = require("src.kernel.process")

function Kernel.init()
    VFS.init()
    WM.init()
    
    -- Spawn System Apps
    local TerminalApp = require("src.apps.terminal_app")
    local FilerApp = require("src.apps.filer")
    local EditorApp = require("src.apps.editor")
    
    -- Terminal (Always running)
    -- Pass Terminal (system) as handler because TerminalApp is just a wrapper
    local Terminal = require("src.system.terminal")
    Scheduler.add(Process.new("Terminal", TerminalApp.run, Terminal))
    
    -- Filer (Windowed)
    Scheduler.add(Process.new("Filer", FilerApp.run, FilerApp))
    
    -- Editor (Windowed)
    Scheduler.add(Process.new("Löve Edit", EditorApp.run, EditorApp))
end

function Kernel.update(dt)
    Scheduler.update(dt)
    WM.update(dt)
end

function Kernel.draw()
    WM.draw()
end

function Kernel.textinput(t)
    Input.textinput(t)
end

function Kernel.keypressed(key)
    Input.keypressed(key)
end

function Kernel.mousepressed(x, y, button)
    Input.mousepressed(x, y, button)
end

function Kernel.mousereleased(x, y, button)
    Input.mousereleased(x, y, button)
end

function Kernel.reload(moduleName)
    if not package.loaded[moduleName] then
        return false, "Module not loaded"
    end
    
    print("Reloading module: " .. moduleName)
    
    -- Unload
    package.loaded[moduleName] = nil
    
    -- Reload
    local status, result = pcall(require, moduleName)
    
    if not status then
        print("Error reloading " .. moduleName .. ": " .. tostring(result))
        return false, result
    end
    
    -- Update references if needed
    if moduleName == "src.kernel.wm" then
        WM = result
        -- Re-init WM if needed? Or just swap functions?
        -- For hot-swapping logic, we usually want to keep state.
        -- But require returns a new table.
        -- Ideally we copy functions from new table to old table to preserve state.
        -- But for now, let's just swap the reference and hope state isn't lost (it will be lost if stored in locals).
        -- To preserve state, modules should return a stateful object or we use a proxy.
        -- Let's try a simple swap first.
    elseif moduleName == "src.kernel.vfs" then
        VFS = result
    end
    
    return true, "Reloaded " .. moduleName
end

return Kernel
