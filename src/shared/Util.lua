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
]=]
function module.GetPlatform()
    if UIS.KeyboardEnabled and UIS.MouseEnabled and not UIS.TouchEnabled then
        return "PC";
    elseif UIS.TouchEnabled and not UIS.GamepadEnabled then
        return "Mobile";
    else
        return "Console";
    end
end

--[=[
    @within Util
    @client

    Make a Deep Copy of a Table
]=]
function module.DeepCopy(original:{})
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = module.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

--[=[
    @within Util
    @client

    For use with AnimController module
    Format:
    ```lua
    {Anim1 = 123456, Anim2 = "rbxassetid://123456", Anim3 = RepStorage.Animations.Anim3}
    ```
]=]
function module.PackToAnimList(original:{})
    local toReturn = {};
    for i,v in original do
        table.insert(toReturn, {
            Name = i,
            ID = v
        })
    end
    return toReturn
end

return module;