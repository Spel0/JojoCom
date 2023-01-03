local module = {}

function module.IsAlive(char:Model)
    if char and char:IsDescendantOf(workspace) and char:FindFirstChild("Humanoid") and char.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and char.Humanoid.Health > 0 then
        return true;
    end
    return false;
end

function module.IsOnGround(char:Model)
    if char and char:FindFirstChild("Humanoid") and (char.Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics or char.Humanoid:GetState() == Enum.HumanoidStateType.Running) then
        return true;
    end
    return false;
end

function module.ApplyImpulse(Part:BasePart, Direction:Vector3, power:number)
    Part:ApplyImpulse(Direction*power);
end

return module;