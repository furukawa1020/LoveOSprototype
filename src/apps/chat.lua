local Chat = {}

Chat.socket = nil
Chat.messages = {}
Chat.input = ""
Chat.status = "Disconnected"

function Chat.run()
    local win = sys.createWindow("Chat", 100, 100, 400, 500)
    
    -- Auto connect
    Chat.connect()
    
    while true do
        local dt = coroutine.yield()
        
        Chat.update(dt)
        
        sys.setCanvas(win.canvas)
        Chat.draw()
        sys.setCanvas()
    end
end

function Chat.connect()
    Chat.socket = sys.net.socket()
    local success, err = sys.net.connect(Chat.socket, "localhost", 8080)
    if success then
        Chat.status = "Connected"
    else
        Chat.status = "Error: " .. tostring(err)
    end
end

function Chat.update(dt)
    if Chat.socket and Chat.status == "Connected" then
        local msg = sys.net.recv(Chat.socket)
        if msg then
            table.insert(Chat.messages, msg)
            if #Chat.messages > 20 then table.remove(Chat.messages, 1) end
        end
    end
end

function Chat.draw()
    sys.graphics.clear(0.95, 0.95, 0.95, 1)
    
    -- Header
    sys.graphics.setColor(0.2, 0.6, 0.2)
    sys.graphics.rectangle("fill", 0, 0, 400, 40)
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.print("Löve Chat - " .. Chat.status, 10, 12)
    
    -- Messages
    sys.graphics.setColor(0, 0, 0)
    local y = 50
    for _, msg in ipairs(Chat.messages) do
        sys.graphics.print(msg, 10, y)
        y = y + 20
    end
    
    -- Input Area
    sys.graphics.setColor(0.9, 0.9, 0.9)
    sys.graphics.rectangle("fill", 0, 460, 400, 40)
    sys.graphics.setColor(0, 0, 0)
    sys.graphics.print("> " .. Chat.input .. "|", 10, 472)
end

function Chat.textinput(t)
    Chat.input = Chat.input .. t
end

function Chat.keypressed(key)
    if key == "backspace" then
        local byteoffset = utf8.offset(Chat.input, -1)
        if byteoffset then Chat.input = string.sub(Chat.input, 1, byteoffset - 1) end
    elseif key == "return" then
        if Chat.input ~= "" then
            if Chat.status == "Connected" then
                sys.net.send(Chat.socket, Chat.input)
                Chat.input = ""
            else
                -- Retry connect
                Chat.connect()
            end
        end
    end
end

return Chat
