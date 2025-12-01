local Login = {}

Login.username = ""
Login.password = ""
Login.focus = "username" -- username, password
Login.status = ""
Login.shake = 0
Login.mode = "login" -- login, register

function Login.run()
    local win = sys.createWindow("Login", 0, 0, 800, 600)
    
    while true do
        local dt = coroutine.yield()
        
        Login.update(dt)
        
        sys.setCanvas(win.canvas)
        Login.draw()
        sys.setCanvas()
    end
end

function Login.update(dt)
    if Login.shake > 0 then
        Login.shake = Login.shake - dt * 10
        if Login.shake < 0 then Login.shake = 0 end
    end
end

function Login.draw()
    -- Background
    sys.graphics.clear(0.1, 0.1, 0.15, 1)
    
    -- Center Box
    local cx, cy = 400, 300
    local bx, by = cx - 150, cy - 100
    
    -- Shake effect
    if Login.shake > 0 then
        bx = bx + math.sin(Login.shake * 20) * 5
    end
    
    sys.graphics.setColor(0.2, 0.2, 0.25)
    sys.graphics.rectangle("fill", bx, by, 300, 240, 10) -- Taller for register button
    
    -- Title
    sys.graphics.setColor(1, 1, 1)
    local title = Login.mode == "login" and "LöveOS Login" or "Create Account"
    sys.graphics.print(title, bx + 100, by + 20)
    
    -- Username Input
    sys.graphics.setColor(0.1, 0.1, 0.1)
    sys.graphics.rectangle("fill", bx + 50, by + 60, 200, 30)
    if Login.focus == "username" then
        sys.graphics.setColor(0.3, 0.3, 0.8, 0.5)
        sys.graphics.rectangle("line", bx + 50, by + 60, 200, 30)
    end
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.print(Login.username .. (Login.focus == "username" and "|" or ""), bx + 55, by + 68)
    sys.graphics.print("User:", bx + 50, by + 45)
    
    -- Password Input
    sys.graphics.setColor(0.1, 0.1, 0.1)
    sys.graphics.rectangle("fill", bx + 50, by + 120, 200, 30)
    if Login.focus == "password" then
        sys.graphics.setColor(0.3, 0.3, 0.8, 0.5)
        sys.graphics.rectangle("line", bx + 50, by + 120, 200, 30)
    end
    sys.graphics.setColor(1, 1, 1)
    local masked = string.rep("*", #Login.password)
    sys.graphics.print(masked .. (Login.focus == "password" and "|" or ""), bx + 55, by + 128)
    sys.graphics.print("Password:", bx + 50, by + 105)
    
    -- Action Button (Login/Register)
    sys.graphics.setColor(0.3, 0.6, 0.3)
    sys.graphics.rectangle("fill", bx + 50, by + 170, 90, 30)
    sys.graphics.setColor(1, 1, 1)
    local actionText = Login.mode == "login" and "Login" or "Create"
    sys.graphics.print(actionText, bx + 70, by + 178)
    
    -- Switch Mode Button
    sys.graphics.setColor(0.4, 0.4, 0.4)
    sys.graphics.rectangle("fill", bx + 160, by + 170, 90, 30)
    sys.graphics.setColor(1, 1, 1)
    local switchText = Login.mode == "login" and "Register" or "Back"
    sys.graphics.print(switchText, bx + 175, by + 178)
    
    -- Status
    sys.graphics.setColor(1, 0.2, 0.2)
    sys.graphics.print(Login.status, bx + 50, by + 210)
    
    -- Hint
    sys.graphics.setColor(0.5, 0.5, 0.5)
    sys.graphics.print("Default: admin / love", 10, 580)
end

function Login.textinput(t)
    if Login.focus == "username" then
        Login.username = Login.username .. t
    elseif Login.focus == "password" then
        Login.password = Login.password .. t
    end
end

function Login.keypressed(key)
    if key == "tab" then
        if Login.focus == "username" then Login.focus = "password"
        else Login.focus = "username" end
    elseif key == "return" then
        if Login.focus == "username" then
            Login.focus = "password"
        else
            Login.submit()
        end
    elseif key == "backspace" then
        if Login.focus == "username" then
            local byteoffset = utf8.offset(Login.username, -1)
            if byteoffset then Login.username = string.sub(Login.username, 1, byteoffset - 1) end
        elseif Login.focus == "password" then
            local byteoffset = utf8.offset(Login.password, -1)
            if byteoffset then Login.password = string.sub(Login.password, 1, byteoffset - 1) end
        end
    elseif key == "f1" then -- Shortcut to toggle mode?
        Login.toggleMode()
    end
end

function Login.mousepressed(x, y, button)
    -- Simple hit testing for buttons
    local cx, cy = 400, 300
    local bx, by = cx - 150, cy - 100
    
    -- Login/Create Button
    if x >= bx + 50 and x <= bx + 140 and y >= by + 170 and y <= by + 200 then
        Login.submit()
    end
    
    -- Register/Back Button
    if x >= bx + 160 and x <= bx + 250 and y >= by + 170 and y <= by + 200 then
        Login.toggleMode()
    end
end

function Login.toggleMode()
    if Login.mode == "login" then
        Login.mode = "register"
        Login.status = "Create new account"
    else
        Login.mode = "login"
        Login.status = ""
    end
    Login.username = ""
    Login.password = ""
    Login.focus = "username"
end

function Login.submit()
    if Login.mode == "login" then
        local success = sys.user.login(Login.username, Login.password)
        if success then
            Login.status = "Welcome!"
            sys.spawn("Terminal", "src/system/terminal.lua")
            sys.spawn("Filer", "src/apps/filer.lua")
            sys.exit()
        else
            Login.status = "Invalid credentials"
            Login.shake = 1
            Login.password = ""
        end
    else
        -- Register
        if Login.username == "" or Login.password == "" then
            Login.status = "Fields cannot be empty"
            Login.shake = 1
            return
        end
        
        local success, msg = sys.user.create(Login.username, Login.password)
        if success then
            Login.status = "Account created!"
            Login.mode = "login"
            Login.password = ""
        else
            Login.status = "Error: " .. (msg or "Failed")
            Login.shake = 1
        end
    end
end

return Login
