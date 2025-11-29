local BattleState = {}
local Input = require("src.system.input")

function BattleState.enter()
    print("Entered Battle State")
end

function BattleState.update(dt)
    if Input.wasPressed("return") then
        RPG.switchState("map")
    end
end

function BattleState.draw()
    love.graphics.print("BATTLE STATE", 10, 10)
    love.graphics.print("Press Enter to Win", 10, 30)
end

function BattleState.exit()
    print("Exited Battle State")
end

return BattleState
