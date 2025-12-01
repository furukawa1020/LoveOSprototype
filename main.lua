-- LöveOS Bootloader

local Kernel = nil

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- BIOS / Bootloader Phase
    local Boot = require("src.boot.boot")
    Kernel = Boot.start()
    
    -- Spawn Login Process (Kernel should handle this, but for now we do it here or in Boot)
    local Process = require("src.kernel.process")
    local Scheduler = require("src.kernel.scheduler")
    Scheduler.add(Process.new("Chat Server", "src/system/chat_server.lua", true))
    Scheduler.add(Process.new("Login", "src/apps/login.lua", true))
end

function love.update(dt)
    if Kernel then Kernel.update(dt) end
end

function love.draw()
    if Kernel then Kernel.draw() end
end

function love.textinput(t)
    if Kernel then Kernel.textinput(t) end
end

function love.keypressed(key)
    if Kernel then Kernel.keypressed(key) end
end

function love.mousepressed(x, y, button)
    if Kernel then Kernel.mousepressed(x, y, button) end
end

function love.mousereleased(x, y, button)
    if Kernel then Kernel.mousereleased(x, y, button) end
end
