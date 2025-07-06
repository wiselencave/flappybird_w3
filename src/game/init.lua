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