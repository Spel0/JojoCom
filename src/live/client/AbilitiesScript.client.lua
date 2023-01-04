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
    ["Heavy Punch"] = function(Stand)
        local Character = Player.Character;
        local HRP = Character.HumanoidRootPart;
        local distance = 10;
        local duration = 0.6;
        HitboxMod.new((HRP.CFrame*CFrame.new(0,0, -(distance/2))).Position, (HRP.CFrame*CFrame.new(0, 0, -99999)).Position, HRP.Size.X*2, HRP.Size.Y*2, distance, duration, {Character, JojoCombat.Stand:GetModel()}):registerHit(function(Model)
            EventsFolder:FindFirstChild("Ability"):FireServer("Heavy Punch", Stand, Model);
        end, true);
        return duration;
    end,
    ["Rage"] = function(Stand)
        if not RSRootFolder.Stands:FindFirstChild(Stand) then warn(string.format("Stand %q not found", Stand)) return; end
        local StandData = require(RSRootFolder.Stands:FindFirstChild(Stand).StandData)
        if not StandData.Abilities.Rage then return; end
        if JojoCombat.Data.DamageDealt >= StandData.Abilities.Rage.NeedDamage then
            EventsFolder:FindFirstChild("Ability"):FireServer("Rage")
        end
    end,
    ["Teleport"] = function(Stand)
        local Player = game.Players.LocalPlayer;
        if not RSRootFolder.Stands:FindFirstChild(Stand) then warn(string.format("Stand %q not found", Stand)) return; end
        local StandData = require(RSRootFolder.Stands:FindFirstChild(Stand).StandData)
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
    end,
    ["Time Stop"] = function(Stand)
        EventsFolder:FindFirstChild("Ability"):FireServer("Time Stop", Stand);
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
    if JojoCombat.Stand.Abilities[Ability].Anim ~= nil then
        JojoCombat.Stand:SetIdle(false);
        JojoCombat.Stand:PlayAnim(Ability);
    end
    local waitTime = Abilities[Ability](Stand);
    task.wait(waitTime);
    JojoCombat.Data.Attacking = false;
    if not JojoCombat.Stand:GetIdle() then
        JojoCombat.Stand:SetIdle(true);
    end
end)