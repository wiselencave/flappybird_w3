do
    local height = .6
    local width = .6 * 288 / 512;
    local skins = {
        "sprites\\background-night",
        "sprites\\background-day"
    }
    local currentSkin

    function createBackground(fixedSkin)
        currentSkin = fixedSkin and currentSkin or skins[math.random(#skins)]
        return createRectangleArray(width, height, currentSkin, 0)
    end

    function reskinBackground()
        local newSkin = skins[math.random(#skins)]
        for _, v in ipairs(Scene.background) do
            SetTexture(v.frame, newSkin, 0, true)
        end
    end
end