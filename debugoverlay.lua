
function debugoverlay()

    local debugTbl = {fps, {dimensions.x, dimensions.y}, (fov/math.pi), rendDist, lod, {accel.x, accel.y, accel.z}, {pos.x, pos.y, pos.z},
    {rot.x, rot.y}, {contact.x, contact.y, contact.z}, flying}
    local output

    love.graphics.setColor(1, 1, 1, 1)

    output = ""
    for i, v in pairs(debugTbl) do
        if type(v) ~= "table" then
            output = output .. tostring(v) .. "\n"
        else
            for j, u in pairs(v) do
                output = output .. tostring(u) .. " "
            end
            output = output .. "\n"
        end
    end

    love.graphics.print(output, 0, 0)

end
