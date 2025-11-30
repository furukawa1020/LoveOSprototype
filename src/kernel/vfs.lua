local VFS = {}

VFS.mounts = {}

function VFS.init()
    VFS.mounts["/"] = {type = "memory", files = {}}
    VFS.mounts["/home"] = {type = "love", path = ""}
end

function VFS.write(path, content)
    -- Simple implementation: if starts with /home, use love.filesystem
    if path:sub(1, 5) == "/home" then
        local relPath = path:sub(7)
        return love.filesystem.write(relPath, content)
    else
        -- Memory write (volatile)
        VFS.mounts["/"].files[path] = content
        return true
    end
end

function VFS.read(path)
    if path:sub(1, 5) == "/home" then
        local relPath = path:sub(7)
        return love.filesystem.read(relPath)
    else
        return VFS.mounts["/"].files[path]
    end
end

function VFS.listFiles(path)
    if path == "/home" then
        return love.filesystem.getDirectoryItems("")
    else
        local items = {}
        for k, v in pairs(VFS.mounts["/"].files) do
            table.insert(items, k)
        end
        return items
    end
end

return VFS
