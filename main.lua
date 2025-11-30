-- LöveOS Bootloader

local Kernel = require("src.kernel.core")
local Scheduler = require("src.kernel.scheduler")
local TerminalApp = require("src.apps.terminal_app")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Initialize Kernel
    Kernel.init()
    
    -- Spawn Terminal App
    Scheduler.spawn("Terminal", TerminalApp.run)
end

function love.update(dt)
    Kernel.update(dt)
end

function love.draw()
    Kernel.draw()
end

function love.textinput(t)
    Kernel.textinput(t)
    -- Hack: Pass input to Terminal directly for now since Input routing isn't fully done
    local Terminal = require("src.system.terminal")
    Terminal.textinput(t)
end

function love.keypressed(key)
    Kernel.keypressed(key)
    -- Hack: Pass input to Terminal directly
    local Terminal = require("src.system.terminal")
    Terminal.keypressed(key)
end

function love.mousepressed(x, y, button)
    Kernel.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Kernel.mousereleased(x, y, button)
end
