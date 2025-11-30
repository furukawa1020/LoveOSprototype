local IPC = {}

IPC.channels = {}
IPC.listeners = {}

function IPC.send(channel, message)
    if IPC.listeners[channel] then
        for _, callback in ipairs(IPC.listeners[channel]) do
            callback(message)
        end
    end
end

function IPC.subscribe(channel, callback)
    if not IPC.listeners[channel] then
        IPC.listeners[channel] = {}
    end
    table.insert(IPC.listeners[channel], callback)
end

function IPC.unsubscribe(channel, callback)
    if IPC.listeners[channel] then
        for i, cb in ipairs(IPC.listeners[channel]) do
            if cb == callback then
                table.remove(IPC.listeners[channel], i)
                break
            end
        end
    end
end

return IPC
