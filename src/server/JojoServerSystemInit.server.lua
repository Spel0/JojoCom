local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local PS = game:GetService("PhysicsService");
local Players = game:GetService"Players";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local CombatMod = require(RSRootFolder.JojoCombatMod);
local ModSettings = require(RSRootFolder.ModSettings);
local Data = require(RSRootFolder.Data);
local Events = require(RSRootFolder.EventsHandler);
local StandsFolder = RSRootFolder.Stands;

local function initializePlayer(plr)
    local PlayerData = Data.getPlayerData(plr);
    local PlayerFolder = Instance.new("Folder")
    PlayerFolder.Name = plr.Name;
    PlayerFolder.Parent = workspace:FindFirstChild("PlayersStuff");
    plr.CharacterAdded:Connect(function(char)
        local Humanoid = char:WaitForChild"Humanoid";
        local Animator = Humanoid:FindFirstChildWhichIsA("Animator");
        if not Animator then
            Animator = Instance.new("Animator");
            Animator.Parent = Humanoid;
        end
        PlayerData.Character = char;
        PlayerData.IsDead = false;
        char.Humanoid.BreakJointsOnDeath = false;
        if not char:IsDescendantOf(workspace) then
            char.AncestryChanged:Wait();
        end
        local finisherAnims = {};
        for _,stand in StandsFolder:GetChildren() do
            local data = require(stand:FindFirstChildOfClass("ModuleScript"));
            for _,finisher in data.Finisher do
                table.insert(finisherAnims, {
                    Name = string.format("%s_Player1", finisher.Name),
                    ID = finisher.Player1Anim
                })
                table.insert(finisherAnims, {
                    Name = string.format("%s_Player2", finisher.Name),
                    ID = finisher.Player2Anim
                })
            end
        end
        PlayerData.AnimMod = CombatMod.GetAnimMod().new(Animator, finisherAnims);

        char.Humanoid.Died:Connect(function()
            char.HumanoidRootPart.Anchored = true;
            PlayerData.IsDead = true;
        end)

        --Setting up the Proxy Prompt Finisher
        --[[for i,v in char:GetDescendants() do
            if v:IsA("BasePart") then
                PS:SetPartCollisionGroup(v, "Players");
            end
        end--]]
        local FinisherProxyPart = Instance.new("Part");
        FinisherProxyPart.Anchored = true;
        FinisherProxyPart.Transparency = 1;
        FinisherProxyPart.CanCollide = false;
        FinisherProxyPart.CanQuery = false;
        FinisherProxyPart.CanTouch = false;
        FinisherProxyPart.Name = "FinisherPart";
        FinisherProxyPart.Parent = PlayerFolder;
        --[[PS:CollisionGroupSetCollidable("Players", "Finisher", false);
        PS:SetPartCollisionGroup(FinisherProxyPart, "Finisher");--]]
        local Proxy = Instance.new("ProximityPrompt");
        Proxy.ObjectText = "Finisher";
        Proxy.ActionText = "Activate";
        Proxy.ClickablePrompt = true;
        Proxy.Enabled = false;
        Proxy.KeyboardKeyCode = Enum.KeyCode.E;
        Proxy.MaxActivationDistance = 8;
        Proxy.RequiresLineOfSight = false;
        Proxy.HoldDuration = 0.3;
        Proxy:SetAttribute("Owner", plr.Name);
        Proxy.Parent = FinisherProxyPart;
        Proxy.Triggered:Connect(function(trigger)
            local target = game.Players:FindFirstChild(Proxy:GetAttribute("Owner"));
            local triggerData, targetData = Data.getPlayerData(trigger), Data.getPlayerData(target);
            local Finisher = triggerData.Stand.Finisher[math.random(1, #triggerData.Stand.Finisher)];
            local params = RaycastParams.new(); params.IgnoreWater = true; params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = {trigger.Character, target.Character};
            local res = workspace:Raycast(trigger.Character.Head.Position, (target.Character.Head.Position - trigger.Character.Head.Position).Unit * (trigger.Character.Head.Position - target.Character.Head.Position).Magnitude, params);
            if res then return; end
            Events.FireEvent("Finisher", trigger, target, Finisher);
            Proxy:Destroy();
            CombatMod.MakePlayerInvincible(trigger, true);
            CombatMod.MakePlayerInvincible(target, true);
            target:SetAttribute("SpecialDeath", true);
            triggerData.InSpecialAnim = true;
            targetData.InSpecialAnim = true;
            Events.GetEventSignal("FinisherFinale"):Wait();
            CombatMod.MakePlayerInvincible(target, false);
            CombatMod.MakePlayerInvincible(trigger, false);
            triggerData.InSpecialAnim = false;
            targetData.InSpecialAnim = false;
            target.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead);
            target.Character.Humanoid.Health = -math.huge
            target.CharacterRemoving:Wait();
            target:SetAttribute("SpecialDeath", false);
        end)

        task.spawn(function()
            while Proxy do
                FinisherProxyPart.Position = char:FindFirstChild("Head").Position;
                if char.Humanoid.Health ~= 0 and char.Humanoid.Health <= ModSettings.HealthForFinisher and ModSettings.HealthForFinisher ~= 0 then
                    Proxy.Enabled = true;
                else
                    Proxy.Enabled = false;
                end
                RS.Heartbeat:Wait();
            end
        end)
    end)

    plr.CharacterRemoving:Connect(function()
        PlayerFolder:FindFirstChild("FinisherPart"):Destroy();
        if ModSettings.KeepStandAfterDeath and PlayerData.Stand.Original ~= nil then
            plr.CharacterAdded:Once(function()
                CombatMod.SummonStand(plr, PlayerData.Stand.Original.Name)
            end)
        else
            table.clear(PlayerData.Stand);
        end
        PlayerData.Character = nil;
    end)
end

--[[PS:CreateCollisionGroup("Players");
PS:CreateCollisionGroup("Finisher");--]]
Instance.new("Folder", workspace).Name = "PlayersStuff";

for i,v in game.Players:GetPlayers() do
    initializePlayer(v);
end
Players.PlayerAdded:Connect(initializePlayer);
Players.PlayerRemoving:Connect(function(plr)
    workspace:FindFirstChild("PlayersStuff"):FindFirstChild(plr.Name):Destroy();
end)

print("Jojo Combat Mod Successfully loaded on Server!")