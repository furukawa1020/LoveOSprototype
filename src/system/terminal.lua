local Terminal = {}
local utf8 = require("utf8")

Terminal.lines = {}
Terminal.maxLines = 24
Terminal.currentLine = ""
Terminal.prompt = "user@love2d:~$ "
Terminal.cursorBlink = 0
Terminal.history = {}
Terminal.historyIndex = 0
Terminal.state = "boot" -- boot, active, installing, installed
Terminal.bootQueue = {}
Terminal.currentBootLine = ""
Terminal.bootCharIndex = 1
Terminal.bootTimer = 0
Terminal.installProgress = 0

-- Color Palette (Retro Amber/Green)
Terminal.colors = {
    default = {0.2, 1.0, 0.2, 1}, -- Green
    highlight = {1.0, 1.0, 0.2, 1}, -- Yellow
    error = {1.0, 0.2, 0.2, 1}, -- Red
    dim = {0.1, 0.5, 0.1, 1} -- Dim Green
}

-- Boot Sequence Data
local bootSequence = {
    {text = "LOVE BIOS v11.4 (c) 2006-2025", delay = 0.5},
    {text = "CPU: LUA JIT 2.1.0 detected", delay = 0.2},
    {text = "Memory Test: ", delay = 0, type = "memory"},
    {text = "OK", delay = 0.5},
    {text = "Detecting Primary Master... LOVE.EXE", delay = 0.3},
    {text = "Detecting Primary Slave...  None", delay = 0.1},
    {text = "", delay = 0.5},
    {text = "Booting from Hard Disk...", delay = 1.0},
    {text = "Loading Kernel...", delay = 0.2},
    {text = "Mounting root filesystem... [OK]", delay = 0.1},
    {text = "Starting init process...    [OK]", delay = 0.1},
    {text = "Initializing graphics...    [OK]", delay = 0.1},
    {text = "Initializing sound...       [OK]", delay = 0.1},
    {text = "", delay = 0.5},
    {text = "Welcome to Love OS.", delay = 0.1},
    {text = "Type 'help' for commands.", delay = 0.1},
    {text = "", delay = 0}
}

function Terminal.init()
    Terminal.lines = {}
    Terminal.currentLine = ""
    Terminal.state = "boot"
    Terminal.bootQueue = {}
    for _, line in ipairs(bootSequence) do
        table.insert(Terminal.bootQueue, line)
    end
    Terminal.currentBootLine = ""
    Terminal.bootCharIndex = 1
    Terminal.bootTimer = 0
    Terminal.installProgress = 0
end

function Terminal.update(dt)
    Terminal.cursorBlink = Terminal.cursorBlink + dt
    
    if Terminal.state == "boot" then
        Terminal.updateBoot(dt)
    elseif Terminal.state == "installing" then
        Terminal.installProgress = Terminal.installProgress + dt * 0.2 -- Slower, more realistic
        if Terminal.installProgress >= 1 then
            Terminal.installProgress = 1
            Terminal.finishInstall()
        end
    end
end

function Terminal.updateBoot(dt)
    if #Terminal.bootQueue == 0 then
        Terminal.state = "active"
        return
    end
    
    local currentTask = Terminal.bootQueue[1]
    
    if currentTask.type == "memory" then
        -- Simulate memory count
        if not currentTask.count then currentTask.count = 0 end
        currentTask.count = currentTask.count + 1024 * 1024 * dt * 50 -- Fast count
        if currentTask.count >= 64 * 1024 * 1024 then -- 64MB
             Terminal.print("Memory Test: 65536KB OK")
             table.remove(Terminal.bootQueue, 1)
        else
             -- Update last line in place? No, just print periodically or wait
             -- For simplicity, we just wait and print at end
        end
        return
    end
    
    Terminal.bootTimer = Terminal.bootTimer - dt
    if Terminal.bootTimer > 0 then return end
    
    -- Typing effect
    local text = currentTask.text
    if Terminal.bootCharIndex <= #text then
        Terminal.currentBootLine = string.sub(text, 1, Terminal.bootCharIndex)
        Terminal.bootCharIndex = Terminal.bootCharIndex + 1
        Terminal.bootTimer = 0.01 -- Fast typing
        
        -- Play typing sound (if we had access to audio here, but we'll do it in main)
        if love.audio then
             -- Trigger sound event?
        end
    else
        -- Line finished
        Terminal.print(Terminal.currentBootLine)
        Terminal.currentBootLine = ""
        Terminal.bootCharIndex = 1
        Terminal.bootTimer = currentTask.delay
        table.remove(Terminal.bootQueue, 1)
    end
end

function Terminal.print(text, color)
    table.insert(Terminal.lines, {text = text, color = color or Terminal.colors.default})
    if #Terminal.lines > Terminal.maxLines then
        table.remove(Terminal.lines, 1)
    end
end

function Terminal.execute(cmd)
    Terminal.print(Terminal.prompt .. cmd, Terminal.colors.highlight)
    table.insert(Terminal.history, cmd)
    Terminal.historyIndex = #Terminal.history + 1
    
    local parts = {}
    for part in string.gmatch(cmd, "%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return end
    
    local command = parts[1]
    
    if command == "help" then
        Terminal.print("Available commands:")
        Terminal.print("  apt-get install <pkg>  Install packages")
        Terminal.print("  ls                     List files")
        Terminal.print("  clear                  Clear screen")
        Terminal.print("  reboot                 Reboot system")
    elseif command == "clear" then
        Terminal.lines = {}
    elseif command == "ls" then
        Terminal.print("readme.txt  kernel.sys  love.tar.gz")
    elseif command == "reboot" then
        love.event.quit("restart")
    elseif command == "apt-get" or command == "apt" then
        if parts[2] == "install" and parts[3] == "love" then
            Terminal.startInstall()
        else
            Terminal.print("Usage: apt-get install <package>", Terminal.colors.error)
        end
    else
        Terminal.print(command .. ": command not found", Terminal.colors.error)
    end
end

function Terminal.startInstall()
    Terminal.state = "installing"
    Terminal.print("Reading package lists... Done")
    Terminal.print("Building dependency tree... Done")
    Terminal.print("The following NEW packages will be installed:")
    Terminal.print("  love")
    Terminal.print("Need to get 4,096 kB of archives.")
end

function Terminal.finishInstall()
    Terminal.state = "installed"
    Terminal.print("Love installed successfully.", Terminal.colors.highlight)
    Terminal.print("Run 'love' to start.", Terminal.colors.highlight)
end

function Terminal.textinput(t)
    if Terminal.state == "active" or Terminal.state == "installed" then
        Terminal.currentLine = Terminal.currentLine .. t
    end
end

function Terminal.keypressed(key)
    if Terminal.state ~= "active" and Terminal.state ~= "installed" then return end

    if key == "backspace" then
        local byteoffset = utf8.offset(Terminal.currentLine, -1)
        if byteoffset then
            Terminal.currentLine = string.sub(Terminal.currentLine, 1, byteoffset - 1)
        end
    elseif key == "return" then
        Terminal.execute(Terminal.currentLine)
        Terminal.currentLine = ""
    elseif key == "up" then
        if Terminal.historyIndex > 1 then
            Terminal.historyIndex = Terminal.historyIndex - 1
            Terminal.currentLine = Terminal.history[Terminal.historyIndex]
        end
    elseif key == "down" then
        if Terminal.historyIndex < #Terminal.history then
            Terminal.historyIndex = Terminal.historyIndex + 1
            Terminal.currentLine = Terminal.history[Terminal.historyIndex]
        elseif Terminal.historyIndex == #Terminal.history then
            Terminal.historyIndex = Terminal.historyIndex + 1
            Terminal.currentLine = ""
        end
    end
end

function Terminal.draw()
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()
    
    -- Draw Lines
    for i, line in ipairs(Terminal.lines) do
        love.graphics.setColor(line.color)
        love.graphics.print(line.text, 10, 10 + (i - 1) * lineHeight)
    end
    
    -- Draw Booting Line (if active)
    if Terminal.state == "boot" and Terminal.currentBootLine ~= "" then
        local y = 10 + #Terminal.lines * lineHeight
        love.graphics.setColor(Terminal.colors.default)
        love.graphics.print(Terminal.currentBootLine, 10, y)
    end
    
    -- Draw Prompt
    if Terminal.state == "active" or Terminal.state == "installed" then
        local y = 10 + #Terminal.lines * lineHeight
        love.graphics.setColor(Terminal.colors.default)
        love.graphics.print(Terminal.prompt .. Terminal.currentLine, 10, y)
        
        -- Draw Cursor
        if math.floor(Terminal.cursorBlink * 2) % 2 == 0 then
            local width = font:getWidth(Terminal.prompt .. Terminal.currentLine)
            love.graphics.rectangle("fill", 10 + width, y, 10, lineHeight)
        end
    elseif Terminal.state == "installing" then
        local y = 10 + #Terminal.lines * lineHeight
        local progress = math.floor(Terminal.installProgress * 20)
        local bar = "[" .. string.rep("#", progress) .. string.rep(" ", 20 - progress) .. "]"
        love.graphics.setColor(Terminal.colors.highlight)
        love.graphics.print("Unpacking: " .. bar .. " " .. math.floor(Terminal.installProgress * 100) .. "%", 10, y)
    end
end

return Terminal
