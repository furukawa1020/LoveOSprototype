local HTML = {}

function HTML.parse(markup)
    local nodes = {}
    local pos = 1
    
    while pos <= #markup do
        local startTag, endTag = markup:find("<.-", pos)
        
        if not startTag then
            -- Remaining text
            local text = markup:sub(pos)
            if text:match("%S") then
                table.insert(nodes, {type = "text", content = text})
            end
            break
        end
        
        -- Text before tag
        if startTag > pos then
            local text = markup:sub(pos, startTag - 1)
            if text:match("%S") then
                table.insert(nodes, {type = "text", content = text})
            end
        end
        
        -- Parse tag
        local tagEnd = markup:find(">", startTag)
        if not tagEnd then break end -- Malformed
        
        local tagContent = markup:sub(startTag + 1, tagEnd - 1)
        local tagName = tagContent:match("^(%w+)")
        local isClosing = tagContent:sub(1, 1) == "/"
        
        if isClosing then
            -- Handle closing tag (simplified: just ignore for flat structure or pop stack)
            -- For this simple engine, we assume flat or simple nesting handled by renderer
        else
            -- Attributes
            local attrs = {}
            for k, v in tagContent:gmatch("(%w+)=['\"](.-)['\"]") do
                attrs[k] = v
            end
            
            table.insert(nodes, {type = "tag", name = tagName, attrs = attrs})
        end
        
        pos = tagEnd + 1
    end
    
    return nodes
end

function HTML.render(nodes, x, y, width)
    local cursorX, cursorY = x, y
    local lineHeight = 20
    
    for _, node in ipairs(nodes) do
        if node.type == "text" then
            sys.graphics.setColor(0, 0, 0)
            sys.graphics.print(node.content, cursorX, cursorY)
            cursorY = cursorY + lineHeight
        elseif node.type == "tag" then
            if node.name == "h1" then
                cursorY = cursorY + 10
                sys.graphics.setColor(0, 0, 0)
                -- Bold/Large (simulated)
                sys.graphics.print(node.content or "", cursorX, cursorY, 0, 2, 2)
                cursorY = cursorY + 40
            elseif node.name == "p" then
                cursorY = cursorY + 10
            elseif node.name == "hr" then
                sys.graphics.setColor(0.8, 0.8, 0.8)
                sys.graphics.rectangle("fill", x, cursorY + 10, width, 2)
                cursorY = cursorY + 20
            elseif node.name == "img" then
                -- Placeholder for image
                sys.graphics.setColor(0.9, 0.9, 0.9)
                sys.graphics.rectangle("fill", cursorX, cursorY, 100, 100)
                sys.graphics.setColor(0.5, 0.5, 0.5)
                sys.graphics.print("IMG: " .. (node.attrs.src or ""), cursorX + 10, cursorY + 40)
                cursorY = cursorY + 110
            elseif node.name == "a" then
                sys.graphics.setColor(0, 0, 1)
                sys.graphics.print(node.attrs.href or "link", cursorX, cursorY)
                cursorY = cursorY + lineHeight
            end
        end
    end
end

return HTML
