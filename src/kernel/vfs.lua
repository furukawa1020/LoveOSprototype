local VFS = {}

-- File System Structure
-- / (Root)
--   /sys (Memory - System Files)
--   /home (Love Filesystem - Persistent)

VFS.root = {
    type = "directory",
    children = {
        sys = {
            type = "directory",
            children = {}
        },
        home = {
            type = "mount",
            source = "love"
        }
    }
}

function VFS.init()
    -- Ensure save directory exists
    if not love.filesystem.getInfo("home") then
        love.filesystem.createDirectory("home")
    end
end

-- Helper to traverse path
local function traverse(path)
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    
    local current = VFS.root
    for i, part in ipairs(parts) do
        if current.type == "mount" and current.source == "love" then
            -- Hand off to love.filesystem
            local relPath = table.concat(parts, "/", i)
            return "love", relPath
        elseif current.type == "directory" then
            if current.children[part] then
                current = current.children[part]
            else
                return nil, "Path not found: " .. part
            end
        else
            return nil, "Not a directory: " .. part
        end
    end
    
    return "node", current
end

function VFS.write(path, content)
    local type, target = traverse(path)
    
    if type == "love" then
        -- Write to love.filesystem
        -- Ensure parent directory exists? Love handles this usually? No, need to check.
        return love.filesystem.write(target, content)
    elseif type == "node" then
        if target.type == "file" then
            target.content = content
            return true
        else
            return false, "Cannot write to directory"
        end
    else
        -- Create file in memory if parent exists
        -- This is tricky with the current traverse. 
        -- Simplified: Only support writing to existing files or /home for now.
        -- Or implement full path creation.
        
        -- Let's support creating files in memory for /sys
        local parentPath = path:match("(.+)/[^/]+$") or "/"
        local fileName = path:match("[^/]+$")
        
        if parentPath == "/" then
            -- Root write? Deny for now except special cases
            return false, "Permission denied"
        end
        
        local pType, pTarget = traverse(parentPath)
        if pType == "node" and pTarget.type == "directory" then
            pTarget.children[fileName] = {type = "file", content = content}
            return true
        end
        
        return false, "Path not found"
    end
end

function VFS.read(path)
    local type, target = traverse(path)
    
    if type == "love" then
        return love.filesystem.read(target)
    elseif type == "node" then
        if target.type == "file" then
            return target.content
        else
            return nil, "Is a directory"
        end
    else
        return nil, "File not found"
    end
end

function VFS.listFiles(path)
    local type, target = traverse(path)
    
    local items = {}
    
    if type == "love" then
        local lItems = love.filesystem.getDirectoryItems(target)
        for _, name in ipairs(lItems) do
            local info = love.filesystem.getInfo(target .. "/" .. name)
            table.insert(items, {
                name = name,
                type = info.type,
                size = info.size
            })
        end
    elseif type == "node" and target.type == "directory" then
        for name, node in pairs(target.children) do
            table.insert(items, {
                name = name,
                type = node.type == "mount" and "directory" or node.type,
                size = node.content and #node.content or 0
            })
        end
    elseif type == "node" and target.type == "mount" and target.source == "love" then
         -- Root of mount
         local lItems = love.filesystem.getDirectoryItems("")
         for _, name in ipairs(lItems) do
            local info = love.filesystem.getInfo(name)
            table.insert(items, {
                name = name,
                type = info.type,
                size = info.size
            })
        end
    end
    
    return items
end

function VFS.mkdir(path)
    local type, target = traverse(path)
    if type == "love" then
        return love.filesystem.createDirectory(target)
    else
        -- Memory mkdir
        local parentPath = path:match("(.+)/[^/]+$")
        local dirName = path:match("[^/]+$")
        local pType, pTarget = traverse(parentPath)
        if pType == "node" and pTarget.type == "directory" then
            pTarget.children[dirName] = {type = "directory", children = {}}
            return true
        end
        return false, "Parent not found"
    end
end

return VFS
