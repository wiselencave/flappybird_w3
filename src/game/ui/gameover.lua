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