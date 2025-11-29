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

function MapState.enter()
    print("Entered Map State")
    Player.init(2, 2)
    Camera.set(0, 0)
    
    -- Initialize NPCs
    npcs = {}
    table.insert(npcs, NPC.new(5, 5, {"Hello, traveler!", "Welcome to Love2D RPG."}))
    table.insert(npcs, NPC.new(10, 8, {"I am a red box.", "Very exciting."}))
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
    for y = 0, MapData.height - 1 do
        for x = 0, MapData.width - 1 do
            local index = y * MapData.width + x + 1
            local tile = MapData.layers[1][index]
            
            if tile == 1 then
                love.graphics.setColor(0.5, 0.5, 0.5) -- Wall (Gray)
            else
                love.graphics.setColor(0.2, 0.2, 0.2) -- Floor (Dark Gray)
            end
            
            love.graphics.rectangle("fill", x * MapData.tilewidth, y * MapData.tileheight, MapData.tilewidth, MapData.tileheight)
        end
    end
    
    -- Draw NPCs
    for _, npc in ipairs(npcs) do
        NPC.draw(npc)
    end
    
    -- Draw Player
    Player.draw()
    
    Camera.detach()
    
    -- Draw UI
    if showDialog then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 10, RPG.HEIGHT - 50, RPG.WIDTH - 20, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 10, RPG.HEIGHT - 50, RPG.WIDTH - 20, 40)
        
        love.graphics.print(currentDialog[dialogIndex], 20, RPG.HEIGHT - 40)
    end
    
    -- Debug
    -- love.graphics.print("Map State", 10, 10)
end

function MapState.exit()
    print("Exited Map State")
end

return MapState
