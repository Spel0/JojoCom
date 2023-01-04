--[=[
    @class Util

    Contains useful methods for various stuff
]=]

local module = {}

local UIS = game:GetService"UserInputService";

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

--[=[
    @within Util
    @client

    Get the Platform that the Client is playing on
--]=]
function module.GetPlatform()
    if UIS.KeyboardEnabled and UIS.MouseEnabled and not UIS.TouchEnabled then
        return "PC";
    elseif UIS.TouchEnabled and not UIS.GamepadEnabled then
        return "Mobile";
    else
        return "Console";
    end
end

return module;