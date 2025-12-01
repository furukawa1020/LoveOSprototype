local Kernel = {}
local Scheduler = require("src.kernel.scheduler")
local WM = require("src.kernel.wm")
local VFS = require("src.kernel.vfs")
local Input = require("src.kernel.input")
local Process = require("src.kernel.process")

Kernel.panicData = nil

function Kernel.init()
    VFS.init()
    WM.init()
    local Users = require("src.kernel.users")
    Users.init()
    local Net = require("src.kernel.net")
    Net.init()
    local Disk = require("src.kernel.disk")
    Disk.init()
end

function Kernel.draw()
    if Kernel.panicData then
        -- BSOD
        love.graphics.clear(0, 0, 0.8) -- Blue
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(":(", 50, 50, 0, 5, 5)
        love.graphics.print("Your PC ran into a problem and needs to restart.", 50, 150, 0, 2, 2)
        love.graphics.print("Error Code: KERNEL_PANIC", 50, 200)
        love.graphics.print(tostring(Kernel.panicData), 50, 250)
        return
    end
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
    elseif moduleName == "src.kernel.vfs" then
        VFS = result
    end
    
    return true, "Reloaded " .. moduleName
end

Kernel.shutdownTimer = 0
Kernel.isShuttingDown = false

function Kernel.reboot()
    print("System Reboot Initiated...")
    Kernel.isShuttingDown = true
    Kernel.shutdownTimer = 1.0 -- Wait 1 second for sound
    local Audio = require("src.system.audio")
    Audio.playSynth("key")
end

function Kernel.update(dt)
    if Kernel.panicData then return end

    if Kernel.isShuttingDown then
        Kernel.shutdownTimer = Kernel.shutdownTimer - dt
        if Kernel.shutdownTimer <= 0 then
            love.event.quit("restart")
        end
        return
    end

    -- Protected Update
    local status, err = xpcall(function()
        Scheduler.update(dt)
        WM.update(dt)
        local Net = require("src.kernel.net")
        Net.update(dt)
    end, debug.traceback)
    
    if not status then
        Kernel.panic(err)
    end
end

function Kernel.panic(err)
    print("KERNEL PANIC: " .. tostring(err))
    Kernel.panicData = err
    -- Stop audio?
end

return Kernel
