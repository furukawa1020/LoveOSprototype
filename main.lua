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
end

function love.update(dt)
    if RPG.currentState and RPG.currentState.update then
        RPG.currentState.update(dt)
    end
    Input.update()
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(RPG.SCALE, RPG.SCALE)
    
    if RPG.currentState and RPG.currentState.draw then
        RPG.currentState.draw()
    end
    
    love.graphics.pop()
    
    -- Debug FPS
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
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
