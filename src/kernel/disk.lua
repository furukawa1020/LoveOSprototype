local Disk = {}

Disk.IMAGE_PATH = "disk.img"
Disk.BLOCK_SIZE = 512
Disk.DISK_SIZE = 1024 * 1024 -- 1MB
Disk.data = nil

-- SimpleFS Structure
-- Block 0: Superblock (Magic "SFS1", Size, RootDirBlock)
-- Block 1-N: FAT (File Allocation Table)
-- Block M: Root Directory
-- Rest: Data

function Disk.init()
    -- Load disk image
    if love.filesystem.getInfo(Disk.IMAGE_PATH) then
        Disk.data = love.filesystem.read(Disk.IMAGE_PATH)
    else
        Disk.format()
    end
end

function Disk.format()
    print("Formatting Virtual Disk...")
    -- Create empty disk
    local blocks = math.floor(Disk.DISK_SIZE / Disk.BLOCK_SIZE)
    local emptyBlock = string.rep("\0", Disk.BLOCK_SIZE)
    
    -- We build the string in chunks to avoid memory issues? 
    -- 1MB is small enough for Lua string.
    local t = {}
    for i=1, blocks do t[i] = emptyBlock end
    Disk.data = table.concat(t)
    
    -- Write Superblock
    -- Manual packing for LuaJIT compatibility (Little Endian 4-byte int)
    local b1 = blocks % 256
    local b2 = math.floor(blocks / 256) % 256
    local b3 = math.floor(blocks / 65536) % 256
    local b4 = math.floor(blocks / 16777216) % 256
    Disk.writeBlock(0, "SFS1" .. string.char(b1, b2, b3, b4))
    
    -- Save
    Disk.sync()
end

function Disk.sync()
    love.filesystem.write(Disk.IMAGE_PATH, Disk.data)
end

function Disk.readBlock(index)
    local start = index * Disk.BLOCK_SIZE + 1
    return Disk.data:sub(start, start + Disk.BLOCK_SIZE - 1)
end

function Disk.writeBlock(index, data)
    local start = index * Disk.BLOCK_SIZE + 1
    -- Pad data
    if #data < Disk.BLOCK_SIZE then
        data = data .. string.rep("\0", Disk.BLOCK_SIZE - #data)
    elseif #data > Disk.BLOCK_SIZE then
        data = data:sub(1, Disk.BLOCK_SIZE)
    end
    
    -- Replace in string (inefficient in Lua, but works for 1MB)
    local before = Disk.data:sub(1, start - 1)
    local after = Disk.data:sub(start + Disk.BLOCK_SIZE)
    Disk.data = before .. data .. after
end

-- File System Layer (Simplified)
function Disk.writeFile(filename, content)
    -- For this prototype, we just store files sequentially or in a simple table in Block 1?
    -- Implementing full FAT is complex for this snippet.
    -- Let's implement a "Flat FS" where Block 1 contains a JSON directory.
    
    -- Read Directory
    local dirBlock = Disk.readBlock(1)
    local dirStr = dirBlock:match("^(%Z+)") -- Read until null
    local dir = {}
    if dirStr and dirStr ~= "" then
        -- Simple parsing "name:block;"
        for name, block in dirStr:gmatch("([^:]+):(%d+);") do
            dir[name] = tonumber(block)
        end
    end
    
    -- Find free block (Naive: just increment from last used)
    local freeBlock = 2
    for _, b in pairs(dir) do
        if b >= freeBlock then freeBlock = b + 1 end
    end
    
    -- Write Content
    Disk.writeBlock(freeBlock, content)
    
    -- Update Directory
    dir[filename] = freeBlock
    local newDirStr = ""
    for k, v in pairs(dir) do
        newDirStr = newDirStr .. k .. ":" .. v .. ";"
    end
    Disk.writeBlock(1, newDirStr)
    
    Disk.sync()
    return true
end

function Disk.readFile(filename)
    local dirBlock = Disk.readBlock(1)
    local dirStr = dirBlock:match("^(%Z+)")
    if not dirStr then return nil end
    
    for name, block in dirStr:gmatch("([^:]+):(%d+);") do
        if name == filename then
            local content = Disk.readBlock(tonumber(block))
            return content:match("^(%Z+)") -- Trim nulls
        end
    end
    return nil
end

return Disk
