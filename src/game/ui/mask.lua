do
    local mask
    local inTimer, outTimer = CreateTimer(), CreateTimer()

    local function reset()
        SetAlpha(mask, 0)
        SetVisible(mask, true)
    end

    function initMask()
        mask = createBackdropSize(getConsole(), .4, .3, 1, 1, "transp", "mask", 20)
        ResetPosition(mask)
        InheritSize(mask, Scene.canvas)
        SetAlpha(mask, 0)
        SetVisible(mask, false)
    end

    function whiteFlash()
        reset()
        SetTexture(mask, "textures\\white", 0, true)

        TimerStart(inTimer, animateAlpha(mask, 0, 200, 1/60, false, 20), false, function()
            TimerStart(outTimer, animateAlpha(mask, 200, 0, 1/60, false, 20), false, function()
                SetVisible(mask, false)
            end)
        end)
    end

    function blackTransition()
        reset()
        SetTexture(mask, "textures\\black32", 0, true)

        local fadeInTime = animateAlpha(mask, 0, 255, 1/60, false, 9)
        TimerStart(inTimer, fadeInTime + 0.1, false, function()
            TimerStart(outTimer, animateAlpha(mask, 255, 0, 1/60, false, 9), false, function()
                SetVisible(mask, false)
            end)
        end)
        return fadeInTime
    end
end