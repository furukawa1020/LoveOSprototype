local Scheduler = {}
local Process = require("src.kernel.process")

Scheduler.processes = {}

function Scheduler.spawn(name, func)
    local proc = Process.new(name, func)
    table.insert(Scheduler.processes, proc)
    print("Spawned process: " .. name)
    return proc
end

function Scheduler.update(dt)
    for i = #Scheduler.processes, 1, -1 do
        local proc = Scheduler.processes[i]
        
        if proc.status == "running" then
            proc:resume(dt)
        end
        
        if proc.status == "dead" then
            print("Process died: " .. proc.name)
            table.remove(Scheduler.processes, i)
        end
    end
end

-- Draw is usually handled by WM, but some background processes might draw directly?
-- For now, we assume visual processes have windows managed by WM.

return Scheduler
