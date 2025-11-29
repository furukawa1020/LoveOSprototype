local Player = {}
local Input = require("src.system.input")

Player.x = 0
Player.y = 0
Player.width = 64
Player.height = 64
Player.speed = 240 -- pixels per second
Player.tileX = 2
Player.tileY = 2

function Player.init(x, y)
    Player.tileX = x
    Player.tileY = y
    Player.x = x * RPG.TILE_SIZE
    Player.y = y * RPG.TILE_SIZE
    
    -- Movement state
    Player.isMoving = false
    Player.targetX = Player.x
    Player.targetY = Player.y
end

function Player.update(dt, map)
    if Player.isMoving then
        -- Move towards target
        local dx = Player.targetX - Player.x
        local dy = Player.targetY - Player.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < 1 then
            Player.x = Player.targetX
            Player.y = Player.targetY
            Player.isMoving = false
        else
            local moveDist = Player.speed * dt
            if moveDist > dist then moveDist = dist end
            
            Player.x = Player.x + (dx / dist) * moveDist
            Player.y = Player.y + (dy / dist) * moveDist
        end
    else
        -- Check input
        local nextTileX, nextTileY = Player.tileX, Player.tileY
        
        if Input.isDown("up") then
            nextTileY = nextTileY - 1
        elseif Input.isDown("down") then
            nextTileY = nextTileY + 1
        elseif Input.isDown("left") then
            nextTileX = nextTileX - 1
        elseif Input.isDown("right") then
            nextTileX = nextTileX + 1
        end
        
        if nextTileX ~= Player.tileX or nextTileY ~= Player.tileY then
            -- Check collision
            if not Player.checkCollision(nextTileX, nextTileY, map) then
                Player.tileX = nextTileX
                Player.tileY = nextTileY
                Player.targetX = nextTileX * RPG.TILE_SIZE
                Player.targetY = nextTileY * RPG.TILE_SIZE
                Player.isMoving = true
            end
        end
    end
end

function Player.checkCollision(tx, ty, map)
    -- Check map bounds
    if tx < 0 or tx >= map.width or ty < 0 or ty >= map.height then
        return true
    end
    
    -- Check tile collision
    local index = ty * map.width + tx + 1
    local tile = map.layers[1][index]
    
    return tile == 1 -- 1 is wall
end

function Player.draw()
    love.graphics.setColor(0, 1, 0) -- Green player
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)
    love.graphics.setColor(1, 1, 1)
end

return Player
