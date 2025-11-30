local VFS = {}

-- File System Structure
-- / (Root) -> Mapped to love.filesystem (Source + Save Directory)

VFS.root = {
    type = "mount",
    source = "love"
}

function VFS.init()
    -- Ensure basic directories exist in save dir if needed
    love.filesystem.createDirectory("home")
    love.filesystem.createDirectory("src") -- For overlay
end

-- Helper to traverse path
local function traverse(path)
    -- Simplified: Root is always love filesystem
    -- We can just pass the path directly to love.filesystem
    -- But we might want virtual directories later (like /proc)
    
    -- For now, let's just assume everything is love filesystem
    -- unless we add special virtual paths.
    
    -- Check for virtual paths
    if path:sub(1, 5) == "/proc" then
        return "virtual", path
    end
    
    -- Remove leading slash
    local relPath = path
    if relPath:sub(1, 1) == "/" then
        relPath = relPath:sub(2)
    end
    
    return "love", relPath
end

function VFS.write(path, content)
    local type, target = traverse(path)
    
    if type == "love" then
        -- Ensure parent directory exists
        local parent = target:match("(.+)/[^/]+$")
        if parent then
            love.filesystem.createDirectory(parent)
        end
        return love.filesystem.write(target, content)
    else
        return false, "Cannot write to virtual path"
    end
end

function VFS.read(path)
    local type, target = traverse(path)
    
    if type == "love" then
        return love.filesystem.read(target)
    else
        return nil, "File not found"
    end
end

function VFS.listFiles(path)
    local type, target = traverse(path)
    
    if type == "love" then
        local items = {}
        local lItems = love.filesystem.getDirectoryItems(target)
        for _, name in ipairs(lItems) do
            local fullPath = target == "" and name or (target .. "/" .. name)
            local info = love.filesystem.getInfo(fullPath)
            if info then
                table.insert(items, {
                    name = name,
                    type = info.type,
                    size = info.size
                })
            end
        end
        return items
    else
        return {}
    end
end

function VFS.mkdir(path)
    local type, target = traverse(path)
    if type == "love" then
        return love.filesystem.createDirectory(target)
    else
        return false, "Cannot mkdir in virtual path"
    end
end

return VFS
