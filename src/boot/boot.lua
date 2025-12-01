local Boot = {}
local Bus = require("src.kernel.bus")
local Disk = require("src.kernel.disk")

function Boot.start()
    print("BIOS: POST...")
    Bus.init()
    Disk.init()
    
    print("BIOS: Booting from Disk...")
    
    -- In a real emulator, we would read the first sector (MBR) into RAM and jump to it.
    -- Here, we simulate loading the Kernel into "Memory".
    
    -- 1. Read Kernel "Binary" (Simulated by requiring the module)
    -- In a true bare metal sim, we would read bytecode from disk.img.
    -- For now, let's just initialize the Kernel module, but conceptually it's loaded.
    
    print("BOOT: Loading Kernel...")
    local Kernel = require("src.kernel.core")
    Kernel.init()
    
    -- Handover control to Kernel
    return Kernel
end

return Boot
