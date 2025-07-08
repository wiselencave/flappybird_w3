SetVisible = BlzFrameSetVisible
Destroy = BlzDestroyFrame
SetAlpha = BlzFrameSetAlpha
SetScale = BlzFrameSetScale
PlayAnimation = BlzFrameSetSpriteAnimate
SetModel = BlzFrameSetModel
SetText = BlzFrameSetText
SetAlignment = BlzFrameSetTextAlignment
IsVisible = BlzFrameIsVisible
SetLevel = BlzFrameSetLevel
SetSize = BlzFrameSetSize
SetValue = BlzFrameSetValue
SetRange = BlzFrameSetMinMaxValue
SetParent = BlzFrameSetParent
ResetPosition = BlzFrameClearAllPoints
InheritSize = BlzFrameSetAllPoints
SetAnchor = BlzFrameSetPoint
SetTexture = BlzFrameSetTexture
SetEnable = BlzFrameSetEnable
SetAbsPoint = BlzFrameSetAbsPoint
--------------------------------------

function getConsole()
    return BlzGetFrameByName("ConsoleUIBackdrop", 0)
end

function getScreenWidth()
    return BlzGetLocalClientWidth() * .6 / BlzGetLocalClientHeight()
end

function getCursorParent()
    return BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 13)
end

function createTextTwoPoints(parent, x1, y1, x2, y2, text, lvl, name)
    local fr = BlzCreateFrameByType("TEXT", name or "", parent, "", 0)
    SetLevel(fr, lvl)
    SetAbsPoint(fr, FRAMEPOINT_TOPLEFT, x1, y1)
    SetAbsPoint(fr, FRAMEPOINT_BOTTOMRIGHT, x2, y2)
    SetText(fr, text)
    SetEnable(fr, false)
    SetScale(fr, 1)
    SetAlignment(fr, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
    return fr
end

function createAnchoredText(parent, point1, point2, xOffset, yOffset, width, height, text, lvl, scale, name)
    local fr = BlzCreateFrameByType("TEXT", name or "", parent, "", 0)
    SetLevel(fr, lvl)
    SetScale(fr, scale)
    SetSize(fr, width, height)
    BlzFrameSetPoint(fr, point1, parent, point2, xOffset, yOffset)
    SetEnable(fr, false)
    SetText(fr, text)
    return fr
end

---scale is set explicitly to disable HUD Scale option effect
function createBackdropSize(parent, x, y, width, height, texture, name, lvl)
    local fr = BlzCreateFrameByType("BACKDROP", name, parent, "", 1)
    SetLevel(fr, lvl)
    SetSize(fr, width, height)
    SetAbsPoint(fr, FRAMEPOINT_CENTER, x, y)
    SetTexture(fr, texture, 0, true)
    SetScale(fr, 1)
    return fr
end

function createAnchoredBackdrop(parent, point1, point2, xOffset, yOffset, width, height, texture, lvl, hide)
    local fr = BlzCreateFrameByType("BACKDROP", "", parent, "", 1)
    SetLevel(fr, lvl)
    SetSize(fr, width, height)
    BlzFrameSetPoint(fr, point1, parent, point2, xOffset, yOffset)
    SetTexture(fr, texture, 0, true)
    SetVisible(fr, not hide)
    return fr
end

function createRectangleOnePoint(parent, xmin, xmax, ymin, ymax, texture, lvl, setVisible)
    local width = xmax - xmin
    local height = ymax - ymin
    local x, y = xmin + width / 2, ymin + height / 2

    local fr = BlzCreateFrameByType("BACKDROP", "", parent, "", 1)
    SetLevel(fr, lvl)
    SetSize(fr, width, height)
    SetAbsPoint(fr, FRAMEPOINT_CENTER, x, y)
    SetTexture(fr, texture, 0, true)
    SetVisible(fr, setVisible)
    return fr, x, y
end

function createSpriteDef(model, cam, x, y, scale, parent, lvl, isVisible)
    local fr = BlzCreateFrameByType("SPRITE", "", parent, "", 0)

    SetLevel(fr, lvl)
    SetAbsPoint(fr, FRAMEPOINT_CENTER, x, y)
    SetSize(fr, 0.001, 0.001)
    SetModel(fr, model, cam)
    SetScale(fr, scale)
    SetVisible(fr, isVisible)

    return fr
end

function createClickBlocker()
    local halfWidth = getScreenWidth() / 2
    local x1, y1, x2, y2 = -1, 0.6, 1.5, 0
    if halfWidth > 0 then
        x1 = .4 - halfWidth
        x2 = .4 + halfWidth
    end

    local fr = createTextTwoPoints(getConsole(), x1, y1, x2, y2, "", 1)
    SetEnable(fr, true)

    return fr, x1, x2
end

function animateAlpha(frame, startAlpha, endAlpha, period, destroyAtTheEnd, customStep)
    local t = CreateTimer()
    local alpha = startAlpha

    local step = customStep or 1
    if startAlpha > endAlpha then step = -step end

    TimerStart(t, period, true, function()
        SetAlpha(frame, alpha)
        alpha = alpha + step
        if (step > 0 and alpha >= endAlpha) or (step < 0 and alpha <= endAlpha) then
            SetAlpha(frame, endAlpha)
            if destroyAtTheEnd then
                Destroy(frame)
            end
            DestroyTimer(t)
        end
    end)

    local time = math.abs(math.abs(endAlpha - startAlpha) / step) * period
    return time
end

function SetPosition(frame, x, y)
    SetAbsPoint(frame, FRAMEPOINT_CENTER, x, y)
end

--- патч 2.0+, эта простыня нужна для того, чтобы сохранить строку фпс
function hideOriginFrames()
    --TODO нужно разобраться и доработать
    local gameui = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    SetVisible(BlzFrameGetChild(gameui, 1), false)
    SetAbsPoint(BlzGetFrameByName("ConsoleUIBackdrop", 0), FRAMEPOINT_TOPRIGHT, 0, 0)

    local exclude = {
        ORIGIN_FRAME_CHAT_MSG,
        ORIGIN_FRAME_UNIT_MSG,
        ORIGIN_FRAME_WORLD_FRAME,
        ORIGIN_FRAME_SIMPLE_UI_PARENT,
        ORIGIN_FRAME_PORTRAIT
    }

    local hideIt = {
        --"UpperButtonBarFrame",
        "MinimapSignalButton",
        "MiniMapTerrainButton",
        "MiniMapAllyButton",
        "MiniMapCreepButton",
        "FormationButton",
        "ConsoleTopBar",
        "ConsoleBottomBar",
        "ConsoleBottomBarOverlay",
    }

    local ResourseBarTextFrames = {
        BlzGetFrameByName("ResourceBarGoldText", 0),
        BlzGetFrameByName("ResourceBarLumberText", 0),
        BlzGetFrameByName("ResourceBarSupplyText", 0),
        BlzGetFrameByName("ResourceBarUpkeepText", 0)
    }

    for f = 1, 4 do
        ResetPosition(ResourseBarTextFrames[f])
        SetScale(ResourseBarTextFrames[f], 0.0001)
        SetAbsPoint(ResourseBarTextFrames[f], FRAMEPOINT_CENTER, -0.2, 0.0)
    end

    for _, v in ipairs(exclude) do
        exclude[BlzGetOriginFrame(v, 0)] = true
    end

    local fr
    for i = 1, 20 do
        fr = BlzGetOriginFrame(ConvertOriginFrameType(i), 0)
        if not exclude[fr] then
            SetVisible(fr, false)
        end
    end

    local game_UI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    SetVisible(BlzFrameGetChild(BlzFrameGetChild(game_UI, 5), 0), false) -- убирает часы, не убирая инпут бокс чата
    SetVisible(BlzFrameGetChild(gameui, 1), false)
    --SetScale(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 5), 0.001)

    for _, v in ipairs(hideIt) do
        SetVisible(BlzGetFrameByName(v, 0), false)
    end
end

function setMenuTransparent()
    local tf = BlzGetFrameByName("EscMenuBackdrop", 0)
    BlzFrameSetTexture(tf, "sprites\\transp.dds", 0, true)
end

---returns a value from 0 to 0.4
function getHUDScale()
    return BlzFrameGetWidth(BlzGetFrameByName("ConsoleBottomBar", 0)) - .4
end

---returns a value from 0 to 100
function getHUDScaleValue()
    return MathRound((BlzFrameGetWidth(BlzGetFrameByName("ConsoleBottomBar", 0)) - .4) * 250)
end