local Assets = {}

Assets.textures = {}

function Assets.generate()
    -- Helper to create a texture from a function
    local function createTexture(width, height, func)
        local data = love.image.newImageData(width, height)
        for y = 0, height - 1 do
            for x = 0, width - 1 do
                local r, g, b, a = func(x, y)
                data:setPixel(x, y, r, g, b, a)
            end
        end
        return love.graphics.newImage(data)
    end

    -- Grass Tile (64x64)
    Assets.textures.grass = createTexture(64, 64, function(x, y)
        local noise = love.math.noise(x * 0.1, y * 0.1)
        return 0.1, 0.5 + noise * 0.2, 0.1, 1
    end)

    -- Wall Tile (64x64)
    Assets.textures.wall = createTexture(64, 64, function(x, y)
        -- Brick pattern
        local brickW, brickH = 16, 8
        local row = math.floor(y / brickH)
        local offset = (row % 2) * (brickW / 2)
        local col = math.floor((x + offset) / brickW)
        
        -- Mortar
        if (x + offset) % brickW == 0 or y % brickH == 0 then
            return 0.6, 0.6, 0.6, 1
        else
            -- Brick color with noise
            local noise = love.math.noise(x * 0.5, y * 0.5)
            return 0.6 + noise * 0.1, 0.3 + noise * 0.1, 0.2, 1
        end
    end)

    -- Player Sprite (64x64)
    Assets.textures.player = createTexture(64, 64, function(x, y)
        -- Simple character
        local cx, cy = 32, 32
        local dx, dy = x - cx, y - cy
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < 20 then
            -- Face
            if x > 36 and x < 40 and y > 24 and y < 28 then return 0, 0, 0, 1 end -- Eye
            if x > 24 and x < 28 and y > 24 and y < 28 then return 0, 0, 0, 1 end -- Eye
            return 0.2, 0.2, 0.8, 1 -- Blue Body
        elseif dist < 22 then
            return 0, 0, 0, 1 -- Outline
        else
            return 0, 0, 0, 0 -- Transparent
        end
    end)

    -- NPC Sprite (64x64)
    Assets.textures.npc = createTexture(64, 64, function(x, y)
        local cx, cy = 32, 32
        local dx, dy = x - cx, y - cy
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < 20 then
            return 0.8, 0.2, 0.2, 1 -- Red Body
        elseif dist < 22 then
            return 0, 0, 0, 1
        else
            return 0, 0, 0, 0
        end
    end)
    
    -- Slime Sprite (64x64)
    Assets.textures.slime = createTexture(64, 64, function(x, y)
        local cx, cy = 32, 40
        local dx, dy = x - cx, y - cy
        -- Blob shape
        if dy < 0 then dy = dy * 1.5 end
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < 25 then
            return 0.2, 0.8, 0.2, 1 -- Green Slime
        elseif dist < 27 then
            return 0, 0, 0, 1
        else
            return 0, 0, 0, 0
        end
    end)

    -- Heart Texture (8x8)
    local heartData = love.image.newImageData(8, 8)
    heartData:mapPixel(function(x, y)
        -- Simple 8x8 heart shape
        local heart = {
            {0,1,1,0,0,1,1,0},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {0,1,1,1,1,1,1,0},
            {0,0,1,1,1,1,0,0},
            {0,0,0,1,1,0,0,0},
            {0,0,0,0,0,0,0,0}
        }
        if heart[y+1] and heart[y+1][x+1] == 1 then
            return 1, 0.4, 0.7, 1 -- Pinkish Red
        end
        return 0, 0, 0, 0
    end)
    Assets.textures.heart = love.graphics.newImage(heartData)
end

return Assets
