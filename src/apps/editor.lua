local Editor = {}
local VFS = require("src.kernel.vfs")
local utf8 = require("utf8")

Editor.lines = {""}
Editor.cursorX = 1
Editor.cursorY = 1
Editor.scrollX = 0
Editor.scrollY = 0
Editor.filePath = nil

function Editor.init(args)
    if args and args.file then
        Editor.open(args.file)
    else
        Editor.lines = {"-- New File", ""}
    end
end

function Editor.open(path)
    Editor.filePath = path
    local content = VFS.read(path)
    if content then
        Editor.lines = {}
        for line in string.gmatch(content .. "\n", "(.-)\n") do
            table.insert(Editor.lines, line)
        end
        if #Editor.lines == 0 then Editor.lines = {""} end
    else
        Editor.lines = {"-- Error loading file"}
    end
end

function Editor.save()
    if Editor.filePath then
        local content = table.concat(Editor.lines, "\n")
        VFS.write(Editor.filePath, content)
    end
end

function Editor.update(dt)
    -- Blink cursor?
end

function Editor.draw()
    love.graphics.clear(0.15, 0.15, 0.18) -- Dark background
    
    local font = love.graphics.getFont()
    local lh = font:getHeight()
    
    -- Draw Lines
    for i, line in ipairs(Editor.lines) do
        local y = (i - 1) * lh - Editor.scrollY
        if y >= -lh and y < love.graphics.getHeight() then
            -- Line Number
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.print(tostring(i), 5, y)
            
            -- Text
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.print(line, 40, y)
        end
    end
    
    -- Draw Cursor
    local cy = (Editor.cursorY - 1) * lh - Editor.scrollY
    local cx = 40 + font:getWidth(string.sub(Editor.lines[Editor.cursorY] or "", 1, Editor.cursorX - 1))
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("fill", cx, cy, 2, lh)
    
    -- Status Bar
    local h = love.graphics.getHeight()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, h - 25, love.graphics.getWidth(), 25)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(Editor.filePath or "Untitled", 10, h - 20)
    love.graphics.print("Ln " .. Editor.cursorY .. ", Col " .. Editor.cursorX, love.graphics.getWidth() - 150, h - 20)
end

function Editor.textinput(t)
    local line = Editor.lines[Editor.cursorY]
    local pre = string.sub(line, 1, Editor.cursorX - 1)
    local post = string.sub(line, Editor.cursorX)
    Editor.lines[Editor.cursorY] = pre .. t .. post
    Editor.cursorX = Editor.cursorX + 1
end

function Editor.keypressed(key)
    if key == "return" then
        local line = Editor.lines[Editor.cursorY]
        local pre = string.sub(line, 1, Editor.cursorX - 1)
        local post = string.sub(line, Editor.cursorX)
        Editor.lines[Editor.cursorY] = pre
        table.insert(Editor.lines, Editor.cursorY + 1, post)
        Editor.cursorY = Editor.cursorY + 1
        Editor.cursorX = 1
    elseif key == "backspace" then
        if Editor.cursorX > 1 then
            local line = Editor.lines[Editor.cursorY]
            local byteoffset = utf8.offset(line, -1, Editor.cursorX)
            if byteoffset then
                local pre = string.sub(line, 1, byteoffset - 1)
                local post = string.sub(line, Editor.cursorX)
                Editor.lines[Editor.cursorY] = pre .. post
                Editor.cursorX = Editor.cursorX - (Editor.cursorX - byteoffset) -- simplified
                Editor.cursorX = utf8.len(pre) + 1 -- Re-calc for safety
            end
        elseif Editor.cursorY > 1 then
            local currentLine = Editor.lines[Editor.cursorY]
            table.remove(Editor.lines, Editor.cursorY)
            Editor.cursorY = Editor.cursorY - 1
            Editor.cursorX = utf8.len(Editor.lines[Editor.cursorY]) + 1
            Editor.lines[Editor.cursorY] = Editor.lines[Editor.cursorY] .. currentLine
        end
    elseif key == "up" then
        if Editor.cursorY > 1 then Editor.cursorY = Editor.cursorY - 1 end
    elseif key == "down" then
        if Editor.cursorY < #Editor.lines then Editor.cursorY = Editor.cursorY + 1 end
    elseif key == "left" then
        if Editor.cursorX > 1 then Editor.cursorX = Editor.cursorX - 1 end
    elseif key == "right" then
        if Editor.cursorX <= utf8.len(Editor.lines[Editor.cursorY]) then Editor.cursorX = Editor.cursorX + 1 end
    elseif key == "s" and love.keyboard.isDown("lctrl") then
        Editor.save()
    end
end

function Editor.run()
    local WM = require("src.kernel.wm")
    -- Create Window
    local win = WM.createWindow(nil, "Löve Edit", 100, 100, 800, 600)
    
    Editor.init()
    
    while true do
        local dt = coroutine.yield()
        
        Editor.update(dt)
        
        love.graphics.setCanvas(win.canvas)
        Editor.draw()
        love.graphics.setCanvas()
    end
end

return Editor
