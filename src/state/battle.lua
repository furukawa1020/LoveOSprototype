local BattleState = {}
local Input = require("src.system.input")

local playerStats = {hp = 100, maxHp = 100, atk = 10, def = 5}
local enemyStats = {hp = 50, maxHp = 50, atk = 8, def = 3, name = "Slime"}

local turn = "PLAYER" -- PLAYER, ENEMY, WIN, LOSE
local battleMenu = {"Attack", "Skill", "Item", "Run"}
local selection = 1
local message = "Battle Start!"
local timer = 0

function BattleState.enter()
    print("Entered Battle State")
    playerStats.hp = 100
    enemyStats.hp = 50
    turn = "PLAYER"
    selection = 1
    message = "Encountered " .. enemyStats.name .. "!"
end

function BattleState.update(dt)
    if turn == "PLAYER" then
        if Input.wasPressed("up") then
            selection = selection - 1
            if selection < 1 then selection = #battleMenu end
        elseif Input.wasPressed("down") then
            selection = selection + 1
            if selection > #battleMenu then selection = 1 end
        elseif Input.wasPressed("return") then
            if battleMenu[selection] == "Attack" then
                -- Attack Logic
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
            elseif battleMenu[selection] == "Run" then
                RPG.switchState("map")
            else
                message = "Not implemented yet."
            end
        end
    elseif turn == "ENEMY_WAIT" then
        timer = timer - dt
        if timer <= 0 then
            turn = "ENEMY"
        end
    elseif turn == "ENEMY" then
        -- Enemy Turn
        local damage = math.max(1, enemyStats.atk - playerStats.def + math.random(-2, 2))
        playerStats.hp = playerStats.hp - damage
        message = enemyStats.name .. " attacks! " .. damage .. " damage."
        
        if playerStats.hp <= 0 then
            playerStats.hp = 0
            turn = "LOSE"
        else
            turn = "PLAYER"
        end
    elseif turn == "WIN" then
        if Input.wasPressed("return") then
            RPG.switchState("map")
        end
    elseif turn == "LOSE" then
        if Input.wasPressed("return") then
            RPG.switchState("title")
        end
    end
end

function BattleState.draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", 0, 0, RPG.WIDTH, RPG.HEIGHT)
    
    -- Enemy
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", RPG.WIDTH/2 - 64, RPG.HEIGHT/2 - 128, 128, 128)
    
    -- UI
    local fontScale = 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(enemyStats.name .. " HP: " .. enemyStats.hp .. "/" .. enemyStats.maxHp, 50, 50, 0, fontScale, fontScale)
    love.graphics.print("Player HP: " .. playerStats.hp .. "/" .. playerStats.maxHp, 50, RPG.HEIGHT - 150, 0, fontScale, fontScale)
    
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
end

function BattleState.exit()
    print("Exited Battle State")
end

return BattleState
