local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local CombatMod = require(RSRootFolder.JojoCombatMod);
local Data = CombatMod.GetDataMod();
local StandFolder = CombatMod.GetModFolder():FindFirstChild("Stands");
local CombatModEventFolder = CombatMod.GetModFolder():FindFirstChild("Events");
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

CombatMod.GetAbilitySignal():Connect(function(plr, Ability, ...)
    local args = {...};
    if Ability == "Heavy Punch" then
        local StandData = require(StandFolder:FindFirstChild(args[1]).StandData);
        local Abil = StandData.Abilities[Ability];
        local hum = args[2]:FindFirstChild("Humanoid");
        if not hum then return; end
        hum:TakeDamage(Abil.Damage);
        local targetPlayer = game.Players:GetPlayerFromCharacter(args[2]);
        if targetPlayer then
            CombatModEventFolder:FindFirstChild("Knockback"):FireClient(targetPlayer, CombatMod.GetStand(plr).PrimaryPart, Abil.KnockbackPower)
        else
            local dir = (args[2].PrimaryPart.Position - CombatMod.GetStand(plr).PrimaryPart.Position).unit;
            dir = Vector3.new(dir.X, 0, dir.Z);
            args[2].PrimaryPart:ApplyImpulse(dir*args[2].PrimaryPart.AssemblyMass*Abil.KnockbackPower);
        end
    end
end)