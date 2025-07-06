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