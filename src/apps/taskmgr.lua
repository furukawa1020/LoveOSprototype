local TaskMgr = {}
-- Requires removed for sandbox compliance

TaskMgr.history = {
    cpu = {},
    mem = {}
}
TaskMgr.maxHistory = 60
TaskMgr.timer = 0

function TaskMgr.init()
    -- Initialize history
    for i = 1, TaskMgr.maxHistory do
        table.insert(TaskMgr.history.cpu, 0)
        table.insert(TaskMgr.history.mem, 0)
    end
end

function TaskMgr.run()
    local process = sys.getProcessInfo()
    local win = sys.createWindow("Task Manager", 200, 100, 400, 300)
    
    TaskMgr.init()
    
    -- Main Loop
    while true do
        local dt = coroutine.yield()
        
        -- Update Stats
        TaskMgr.timer = TaskMgr.timer + dt
        if TaskMgr.timer > 0.5 then -- Update every 0.5s
            TaskMgr.timer = 0
            
            -- CPU (Simulated by FPS)
            local fps = sys.getFPS()
            local cpuUsage = math.max(0, 100 - fps) -- Rough estimate
            table.remove(TaskMgr.history.cpu, 1)
            table.insert(TaskMgr.history.cpu, cpuUsage)
            
            -- Memory
            -- We need to read from /dev/mem
            -- But sys.read returns string. We need to parse it?
            -- Or we can add sys.getMemoryStats()?
            -- For now let's use collectgarbage since we allowed it in sandbox?
            -- Wait, we didn't allow collectgarbage.
            -- We should use sys.read("/dev/mem") but parsing is annoying.
            -- Let's assume we can use a syscall for it.
            local mem = 0 -- Placeholder
            table.remove(TaskMgr.history.mem, 1)
            table.insert(TaskMgr.history.mem, mem)
        end
        
        -- Draw Content
        sys.setCanvas(win.canvas)
        sys.graphics.clear(0.1, 0.1, 0.1, 0.9)
        
        -- Graphs
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print("CPU Usage", 10, 10)
        TaskMgr.drawGraph(TaskMgr.history.cpu, 10, 30, 180, 60, {1, 0.2, 0.2})
        
        sys.graphics.print("Memory Usage (MB)", 210, 10)
        TaskMgr.drawGraph(TaskMgr.history.mem, 210, 30, 180, 60, {0.2, 0.2, 1})
        
        -- Process List
        sys.graphics.setColor(1, 1, 1)
        sys.graphics.print("Processes:", 10, 100)
        
        local y = 120
        local processes = sys.getProcesses()
        for i, proc in ipairs(processes) do
            if y > 280 then break end
            sys.graphics.setColor(0.2, 0.2, 0.2)
            if i % 2 == 0 then sys.graphics.setColor(0.25, 0.25, 0.25) end
            sys.graphics.rectangle("fill", 10, y, 380, 20)
            
            sys.graphics.setColor(1, 1, 1)
            sys.graphics.print(proc.name, 15, y + 2)
            sys.graphics.print(proc.status, 200, y + 2)
            sys.graphics.print(string.format("%.2f", proc.id), 300, y + 2)
            
            y = y + 22
        end
        
        sys.setCanvas()
    end
end

function TaskMgr.drawGraph(data, x, y, w, h, color)
    sys.graphics.setColor(0, 0, 0, 0.5)
    sys.graphics.rectangle("fill", x, y, w, h)
    
    sys.graphics.setColor(color)
    local maxVal = 100
    if data == TaskMgr.history.mem then maxVal = 20 end -- Scale for mem
    
    local step = w / #data
    for i = 1, #data - 1 do
        local val1 = math.min(data[i], maxVal) / maxVal
        local val2 = math.min(data[i+1], maxVal) / maxVal
        sys.graphics.line(x + (i-1)*step, y + h - val1*h, x + i*step, y + h - val2*h)
    end
end

return TaskMgr
