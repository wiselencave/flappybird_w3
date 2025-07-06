function createRectangleArray(width, height, texture, lvl)
    local seam = Scene.minX
    local t = {}

    while math.abs(seam) < Scene.endPointX2 do
        local segment, x = createRectangleOnePoint(Scene.canvas, seam, seam + width, 0, height, texture, lvl, true)
        seam = seam + width
        table.insert(t, {
            frame = segment,
            pos = x,
        })
    end
    return t
end

function destroyRectangleArray(t)
    for _, v in ipairs(t) do
        Destroy(v.frame)
        table.clear(v)
    end
    table.clear(t)
end