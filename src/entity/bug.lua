local Bug = {}
local Assets = require("src.system.assets")

function Bug.new(x, y)
    local instance = {
        x = x * RPG.TILE_SIZE,
        y = y * RPG.TILE_SIZE,
        width = 32,
        height = 32,
        speed = 50,
        color = {1, 0, 0}, -- Red
        timer = 0,
        isDead = false
    }
    return instance
end

function Bug.update(bug, dt, player)
    if bug.isDead then return end
    
    -- Glitch effect
    bug.timer = bug.timer + dt
    if bug.timer > 0.1 then
        bug.timer = 0
        bug.color = {math.random(), 0, math.random()} -- Random glitch color
        bug.x = bug.x + (math.random() * 4 - 2) -- Jitter
        bug.y = bug.y + (math.random() * 4 - 2)
    end
    
    -- Chase Player
    local dx = player.x - bug.x
    local dy = player.y - bug.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist > 0 then
        bug.x = bug.x + (dx/dist) * bug.speed * dt
        bug.y = bug.y + (dy/dist) * bug.speed * dt
    end
    
    -- Collision with Player (Game Over check)
    if dist < 32 then
        if RPG.crash then
            RPG.crash()
        end
    end
end

function Bug.draw(bug)
    if bug.isDead then return end
    love.graphics.setColor(bug.color)
    love.graphics.rectangle("fill", bug.x, bug.y, bug.width, bug.height)
    love.graphics.setColor(1, 1, 1)
end

return Bug
