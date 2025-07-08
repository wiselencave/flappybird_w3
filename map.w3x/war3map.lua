function InitGlobals()
end

--CUSTOM_CODE
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
function table.removeValue(t, value)
    for i = 1, #t do
        if t[i] == value then
            table.remove(t, i)
            return true
        end
    end
    return false
end

function table.clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function math.countDigits(n)
    local count = 0
    repeat count = count + 1
        n = math.floor(n / 10)
    until n == 0
    return count
end

function math.getDigits(n, t)
    repeat
        table.insert(t, 1, n % 10)
        n = math.floor(n / 10)
    until n == 0
end

function math.getDivisibleNumber(n, divisor)
    return math.ceil(n / divisor) * divisor
end
Game = {}
Game.velocity = -0.0006
Game.delayTimer = CreateTimer()
Game.transitionTimer = CreateTimer()
Game.waitingForInput = true
Game.idle, Game.lost = nil, nil

function Game.init()
    math.randomseed(os.time())

    BlzShowSkyBox(false)
    BlzShowTerrain(false)

    hideOriginFrames()
    Scene.create()
    initUI()
    initScore()
    loadScore()

    local bird = Bird:new()
    Game.player = bird
    outputNumber(0)
end

function Game.start()
    local sT = CreateTimer()
    Game.player:setIdleModel()
    TimerStart(sT, showMessage(true), false, function()
        initMouseTrigger()
        initKeyTrigger()
        Game.idle = true
        DestroyTimer(sT)
    end)
end

function Game.startTimers()
    Game.player:startMovement()

    TimerStart(CreateTimer(), 1/250, true, function()
        if Game.player.isActive then
            Scene:update()
        end
    end)
end

function Game.run()
    showMessage(false)
    Game.player:setActive()
    Game.player:jump()
    Game.idle = false
end

function Game.lost()
    showDigits(false)
    showGameOver(true)
    Counter:setMaxScore()
    moveScoreFrameToTarget()

    TimerStart(Game.delayTimer, 0.6, false, function()
        Game.lostFlag = true
    end)
end

function Game.restart()
    Game.lostFlag = false
    local time = blackTransition()
    TimerStart(Game.transitionTimer, time, false, function()
        showGameOver(false)
        hideScore()

        for i = #Scene.pipes, 1, -1 do
            Scene.pipes[i]:destroy()
        end

        Scene:resetSpawnCounter()
        reskinBackground()

        Game.player:reset()
        Counter:reset()
        showDigits(true)
        Play.swoosh2()
        showMessage(true)

        TimerStart(Game.transitionTimer, time - 0.1, false, function()
            Game.idle = true
        end)
    end)
end
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
function startMusic()
    if not _ENV.snd then
        snd = CreateSound("sound\\music\\mp3music\\war2\\orc3_opl",true, false, false, 10, 10, "DefaultEAXON")
        SetSoundChannel(snd, 7)
        SetSoundVolume(snd, 35)
        StartSoundEx(snd, 0)
    end
end
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
do
    -- calling menu on Escape
    local menuTrigger = CreateTrigger()

    function initKeyTrigger()
        TriggerRegisterPlayerEventEndCinematic(menuTrigger, Player(0))
        TriggerAddAction(menuTrigger, function()
            BlzFrameClick(BlzGetFrameByName("UpperButtonBarMenuButton", 0))
        end)
    end
end
do
    local clickTrigger, tempAction = CreateTrigger()
    local cursorParent
    local t = CreateTimer()

    local function mouseCondition()
        return BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT
    end

    local function mouseAction()
        SetScale(cursorParent, 0.8)

        if Game.lostFlag then
            Game.restart()
        elseif Game.idle then
            Game.run()
        else
            Game.player:jump()
        end

        TimerStart(t, .075, false, function()
            SetScale(cursorParent, 1)
        end)
    end

    local function firstRunAction()
        Game.startTimers()
        TriggerRemoveAction(clickTrigger, tempAction)
    end

    function initMouseTrigger()
        cursorParent = getCursorParent()

        TriggerRegisterPlayerEvent(clickTrigger, Player(0), EVENT_PLAYER_MOUSE_DOWN)
        TriggerAddCondition(clickTrigger, Condition(mouseCondition))
        TriggerAddAction(clickTrigger, mouseAction)
        tempAction = TriggerAddAction(clickTrigger, firstRunAction)
    end
end
do
    local height = .6
    local width = .6 * 288 / 512;
    local skins = {
        "sprites\\background-night",
        "sprites\\background-day"
    }
    local currentSkin

    function createBackground(fixedSkin)
        currentSkin = fixedSkin and currentSkin or skins[math.random(#skins)]
        return createRectangleArray(width, height, currentSkin, 0)
    end

    function reskinBackground()
        local newSkin = skins[math.random(#skins)]
        for _, v in ipairs(Scene.background) do
            SetTexture(v.frame, newSkin, 0, true)
        end
    end
end
do
    local height = .6 / 5; local hh = height / 2
    local width = height * 3
    local velocity = Game.velocity

    function createBase()
        Scene.endPointX1 = Scene.minX - width * 2
        Scene.endPointX2 = Scene.maxX + width * 3
        Scene.floorHeight = height

        return createRectangleArray(width, height, "sprites\\base", 4)
    end

    local function addSegment(sTable) -- reuse table
        local t = Scene.base
        local seam = t[#t].pos + width / 2

        sTable.frame, sTable.pos = createRectangleOnePoint(Scene.canvas, seam, seam + width, 0, height, "sprites\\base", 4, true)
        table.insert(t, sTable)
    end

    local function removeSegment(s, i)
        Destroy(s.frame)
        table.clear(s)
        return table.remove(Scene.base, i) -- reuse table
    end

    function moveBase()
        for k, v in ipairs(Scene.base) do
            v.pos = v.pos + velocity
            SetPosition(v.frame, v.pos, hh)

            if v.pos <= Scene.endPointX1 then
                addSegment(removeSegment(v, k))
            end
        end
    end
end


function createRectangleArray(width, height, texture, lvl)
    local seam = Scene.minX
    local t = {}

    while math.abs(seam) < Scene.endPointX2 do
        local segment, x = createRectangleOnePoint(Scene.canvas, seam, seam + width, 0, height, texture, lvl, true)
        seam = seam + width
        table.insert(t, {
            frame = segment,
            pos = x,
        })
    end
    return t
end

function destroyRectangleArray(t)
    for _, v in ipairs(t) do
        Destroy(v.frame)
        table.clear(v)
    end
    table.clear(t)
end
Scene = {}
Scene.pipes = {}

function Scene.create()
    Scene.width = getScreenWidth()
    Scene.canvas, Scene.minX, Scene.maxX = createClickBlocker()
    Scene.endPointX1, Scene.endPointX2 = 0, 0
    Scene.spawnTick = 500

    Scene.base = createBase()
    Scene.background = createBackground()

    Scene.screenTimer()

    local spawnCounter = math.floor(Scene.spawnTick / 2)

    function Scene:resetSpawnCounter()
        spawnCounter = Scene.spawnTick - 1
    end

    function Scene:update()
        for _, v in ipairs(Scene.pipes) do
            v:setPosition()
        end
        moveBase()
        spawnCounter = spawnCounter + 1
        if spawnCounter == self.spawnTick then
            table.insert(self.pipes, Pipe:new())
            spawnCounter = 0
        end
    end
end

---Адаптирует сцену при изменении разрешения экрана
function Scene.screenTimer()
    local t = CreateTimer()
    TimerStart(CreateTimer(), .25, true, function()
        local width = getScreenWidth()
        --- кажется, что при уменьшении ширины, перестраивать необязательно
        if width ~= 0 and width > Scene.width then
            Scene.width = width
            Scene.minX = .4 - width / 2
            Scene.maxX = .4 + width / 2
            Scene:rebuild()
        end
    end)
end

function Scene:rebuild()
    SetAbsPoint(self.canvas, FRAMEPOINT_TOPLEFT, self.minX, 0.6)
    SetAbsPoint(self.canvas, FRAMEPOINT_BOTTOMRIGHT, self.maxX, 0)

    destroyRectangleArray(self.background)
    self.background = createBackground(true)

    destroyRectangleArray(self.base)
    self.base = createBase()
end
Counter = {}
Counter.score = 0
Counter.maxScore = 0

function Counter:add()
    self.score = self.score + 1
    Play.point()
    outputNumber(self.score)
end

function Counter:setMaxScore()
    self.maxScore = math.max(self.score, self.maxScore)
    saveScore(self.maxScore)
end

function Counter:reset()
    self.score = 0
    outputNumber(0)
end
do
    local scoreStorage
    function initScore()
        scoreStorage = createTextTwoPoints(getConsole(), 0, -1, .8, -1.5, "not loaded", 1, "scoreStorage")
    end

    function loadScore()
        Preloader("flappybird\\score.txt")

        local score = (BlzFrameGetText(BlzGetFrameByName("scoreStorage", 0)))
        score = (#score < 9 and tonumber(score)) or 0
        Counter.maxScore = (math.type(score) == "integer" and score) or 0
    end

    function saveScore(n)
        PreloadGenClear()
        Preload("\")\n\tcall BlzFrameSetText(BlzGetFrameByName(\"scoreStorage\", 0),\"" .. tostring(n) .. "\") //")
        PreloadGenEnd("flappybird\\score.txt")
    end
end
-- 24 x 36, 16 x 36
do
    local maxNumber, n = 9999999
    local parent
    local frames, textures, digits = {}, {}, {}
    local sizes = {0.016 * .8, 0.024 * .8, 0.036 * .8} -- ширина единицы / ширина другой цифры / высота любой цифры
    local y = .5

    function initDigits()
        -- local line = createBackdropSize(getConsole(), .4, .3, 0.001, 0.6, "", "", 3)
        n = math.countDigits(maxNumber)
        parent = createBackdropSize(getConsole(), 0.4, y, (n - 1) * sizes[2], 0.036, "sprites\\transp", "", 2 )
        for i = 1, n do
            table.insert(frames,
                createAnchoredBackdrop(parent, FRAMEPOINT_CENTER, FRAMEPOINT_LEFT, sizes[2] * (i - 1), 0, sizes[2], sizes[3], "", 1, true)
            )
        end

        for i = 0, 9 do
            textures[i] = "sprites\\" .. i
        end
        return frames
    end

    function outputNumber(numb)
        table.clear(digits)
        math.getDigits(numb, digits)
        local nd, size, frameId = #digits
        if nd > n then return end

        local firstIndex = 4 - math.floor(nd / 2)

        for i = 1, nd do
            frameId = firstIndex + (i - 1)
            SetTexture(frames[frameId], textures[digits[i]], 0, true)
            size = (digits[i] == 1 and sizes[1]) or sizes[2]

            SetSize(frames[frameId], size, sizes[3])
            SetVisible(frames[frameId], true)
        end

        local newX = .4 - ((nd % 2) - 1) * (sizes[2] / 2)
        SetPosition(parent, newX, y)

        if nd == n then return end

        for i = 1, n do
            if i < firstIndex or i >= firstIndex + nd then
                SetVisible(frames[i], false)
            end
        end
    end

    function showDigits(flag)
        if flag then
            SetAlpha(parent, 255)
            return
        end
        return animateAlpha(parent, 255, 0, 1/120, false, 10)
    end
end
function editFPS()
    local resourceBarFrame = BlzGetFrameByName("ResourceBarFrame", 0)
    ResetPosition(resourceBarFrame)
    BlzFrameSetAbsPoint(resourceBarFrame, FRAMEPOINT_CENTER, 1.0, 0.617)
end
do
    local gameOver
    function initGameOver()
        gameOver = createBackdropSize(getConsole(), .4, .45, .16, .16 / 4.57143, "sprites\\gameover", "", 5)
        SetAlpha(gameOver, 0)
        SetScale(gameOver, 1)
        return gameOver
    end

    function showGameOver(flag)
        if flag then
            return animateAlpha(gameOver, 0, 255, 1/120, false, 10)
        end
        SetAlpha(gameOver, 0)
    end
end
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
function editMenuButton()
    local menu = BlzGetFrameByName("UpperButtonBarMenuButton",0)
    ResetPosition(menu)
    InheritSize(menu, BlzGetFrameByName("UpperButtonBarQuestsButton",0))
    SetVisible(menu, true)

    local names = {
        "UpperButtonBarAlliesButton",
        "UpperButtonBarChatButton",
        "UpperButtonBarQuestsButton"
    }

    for _, v in ipairs(names) do
        SetVisible(BlzGetFrameByName(v,0), false)
    end

    SetVisible(menu, true)
end
-- 184 x 267
do
    local message
    function initMessage()
        message = createBackdropSize(getConsole(), 0.4, 0.3, 0.184 * 0.75, 0.267 * 0.75, "sprites\\message", "", 11)
        SetAlpha(message, 0)
        return message
    end

    function showMessage(flag)
        if flag then
            return animateAlpha(message, 0, 255, 1/100, false, 10)
        end
        return animateAlpha(message, 255, 0, 1/100, false, 12)
    end
end
do
    local parent, text1, text2, bkdrp, bkdrp1, bkdrp2
    local target, vel = .35, .02
    local width, height = .26, .13
    local t = CreateTimer()

    local function addText(id, xOffset, yOffset, xOffset1, yOffset1)
        local fr = BlzCreateFrame("CustomText", parent, 0, id)
        BlzFrameSetPoint(fr, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xOffset, yOffset)
        BlzFrameSetPoint(fr, FRAMEPOINT_BOTTOMRIGHT, parent, FRAMEPOINT_BOTTOMRIGHT, xOffset1, yOffset1)

        return fr
    end

    local function addIcon(yOffset, texture)
        return createAnchoredBackdrop(parent, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0.08, yOffset, width / 5, width / 5, texture, 1)
    end

    function initScoreFrame()
        parent = createBackdropSize(getConsole(), .4, -width, width, height, "replaceabletextures\\teamcolor\\teamcolor17", "", 5)
        text1 = addText(0, 0.025, 0, 0, height / 2)
        text2 = addText(1,0.025, -height / 2, 0, 0)

        bkdrp = addIcon(0, "sprites\\bluebird-midflap512")
        bkdrp1 = addIcon(0.04, "sprites\\redbird-downflap512")
        bkdrp2 = addIcon(-0.04, "sprites\\yellowbird-upflap512")

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
function initUI()
    initMask()
    initDigits()
    initGameOver()
    editMenuButton()
    editFPS()
    initScoreFrame()
    initMessage()
end
Bird = {
    --- Constants
    sprite = "sprites\\birdAngles\\bird", --bird-template3,
    variations = {2, 3, 4},
    idleSprites = {},
    radius = 0.0132,
    x = 0.25,
    minAngle = -90,
    maxAngle = 40,
    turningRatio = 2,
    gravity = - (0.6 - .6 / 5) / 1.15 / 95 --TODO ??????
}

--- Movement settings
Bird.jumpVelocity = - Bird.gravity * 1.9
Bird.slowdown = Bird.gravity / 35
Bird.addSlowdown = Bird.gravity / 20
Bird.ceiling = 0.607

Bird.__index = Bird

function Bird:new()
    local bird = setmetatable({}, Bird)
    bird.model = createSpriteDef(self.sprite .. "0", 0, self.x, 0.3, 1.25, Scene.canvas, 3, true)
    bird.variation = self.variations[math.random(1, #self.variations)]
    bird:useVariation()

    bird.y = 0.3
    bird.velocity = 0
    bird.angle = 0 -- deg
    bird.minPoint = Scene.floorHeight + Bird.radius

    bird.path = nil
    bird.animating = false
    bird.isActive = false
    return bird
end

function Bird:setPosition(y)
    self.y = math.max(y, self.minPoint)
    SetPosition(self.model, self.x, self.y)

    return y > self.minPoint
end

function Bird:redraw(angle)
    self.angle = angle or self.angle
    SetModel(self.model, self.angles[self.angle], 0)
    self.path = self.angles[self.angle]
    self:useVariation()
end

function Bird:initIdleModels()
    for _, v in ipairs(self.variations) do
        self.idleSprites[v] = self.sprite .. "V" .. v
    end
end

function Bird:setIdleModel()
    SetModel(self.model, self.idleSprites[self.variation], 0)
end

function Bird:useVariation()
    PlayAnimation(self.model, self.variation, 0)
end

function Bird:startMovement()
    self.isActive = true
    local rotTimer, posTimer, killTimer = CreateTimer(), CreateTimer(), CreateTimer()
    self.killTimer = killTimer

    TimerStart(rotTimer, 1/45, true, function()
        if not self.isActive then return end

        if not self.animating and self.angles[self.angle] ~= self.path then
            self:redraw()
        end
    end)

    TimerStart(posTimer, 1/100, true, function()
        if not self.isActive then return end

        -- снижение сопртивления гравитации
        self.velocity = self.velocity > 0 and math.max(0, self.velocity + self.slowdown) or self.velocity

        -- наклон вниз при падении
        self.angle = self.velocity < math.abs(Bird.gravity) and math.max(self.minAngle, self.angle - self.turningRatio) or self.angle

        -- расчёт текущего положения
        local pos = self.y + self.velocity + self.gravity

        -- проверка пола
        if not self:setPosition(pos) then
            self:kill()
            return
        end

        -- проверка столкновений с трубами
        if not self:checkCollision() then
            self:kill(true)
            return
        end

        -- дополнительное снижение сопротивления гравитации при выходе за пределы экрана
        self.velocity = pos > self.ceiling and math.max(0, self.velocity + self.addSlowdown) or self.velocity
    end)
end

function Bird:jump()
    if self.isActive then
        Play.wing()
        self.velocity = self.jumpVelocity
        self:animateAngle(self.maxAngle, 8)
    end
end

function Bird:kill(needFall)
    Play.hit()
    whiteFlash()
    self.isActive = false

    local t = self.killTimer
    local time = self:animateAngle(-90, -6), 0
    TimerStart(t, time, false, function()
        PauseTimer(t)
        if not needFall then Game.lost() return end

        Play.die()
        TimerStart(t, 1/100, true, function()
            if not self:setPosition(self.y + self.gravity) then
                Game.lost()
                PauseTimer(t)
            end
        end)
    end)
end

function Bird:animateAngle(angle, step)
    self.animating = true
    local angleLoc, dir, t = self.angle, step > 0, CreateTimer()

    TimerStart(t, 1/100, true, function()
        if (dir and angleLoc >= angle) or (not dir and angleLoc <= angle) then
            self:redraw(angle)
            self.animating = false
            DestroyTimer(t)
        else
            self:redraw(angleLoc)
        end
        angleLoc = angleLoc + step
    end)
    return (math.getDivisibleNumber(math.abs(angle - angleLoc), step) / step) * 1 / 100
end

function Bird:checkCollision()
    local posX, posY, radius = self.x, self.y, self.radius
    for _, v in ipairs(Scene.pipes) do
        local x, y, halfWidth, halfHole = v.x, v.y, v.colWidth, v.hole / 2
        if (posX + radius > x - halfWidth) and (posX - radius < x + halfWidth) then -- сейчас проходит эту трубу
            return (posY - radius > y - halfHole) and (posY + radius < y + halfHole)
        end
    end
    return true
end

function Bird:loadAngles()
    Bird.angles = loadAngles(self.sprite, self.minAngle, self.maxAngle)
    return self.angles, self.minAngle, self.maxAngle
end

function Bird:reset()
    self:setPosition(.3)
    self.variation = self.variations[math.random(1, #self.variations)]
    self:redraw(0)
    self:setIdleModel()
end

function Bird:setActive()
    self.isActive = true
end

Pipe = {
    --- Constants
    sprite = "sprites\\pipe-green",
    sprite2 = "sprites\\pipe-greenInv",
    hole = (0.6 - .6 / 5) * 0.25, -- связать бы с высотой пола из Scene
    yMin = .6 / 5 + 0.075,
    yMax = 0.525,
}

Pipe.__index = Pipe

Pipe.width = 0.072
Pipe.colWidth = (Pipe.width / 2) * .925
Pipe.length = Pipe.width * 6.1538

Pipe.pool = {}

function Pipe:new()
    local pipe = table.remove(Pipe.pool) or setmetatable({}, Pipe)
    local x, y = Scene.maxX + self.width, GetRandomReal(self.yMin + self.hole / 2, self.yMax - self.hole / 2)

    pipe.controller = createBackdropSize(Scene.canvas, x, y, self.width, self.hole, "sprites\\transp", "", 1)
    pipe.bottom = createAnchoredBackdrop(pipe.controller, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0,  0, self.width, self.length, self.sprite, 1)
    pipe.top = createAnchoredBackdrop(pipe.controller, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0,  0, self.width, self.length, self.sprite2, 1)

    pipe.x, pipe.y = x, y
    pipe.velocity = Game.velocity
    pipe.counter = false

    return pipe
end

function Pipe:setPosition()
    self.x = self.x + self.velocity
    if self.x < Scene.endPointX1 then
        self:destroy()
        return
    end
    SetPosition(self.controller, self.x, self.y)
    if not self.counter and self.x < Bird.x then
        self.counter = true
        Counter:add()
    end
end

function Pipe:destroy()
    table.removeValue(Scene.pipes, self)

    Destroy(self.top); Destroy(self.bottom); Destroy(self.controller)
    table.clear(self)

    table.insert(Pipe.pool, self)
end








function customMain()
    preloadAngles(Bird:loadAngles())
    Bird:initIdleModels()
    BlzLoadTOCFile("framedef\\flappybird.toc")
    initSounds()
    Game.init()
    TimerStart(CreateTimer(), 0, false, function()
        setMenuTransparent()
        Game.start()
        DestroyTimer(GetExpiredTimer())
    end)
end
function customConfig()
    startMusic()
end
local function mainInject(funcMain, funcConfig)
    local mt = getmetatable(_G) or {}
    if not getmetatable(_G) then
        setmetatable(_G, mt)
    end

    local originalConfig
    local injected = {config = false, main = false}

    mt.__newindex = function(tbl, key, val)
        if key == "config" and not injected.config then
            originalConfig = val
            rawset(tbl, key, function(...)
                originalConfig(...)
                funcConfig(...)
            end)
            injected.config = true
        elseif key == "main" and not injected.main then
            rawset(tbl, key, funcMain)
            injected.main = true
        else
            rawset(tbl, key, val)
        end

        if injected.config and injected.main then
            mt.__newindex = nil
        end
    end
end

mainInject(customMain, customConfig)

--CUSTOM_CODE
function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
ForcePlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_NIGHTELF)
SetPlayerRaceSelectable(Player(0), false)
SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
InitBlizzard()
InitGlobals()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("")
SetPlayers(1)
SetTeams(1)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -1152.0, 2240.0)
InitCustomPlayerSlots()
InitCustomTeams()
end

