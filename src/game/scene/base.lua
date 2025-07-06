do
    local height = .6 / 5; local hh = height / 2
    local width = height * 3
    local velocity = Game.velocity

    function createBase()
        Scene.endPointX1 = Scene.minX - width * 2
        Scene.endPointX2 = Scene.maxX + width * 3
        Scene.floorHeight = height

        return createRectangleArray(width, height, "sprites\\base", 4)
    end

    local function addSegment(sTable) -- reuse table
        local t = Scene.base
        local seam = t[#t].pos + width / 2

        sTable.frame, sTable.pos = createRectangleOnePoint(Scene.canvas, seam, seam + width, 0, height, "sprites\\base", 4, true)
        table.insert(t, sTable)
    end

    local function removeSegment(s, i)
        Destroy(s.frame)
        table.clear(s)
        return table.remove(Scene.base, i) -- reuse table
    end

    function moveBase()
        for k, v in ipairs(Scene.base) do
            v.pos = v.pos + velocity
            SetPosition(v.frame, v.pos, hh)

            if v.pos <= Scene.endPointX1 then
                addSegment(removeSegment(v, k))
            end
        end
    end
end

