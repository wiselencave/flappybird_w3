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