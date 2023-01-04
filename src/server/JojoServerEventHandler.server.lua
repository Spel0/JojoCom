local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local StandsFolder = RSRootFolder.Stands;
local EventsHandler = require(RSRootFolder.EventsHandler);
local ModSettings = require(RSRootFolder.ModSettings);
local Data = require(RSRootFolder.Data);
local EventsFolder = RSRootFolder:WaitForChild("Events");
local UtilMod = require(RSRootFolder.Util);


EventsFolder.AttackFunc.OnServerInvoke = function(plr, target:Model, withStand:boolean)
    local PlayerData = Data.getPlayerData(plr);
    local targetPlayer = game.Players:GetPlayerFromCharacter(target);
    local targetData;
    if targetPlayer then
        targetData = Data.getPlayerData(targetPlayer);
    end
    if not PlayerData.IsDead and os.clock() - PlayerData.LastAttack > ModSettings.AttackCooldown then
        local params = RaycastParams.new(); params.IgnoreWater = true; params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = {plr.Character, target};
        local targetHit = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart;
        local HRP = plr.Character.HumanoidRootPart;
        local wallCheck = UtilMod.WallCheck(HRP, targetHit, params);
        local dotCheck;
        if withStand then
            local Stand = PlayerData.Stand.Model
            dotCheck = UtilMod.DotCheck(Stand.PrimaryPart, targetHit);
        else
            dotCheck = UtilMod.DotCheck(HRP, targetHit);
        end
        if wallCheck or dotCheck < 0.1 then return false; end
        local damage = withStand and ModSettings.StandAttackDamage or ModSettings.AttackDamage;
        local blocking = targetData and (targetData.Block.IsBlocking or targetData.InSpecialAnim) or nil;
        local params = {plr, target, damage*PlayerData.DamageMult, blocking};
        EventsHandler.FireEvent("Attack", unpack(params));
        EventsFolder.Attack:FireClient(unpack(params));
        PlayerData.LastAttack = os.clock();
        return true;
    end
    return false;
end

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

EventsFolder.Ability.OnServerEvent:Connect(function(plr, Ability:string, ...)
    local PlayerData = Data.getPlayerData(plr);
    local stand = StandsFolder:FindFirstChild(PlayerData.Stand.Name);
    if not PlayerData.IsDead and stand ~= nil and PlayerData.Stand.Model ~= nil then
        local abil = PlayerData.Stand.Abilities[Ability];
        if abil ~= nil and (abil.Cooldown == nil or os.clock() - (abil.LastUsed or 0) > abil.Cooldown) then
            EventsHandler.FireEvent("Ability", plr, Ability, ...);
            abil.LastUsed = os.clock();
        end
    end
end)