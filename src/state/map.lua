local MapState = {}
local Input = require("src.system.input")

function MapState.enter()
    print("Entered Map State")
end

function MapState.update(dt)
    if Input.wasPressed("return") then
        RPG.switchState("menu")
    end
end

function MapState.draw()
    love.graphics.print("MAP STATE", 10, 10)
    love.graphics.print("Press Enter for Menu", 10, 30)
end

function MapState.exit()
    print("Exited Map State")
end

return MapState
