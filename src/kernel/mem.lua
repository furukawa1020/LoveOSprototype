local ffi = require("ffi")
local Mem = {}

-- 64MB RAM
Mem.SIZE = 64 * 1024 * 1024
Mem.ram = ffi.new("uint8_t[?]", Mem.SIZE)

function Mem.init()
    print("VMM: Initialized " .. (Mem.SIZE / 1024 / 1024) .. "MB RAM")
    -- Zero out memory
    ffi.fill(Mem.ram, Mem.SIZE, 0)
end

function Mem.read(addr)
    if addr < 0 or addr >= Mem.SIZE then
        error("Segmentation Fault: Read at " .. tostring(addr))
    end
    return Mem.ram[addr]
end

function Mem.write(addr, val)
    if addr < 0 or addr >= Mem.SIZE then
        error("Segmentation Fault: Write at " .. tostring(addr))
    end
    Mem.ram[addr] = val
end

function Mem.readInt(addr)
    -- Little Endian
    local b1 = Mem.read(addr)
    local b2 = Mem.read(addr + 1)
    local b3 = Mem.read(addr + 2)
    local b4 = Mem.read(addr + 3)
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function Mem.writeInt(addr, val)
    -- Little Endian
    Mem.write(addr, val % 256)
    Mem.write(addr + 1, math.floor(val / 256) % 256)
    Mem.write(addr + 2, math.floor(val / 65536) % 256)
    Mem.write(addr + 3, math.floor(val / 16777216) % 256)
end

-- Direct pointer access for high performance (Unsafe)
function Mem.getPointer(addr)
    return Mem.ram + addr
end

return Mem
