-- Love OS Main Entry Point

-- Constants
RPG = {} -- Keep global namespace for compatibility if needed later
RPG.WIDTH = 1280
RPG.HEIGHT = 720

local Terminal = require("src.system.terminal")
local Shader = require("src.system.shader")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Setup Font (Retro Monospace if possible, default for now)
    -- love.graphics.setFont(love.graphics.newFont("assets/font.ttf", 20)) 
    love.graphics.setFont(love.graphics.newFont(16))
    
    Terminal.init()
    
    -- Canvas for CRT effect
    RPG.canvas = love.graphics.newCanvas(RPG.WIDTH, RPG.HEIGHT)
    RPG.shader = Shader.crt
    RPG.shader:send("screen_size", {RPG.WIDTH, RPG.HEIGHT})
end

function love.update(dt)
    Terminal.update(dt)
end

function love.draw()
    -- Draw Terminal to Canvas
    love.graphics.setCanvas(RPG.canvas)
    love.graphics.clear(0, 0.05, 0, 1) -- Very dark green background
    
    Terminal.draw()
    
    love.graphics.setCanvas()
    
    -- Apply CRT Shader
    love.graphics.setColor(1, 1, 1)
    love.graphics.setShader(RPG.shader)
    love.graphics.draw(RPG.canvas, 0, 0)
    love.graphics.setShader()
end

function love.textinput(t)
    Terminal.textinput(t)
    local Audio = require("src.system.audio")
    Audio.playSynth("key")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    Terminal.keypressed(key)
    local Audio = require("src.system.audio")
    Audio.playSynth("key")
end
