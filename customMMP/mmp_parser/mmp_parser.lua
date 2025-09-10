do
    local function Color(b, g, r, a)
        return {Red = r, Green = g, Blue = b, Alpha = a}
    end

    local function Position(x, y)
        return {X = x, Y = y}
    end

    BinaryIcon = {}
    BinaryIcon.__index = BinaryIcon

    function BinaryIcon:new(id, type, pos, color)
        local icon = setmetatable({}, BinaryIcon)

        icon.id = id
        icon.type = type
        icon.pos = pos
        icon.color = color

        return icon
    end

    function BinaryIcon:setTransparent()
        self.color.Alpha = 0
    end

    function BinaryIcon:pack()
        local base = string.pack("<i4i4i4", self.type, self.pos.X, self.pos.Y)

        local c = self.color
        local color = string.pack("BBBB", c.Blue, c.Green, c.Red, c.Alpha)

        return base .. color
    end

    function BinaryIcon:print()
        print("Icon #" .. self.id .. ": Type: " .. self.type)

        local p = self.pos
        print("\tPosition:", p.X, p.Y)

        local c = self.color
        print("\tColor:", c.Red, c.Green, c.Blue, c.Alpha)
    end

    BinaryData = {}
    BinaryData.__index = BinaryData

    function BinaryData:new(filePath)
        local binaryData = setmetatable({}, BinaryData)

        local input = assert(io.open(filePath, "rb"))
        local fileData = input:read("*all")
        input:close()

        binaryData.version = 0
        binaryData.iconNumber = 0
        binaryData.icons = {}

        binaryData.fileData = fileData
        binaryData.size = #fileData
        binaryData.offset = 1
        binaryData:parse()

        return binaryData
    end

    function BinaryData:parse()
        local version = self:getNumber("<i4", 4)
        local iconNumber = self:getNumber("<i4", 4)
        local icons = {}

        for i = 0, iconNumber - 1 do
            table.insert(icons, self:readIcon(i))
        end

        self.version = version
        self.iconNumber = iconNumber
        self.icons = icons
    end

    function BinaryData:readIcon(counter)
        return BinaryIcon:new(
                counter,
                self:getNumber("<i4", 4),
                Position(
                        self:getNumber("<i4", 4),
                        self:getNumber("<i4", 4)
                ),
                Color(
                        self:getNumber("B", 1),
                        self:getNumber("B", 1),
                        self:getNumber("B", 1),
                        self:getNumber("B", 1)
                )
        )
    end

    function BinaryData:addIcon(icon)
        table.insert(self.icons, icon)
        self.iconNumber = self.iconNumber + 1
    end

    function BinaryData:getNumber(fmt, size)
        local number = string.unpack(fmt, self.fileData, self.offset)
        self.offset = self.offset + size
        return number
    end

    function BinaryData:write(filePath)
        local data = string.pack("<i4i4", self.version, self.iconNumber)
        local icons = {}

        for i = 1, self.iconNumber do
            table.insert(icons, self.icons[i]:pack())
        end

        data = data .. table.concat(icons)

        local output = assert(io.open(filePath, "wb"))
        output:write(data)
        output:close()
    end

    function BinaryData:print()
        print("MMP FILE: VERSION " .. self.version, "ICON NUMBER: " .. self.iconNumber)
        for _, v in ipairs(self.icons) do
            v:print()
        end
    end
end

-- Тест
local testFile = "D:\\WC3_Projects\\flappybird\\map.w3x\\war3map.mmp"
local binaryData = BinaryData:new(testFile)
binaryData:print()

for _, v in ipairs(binaryData.icons) do
    v:setTransparent()
end

binaryData:write("D:\\WC3_Projects\\flappybird\\customMMP\\war3map.mmp")

-- Проверка
binaryData = BinaryData:new("D:\\WC3_Projects\\flappybird\\customMMP\\war3map.mmp")
binaryData:print()