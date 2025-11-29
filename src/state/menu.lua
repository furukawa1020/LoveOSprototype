local MenuState = {}
local Input = require("src.system.input")

local options = {"Items", "Status", "Save", "Quit"}
local selection = 1

function MenuState.enter()
    print("Entered Menu State")
    selection = 1
end

function MenuState.update(dt)
    if Input.wasPressed("up") then
        selection = selection - 1
        if selection < 1 then selection = #options end
    elseif Input.wasPressed("down") then
        selection = selection + 1
        if selection > #options then selection = 1 end
    elseif Input.wasPressed("return") then
        if options[selection] == "Quit" then
            love.event.quit()
        elseif options[selection] == "Status" then
            -- Show status (placeholder)
        else
            -- Placeholder for other options
            RPG.switchState("map")
        end
    elseif Input.wasPressed("escape") then
        RPG.switchState("map")
    end
end

function MenuState.draw()
    -- Draw semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, RPG.WIDTH, RPG.HEIGHT)
    
    -- Draw Menu Window
    local menuWidth = 400
    local menuHeight = 400
    local menuX = (RPG.WIDTH - menuWidth) / 2
    local menuY = (RPG.HEIGHT - menuHeight) / 2
    
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", menuX, menuY, menuWidth, menuHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", menuX, menuY, menuWidth, menuHeight)
    
    -- Draw Options
    local fontScale = 3
    for i, option in ipairs(options) do
        if i == selection then
            love.graphics.print("> " .. option, menuX + 40, menuY + 40 + (i-1)*60, 0, fontScale, fontScale)
        else
            love.graphics.print("  " .. option, menuX + 40, menuY + 40 + (i-1)*60, 0, fontScale, fontScale)
        end
    end
end

function MenuState.exit()
    print("Exited Menu State")
end

return MenuState
