if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local JojoCombat = _G.JojoCombatScripts;
local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local CAS = game:GetService"ContextActionService";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");

EventsFolder:FindFirstChild("Knockback").OnClientEvent:Connect(function(part, power)
    local HRP = Player.Character.HumanoidRootPart;
    local dir = (HRP.Position - part.Position).unit;
    dir = Vector3.new(dir.X, 0, dir.Z);
    Player.Character.HumanoidRootPart:ApplyImpulse(dir*HRP.AssemblyMass*power);
end)