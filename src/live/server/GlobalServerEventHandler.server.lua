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
        CombatModEventFolder:FindFirstChild("Attack"):FireClient(plr, args[2], damage);
        if TargetPlayer and TargetData.Block.IsBlocking then
            CombatModEventFolder:FindFirstChild("Block"):FireClient(TargetPlayer);
        end
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
            task.wait(AbilData.Duration);
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
                local TargetData = Data.getPlayerData(plr);
                TimeStopEvent:FireClient(player, not localPlayer, AbilData.Duration);
                game.Players.RespawnTime = AbilData.Duration + 3;
                if not localPlayer then
                    player.Character.HumanoidRootPart.Anchored = true;
                    TargetData.IsDead = true;
                    local Animator = player.Character.Humanoid.Animator;
                    Animator.Parent = nil;
                    task.delay(AbilData.Duration, function()
                        game.Players.RespawnTime = 3;
                        if player.Character.Humanoid.Health ~= 0 then
                            TargetData.IsDead = false;
                            player.Character.HumanoidRootPart.Anchored = false;
                        end
                        Animator.Parent = player.Character.Humanoid;
                    end)
                end
            end
        end
    end,
    
    Barrage = function(plr, Ability, args)
        local StandData = require(StandFolder:FindFirstChild(args[1]).StandData);
        local PlayerData = Data.getPlayerData(plr);
        if typeof(args[2]) == "boolean" then
            local hum = plr.Character.Humanoid;
            local lastSpeed = hum.WalkSpeed;
            hum.WalkSpeed = StandData.Abilities[Ability].WalkSpeed;
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
            local parts = {};
            local offsetForAnim = {
                ["Right"] = {
                    {Vector3.new(1.116, 2.744, -0),Vector3.new(-0.384, 0.744, 0)},
                    {Vector3.new(2.135, 1.549, -0),Vector3.new(-0.384, 0.744, 0)}
                },
                ["Left"] = {
                    {Vector3.new(-1.183, 2.744, -0),Vector3.new(0.317, 0.744, 0)},
                    {Vector3.new(-2.162, 1.549, -0),Vector3.new(0.317, 0.744, 0)}
                }
            }
            local StandModel = PlayerData.Stand.Model;
            for i = 2, 3 do
                local left = StandModel:FindFirstChild("Left Arm");
                local right = StandModel:FindFirstChild("Right Arm");
                local cloneLeft = left:Clone();
                cloneLeft.Name = string.format("Left Arm_%s", i);
                cloneLeft.Parent = StandModel;
                local Motor = Instance.new("Motor6D");
                Motor.Part0 = StandModel:FindFirstChild("Torso");
                Motor.Part1 = cloneLeft;
                Motor.C0 = CFrame.new(offsetForAnim["Left"][i-1][1]);
                Motor.C1 = CFrame.new(offsetForAnim["Left"][i-1][2]);
                Motor.Parent = StandModel:FindFirstChild("Torso");
                table.insert(parts, cloneLeft);
                table.insert(parts, Motor);
                local cloneRight = right:Clone();
                cloneRight.Name = string.format("Right Arm_%s", i);
                cloneRight.Parent = StandModel;
                local Motor = Instance.new("Motor6D");
                Motor.Part0 = StandModel:FindFirstChild("Torso");
                Motor.Part1 = cloneRight;
                Motor.C0 = CFrame.new(offsetForAnim["Right"][i-1][1]);
                Motor.C1 = CFrame.new(offsetForAnim["Right"][i-1][2]);
                Motor.Parent = StandModel:FindFirstChild("Torso");
                table.insert(parts, cloneRight);
                table.insert(parts, Motor);
            end
            task.wait(StandData.Abilities[Ability].Duration);
            hum.WalkSpeed = lastSpeed;
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true);
            for _,v in parts do
                v:Destroy();
            end
            table.clear(parts);
            parts = nil;
        elseif typeof(args[2]) == "Instance" then
            local Abil = StandData.Abilities[Ability];
            local hum = args[2]:FindFirstChild("Humanoid");
            local TargetPlayer = game.Players:GetPlayerFromCharacter(args[2]);
            local TargetData = TargetPlayer and Data.getPlayerData(TargetPlayer) or nil;
            if not hum or (TargetData and TargetData.InSpecialAnim) then return; end
            local damage = Abil.Damage*Data.getDamageMult(plr);
            damage *= TargetData and (TargetData.Block.IsBlocking and Abil.BlockNegate or 1) or 1;
            hum:TakeDamage(damage);
            CombatModEventFolder:FindFirstChild("Attack"):FireClient(plr, args[2], damage)
            if TargetPlayer and TargetData.Block.IsBlocking then
                CombatModEventFolder:FindFirstChild("Block"):FireClient(TargetPlayer);
            end
            if PlayerData.Stand and not PlayerData.Stand.Abilities.Rage.Active then
                PlayerData.DamageDealt += damage;
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