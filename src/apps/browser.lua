local Browser = {}
local HTML = require("src.lib.html")

Browser.url = "http://love.os/"
Browser.history = {}
Browser.historyIndex = 0
Browser.content = {}
Browser.scroll = 0
Browser.status = "Ready"

function Browser.run()
    local win = sys.createWindow("Browser", 50, 50, 800, 600)
    Browser.navigate(Browser.url)
    
    while true do
        local dt = coroutine.yield()
        
        sys.setCanvas(win.canvas)
        Browser.draw()
        sys.setCanvas()
    end
end

function Browser.navigate(url)
    Browser.status = "Loading..."
    Browser.url = url
    
    -- Fetch content
    local html, code = sys.net.http.get(url)
    
    if code == 200 then
        Browser.content = HTML.parse(html)
        Browser.status = "Done"
    else
        Browser.content = HTML.parse("<h1>Error " .. code .. "</h1><p>" .. html .. "</p>")
        Browser.status = "Error"
    end
    
    -- History
    -- Simplified history management
end

function Browser.draw()
    sys.graphics.clear(1, 1, 1, 1)
    
    -- Address Bar
    sys.graphics.setColor(0.9, 0.9, 0.9)
    sys.graphics.rectangle("fill", 0, 0, 800, 40)
    
    -- URL Input
    sys.graphics.setColor(1, 1, 1)
    sys.graphics.rectangle("fill", 60, 5, 600, 30, 5)
    sys.graphics.setColor(0, 0, 0)
    sys.graphics.print(Browser.url, 70, 12)
    
    -- Buttons
    sys.graphics.setColor(0.5, 0.5, 0.5)
    sys.graphics.print("<", 15, 12)
    sys.graphics.print(">", 40, 12)
    sys.graphics.print("Go", 670, 12)
    
    -- Content Area
    sys.graphics.setScissor(0, 40, 800, 560)
    
    -- Render HTML
    -- We need to handle links. HTML.render is simple, doesn't return clickable areas.
    -- We should probably enhance HTML.render to return layout or handle clicks.
    -- For now, let's just render and handle clicks by checking approximate locations?
    -- No, let's make HTML.render stateful or return a layout list.
    -- Or better, let's just use a simple immediate mode GUI approach for links in HTML.render?
    -- Since HTML.render is in lib, we can't easily change it to use sys.
    -- Let's just modify HTML.render to accept a "dry run" or return layout.
    -- Actually, let's just use a global layout table for now (hacky but works for proto).
    
    Browser.links = {}
    local cursorY = 50 - Browser.scroll
    
    for _, node in ipairs(Browser.content) do
        if node.type == "text" then
            sys.graphics.setColor(0, 0, 0)
            sys.graphics.print(node.content, 20, cursorY)
            cursorY = cursorY + 20
        elseif node.type == "tag" then
            if node.name == "h1" then
                cursorY = cursorY + 10
                sys.graphics.setColor(0, 0, 0)
                sys.graphics.print(node.content or "", 20, cursorY, 0, 2, 2)
                cursorY = cursorY + 40
            elseif node.name == "p" then
                cursorY = cursorY + 10
            elseif node.name == "hr" then
                sys.graphics.setColor(0.8, 0.8, 0.8)
                sys.graphics.rectangle("fill", 20, cursorY + 10, 760, 2)
                cursorY = cursorY + 20
            elseif node.name == "a" then
                sys.graphics.setColor(0, 0, 1)
                sys.graphics.print(node.content or node.attrs.href, 20, cursorY)
                -- Store link area
                table.insert(Browser.links, {
                    x = 20, y = cursorY, w = 200, h = 20,
                    href = node.attrs.href
                })
                cursorY = cursorY + 20
            end
        end
    end
    
    sys.graphics.setScissor()
    
    -- Status Bar
    sys.graphics.setColor(0.95, 0.95, 0.95)
    sys.graphics.rectangle("fill", 0, 580, 800, 20)
    sys.graphics.setColor(0.5, 0.5, 0.5)
    sys.graphics.print(Browser.status, 5, 582)
end

function Browser.mousepressed(x, y, button)
    -- Check links
    local my = y + Browser.scroll
    for _, link in ipairs(Browser.links) do
        if x >= link.x and x <= link.x + link.w and y >= link.y and y <= link.y + link.h then
            Browser.navigate(link.href)
            return
        end
    end
    
    -- Scroll (simple drag)
    -- Ideally wheel, but let's just click top/bottom?
    -- Or just use wheel event if we had it.
    -- Let's assume wheel is not available via syscall yet.
end

return Browser
