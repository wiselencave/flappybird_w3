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

    SetText(menu, GetText(menu))
    SetVisible(menu, true)
end

function setTitleHeight()
    local title = BlzGetFrameByName("WouldTheRealOptionsTitleTextPleaseStandUp", 0)
    SetPosition(title, 0.4, 0.46)
    SetSize(title, GetWidth(title) * 3, GetHeight(title))
    SetAlignment(title, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
end