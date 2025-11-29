-- Global Namespace
RPG = {}

-- Constants
RPG.WIDTH = 1280
RPG.HEIGHT = 720
RPG.SCALE = 1
RPG.TILE_SIZE = 64

-- Require core systems
require("src.system.util")
local Input = require("src.system.input")
local Assets = require("src.system.assets")

-- States
local TitleState = require("src.state.title")
local MapState = require("src.state.map")
local MenuState = require("src.state.menu")
local BattleState = require("src.state.battle")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Generate Assets
    Assets.generate()
    
    -- Initialize Audio
    local Audio = require("src.system.audio")
    Audio.init()
    
    -- Initialize State Machine
    RPG.states = {
        title = TitleState,
        map = MapState,
        menu = MenuState,
        battle = BattleState
    }
    
    RPG.currentState = nil
    RPG.switchState("title")
    
    -- Initialize Input
    Input.init()
    
    -- Canvas and Shader
    RPG.canvas = love.graphics.newCanvas(RPG.WIDTH, RPG.HEIGHT)
    RPG.shaders = {
        crt = require("src.system.shader").crt,
        dream = require("src.system.shader").dream,
        none = nil
    }
    RPG.currentShaderName = "none"
    RPG.shader = nil
    
    -- Love Tribute Particles
    RPG.loveParticles = love.graphics.newParticleSystem(Assets.textures.heart, 100)
    RPG.loveParticles:setParticleLifetime(1, 2)
    RPG.loveParticles:setLinearAcceleration(-50, -100, 50, -200) -- Float up
    RPG.loveParticles:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade out
    RPG.loveParticles:setSizes(2, 4, 0) -- Grow then shrink
    RPG.loveParticles:setEmissionRate(0)
end

function love.draw()
    -- Draw to Canvas
    love.graphics.setCanvas(RPG.canvas)
    love.graphics.clear()
    
    if RPG.currentState and RPG.currentState.draw then
        RPG.currentState.draw()
    end
    
    love.graphics.setCanvas()
    
    -- Draw Canvas with Shader
    love.graphics.setColor(1, 1, 1)
    if RPG.shader then
        love.graphics.setShader(RPG.shader)
        if RPG.currentShaderName == "dream" then
            RPG.shader:send("time", love.timer.getTime())
        end
    end
    love.graphics.draw(RPG.canvas, 0, 0)
    love.graphics.setShader()
    
    -- Draw Love Particles (Topmost)
    if RPG.loveParticles then
        love.graphics.draw(RPG.loveParticles, 0, 0)
    end
    
    -- Debug FPS
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Shader: " .. RPG.currentShaderName .. " (Tab to switch)", 10, 30)
end

function RPG.switchState(stateName, params)
    if RPG.states[stateName] then
        if RPG.currentState and RPG.currentState.exit then
            RPG.currentState.exit()
        end
        
        RPG.currentState = RPG.states[stateName]
        
        if RPG.currentState.enter then
            RPG.currentState.enter(params)
        end
    else
        print("Error: State " .. stateName .. " does not exist.")
    end
end

function love.keypressed(key)
    Input.keypressed(key)
end
