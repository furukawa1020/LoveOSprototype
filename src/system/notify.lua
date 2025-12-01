local Notify = {}

Notify.list = {}
Notify.timer = 0

function Notify.push(title, message, icon)
    table.insert(Notify.list, {
        title = title,
        message = message,
        icon = icon,
        time = 5, -- seconds
        y = -60 -- slide in animation start
    })
    -- Play sound
    local Audio = require("src.system.audio")
    Audio.playSynth("notify")
end

function Notify.update(dt)
    for i = #Notify.list, 1, -1 do
        local n = Notify.list[i]
        n.time = n.time - dt
        
        -- Slide in
        if n.y < 10 + (i-1)*70 then
            n.y = n.y + dt * 200
        end
        
        if n.time <= 0 then
            table.remove(Notify.list, i)
        end
    end
end

function Notify.draw()
    local w = 250
    local x = love.graphics.getWidth() - w - 10
    
    for i, n in ipairs(Notify.list) do
        -- Background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", x, n.y, w, 60, 5)
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("line", x, n.y, w, 60, 5)
        
        -- Icon
        love.graphics.setColor(0.3, 0.8, 0.3)
        love.graphics.circle("fill", x + 30, n.y + 30, 15)
        
        -- Text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(n.title, x + 60, n.y + 10)
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print(n.message, x + 60, n.y + 30)
    end
end

return Notify
