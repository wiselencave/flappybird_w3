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