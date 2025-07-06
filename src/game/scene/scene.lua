Scene = {}
Scene.pipes = {}

function Scene.create()
    Scene.width = getScreenWidth()
    Scene.canvas, Scene.minX, Scene.maxX = createClickBlocker()
    Scene.endPointX1, Scene.endPointX2 = 0, 0
    Scene.spawnTick = 500

    Scene.base = createBase()
    Scene.background = createBackground()

    Scene.screenTimer()

    local spawnCounter = math.floor(Scene.spawnTick / 2)

    function Scene:resetSpawnCounter()
        spawnCounter = Scene.spawnTick - 1
    end

    function Scene:update()
        for _, v in ipairs(Scene.pipes) do
            v:setPosition()
        end
        moveBase()
        spawnCounter = spawnCounter + 1
        if spawnCounter == self.spawnTick then
            table.insert(self.pipes, Pipe:new())
            spawnCounter = 0
        end
    end
end

---Адаптирует сцену при изменении разрешения экрана
function Scene.screenTimer()
    local t = CreateTimer()
    TimerStart(CreateTimer(), .25, true, function()
        local width = getScreenWidth()
        --- кажется, что при уменьшении ширины, перестраивать необязательно
        if width ~= 0 and width > Scene.width then
            Scene.width = width
            Scene.minX = .4 - width / 2
            Scene.maxX = .4 + width / 2
            Scene:rebuild()
        end
    end)
end

function Scene:rebuild()
    SetAbsPoint(self.canvas, FRAMEPOINT_TOPLEFT, self.minX, 0.6)
    SetAbsPoint(self.canvas, FRAMEPOINT_BOTTOMRIGHT, self.maxX, 0)

    destroyRectangleArray(self.background)
    self.background = createBackground(true)

    destroyRectangleArray(self.base)
    self.base = createBase()
end