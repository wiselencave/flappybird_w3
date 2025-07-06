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