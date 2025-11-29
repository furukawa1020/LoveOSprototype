local Terminal = {}

Terminal.lines = {}
Terminal.maxLines = 24
Terminal.currentLine = ""
Terminal.prompt = "user@love2d:~$ "
Terminal.cursorBlink = 0
Terminal.history = {}
Terminal.historyIndex = 0
Terminal.state = "boot" -- boot, active, installing, installed
Terminal.bootTimer = 0
Terminal.installProgress = 0

-- Boot sequence text
local bootText = {
    "LOVE OS v11.4 (tty1)",
    "Copyright (c) 2006-2025 LOVE Development Team",
    "",
    "Loading kernel...",
    "Mounting file systems...",
    "Initializing graphics... [OK]",
    "Initializing sound... [OK]",
    "Checking dependencies...",
    "  lua5.1... [OK]",
    "  sdl2... [OK]",
    "  freetype... [OK]",
    "",
    "Welcome to Love2D.",
    "Type 'help' for a list of commands.",
    ""
}

function Terminal.init()
    Terminal.lines = {}
    Terminal.currentLine = ""
    Terminal.state = "boot"
    Terminal.bootTimer = 0
    Terminal.installProgress = 0
end

function Terminal.update(dt)
    Terminal.cursorBlink = Terminal.cursorBlink + dt
    
    if Terminal.state == "boot" then
        Terminal.bootTimer = Terminal.bootTimer + dt
        if Terminal.bootTimer > 0.1 then
            Terminal.bootTimer = 0
            if #bootText > 0 then
                table.insert(Terminal.lines, table.remove(bootText, 1))
                if #Terminal.lines > Terminal.maxLines then
                    table.remove(Terminal.lines, 1)
                end
            else
                Terminal.state = "active"
            end
        end
    elseif Terminal.state == "installing" then
        Terminal.installProgress = Terminal.installProgress + dt * 0.5
        if Terminal.installProgress >= 1 then
            Terminal.installProgress = 1
            Terminal.finishInstall()
        end
    end
end

function Terminal.print(text)
    table.insert(Terminal.lines, text)
    if #Terminal.lines > Terminal.maxLines then
        table.remove(Terminal.lines, 1)
    end
end

function Terminal.execute(cmd)
    Terminal.print(Terminal.prompt .. cmd)
    table.insert(Terminal.history, cmd)
    Terminal.historyIndex = #Terminal.history + 1
    
    local parts = {}
    for part in string.gmatch(cmd, "%S+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return end
    
    local command = parts[1]
    
    if command == "help" then
        Terminal.print("GNU bash, version 5.1-release (x86_64-pc-love-gnu)")
        Terminal.print("These shell commands are defined internally.  Type 'help' to see this list.")
        Terminal.print("")
        Terminal.print("  apt-get [install] <pkg>  Install new packages")
        Terminal.print("  ls                       List directory contents")
        Terminal.print("  clear                    Clear the terminal screen")
        Terminal.print("  whoami                   Print effective userid")
        Terminal.print("  reboot                   Reboot the system")
        Terminal.print("  exit                     Logout")
    elseif command == "clear" then
        Terminal.lines = {}
    elseif command == "ls" then
        Terminal.print("readme.txt  kernel.sys  love.tar.gz")
    elseif command == "whoami" then
        Terminal.print("developer")
    elseif command == "reboot" then
        love.event.quit("restart")
    elseif command == "exit" then
        love.event.quit()
    elseif command == "apt-get" or command == "apt" then
        if parts[2] == "install" then
            if parts[3] == "love" then
                Terminal.startInstall()
            elseif parts[3] then
                Terminal.print("E: Unable to locate package " .. parts[3])
            else
                Terminal.print("apt 1.0.9.8 (amd64)")
                Terminal.print("Usage: apt-get install <package_name>")
            end
        else
            Terminal.print("apt 1.0.9.8 (amd64)")
            Terminal.print("Usage: apt-get <command>")
        end
    else
        Terminal.print(command .. ": command not found")
    end
end

function Terminal.startInstall()
    Terminal.state = "installing"
    Terminal.print("Reading package lists... Done")
    Terminal.print("Building dependency tree... Done")
    Terminal.print("The following NEW packages will be installed:")
    Terminal.print("  love")
    Terminal.print("0 upgraded, 1 newly installed, 0 to remove.")
    Terminal.print("Need to get 4,096 kB of archives.")
    Terminal.print("Get:1 http://love2d.org/ stable/main love amd64 11.4 [4,096 kB]")
end

function Terminal.finishInstall()
    Terminal.state = "installed"
    Terminal.print("Fetched 4,096 kB in 2s (2,048 kB/s)")
    Terminal.print("Selecting previously unselected package love.")
    Terminal.print("(Reading database ... 12345 files and directories currently installed.)")
    Terminal.print("Preparing to unpack .../love_11.4_amd64.deb ...")
    Terminal.print("Unpacking love (11.4) ...")
    Terminal.print("Setting up love (11.4) ...")
    Terminal.print("Processing triggers for man-db (2.9.4-2) ...")
    Terminal.print("")
    Terminal.print("Love installed successfully.")
    Terminal.print("Run 'love' to start the engine.")
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
        if Terminal.state == "installed" and Terminal.lines[#Terminal.lines] == "Run 'love' to start the engine." then
             -- Special case handling if needed, or just let them type 'love' next
        end
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
    love.graphics.setColor(0.2, 1.0, 0.2) -- Retro Green
    for i, line in ipairs(Terminal.lines) do
        love.graphics.print(line, 10, 10 + (i - 1) * lineHeight)
    end
    
    -- Draw Prompt and Current Line
    if Terminal.state == "active" or Terminal.state == "installed" then
        local y = 10 + #Terminal.lines * lineHeight
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
        love.graphics.print("Unpacking: " .. bar .. " " .. math.floor(Terminal.installProgress * 100) .. "%", 10, y)
    end
end

return Terminal
