local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local CombatMod = require(RSRootFolder.JojoCombatMod);
local AttackEvent = CombatMod.GetAttackSignal();
local EventsFolder = game.ReplicatedStorage:FindFirstChild("Events") or Instance.new("Folder", game.ReplicatedStorage);
EventsFolder.Name = "Events"
local SprintEvent = EventsFolder:FindFirstChild("Sprint") or Instance.new("RemoteEvent", EventsFolder);
SprintEvent.Name = "Sprint";

SprintEvent.OnServerEvent:Connect(function(plr, active:boolean)
    if plr.Character then
        plr.Character.Humanoid.WalkSpeed = active and 28 or 16;
    end
end)

AttackEvent:Connect(function(owner, target, damage, blocking)
    print(damage);
    local hum = target:FindFirstChildWhichIsA("Humanoid");
    if not hum or blocking then return; end
    hum:TakeDamage(damage);
end)