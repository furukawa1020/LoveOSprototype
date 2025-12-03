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
    
    function interface.spawn(name, pathOrFunc)
        local isPath = type(pathOrFunc) == "string"
        local proc = Process.new(name, pathOrFunc, isPath)
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
        local Audio = require("src.system.audio")
        Audio.playSynth(type)
    end
    
    function interface.audio.playTone(freq, duration)
        local Audio = require("src.system.audio")
        Audio.playTone(freq, duration)
    end
    
    function interface.audio.setVolume(vol)
        local Audio = require("src.system.audio")
        Audio.setVolume(vol)
    end
    
    -- Registry
    interface.registry = {}
    function interface.registry.get(key)
        local Registry = require("src.system.registry")
        return Registry.get(key)
    end
    
    function interface.registry.set(key, value)
        local Registry = require("src.system.registry")
        Registry.set(key, value)
    end
    
    -- User Management
    interface.user = {}
    function interface.user.login(username, password)
        local Users = require("src.kernel.users")
        return Users.authenticate(username, password)
    end
    
    function interface.user.current()
        local Users = require("src.kernel.users")
        local u = Users.getCurrentUser()
        if u then
            return {name = u.name, home = u.home, role = u.role}
        end
        return nil
    end
    
    function interface.user.create(username, password)
        local Users = require("src.kernel.users")
        -- Check if user exists? Users module should handle it.
        -- For now, just call addUser.
        -- In a real OS, this would require admin privileges or be restricted.
        -- Since this is the Login app (which runs as root essentially before login), it's fine.
        if Users.list[username] then
            return false, "User already exists"
        end
        Users.addUser(username, password, "home/" .. username, "user")
        return true
    end
    
    -- Network
    interface.net = {}
    function interface.net.socket()
        local Net = require("src.kernel.net")
        return Net.socket()
    end
    
    function interface.net.bind(id, port)
        local Net = require("src.kernel.net")
        return Net.bind(id, port)
    end
    
    function interface.net.listen(id)
        local Net = require("src.kernel.net")
        return Net.listen(id)
    end
    
    function interface.net.connect(id, addr, port)
        local Net = require("src.kernel.net")
        return Net.connect(id, addr, port)
    end
    
    function interface.net.accept(id)
        local Net = require("src.kernel.net")
        return Net.accept(id)
    end
    
    function interface.net.send(id, data)
        local Net = require("src.kernel.net")
        return Net.send(id, data)
    end
    
    function interface.net.recv(id)
        local Net = require("src.kernel.net")
        return Net.recv(id)
    end
    
    function interface.net.close(id)
        local Net = require("src.kernel.net")
        Net.close(id)
    end
    
    interface.net.http = {}
    function interface.net.http.request(url)
        local Net = require("src.kernel.net")
        return Net.http.request(url)
    end
    
    function interface.net.http.check(id)
        local Net = require("src.kernel.net")
        return Net.http.check(id)
    end
    
    -- Notifications
    function interface.notify(title, message, icon)
        local Notify = require("src.system.notify")
        Notify.push(title, message, icon)
    end
    
    return interface
end

return Syscall
