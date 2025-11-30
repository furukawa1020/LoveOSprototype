-- LöveOS Bootloader

local Kernel = require("src.kernel.core")
local Scheduler = require("src.kernel.scheduler")
-- We don't require apps here anymore, we spawn them by path

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Initialize Kernel
    Kernel.init()
    
    -- Spawn System Processes (True OS Style)
    local Process = require("src.kernel.process")
    
    -- Terminal (The Shell)
    Scheduler.add(Process.new("Terminal", "src/system/terminal.lua", true))
    
    -- Filer (File Manager)
    Scheduler.add(Process.new("Filer", "src/apps/filer.lua", true))
    
    -- Editor (Text Editor)
    Scheduler.add(Process.new("Love Edit", "src/apps/editor.lua", true))
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
