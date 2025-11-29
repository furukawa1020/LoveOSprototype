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
    love.graphics.print("TITLE SCREEN", 100, 80)
    love.graphics.print("Press Enter", 110, 100)
end

function TitleState.exit()
    print("Exited Title State")
end

return TitleState
