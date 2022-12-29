local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local StandsFolder = RSRootFolder.Stands;
local EventsHandler = require(RSRootFolder.EventsHandler);
local ModSettings = require(RSRootFolder.ModSettings);
local Data = require(RSRootFolder.Data);
local EventsFolder = RSRootFolder:WaitForChild("Events");


EventsFolder.Attack.OnServerEvent:Connect(function(plr, target:Model, withStand:boolean)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead and os.clock() - PlayerData.LastAttack > ModSettings.AttackCooldown then
        local params = RaycastParams.new(); params.IgnoreWater = true; params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = {target};
        local targetHit = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart;
        local HRP = plr.Character.HumanoidRootPart;
        local wallCheck = workspace:Raycast(HRP.Position, HRP.CFrame.LookVector * (HRP.Position - targetHit.Position).magnitude, params);
        local dotCheck;
        if withStand then
            local Stand = PlayerData.Stand.Model
            dotCheck = (targetHit.Position - HRP.Position).Unit:Dot(Stand.PrimaryPart.CFrame.LookVector);
        else
            dotCheck = (targetHit.Position - HRP.Position).Unit:Dot(HRP.CFrame.LookVector);
        end
        if wallCheck or dotCheck < 0.1 then return; end
        local damage = withStand and ModSettings.StandAttackDamage or ModSettings.AttackDamage;
        EventsHandler.FireEvent("Attack", plr, target, damage*PlayerData.DamageMult);
        EventsFolder.Attack:FireClient(plr, target, damage*PlayerData.DamageMult);
        PlayerData.LastAttack = os.clock();
    end
end)

EventsFolder.Block.OnServerEvent:Connect(function(plr)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead then
        if not PlayerData.Block.IsBlocking and os.clock() - PlayerData.Block.LastBlock > ModSettings.BlockCooldown then
            PlayerData.Block.IsBlocking = true;
            EventsHandler.FireEvent("Block", plr, true);
        elseif PlayerData.Block.IsBlocking then
            PlayerData.Block.LastBlock = os.clock();
            PlayerData.Block.IsBlocking = false;
            EventsHandler.FireEvent("Block", plr, false);
        end
    end
end)

EventsFolder.Ability.OnServerEvent:Connect(function(plr, Ability:string)
    local PlayerData = Data.getPlayerData(plr);
    local stand = StandsFolder:FindFirstChild(PlayerData.Stand.Name);
    if not PlayerData.IsDead and stand ~= nil and PlayerData.Stand.Model ~= nil then
        local abil = PlayerData.Stand.Abilities[Ability];
        if abil ~= nil and (abil.Cooldown == nil or os.clock() - abil.LastUsed > abil.Cooldown) then
            EventsHandler.FireEvent("Ability", plr, Ability);
            abil.LastUsed = os.clock();
        end
    end
end)