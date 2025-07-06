do
    local path = "audio\\"
    local sounds = {
        "die",
        "hit",
        "point",
        "swoosh2",
        "wing"
    }
    Play = {}

    function initSounds()
        for _, v in ipairs(sounds) do
            sounds[v] = CreateSound(path .. v, false, false, false, 10, 10, "")
            SetSoundVolume(sounds[v], 0)
            Play[v] = function() StartSound(sounds[v]) end
            Play[v]()
        end

        TimerStart(CreateTimer(), .8, false, function()
            DestroyTimer(GetExpiredTimer())
            for _, v in ipairs(sounds) do
                SetSoundVolume(sounds[v], 100)
            end
        end)
    end
end