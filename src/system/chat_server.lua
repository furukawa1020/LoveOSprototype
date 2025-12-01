local ChatServer = {}

ChatServer.socket = nil
ChatServer.clients = {} -- list of client socket IDs

function ChatServer.run()
    ChatServer.socket = sys.net.socket()
    local success, err = sys.net.bind(ChatServer.socket, 8080)
    if not success then
        sys.print("ChatServer: Failed to bind port 8080: " .. tostring(err))
        return
    end
    
    sys.net.listen(ChatServer.socket)
    sys.print("ChatServer: Listening on port 8080")
    
    while true do
        local dt = coroutine.yield()
        
        -- Accept new clients
        local client = sys.net.accept(ChatServer.socket)
        if client then
            sys.print("ChatServer: New client connected: " .. client)
            table.insert(ChatServer.clients, client)
            sys.net.send(client, "Welcome to Löve Chat Server!")
        end
        
        -- Process messages
        for i, client in ipairs(ChatServer.clients) do
            local msg = sys.net.recv(client)
            if msg then
                sys.print("ChatServer: Received from " .. client .. ": " .. msg)
                -- Broadcast
                for _, other in ipairs(ChatServer.clients) do
                    -- if other ~= client then -- Echo to self too? Sure.
                        sys.net.send(other, "User" .. client .. ": " .. msg)
                    -- end
                end
            end
        end
    end
end

return ChatServer
