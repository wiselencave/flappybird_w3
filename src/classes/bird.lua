Bird = {
    --- Constants
    sprite = "sprites\\birdAngles\\bird", --bird-template3,
    variations = {2, 3, 4},
    idleSprites = {},
    radius = 0.0132,
    x = 0.25,
    minAngle = -90,
    maxAngle = 40,
    turningRatio = 2,
    gravity = - (0.6 - .6 / 5) / 1.15 / 95 --TODO ??????
}

--- Movement settings
Bird.jumpVelocity = - Bird.gravity * 1.9
Bird.slowdown = Bird.gravity / 35
Bird.addSlowdown = Bird.gravity / 20
Bird.ceiling = 0.607

Bird.__index = Bird

function Bird:new()
    local bird = setmetatable({}, Bird)
    bird.model = createSpriteDef(self.sprite .. "0", 0, self.x, 0.3, 1.25, Scene.canvas, 3, true)
    bird.variation = self.variations[math.random(1, #self.variations)]
    bird:useVariation()

    bird.y = 0.3
    bird.velocity = 0
    bird.angle = 0 -- deg
    bird.minPoint = Scene.floorHeight + Bird.radius

    bird.path = nil
    bird.animating = false
    bird.isActive = false
    return bird
end

function Bird:setPosition(y)
    self.y = math.max(y, self.minPoint)
    SetPosition(self.model, self.x, self.y)

    return y > self.minPoint
end

function Bird:redraw(angle)
    self.angle = angle or self.angle
    SetModel(self.model, self.angles[self.angle], 0)
    self.path = self.angles[self.angle]
    self:useVariation()
end

function Bird:initIdleModels()
    for _, v in ipairs(self.variations) do
        self.idleSprites[v] = self.sprite .. "V" .. v
    end
end

function Bird:setIdleModel()
    SetModel(self.model, self.idleSprites[self.variation], 0)
end

function Bird:useVariation()
    PlayAnimation(self.model, self.variation, 0)
end

function Bird:startMovement()
    self.isActive = true
    local rotTimer, posTimer, killTimer = CreateTimer(), CreateTimer(), CreateTimer()
    self.killTimer = killTimer

    TimerStart(rotTimer, 1/45, true, function()
        if not self.isActive then return end

        if not self.animating and self.angles[self.angle] ~= self.path then
            self:redraw()
        end
    end)

    TimerStart(posTimer, 1/100, true, function()
        if not self.isActive then return end

        -- снижение сопртивления гравитации
        self.velocity = self.velocity > 0 and math.max(0, self.velocity + self.slowdown) or self.velocity

        -- наклон вниз при падении
        self.angle = self.velocity < math.abs(Bird.gravity) and math.max(self.minAngle, self.angle - self.turningRatio) or self.angle

        -- расчёт текущего положения
        local pos = self.y + self.velocity + self.gravity

        -- проверка пола
        if not self:setPosition(pos) then
            self:kill()
            return
        end

        -- проверка столкновений с трубами
        if not self:checkCollision() then
            self:kill(true)
            return
        end

        -- дополнительное снижение сопротивления гравитации при выходе за пределы экрана
        self.velocity = pos > self.ceiling and math.max(0, self.velocity + self.addSlowdown) or self.velocity
    end)
end

function Bird:jump()
    if self.isActive then
        Play.wing()
        self.velocity = self.jumpVelocity
        self:animateAngle(self.maxAngle, 8)
    end
end

function Bird:kill(needFall)
    Play.hit()
    whiteFlash()
    self.isActive = false

    local t = self.killTimer
    local time = self:animateAngle(-90, -6), 0
    TimerStart(t, time, false, function()
        PauseTimer(t)
        if not needFall then Game.lost() return end

        Play.die()
        TimerStart(t, 1/100, true, function()
            if not self:setPosition(self.y + self.gravity) then
                Game.lost()
                PauseTimer(t)
            end
        end)
    end)
end

function Bird:animateAngle(angle, step)
    self.animating = true
    local angleLoc, dir, t = self.angle, step > 0, CreateTimer()

    TimerStart(t, 1/100, true, function()
        if (dir and angleLoc >= angle) or (not dir and angleLoc <= angle) then
            self:redraw(angle)
            self.animating = false
            DestroyTimer(t)
        else
            self:redraw(angleLoc)
        end
        angleLoc = angleLoc + step
    end)
    return (math.getDivisibleNumber(math.abs(angle - angleLoc), step) / step) * 1 / 100
end

function Bird:checkCollision()
    local posX, posY, radius = self.x, self.y, self.radius
    for _, v in ipairs(Scene.pipes) do
        local x, y, halfWidth, halfHole = v.x, v.y, v.colWidth, v.hole / 2
        if (posX + radius > x - halfWidth) and (posX - radius < x + halfWidth) then -- сейчас проходит эту трубу
            return (posY - radius > y - halfHole) and (posY + radius < y + halfHole)
        end
    end
    return true
end

function Bird:loadAngles()
    Bird.angles = loadAngles(self.sprite, self.minAngle, self.maxAngle)
    return self.angles, self.minAngle, self.maxAngle
end

function Bird:reset()
    self:setPosition(.3)
    self.variation = self.variations[math.random(1, #self.variations)]
    self:redraw(0)
    self:setIdleModel()
end

function Bird:setActive()
    self.isActive = true
end
