local Syscall = {}
local Kernel = require("src.kernel.core")
local VFS = require("src.kernel.vfs")
local WM = require("src.kernel.wm")
local Scheduler = require("src.kernel.scheduler")
local Process = require("src.kernel.process")
local IPC = require("src.kernel.ipc")

-- The Syscall API exposed to User Space
-- Apps will see this as the global 'sys' table

function Syscall.createInterface(process)
    local interface = {}
    
    -- System
    function interface.print(text)
        print("[Process " .. process.name .. "]: " .. tostring(text))
    end
    
    function interface.exit()
        process.status = "dead"
    end
    
    function interface.spawn(name, func)
        -- Security check? For now allow spawning
        -- But wait, func is a function. In a real OS we spawn from file.
        -- For now, we support spawning functions (threads)
        local proc = Process.new(name, func)
        Scheduler.add(proc)
    end
    
    -- VFS
    function interface.read(path)
        return VFS.read(path)
    end
    
    function interface.write(path, content)
        return VFS.write(path, content)
    end
    
    function interface.listFiles(path)
        return VFS.listFiles(path)
    end
    
    function interface.mkdir(path)
        return VFS.mkdir(path)
    end
    
    -- Window Manager
    function interface.createWindow(title, x, y, w, h)
        return WM.createWindow(process, title, x, y, w, h)
    end
    
    function interface.setCanvas(canvas)
        -- This is tricky. User space has a canvas object?
        -- If we pass LÖVE objects to user space, they can call methods on them.
        -- Ideally we wrap them. For now, we allow it but it's a "leaky" sandbox.
        love.graphics.setCanvas(canvas)
    end
    
    -- Graphics (Wrapper around love.graphics)
    -- We need to expose drawing commands
    interface.graphics = {
        print = love.graphics.print,
        rectangle = love.graphics.rectangle,
        setColor = love.graphics.setColor,
        clear = love.graphics.clear,
        getFont = love.graphics.getFont,
        line = love.graphics.line,
        circle = love.graphics.circle,
        draw = love.graphics.draw,
        newCanvas = love.graphics.newCanvas, -- Leaky
        setCanvas = love.graphics.setCanvas, -- Leaky
        setScissor = love.graphics.setScissor
    }
    
    -- Input
    -- Input is event based, handled by handlers.
    
    -- IPC
    function interface.send(channel, message)
        IPC.send(channel, message)
    end
    
    function interface.subscribe(channel, callback)
        IPC.subscribe(channel, callback)
    end
    
    -- Process Management
    function interface.getProcesses()
        local list = {}
        for _, proc in ipairs(Scheduler.processes) do
            table.insert(list, {
                id = proc.id,
                name = proc.name,
                status = proc.status
            })
        end
        return list
    end
    
    function interface.getProcessInfo()
        return {
            id = process.id,
            name = process.name,
            status = process.status
        }
    end

    -- Time
    function interface.getTime()
        return love.timer.getTime()
    end
    
    function interface.getFPS()
        return love.timer.getFPS()
    end
    
    -- Audio
    interface.audio = {}
    function interface.audio.play(type)
        -- We need to access Audio module. 
        -- Since Syscall is in kernel, we can require it.
        local Audio = require("src.system.audio")
        Audio.playSynth(type)
    end
    
    return interface
end

return Syscall
