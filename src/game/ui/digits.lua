-- 24 x 36, 16 x 36
do
    local maxNumber, n = 9999999
    local parent
    local frames, textures, digits = {}, {}, {}
    local sizes = {0.016 * .8, 0.024 * .8, 0.036 * .8} -- ширина единицы / ширина другой цифры / высота любой цифры
    local y = .5

    function initDigits()
        -- local line = createBackdropSize(getConsole(), .4, .3, 0.001, 0.6, "", "", 3)
        n = math.countDigits(maxNumber)
        parent = createBackdropSize(getConsole(), 0.4, y, (n - 1) * sizes[2], 0.036, "sprites\\transp", "", 2 )
        for i = 1, n do
            table.insert(frames,
                createAnchoredBackdrop(parent, FRAMEPOINT_CENTER, FRAMEPOINT_LEFT, sizes[2] * (i - 1), 0, sizes[2], sizes[3], "", 1, true)
            )
        end

        for i = 0, 9 do
            textures[i] = "sprites\\" .. i
        end
        return frames
    end

    function outputNumber(numb)
        table.clear(digits)
        math.getDigits(numb, digits)
        local nd, size, frameId = #digits
        if nd > n then return end

        local firstIndex = 4 - math.floor(nd / 2)

        for i = 1, nd do
            frameId = firstIndex + (i - 1)
            SetTexture(frames[frameId], textures[digits[i]], 0, true)
            size = (digits[i] == 1 and sizes[1]) or sizes[2]

            SetSize(frames[frameId], size, sizes[3])
            SetVisible(frames[frameId], true)
        end

        local newX = .4 - ((nd % 2) - 1) * (sizes[2] / 2)
        SetPosition(parent, newX, y)

        if nd == n then return end

        for i = 1, n do
            if i < firstIndex or i >= firstIndex + nd then
                SetVisible(frames[i], false)
            end
        end
    end

    function showDigits(flag)
        if flag then
            SetAlpha(parent, 255)
            return
        end
        return animateAlpha(parent, 255, 0, 1/120, false, 10)
    end
end