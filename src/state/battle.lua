local BattleState = {}
local Input = require("src.system.input")

local playerStats = {hp = 100, maxHp = 100, mp = 20, maxMp = 20, atk = 10, def = 5}
local enemyStats = {hp = 50, maxHp = 50, atk = 8, def = 3, name = "Slime"}

local turn = "PLAYER" -- PLAYER, ENEMY, WIN, LOSE
local battleMenu = {"Attack", "Skill", "Item", "Run"}
local selection = 1
local message = "Battle Start!"
local timer = 0

-- Animation vars
local enemyAnim = {yOffset = 0, xOffset = 0}
local animTimer = 0
local screenShake = 0
local particles = nil

function BattleState.enter()
    print("Entered Battle State")
    playerStats.hp = 100
    playerStats.mp = 20
    enemyStats.hp = 50
    turn = "PLAYER"
    selection = 1
    message = "Encountered " .. enemyStats.name .. "!"
    
    local Audio = require("src.system.audio")
    Audio.playBGM("battle")
    
    enemyAnim.yOffset = 0
    enemyAnim.xOffset = 0
    animTimer = 0
    screenShake = 0
    
    -- Initialize Particles
    local img = love.image.newImageData(4, 4)
    img:mapPixel(function(x,y) return 1, 1, 0.5, 1 end)
    local pTexture = love.graphics.newImage(img)
    particles = love.graphics.newParticleSystem(pTexture, 100)
    particles:setParticleLifetime(0.5, 1)
    particles:setLinearAcceleration(-100, -100, 100, 100)
    particles:setColors(1, 1, 0, 1, 1, 0, 0, 0) -- Yellow to Red fade
    particles:setSizes(2, 0)
    particles:setEmissionRate(0)
end

function BattleState.update(dt)
    local Audio = require("src.system.audio")
    
    -- Update Particles
    if particles then particles:update(dt) end
    
    -- Idle Animation (Bobbing)
    animTimer = animTimer + dt
    enemyAnim.yOffset = math.sin(animTimer * 5) * 5
    
    -- Screen Shake decay
    if screenShake > 0 then
        screenShake = screenShake - dt * 10
        if screenShake < 0 then screenShake = 0 end
    end
    
    if turn == "PLAYER" then
        enemyAnim.xOffset = 0 -- Reset position
        if Input.wasPressed("up") then
            Audio.playSFX("select")
            selection = selection - 1
            if selection < 1 then selection = #battleMenu end
        elseif Input.wasPressed("down") then
            Audio.playSFX("select")
            selection = selection + 1
            if selection > #battleMenu then selection = 1 end
        elseif Input.wasPressed("return") then
            Audio.playSFX("select")
            if battleMenu[selection] == "Attack" then
                -- Attack Logic
                Audio.playSFX("attack")
                local damage = math.max(1, playerStats.atk - enemyStats.def + math.random(-2, 2))
                enemyStats.hp = enemyStats.hp - damage
                message = "Player attacks! " .. damage .. " damage."
                
                if enemyStats.hp <= 0 then
                    enemyStats.hp = 0
                    turn = "WIN"
                else
                    turn = "ENEMY_WAIT"
                    timer = 1
                end
            elseif battleMenu[selection] == "Skill" then
                -- Fireball (Cost 5 MP)
                if playerStats.mp >= 5 then
                    playerStats.mp = playerStats.mp - 5
                    Audio.playSFX("attack")
                    
                    -- Emit Particles
                    particles:setPosition(RPG.WIDTH/2, RPG.HEIGHT/2 - 32)
                    particles:emit(50)
                    
                    local damage = 20 + math.random(-5, 5)
                    enemyStats.hp = enemyStats.hp - damage
                    message = "Player casts Fireball! " .. damage .. " damage."
                    
                    if enemyStats.hp <= 0 then
                        enemyStats.hp = 0
                        turn = "WIN"
                    else
                        turn = "ENEMY_WAIT"
                        timer = 1
                    end
                else
                    message = "Not enough MP!"
                end
            elseif battleMenu[selection] == "Item" then
                -- Potion
                Audio.playSFX("select")
                playerStats.hp = math.min(playerStats.maxHp, playerStats.hp + 50)
                message = "Player used Potion! Recovered 50 HP."
                turn = "ENEMY_WAIT"
                timer = 1
            elseif battleMenu[selection] == "Run" then
                RPG.switchState("map", {fromBattle = true})
            end
        end
    elseif turn == "ENEMY_WAIT" then
        timer = timer - dt
        if timer <= 0 then
            turn = "ENEMY"
            timer = 0.5 -- Attack animation duration
        end
    elseif turn == "ENEMY" then
        -- Enemy Turn Animation
        timer = timer - dt
        if timer > 0.25 then
            -- Lunge forward
            enemyAnim.xOffset = enemyAnim.xOffset - dt * 200
        elseif timer > 0 then
            -- Return
            enemyAnim.xOffset = enemyAnim.xOffset + dt * 200
        else
            -- Deal Damage
            Audio.playSFX("attack")
            local damage = math.max(1, enemyStats.atk - playerStats.def + math.random(-2, 2))
            playerStats.hp = playerStats.hp - damage
            Audio.playSFX("hit")
            message = enemyStats.name .. " attacks! " .. damage .. " damage."
            screenShake = 10 -- Trigger shake
            
            if playerStats.hp <= 0 then
                playerStats.hp = 0
                turn = "LOSE"
            else
                turn = "PLAYER"
            end
        end
    elseif turn == "WIN" then
        if Input.wasPressed("return") then
            RPG.switchState("map", {fromBattle = true})
        end
    elseif turn == "LOSE" then
        if Input.wasPressed("return") then
            RPG.switchState("title")
        end
    end
end

function BattleState.draw()
    -- Screen Shake
    local shakeX = 0
    local shakeY = 0
    if screenShake > 0 then
        shakeX = math.random(-screenShake, screenShake)
        shakeY = math.random(-screenShake, screenShake)
    end
    
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)

    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", 0, 0, RPG.WIDTH, RPG.HEIGHT)
    
    -- Enemy
    local Assets = require("src.system.assets")
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Assets.textures.slime, RPG.WIDTH/2 - 32 + enemyAnim.xOffset, RPG.HEIGHT/2 - 64 + enemyAnim.yOffset)
    
    -- Particles
    if particles then
        love.graphics.draw(particles, 0, 0)
    end
    
    -- UI
    local fontScale = 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(enemyStats.name .. " HP: " .. enemyStats.hp .. "/" .. enemyStats.maxHp, 50, 50, 0, fontScale, fontScale)
    love.graphics.print("Player HP: " .. playerStats.hp .. "/" .. playerStats.maxHp .. " MP: " .. playerStats.mp .. "/" .. playerStats.maxMp, 50, RPG.HEIGHT - 150, 0, fontScale, fontScale)
    
    -- Message
    love.graphics.print(message, 50, 100, 0, fontScale, fontScale)
    
    -- Menu
    if turn == "PLAYER" then
        love.graphics.rectangle("line", RPG.WIDTH - 300, RPG.HEIGHT - 300, 250, 250)
        for i, option in ipairs(battleMenu) do
            if i == selection then
                love.graphics.print("> " .. option, RPG.WIDTH - 280, RPG.HEIGHT - 280 + (i-1)*50, 0, fontScale, fontScale)
            else
                love.graphics.print("  " .. option, RPG.WIDTH - 280, RPG.HEIGHT - 280 + (i-1)*50, 0, fontScale, fontScale)
            end
        end
    elseif turn == "WIN" then
        love.graphics.print("YOU WON! Press Enter.", RPG.WIDTH/2 - 150, RPG.HEIGHT/2 + 100, 0, fontScale, fontScale)
    elseif turn == "LOSE" then
        love.graphics.print("YOU LOST... Press Enter.", RPG.WIDTH/2 - 150, RPG.HEIGHT/2 + 100, 0, fontScale, fontScale)
    end
    
    love.graphics.pop()
end

function BattleState.exit()
    print("Exited Battle State")
end

return BattleState
