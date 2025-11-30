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
        
        // Vignette
        vec2 uv = texture_coords * (1.0 - texture_coords.yx);
        float vig = uv.x * uv.y * 15.0;
        vig = pow(vig, 0.25);
        
        return texColor * color * vec4(vec3(scanline * vig), 1.0);
    }
]]

Shader.blur = love.graphics.newShader[[
    extern vec2 screen_size;
    
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 sum = vec4(0.0);
        // Hardcoded radius approx 2.0 for now, scaled by screen width
        number blur = 2.0 / screen_size.x; 
        
        // Simple 1D box blur approximation for visual style
        sum += Texel(texture, texture_coords + vec2(-4.0*blur, 0.0)) * 0.05;
        sum += Texel(texture, texture_coords + vec2(-3.0*blur, 0.0)) * 0.09;
        sum += Texel(texture, texture_coords + vec2(-2.0*blur, 0.0)) * 0.12;
        sum += Texel(texture, texture_coords + vec2(-1.0*blur, 0.0)) * 0.15;
        sum += Texel(texture, texture_coords + vec2(0.0, 0.0)) * 0.16;
        sum += Texel(texture, texture_coords + vec2(1.0*blur, 0.0)) * 0.15;
        sum += Texel(texture, texture_coords + vec2(2.0*blur, 0.0)) * 0.12;
        sum += Texel(texture, texture_coords + vec2(3.0*blur, 0.0)) * 0.09;
        sum += Texel(texture, texture_coords + vec2(4.0*blur, 0.0)) * 0.05;
        
        return sum * color;
    }
]]

return Shader
