local Registry = {}
local VFS = require("src.kernel.vfs")

Registry.data = {
    theme = "default",
    wallpaperColor = {0.1, 0.1, 0.2},
    bootSound = true
}

local REGISTRY_PATH = "/home/system/registry.dat"

function Registry.init()
    -- Ensure system directory exists
    VFS.mkdir("/home/system")
    Registry.load()
end

function Registry.load()
    local content = VFS.read(REGISTRY_PATH)
    if content then
        -- Simple serialization: key=value lines? Or Lua table string?
        -- Let's use a simple key=value parser for now, or loadstring if we trust it (it's our OS)
        -- For safety and simplicity, let's use a custom parser or JSON if available.
        -- Since we don't have JSON lib, let's use Lua chunk loading for now (unsafe but "Löve Philosophy")
        local chunk = loadstring("return " .. content)
        if chunk then
            local success, data = pcall(chunk)
            if success and type(data) == "table" then
                for k, v in pairs(data) do
                    Registry.data[k] = v
                end
            end
        end
    end
end

function Registry.save()
    -- Serialize to Lua table string
    local str = "{\n"
    for k, v in pairs(Registry.data) do
        if type(v) == "string" then
            str = str .. string.format("    [\"%s\"] = \"%s\",\n", k, v)
        elseif type(v) == "number" then
            str = str .. string.format("    [\"%s\"] = %s,\n", k, v)
        elseif type(v) == "boolean" then
            str = str .. string.format("    [\"%s\"] = %s,\n", k, tostring(v))
        elseif type(v) == "table" then
            -- Simple array support for color
            str = str .. string.format("    [\"%s\"] = {%s, %s, %s},\n", k, v[1], v[2], v[3])
        end
    end
    str = str .. "}"
    
    VFS.write(REGISTRY_PATH, str)
end

function Registry.get(key)
    return Registry.data[key]
end

function Registry.set(key, value)
    Registry.data[key] = value
    Registry.save()
end

return Registry
