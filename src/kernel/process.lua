local Process = {}
Process.__index = Process

function Process.new(name, func)
    local self = setmetatable({}, Process)
    self.id = love.timer.getTime() .. math.random() -- Simple unique ID
    self.name = name
    self.co = coroutine.create(func)
    self.status = "running" -- running, dead, suspended
    self.window = nil -- Reference to associated window if any
    self.env = {} -- Sandboxed environment (optional)
    return self
end

function Process:resume(dt, ...)
    if self.status ~= "running" then return false end
    
    -- Resume coroutine
    local success, result = coroutine.resume(self.co, dt, ...)
    
    if not success then
        print("Process " .. self.name .. " crashed: " .. tostring(result))
        self.status = "dead"
        return false
    end
    
    if coroutine.status(self.co) == "dead" then
        self.status = "dead"
    end
    
    return true
end

function Process:kill()
    self.status = "dead"
end

return Process
