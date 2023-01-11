local Debris = game:GetService("Debris")
local PS = game:GetService"PhysicsService";
local RunService = game:GetService"RunService";
local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local StandsFolder = RSRootFolder.Stands;
local CombatMod = require(RSRootFolder.JojoCombatMod);
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
        if targetData.InSpecialAnim or targetData.Invincible then return; end
    end
    if not PlayerData.IsDead and not PlayerData.Stunned and os.clock() - PlayerData.LastAttack > ModSettings.AttackCooldown then
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
        if targetPlayer and targetData.Block.IsBlocking then
            EventsFolder:FindFirstChild("Block"):FireClient(targetPlayer);
        end
        PlayerData.LastAttack = os.clock();
        return true;
    end
    return false;
end

EventsFolder.Block.OnServerEvent:Connect(function(plr, active)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead and not PlayerData.Stunned then
        if not PlayerData.Block.IsBlocking and os.clock() - PlayerData.Block.LastBlock > ModSettings.BlockCooldown and active then
            PlayerData.Block.IsBlocking = true;
            task.wait(ModSettings.BlockWearOff);
        end
        PlayerData.Block.LastBlock = os.clock();
        PlayerData.Block.IsBlocking = false;
    end
end)

local abilTaskTable = {};

EventsFolder.Ability.OnServerEvent:Connect(function(plr, Ability:string, ...)
    local PlayerData = Data.getPlayerData(plr);
    local stand = StandsFolder:FindFirstChild(PlayerData.Stand.Name);
    if not PlayerData.IsDead and not PlayerData.Stunned and stand ~= nil and PlayerData.Stand.Model ~= nil then
        local abil = PlayerData.Stand.Abilities[Ability];
        if abil ~= nil and (abil.Cooldown == nil or os.clock() - (abil.LastUsed or 0) > abil.Cooldown) then
            if abil.Type == "Damage" then
                local args = {...};
                if typeof(args[2]) == "Instance" and args[2]:IsA("Player") then
                    local targetPlayer = game.Players:GetPlayerFromCharacter(args[2]);
                    local targetPlayer = Data.getPlayerData(targetPlayer);
                    if targetPlayer.InSpecialAnim or targetPlayer.Invincible then return; end
                end
            end
            EventsHandler.FireEvent("Ability", plr, Ability, ...);
            if not abilTaskTable[abil] or coroutine.status(abilTaskTable[abil]) == "dead" then
                abilTaskTable[abil] = coroutine.create(function() 
                    abil.LastUsed = os.clock();
                end)
                task.delay(abil.Duration or 0, abilTaskTable[abil]);
            end
        end
    end
end)

CombatMod.GetBlockSignal():Connect(function(plr)
    EventsFolder:FindFirstChild("Block"):FireClient(plr);
end)

local function AddAnimItem(item, character, duration)
    item.Parent = character;
    local Motor = Instance.new("Motor6D");
    if item:IsA("Model") then
        --item.PrimaryPart.Position = character.HumanoidRootPart.Position;
        Motor.Part1 = item.PrimaryPart;
    else
        --item.Position = character.HumanoidRootPart.Position;
        Motor.Part1 = item;
    end
    Motor.Part0 = character.HumanoidRootPart;
    Motor.Parent = character.HumanoidRootPart;
    task.delay(duration, function()
        Motor.Part0 = nil;
        Motor.Part1 = nil;
        Motor:Destroy();
        item:Destroy();
    end)
end

CombatMod.GetFinisherSignal():Connect(function(trigger, target, finisher)
    for _,v in trigger.Character:GetDescendants() do
        if v:IsA("BasePart") then
            local old = v.CanCollide;
            v.CanCollide = false;
            local con; con = RunService.Stepped:Connect(function()
                v.CanCollide = false;
            end)
            task.delay(finisher.Duration, function()
                v.CanCollide = old;
                con:Disconnect();
            end)
        end
    end
    for _,v in target.Character:GetDescendants() do
        if v:IsA("BasePart") then
            local old = v.CanCollide;
            v.CanCollide = false;
            local con; con = RunService.Stepped:Connect(function()
                v.CanCollide = false;
            end)
            task.delay(finisher.Duration, function()
                v.CanCollide = old;
                con:Disconnect();
            end)
        end
    end
    trigger.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable;
    trigger.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable;
    target.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable;
    target.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable;
    for _,item in finisher.Player1Items do
        AddAnimItem(item:Clone(), trigger.Character, finisher.Duration);
    end
    for _,item in finisher.Player2Items do
        AddAnimItem(item:Clone(), target.Character, finisher.Duration);
    end
    target.Character.HumanoidRootPart.CFrame = trigger.Character.HumanoidRootPart.CFrame * CFrame.new((finisher.Player2Offset or Vector3.new()));
    local triggerData, targetData = Data.getPlayerData(trigger), Data.getPlayerData(target);
    local player1Anim, player2Anim = string.format("%s_Player1", finisher.Name), string.format("%s_Player2", finisher.Name);

    triggerData.AnimMod:PlayAnim(player1Anim);
    local track = targetData.AnimMod:PlayAnim(player2Anim);
    task.wait(finisher.Duration);
    targetData.AnimMod:PlayAnim(player2Anim);
    targetData.AnimMod:ChangeTimePos(player2Anim, track.Length-0.1);
    targetData.AnimMod:ChangeSpeed(player2Anim, 0);
    CombatMod.Fire("FinisherFinale");
    trigger.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice;
    trigger.DevTouchMovementMode = Enum.DevTouchMovementMode.UserChoice;
    target.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice;
    target.DevTouchMovementMode = Enum.DevTouchMovementMode.UserChoice;
end)