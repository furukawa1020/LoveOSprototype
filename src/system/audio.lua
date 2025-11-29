local Audio = {}

Audio.sources = {}
Audio.bgm = {}
Audio.currentBGM = nil
Audio.bgmTimer = 0
Audio.bgmNote = 1

-- Simple waveforms
local function generateWave(type, duration, freq)
    local rate = 44100
    local length = math.floor(rate * duration)
    local data = love.sound.newSoundData(length, rate, 16, 1)
    
    for i = 0, length - 1 do
        local t = i / rate
        local sample = 0
        if type == "square" then
            sample = (math.sin(t * freq * 2 * math.pi) > 0) and 0.5 or -0.5
        elseif type == "noise" then
            sample = (math.random() * 2 - 1) * 0.5
        elseif type == "saw" then
            sample = ((t * freq) % 1) * 2 - 1
        end
        
        -- Envelope (Fade out)
        sample = sample * (1 - i / length)
        
        data:setSample(i, sample)
    end
    
    return love.audio.newSource(data, "static")
end

function Audio.init()
    -- SFX
    Audio.sources.select = generateWave("square", 0.1, 880)
    Audio.sources.attack = generateWave("noise", 0.2, 0)
    Audio.sources.hit = generateWave("saw", 0.3, 110)
    
    -- BGM Patterns (Note frequencies)
    Audio.bgm.field = {261, 329, 392, 523, 392, 329} -- C Major Arpeggio
    Audio.bgm.battle = {110, 110, 123, 110, 130, 110, 123, 110} -- Fast Bass
end

function Audio.playSynth(type)
    local sampleRate = 44100
    local duration = 0.1
    local data = love.sound.newSoundData(math.floor(sampleRate * duration), sampleRate, 16, 1)
    
    for i = 0, data:getSampleCount() - 1 do
        local t = i / sampleRate
        local value = 0
        
        if type == "key" then
            -- High pitched blip
            value = math.sin(t * 2000 * math.pi * 2) * (1 - t/duration) * 0.1
        elseif type == "boot" then
            -- Ascending chime
            duration = 0.5
            value = math.sin(t * (440 + t * 440) * math.pi * 2) * 0.2
        elseif type == "hdd" then
            -- Random crunch
            value = (math.random() * 2 - 1) * 0.1
        end
        
        data:setSample(i, value)
    end
    
    local source = love.audio.newSource(data, "static")
    source:play()
    -- We don't need to track these strictly if they are static and auto-GC'd, 
    -- but keeping them in a list prevents early GC if playing.
    table.insert(Audio.sources, source)
end

function Audio.playSFX(name)
    if Audio.sources[name] and Audio.sources[name].clone then
        Audio.sources[name]:clone():play()
    end
end

function Audio.playBGM(name)
    if Audio.currentBGM ~= name then
        Audio.currentBGM = name
        Audio.bgmNote = 1
        Audio.bgmTimer = 0
    end
end

function Audio.setReverb(enable)
    if enable then
        if not love.audio.getEffect("reverb") then
            love.audio.setEffect("reverb", {
                type = "reverb",
                gain = 0.5,
                decaytime = 1.5,
                density = 1.0,
            })
        end
        Audio.reverbEnabled = true
    else
        Audio.reverbEnabled = false
    end
end

function Audio.update(dt)
    -- Clean up sources list (simple check)
    -- In a real engine we'd be more careful, but for this proto it's fine.
    
    if not Audio.currentBGM then return end
    
    local tempo = 0.2 -- Seconds per note
    if Audio.currentBGM == "battle" then tempo = 0.1 end
    
    Audio.bgmTimer = Audio.bgmTimer + dt
    if Audio.bgmTimer >= tempo then
        Audio.bgmTimer = Audio.bgmTimer - tempo
        
        local pattern = Audio.bgm[Audio.currentBGM]
        if pattern then
            local freq = pattern[Audio.bgmNote]
            
            -- Play note
            local note = generateWave("square", tempo * 0.8, freq)
            note:setVolume(0.2) -- Lower volume for BGM
            
            if Audio.reverbEnabled then
                note:setEffect("reverb")
            end
            
            note:play()
            
            Audio.bgmNote = Audio.bgmNote + 1
            if Audio.bgmNote > #pattern then Audio.bgmNote = 1 end
        end
    end
end

return Audio
