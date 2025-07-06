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