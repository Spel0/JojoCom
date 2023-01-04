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
local TimeStopEvent = EventsFolder:FindFirstChild("TimeStop") or Instance.new("RemoteEvent", EventsFolder);
TimeStopEvent.Name = "TimeStop";

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
    local Data = Data.getPlayerData(owner);
    if Data.Stand and not Data.Stand.Abilities.Rage.Active then
        Data.DamageDealt += damage;
    end
end)

local Abilities = {
    ["Heavy Punch"] = function(plr, Ability, args)
        local StandData = require(StandFolder:FindFirstChild(args[1]).StandData);
        local Abil = StandData.Abilities[Ability];
        local hum = args[2]:FindFirstChild("Humanoid");
        local TargetPlayer = game.Players:GetPlayerFromCharacter(args[2]);
        local TargetData;
        if TargetPlayer then
            TargetData = Data.getPlayerData(TargetPlayer);
        end
        if not hum or (TargetData and TargetData.InSpecialAnim) then return; end
        local damage = Abil.Damage*Data.getDamageMult(plr);
        hum:TakeDamage(damage);
        CombatModEventFolder:FindFirstChild("Attack"):FireClient(plr, args[2], damage)
        local PlayerData = Data.getPlayerData(plr);
        if PlayerData.Stand and not PlayerData.Stand.Abilities.Rage.Active then
            PlayerData.DamageDealt += damage;
        end
        local targetPlayer = game.Players:GetPlayerFromCharacter(args[2]);
        if targetPlayer then
            CombatModEventFolder:FindFirstChild("Knockback"):FireClient(targetPlayer, CombatMod.GetStand(plr).PrimaryPart, Abil.KnockbackPower)
        else
            local dir = (args[2].PrimaryPart.Position - CombatMod.GetStand(plr).PrimaryPart.Position).unit;
            dir = Vector3.new(dir.X, 0, dir.Z);
            args[2].PrimaryPart:ApplyImpulse(dir*args[2].PrimaryPart.AssemblyMass*Abil.KnockbackPower);
        end
    end,
    ["Rage"] = function(plr, Ability, args)
        local PlayerData = Data.getPlayerData(plr);
        local AbilData = PlayerData.Stand.Abilities[Ability]
        if PlayerData.DamageDealt >= AbilData.NeedDamage then
            print('Rage Activated')
            Data.applyDamageMult(plr, 1);
            AbilData.Active = true;
            PlayerData.DamageDealt = 0;
            task.wait(AbilData.ActiveFor);
            print("Rage Off")
            Data.applyDamageMult(plr, -1);
            AbilData.Active = false;
        end
    end,
    ["Time Stop"] = function(plr, Ability, args)
        local PlayerData = Data.getPlayerData(plr);
        local AbilData = PlayerData.Stand.Abilities[Ability]
        for _,player in game.Players:GetPlayers() do
            if (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude <= AbilData.Distance then
                local localPlayer = plr == player;
                TimeStopEvent:FireClient(player, not localPlayer, AbilData.Duration);
                game.Players.RespawnTime = AbilData.Duration + 3;
                if not localPlayer then
                    player.Character.HumanoidRootPart.Anchored = true;
                    local Animator = player.Character.Humanoid.Animator;
                    Animator.Parent = nil;
                    task.delay(AbilData.Duration, function()
                        game.Players.RespawnTime = 3;
                        if player.Character.Humanoid.Health ~= 0 then
                            player.Character.HumanoidRootPart.Anchored = false;
                        end
                        Animator.Parent = player.Character.Humanoid;
                    end)
                end
            end
        end
    end
}

CombatMod.GetAbilitySignal():Connect(function(plr, Ability, ...)
    local args = {...};
    if not Abilities[Ability] then warn(string.format("Ability %q not found", Ability)); return; end
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.Stand or not PlayerData.Stand.Abilities[Ability] then return; end
    Abilities[Ability](plr, Ability, args);
end)