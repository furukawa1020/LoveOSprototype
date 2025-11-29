local TitleState = {}
local Input = require("src.system.input")

function TitleState.enter()
    print("Entered Title State")
end

function TitleState.update(dt)
    if Input.wasPressed("return") then
        RPG.switchState("map")
    end
end

function TitleState.draw()
    local fontScale = 4
    love.graphics.print("TITLE SCREEN", RPG.WIDTH/2 - 150, RPG.HEIGHT/2 - 50, 0, fontScale, fontScale)
    love.graphics.print("Press Enter", RPG.WIDTH/2 - 100, RPG.HEIGHT/2 + 50, 0, 2, 2)
end

function TitleState.exit()
    print("Exited Title State")
end

return TitleState
