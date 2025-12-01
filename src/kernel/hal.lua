local HAL = {}
local VFS = require("src.kernel.vfs")

-- HAL maps hardware stats to virtual files in /dev
-- This allows "cat /dev/gpu" etc.

function HAL.init()
    -- We need VFS to support virtual files first.
    -- HAL will register itself as a VFS handler for /dev
    -- But for now, let's just define the data retrieval functions.
end

function HAL.getGPUStats()
    local stats = love.graphics.getStats()
    return string.format(
        "GPU Stats:\nDraw Calls: %d\nCanvas Switches: %d\nTexture Memory: %.2f MB\nImages: %d\nCanvases: %d\nFonts: %d",
        stats.drawcalls,
        stats.canvasswitches,
        stats.texturememory / 1024 / 1024,
        stats.images,
        stats.canvases,
        stats.fonts
    )
end
function HAL.getMemoryStats()
    local count = collectgarbage("count")
    return string.format("Lua Memory Usage: %.2f KB (%.2f MB)", count, count / 1024)
end

function HAL.getPowerInfo()
    local state, percent, seconds = love.system.getPowerInfo()
    if state == "unknown" then return "Power: Unknown" end
    if state == "nobattery" then return "Power: AC" end
    return string.format("Battery: %d%% (%s)", percent, state)
end

function HAL.getSystemInfo()
    local os = love.system.getOS()
    local cores = love.system.getProcessorCount()
    local model = "PC"
    return string.format("OS: %s\nCores: %d\nModel: %s", os, cores, model)
end

return HAL
