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







