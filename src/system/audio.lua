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
end

function Audio.playSFX(name)
    if Audio.sources[name] then
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
        -- Apply to all active sources? 
        -- For generated sources, we need to apply it when they are created or played.
        -- Since we generate new sources constantly in update(), we should apply it there.
        Audio.reverbEnabled = true
    else
        Audio.reverbEnabled = false
    end
end

function Audio.update(dt)
    if not Audio.currentBGM then return end
    
    local tempo = 0.2 -- Seconds per note
    if Audio.currentBGM == "battle" then tempo = 0.1 end
    
    Audio.bgmTimer = Audio.bgmTimer + dt
    if Audio.bgmTimer >= tempo then
        Audio.bgmTimer = Audio.bgmTimer - tempo
        
        local pattern = Audio.bgm[Audio.currentBGM]
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

return Audio
