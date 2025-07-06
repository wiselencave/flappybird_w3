AnglesDB = {}

function loadAngles(path, min, max)
    if AnglesDB[path] then return end
    local t = {}
    for i = min, max do
        t[i] = path..i
    end
    table.insert(AnglesDB, t)
    return t
end

function preloadAngles(t, min, max)
    local spr = createSpriteDef("", 0, 0, .3, 0.0001, getConsole(), 1, true)
    local timer = CreateTimer()

    local counter = min
    TimerStart(timer, 0.009, true, function()
        SetModel(spr, t[counter], 0)
        counter = counter + 1
        if counter > max then
            Destroy(spr)
            DestroyTimer(timer)
            return
        end
    end)
end