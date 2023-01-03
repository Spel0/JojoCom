--[=[
    @class Util

    Contains useful methods for various stuff
]=]

local module = {}

--[=[
    @within Util

    Raycast check for the wall between 2 parts
]=]
function module.WallCheck(part1:BasePart, part2:BasePart, params:RaycastParams?):RaycastResult
    if not params then
        params = RaycastParams.new(); params.IgnoreWater = true;
    end
    return workspace:Raycast(part1.Position, part1.CFrame.LookVector * (part1.Position - part2.Position).Magnitude, params);
end

--[=[
    @within Util

    Vector3 Dot Check between 2 parts, returns dot product ([-1;1])
]=]
function module.DotCheck(part1:BasePart, part2:BasePart):number
    return (part2.Position - part1.Position).Unit:Dot(part1.CFrame.LookVector);
end

return module;