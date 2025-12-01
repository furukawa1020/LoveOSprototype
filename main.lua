-- LöveOS Bootloader

local Kernel = require("src.kernel.core")
local Scheduler = require("src.kernel.scheduler")
-- We don't require apps here anymore, we spawn them by path

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Initialize Kernel
    Kernel.init()
    
    -- Spawn Login Process
    local Process = require("src.kernel.process")
    Scheduler.add(Process.new("Chat Server", "src/system/chat_server.lua", true))
    Scheduler.add(Process.new("Login", "src/apps/login.lua", true))
end

function love.update(dt)
    Kernel.update(dt)
end

function love.draw()
    Kernel.draw()
end

function love.textinput(t)
    Kernel.textinput(t)
end

function love.keypressed(key)
    Kernel.keypressed(key)
end

function love.mousepressed(x, y, button)
    Kernel.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Kernel.mousereleased(x, y, button)
end
