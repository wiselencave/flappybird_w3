function editFPS()
    local resourceBarFrame = BlzGetFrameByName("ResourceBarFrame", 0)
    ResetPosition(resourceBarFrame)
    BlzFrameSetAbsPoint(resourceBarFrame, FRAMEPOINT_CENTER, 1.0, 0.617)
end