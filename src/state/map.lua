local MapState = {}
local Input = require("src.system.input")
local Camera = require("src.system.camera")
local MapData = require("src.map.map1")
local Player = require("src.entity.player")
local NPC = require("src.entity.npc")

local npcs = {}
local showDialog = false
local currentDialog = {}
local dialogIndex = 1
local dialogTimer = 0

function MapState.enter(params)
    print("Entered Map State")
    if not params or not params.fromBattle then
        Player.init(2, 2)
        Camera.set(0, 0)
    end
    
    local Audio = require("src.system.audio")
    Audio.playBGM("field")
    
    -- Initialize NPCs
    npcs = {}
    table.insert(npcs, NPC.new(5, 5, {"Welcome to the Floating Isle.", "The void surrounds us all."}))
    table.insert(npcs, NPC.new(10, 8, {"Have you seen the Slimes?", "They are weak to Fire."}))
    table.insert(npcs, NPC.new(15, 12, {"The Demon Lord waits ahead.", "Prepare yourself."}))
    table.insert(npcs, NPC.new(8, 15, {"This world is built of pixels.", "64 by 64, to be exact."}))
end

function MapState.update(dt)
    if showDialog then
        if Input.wasPressed("return") then
            dialogIndex = dialogIndex + 1
            if dialogIndex > #currentDialog then
                showDialog = false
                dialogIndex = 1
            end
        end
    else
        Player.update(dt, MapData)
        Camera.follow(Player.x + Player.width/2, Player.y + Player.height/2)
        
        if Input.wasPressed("return") then
            -- Check for NPC interaction
            local targetX, targetY = Player.tileX, Player.tileY
            -- Simple check: assume facing direction based on last move or just check neighbors?
            -- For simplicity, let's check the tile in front of the player if we tracked direction,
            -- but we didn't track direction explicitly in Player.lua yet.
            -- Let's just check if any NPC is adjacent.
            
            for _, npc in ipairs(npcs) do
                local dx = math.abs(Player.tileX - npc.tileX)
                local dy = math.abs(Player.tileY - npc.tileY)
                if dx + dy == 1 then
                    currentDialog = npc.dialog
                    showDialog = true
                    dialogIndex = 1
                    break
                end
            end
            
            if not showDialog then
                 RPG.switchState("menu")
            end
        end
        
        -- Random Encounter Check (when arriving at a tile)
        if not Player.isMoving and Player.wasMoving then
             if math.random() < 0.1 then -- 10% chance per tile
                 RPG.switchState("battle")
             end
        end
        Player.wasMoving = Player.isMoving
    end
end

function MapState.draw()
    Camera.attach()
    
    -- Draw Map
    local Assets = require("src.system.assets")
    for y = 0, MapData.height - 1 do
        for x = 0, MapData.width - 1 do
            local index = y * MapData.width + x + 1
            local tile = MapData.layers[1][index]
            
            if tile == 1 then
                love.graphics.draw(Assets.textures.wall, x * MapData.tilewidth, y * MapData.tileheight)
            else
                love.graphics.draw(Assets.textures.grass, x * MapData.tilewidth, y * MapData.tileheight)
            end
        end
    end
    
    -- Draw NPCs
    for _, npc in ipairs(npcs) do
        love.graphics.print(currentDialog[dialogIndex], 100, RPG.HEIGHT - 150, 0, 2, 2)
    end
    
    -- Debug
    -- love.graphics.print("Map State", 10, 10)
end

function MapState.exit()
    print("Exited Map State")
end

return MapState
