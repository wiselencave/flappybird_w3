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