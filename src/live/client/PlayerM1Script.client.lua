if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local CAS = game:GetService"ContextActionService";
local Player = game.Players.LocalPlayer;
local JojoCombat = _G.JojoCombatScripts;
local ModSettings = JojoCombat.GetModSettings();
local HitboxMod = require(game.ReplicatedStorage.CustomModules.Hitbox);
local MaxAttack = 4;
local Event = JojoCombat.GetAttackSignal();
local TS = game:GetService"TweenService";

CAS:BindAction("Attack", function(_, inputState)
    if inputState ~= Enum.UserInputState.Begin or not _G.GlobalFunc.IsAlive(Player.Character) or JojoCombat.Data.Attacking or JojoCombat.Data.Blocking then return; end
    if os.clock() - JojoCombat.Data.LastAttack > ModSettings.AttackCooldown then
        if _G.CharAnim then
            if JojoCombat.Data.AttackAnimCount > MaxAttack then JojoCombat.Data.AttackAnimCount = 1; end
            _G.CharAnim:PlayAnim("Attack"..JojoCombat.Data.AttackAnimCount);
            JojoCombat.Data.AttackAnimCount += 1;
        end
        local Character = Player.Character;
        local HRP = Character.HumanoidRootPart;
        local distance = 4;
        local duration = 0.6;
        HitboxMod.new((HRP.CFrame*CFrame.new(0,0, -(distance/2))).Position, (HRP.CFrame*CFrame.new(0, 0, -99999)).Position, HRP.Size.X*2, HRP.Size.Y*2, distance, duration, {Character}):registerHit(function(Model)
            Event:Fire(Model, false);
            local res = JojoCombat.GetEventMod().GetEventSignal("AttackCallback"):Wait();
            return res;
        end, true):setFollowTarget(HRP, Vector3.new(0, 0, -(distance/2)));
        JojoCombat.Data.Attacking = true;
        JojoCombat.Data.LastAttack = os.clock();
        task.wait(duration);
        JojoCombat.Data.Attacking = false;
    end
end, true, Enum.UserInputType.MouseButton1)
CAS:SetTitle("Attack", "Attack");

CAS:BindAction("AttackStand", function(_, inputState) 
    if inputState ~= Enum.UserInputState.Begin or not _G.GlobalFunc.IsAlive(Player.Character) or not JojoCombat.Stand or JojoCombat.Data.Attacking or JojoCombat.Data.Blocking then return; end
    if os.clock() - JojoCombat.Data.LastAttack > ModSettings.AttackCooldown then
        local Character = Player.Character;
        local HRP = Character.HumanoidRootPart;
        if JojoCombat.Data.AttackAnimCount > MaxAttack then JojoCombat.Data.AttackAnimCount = 1; end
            JojoCombat.Stand:SetIdle(false);
            JojoCombat.Stand:PlayAnim("Attack"..JojoCombat.Data.AttackAnimCount);
            JojoCombat.Data.AttackAnimCount += 1;
        local _, _, _, R00, R01, R02, R10, R11, R12, R20, R21, R22 = HRP.CFrame:GetComponents();
        local StandModel = JojoCombat.Stand:GetModel();
        local FinalPos = CFrame.new(HRP.CFrame * Vector3.new(0, 1, -3)) * CFrame.new(0, 0, 0, R00, R01, R02, R10, R11, R12, R20, R21, R22);
        TS:Create(StandModel.PrimaryPart, TweenInfo.new(0.1), {CFrame = FinalPos}):Play();
        local distance = 5;
        local duration = 0.6;
        HitboxMod.new((FinalPos*CFrame.new(0,0, -(distance/2))).Position, (HRP.CFrame*CFrame.new(0, 0, -99999)).Position, HRP.Size.X*2, HRP.Size.Y*2, distance, duration, {Character}):registerHit(function(Model)
            Event:Fire(Model, false);
            local res = JojoCombat.GetEventMod().GetEventSignal("AttackCallback"):Wait() or false;
            return res;
        end, true);
        JojoCombat.Data.Attacking = true;
        JojoCombat.Data.LastAttack = os.clock();
        task.wait(duration);
        JojoCombat.Data.Attacking = false;
        JojoCombat.Stand:SetIdle(true);
    end
end, true, Enum.KeyCode.Q)
CAS:SetTitle("AttackStand", "Stand Attack");