local Net = {}

Net.sockets = {}
Net.nextId = 1
Net.listeners = {} -- port -> socketId

function Net.init()
    Net.sockets = {}
    Net.listeners = {}
end

function Net.socket()
    local id = Net.nextId
    Net.nextId = Net.nextId + 1
    Net.sockets[id] = {
        id = id,
        state = "closed",
        buffer = {},
        peer = nil, -- connected socket id
        port = nil
    }
    return id
end

function Net.bind(id, port)
    local sock = Net.sockets[id]
    if not sock then return false, "Invalid socket" end
    if Net.listeners[port] then return false, "Port in use" end
    
    sock.port = port
    sock.state = "bound"
    Net.listeners[port] = id
    return true
end

function Net.listen(id)
    local sock = Net.sockets[id]
    if not sock or sock.state ~= "bound" then return false, "Socket not bound" end
    sock.state = "listening"
    return true
end

function Net.connect(id, addr, port)
    local sock = Net.sockets[id]
    if not sock then return false, "Invalid socket" end
    
    -- Simulate local connection only for now
    if addr ~= "localhost" and addr ~= "127.0.0.1" then
        return false, "Only localhost supported"
    end
    
    local targetId = Net.listeners[port]
    if not targetId then return false, "Connection refused" end
    
    local target = Net.sockets[targetId]
    if not target or target.state ~= "listening" then return false, "Connection refused" end
    
    -- Establish connection (Virtual P2P for simplicity)
    -- In real TCP, we'd create a new socket for the server side.
    -- Here, let's just link them? Or create a new server-side socket?
    -- Let's create a new server-side socket to handle this client.
    local serverClientSockId = Net.socket()
    local serverClientSock = Net.sockets[serverClientSockId]
    serverClientSock.state = "connected"
    serverClientSock.peer = id
    
    sock.state = "connected"
    sock.peer = serverClientSockId
    
    -- Queue "accept" event for server?
    -- Or just let server accept() to get the new socket?
    -- Let's implement accept() queue.
    if not target.acceptQueue then target.acceptQueue = {} end
    table.insert(target.acceptQueue, serverClientSockId)
    
    return true
end

function Net.accept(id)
    local sock = Net.sockets[id]
    if not sock or sock.state ~= "listening" then return nil, "Invalid socket" end
    
    if sock.acceptQueue and #sock.acceptQueue > 0 then
        local clientSockId = table.remove(sock.acceptQueue, 1)
        return clientSockId
    end
    return nil -- Would block
end

function Net.send(id, data)
    local sock = Net.sockets[id]
    if not sock or sock.state ~= "connected" then return false, "Not connected" end
    
    local peer = Net.sockets[sock.peer]
    if not peer then 
        sock.state = "closed"
        return false, "Peer closed" 
    end
    
    table.insert(peer.buffer, data)
    return true
end

function Net.recv(id)
    local sock = Net.sockets[id]
    if not sock then return nil, "Invalid socket" end
    
    if #sock.buffer > 0 then
        return table.remove(sock.buffer, 1)
    end
    return nil -- Would block
end

function Net.close(id)
    local sock = Net.sockets[id]
    if sock then
        if sock.peer then
            local peer = Net.sockets[sock.peer]
            if peer then
                peer.state = "closed"
                peer.peer = nil
            end
        end
        if sock.port then
            Net.listeners[sock.port] = nil
        end
        Net.sockets[id] = nil
    end
end

Net.http = {}

Net.http.sites = {
    ["http://love.os/"] = [[
        <h1>Welcome to LoveOS</h1>
        <p>The operating system with soul.</p>
        <hr>
        <p>Links:</p>
        <a href="http://love.os/about">About Us</a>
        <a href="http://love.os/news">Latest News</a>
    ]],
    ["http://love.os/about"] = [[
        <h1>About LoveOS</h1>
        <p>Built with Love2D and Lua.</p>
        <p>Designed for fun and creativity.</p>
        <a href="http://love.os/">Back Home</a>
    ]],
    ["http://love.os/news"] = [[
        <h1>Latest News</h1>
        <p>2025-12-01: Browser Released!</p>
        <p>2025-11-30: Paint App Added.</p>
        <a href="http://love.os/">Back Home</a>
    ]]
}

function Net.http.get(url)
    -- Simulate network delay?
    -- For now, instant.
    local content = Net.http.sites[url]
    if content then
        return content, 200
    else
        return "<h1>404 Not Found</h1><p>The requested URL was not found.</p>", 404
    end
end

return Net
