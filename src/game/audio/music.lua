function startMusic()
    if not _ENV.snd then
        snd = CreateSound("sound\\music\\mp3music\\war2\\orc3_opl",true, false, false, 10, 10, "DefaultEAXON")
        SetSoundChannel(snd, 7)
        SetSoundVolume(snd, 35)
        StartSoundEx(snd, 0)
    end
end