local Scheduler = {}
local Process = require("src.kernel.process")

Scheduler.processes = {}

function Scheduler.spawn(name, func)
    local proc = Process.new(name, func)
    table.insert(Scheduler.processes, proc)
    print("Spawned process: " .. name)
    return proc
end

function Scheduler.add(proc)
    table.insert(Scheduler.processes, proc)
    print("Added process: " .. proc.name)
    return proc
end

Scheduler.currentProcess = nil

function Scheduler.getCurrentProcess()
    return Scheduler.currentProcess
end

function Scheduler.update(dt)
    local timeSlice = 0.01 -- 10ms time slice
    
    for i = #Scheduler.processes, 1, -1 do
        local proc = Scheduler.processes[i]
        
        if proc.status == "running" then
            Scheduler.currentProcess = proc
            
            -- Preemption Hook
            -- Check time every 1000 instructions
            local startTime = love.timer.getTime()
            
            local function hook()
                if love.timer.getTime() - startTime > timeSlice then
                    -- Force yield
                    coroutine.yield()
                end
            end
            
            -- Set hook on the process coroutine
            if proc.co and coroutine.status(proc.co) ~= "dead" then
                debug.sethook(proc.co, hook, "", 1000)
            end
            
            proc:resume(dt)
            
            -- Clear hook
            if proc.co and coroutine.status(proc.co) ~= "dead" then
                debug.sethook(proc.co)
            end
            
            Scheduler.currentProcess = nil
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
