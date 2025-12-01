local Bus = {}
local Mem = require("src.kernel.mem")
local HAL = require("src.kernel.hal")

-- Memory Map
-- 0x00000000 - 0x03FFFFFF: RAM (64MB)
-- 0x04000000 - 0x040FFFFF: VRAM (1MB)
-- 0x04100000 - 0x041000FF: Audio Registers
-- 0xFFFFFFFF: Reset Vector

Bus.VRAM_START = 0x04000000
Bus.VRAM_END   = 0x040FFFFF
Bus.AUDIO_START= 0x04100000
Bus.AUDIO_END  = 0x041000FF

function Bus.init()
    Mem.init()
end

function Bus.read(addr)
    if addr < Bus.VRAM_START then
        return Mem.read(addr)
    elseif addr <= Bus.VRAM_END then
        -- Read from VRAM (Simulated)
        return 0 -- TODO: Implement VRAM read
    elseif addr <= Bus.AUDIO_END then
        return 0
    else
        return 0
    end
end

function Bus.write(addr, val)
    if addr < Bus.VRAM_START then
        Mem.write(addr, val)
    elseif addr <= Bus.VRAM_END then
        -- Write to VRAM
        -- In a real emulator, this would update a texture.
        -- For now, we just log it or ignore it to save perf.
        -- print("VRAM Write: " .. string.format("%x", addr) .. " = " .. val)
    elseif addr <= Bus.AUDIO_END then
        -- Audio Registers
        if addr == Bus.AUDIO_START then
            -- 0x04100000: Tone Frequency
            local Audio = require("src.system.audio")
            Audio.playTone(val * 10, 0.1)
        end
    end
end

return Bus
