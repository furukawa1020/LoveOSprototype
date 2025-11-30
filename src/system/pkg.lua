local Pkg = {}
local VFS = require("src.kernel.vfs")
local Terminal = require("src.system.terminal")

-- Simulated Package Repository
Pkg.repo = {
    calculator = {
        name = "Calculator",
        version = "1.0",
        files = {
            ["/home/apps/calc.lua"] = [[
local Calc = {}
function Calc.run()
    local WM = require("src.kernel.wm")
    local Scheduler = require("src.kernel.scheduler")
    local process = Scheduler.getCurrentProcess()
    local win = WM.createWindow(process, "Calculator", 150, 150, 200, 300)
    
    local result = "0"
    
    while true do
        local dt = coroutine.yield()
        love.graphics.setCanvas(win.canvas)
        love.graphics.clear(0.2, 0.2, 0.2, 1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(result, 10, 10, 0, 2, 2)
        love.graphics.print("Press 1-9 to add", 10, 50)
        love.graphics.setCanvas()
    end
end
return Calc
]]
        }
    },
    clock = {
        name = "Clock Widget",
        version = "1.1",
        files = {
            ["/home/apps/clock.lua"] = [[
local Clock = {}
function Clock.run()
    local WM = require("src.kernel.wm")
    local Scheduler = require("src.kernel.scheduler")
    local process = Scheduler.getCurrentProcess()
    local win = WM.createWindow(process, "Clock", 400, 50, 150, 80)
    
    while true do
        local dt = coroutine.yield()
        love.graphics.setCanvas(win.canvas)
        love.graphics.clear(0, 0, 0, 0.5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(os.date("%H:%M:%S"), 10, 20, 0, 2, 2)
        love.graphics.setCanvas()
    end
end
return Clock
]]
        }
    }
}

function Pkg.install(pkgName)
    local pkg = Pkg.repo[pkgName]
    if not pkg then
        return false, "Package not found: " .. pkgName
    end
    
    -- "Download" and install files
    for path, content in pairs(pkg.files) do
        VFS.write(path, content)
    end
    
    return true, "Installed " .. pkg.name .. " v" .. pkg.version
end

function Pkg.list()
    local list = {}
    for name, pkg in pairs(Pkg.repo) do
        table.insert(list, name .. " (" .. pkg.version .. ")")
    end
    return list
end

return Pkg
