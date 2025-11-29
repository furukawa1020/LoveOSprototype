local MenuState = {}
local Input = require("src.system.input")

function MenuState.enter()
    print("Entered Menu State")
end

function MenuState.update(dt)
    if Input.wasPressed("return") then
        RPG.switchState("map")
    end
end

function MenuState.draw()
    love.graphics.print("MENU STATE", 10, 10)
    love.graphics.print("Press Enter to Return", 10, 30)
end

function MenuState.exit()
    print("Exited Menu State")
end

return MenuState
