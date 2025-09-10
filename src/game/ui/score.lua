do
    local parent, mainRect, text1, text2

    local target, vel = .35, .02
    local width, height = .26, .13
    local textOffset = 0.025
    local iconOffset = 0.04

    local color = "replaceabletextures\\teamcolor\\teamcolor17"
    local borderColor = "textures\\white"
    local thickness = 0.008

    local t = CreateTimer()

    local function addText(id, xOffset, yOffset, xOffset1, yOffset1)
        local fr = BlzCreateFrame("CustomText", mainRect, 0, id)
        BlzFrameSetPoint(fr, FRAMEPOINT_TOPLEFT, mainRect, FRAMEPOINT_TOPLEFT, xOffset, yOffset)
        BlzFrameSetPoint(fr, FRAMEPOINT_BOTTOMRIGHT, mainRect, FRAMEPOINT_BOTTOMRIGHT, xOffset1, yOffset1)

        return fr
    end

    local function addIcon(yOffset, texture)
        return createAnchoredBackdrop(mainRect, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0.08, yOffset, width / 5, width / 5, texture, 1)
    end

    function initScoreFrame()
        parent = createBackdropSize(getConsole(), .4, -width, width, height, borderColor, "", 5)
        mainRect = createAnchoredBackdrop(parent, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0, 0, width - thickness, height - thickness, color, 1, false)

        text1 = addText(0, textOffset, 0, 0, height / 2)
        text2 = addText(1, textOffset, -height / 2, 0, 0)

        addIcon(0, "sprites\\bluebird-midflap512")
        addIcon(iconOffset, "sprites\\redbird-downflap512")
        addIcon(-iconOffset, "sprites\\yellowbird-upflap512")

        return parent
    end

    function moveScoreFrameToTarget()
        Play.swoosh2()
        SetText(text1, "Score: |cff6f2583".. Counter.score .."|r")
        SetText(text2, "Best: |cff6f2583".. Counter.maxScore .."|r")

        local y = -width
        TimerStart(t, 1/60, true, function()
            y = math.min(y + vel, target)
            SetPosition(parent, .4, y)
            if y >= target then
                PauseTimer(t)
            end
        end)
    end

    function hideScore()
        SetPosition(parent, .4, -width)
    end
end