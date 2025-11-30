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

return Kernel
