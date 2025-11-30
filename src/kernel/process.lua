local Process = {}
Process.__index = Process

function Process.new(name, pathOrFunc, isPath)
    local self = setmetatable({}, Process)
    self.id = love.timer.getTime() .. math.random()
    self.name = name
    
    -- Sandboxing
    local env = {
        -- Standard Lua Libs
        pairs = pairs, ipairs = ipairs, next = next,
        tostring = tostring, tonumber = tonumber, type = type,
        print = print, error = error,
        pcall = pcall, xpcall = xpcall, assert = assert, select = select,
        table = table, string = string, math = math,
        os = {date = os.date, time = os.time, clock = os.clock},
        coroutine = coroutine,
    }
    self.env = env
    
    -- Load Code
    local chunk
    if isPath then
        -- Load from VFS
        local VFS = require("src.kernel.vfs")
        local content, err = VFS.read(pathOrFunc)
        if not content then
            print("Error loading process " .. name .. ": " .. tostring(err))
            chunk = function() print("Process failed to load: " .. tostring(err)) end
        else
            local func, loadErr = loadstring(content, pathOrFunc)
            if not func then
                print("Error compiling process " .. name .. ": " .. tostring(loadErr))
                chunk = function() print("Process compilation failed: " .. tostring(loadErr)) end
            else
                chunk = func
            end
        end
    else
        chunk = pathOrFunc
    end
    
    -- Apply Sandbox
    if type(chunk) == "function" then
        setfenv(chunk, env)
    end
    
    local entry = chunk
    local handler = nil
    
    -- If loaded from path, execute to get module
    if isPath then
        local success, result = pcall(chunk)
        if success then
            if type(result) == "table" then
                handler = result
                entry = result.run or function() end
            elseif type(result) == "function" then
                entry = result
            end
        else
            print("Error running process chunk " .. name .. ": " .. tostring(result))
            entry = function() end
        end
    elseif type(pathOrFunc) == "table" then
        -- Handle table passed directly (legacy/internal)
        handler = pathOrFunc
        entry = pathOrFunc.run
        -- We need to sandbox the table methods? 
        -- If passed as table, it's likely already loaded via require (BAD for sandbox).
        -- We should avoid this for apps.
    end
    
    self.co = coroutine.create(entry)
    self.status = "running"
    self.window = nil
    self.handler = handler
    
    -- Inject Syscalls
    local Syscall = require("src.kernel.syscall")
    self.env.sys = Syscall.createInterface(self)
    
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
