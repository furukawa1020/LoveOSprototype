local BSOD = {}

function BSOD.enter()
    love.graphics.setBackgroundColor(0, 0, 0.67) -- Classic Blue (approx #0000AA)
    
    -- Play glitch sound if available
    local Audio = require("src.system.audio")
    if Audio and Audio.playSynth then
        Audio.playSynth("hdd") -- Crunch sound as "crash"
    end
end

function BSOD.update(dt)
    if love.keyboard.isDown("r") or love.keyboard.isDown("return") or love.keyboard.isDown("space") then
         -- Allow manual reboot after a moment?
         -- For realism, maybe require a specific key or just wait
    end
end

function BSOD.draw()
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    
    local text = [[
A fatal exception 0E has occurred at 0028:C0011E36 in VXD VMM(01) +
00010E36. The current application will be terminated.

*  Press any key to terminate the current application.
*  Press CTRL+ALT+DEL again to restart your computer.  You will
   lose any unsaved information in all applications.

Press any key to continue_
]]
    
    love.graphics.print(text, 50, 50)
end

function BSOD.keypressed(key)
    -- Any key restarts
    love.event.quit("restart")
end

return BSOD
