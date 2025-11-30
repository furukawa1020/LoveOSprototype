local Shader = {}

Shader.crt = love.graphics.newShader[[
    extern vec2 screen_size;
    
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        // Chromatic Aberration
        vec2 offset = vec2(0.002, 0.0);
        float r = Texel(texture, texture_coords + offset).r;
        float g = Texel(texture, texture_coords).g;
        float b = Texel(texture, texture_coords - offset).b;
        vec4 texColor = vec4(r, g, b, 1.0);
        
        // Scanlines
        float scanline = sin(texture_coords.y * screen_size.y * 3.1415 * 2.0);
        scanline = (scanline + 1.0) * 0.5;
        scanline = 1.0 - (scanline * 0.2); // Intensity
        
    vec4 position(mat4 transform_projection, vec4 vertex_position) {
        // Wobble effect
        vertex_position.x += sin(time * 2.0 + vertex_position.y * 0.05) * 10.0;
        vertex_position.y += cos(time * 3.0 + vertex_position.x * 0.05) * 10.0;
        return transform_projection * vertex_position;
    }
]]

return Shader
