if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local JojoCombat = _G.JojoCombatScripts;
local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local CAS = game:GetService"ContextActionService";
local UIS = game:GetService"UserInputService";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local EventsHandler = require(RSRootFolder.EventsHandler)
local StandMod = require(RSRootFolder.Stand);
local HitboxMod = require(game.ReplicatedStorage.CustomModules.Hitbox);
local UtilMod = JojoCombat.GetUtilMod();
local activatedActions = {}

local Abilities = {
    ["Heavy Punch"] = function(Stand, StandData)
        local Character = Player.Character;
        local HRP = Character.HumanoidRootPart;
        local distance = 10;
        local duration = StandData.Abilities["Heavy Punch"].Duration;
        HitboxMod.new((HRP.CFrame*CFrame.new(0,0, -(distance/2))).Position, (HRP.CFrame*CFrame.new(0, 0, -99999)).Position, HRP.Size.X*2, HRP.Size.Y*2, distance, duration, {Character, JojoCombat.Stand:GetModel()}):registerHit(function(Model)
            EventsFolder:FindFirstChild("Ability"):FireServer("Heavy Punch", Stand, Model);
        end, true);
        return duration;
    end,
    ["Rage"] = function(Stand, StandData)
        if not StandData.Abilities.Rage then return; end
        if JojoCombat.Data.DamageDealt >= StandData.Abilities.Rage.NeedDamage then
            if _G.CharAnim then
                _G.CharAnim:PlayAnim("Rage");
            end
            EventsFolder:FindFirstChild("Ability"):FireServer("Rage")
        end
    end,
    ["Teleport"] = function(Stand, StandData)
        local Player = game.Players.LocalPlayer;
        if not StandData.Abilities.Teleport then return; end
        local AbilData = StandData.Abilities.Teleport
        if UtilMod.GetPlatform() == "PC" then
            local MouseHit = Player:GetMouse().Hit.Position;
            local PlayerPos = Player.Character.HumanoidRootPart.Position;
            local MouseHit2 = Vector3.new(MouseHit.X, PlayerPos.Y, MouseHit.Z)
            Player.Character:MoveTo(PlayerPos + (CFrame.new(PlayerPos, MouseHit2).LookVector*math.clamp((PlayerPos - MouseHit2).Magnitude, 0, AbilData.MaxDistance)));
        else
            Player.Character:MoveTo(Player.Character.HumanoidRootPart.CFrame.LookVector*math.random(3, AbilData.MaxDistance));
        end
        if _G.CharAnim then
            _G.CharAnim:PlayAnim("TeleportAbil");
        end
    end,
    ["Time Stop"] = function(Stand, StandData)
        if not StandData.Abilities["Time Stop"] then return; end
        _G.CharAnim:PlayAnim("Time Stop");
        JojoCombat.Stand:PlayAnim("Time Stop");
        EventsFolder:FindFirstChild("Ability"):FireServer("Time Stop", Stand);
    end,
    ["Barrage"] = function(Stand, StandData)
        if not StandData.Abilities.Barrage then return; end
        local Character = Player.Character;
        local HRP = Character.HumanoidRootPart;
        local lastSpeed = Character.Humanoid.WalkSpeed;
        local distance = 5;
        local duration = StandData.Abilities.Barrage.Duration;
        local StandModel = JojoCombat.Stand:GetModel();
        task.spawn(function()
            local last = os.clock();
            while os.clock() - last < duration do
                StandModel.PrimaryPart.CFrame = HRP.CFrame * CFrame.new(0, 1, -(distance/2));
                RS.Heartbeat:Wait();
            end
            Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true);
            Character.Humanoid.WalkSpeed = lastSpeed;
        end)
        EventsFolder:FindFirstChild("Ability"):FireServer("Barrage", Stand, true);
        HitboxMod.new((HRP.CFrame*CFrame.new(0,0, -(distance/2))).Position, (HRP.CFrame*CFrame.new(0, 0, -99999)).Position, HRP.Size.X*2, HRP.Size.Y*2, distance, duration, {Character, StandModel}):registerHit(function(Model)
            EventsFolder:FindFirstChild("Ability"):FireServer("Barrage", Stand, Model);
        end, false, 0.2):setFollowTarget(StandModel.PrimaryPart, Vector3.new(0, 0, -(distance/2)));
        Character.Humanoid.WalkSpeed = StandData.Abilities.Barrage.WalkSpeed;
        Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
        return duration;
    end
}

EventsFolder:WaitForChild("StandInit").OnClientEvent:Connect(function(active:boolean, Name:string?, Model:Model?)
    if active then
        local StandFolder = RSRootFolder.Stands:FindFirstChild(Name);
        assert(StandFolder, "Stand Folder Doesn't Exist");
        if not JojoCombat.Stand then
            repeat task.wait() until JojoCombat.Stand
        end
        for i,v in require(StandFolder.StandData)["Abilities"] do
            if not v.BindKey then
                warn(string.format("Keyboard bind for %q ability wasn't set! Please set it in the StandData module!", i));
                continue;
            end
            CAS:BindAction(i, function(_, inputState)
                if inputState ~= Enum.UserInputState.Begin or not _G.GlobalFunc.IsAlive(Player.Character) or JojoCombat.Data.Attacking or JojoCombat.Data.Blocking then return; end
                JojoCombat.Stand:UseAbility(i);
            end, true, v.BindKey);
            table.insert(activatedActions, i);
        end
    else
        for _,v in activatedActions do
            CAS:UnbindAction(v);
        end
        table.clear(activatedActions);
    end
end)

JojoCombat.GetAbilitySignal():Connect(function(Stand:string, Ability:string)
    if not Abilities[Ability] then warn(string.format("Ability %q not found", Ability)); return; end
    JojoCombat.Data.Attacking = true;
    print(Stand, Ability);
    local StandData = require(RSRootFolder.Stands:FindFirstChild(Stand).StandData)
    local waitTime = Abilities[Ability](Stand, StandData);
    if JojoCombat.Stand.Abilities[Ability].Anim ~= nil and waitTime ~= false then
        JojoCombat.Stand:SetIdle(false);
        JojoCombat.Stand:PlayAnim(Ability);
    end
    task.wait(waitTime or 0);
    JojoCombat.Data.Attacking = false;
    JojoCombat.Stand:StopAnim(Ability);
    if not JojoCombat.Stand:GetIdle() then
        JojoCombat.Stand:SetIdle(true);
    end
end)