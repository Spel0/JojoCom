local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local EventsHandler = require(RSRootFolder.EventsHandler)
local StandMod = require(RSRootFolder.Stand);
local Util = require(RSRootFolder.Util);

EventsFolder:WaitForChild("StandInit").OnClientEvent:Connect(function(active:boolean, Name:string?, Model:Model?)
    local char = Player.Character or Player.CharacterAdded:Wait();
    active = active and true or false;
    if _G.JojoCombatScripts.Stand ~= nil and _G.JojoCombatScripts.Stand.Alive then
        _G.JojoCombatScripts.Stand:Destroy();
    end
    if active then
        local StandFolder = RSRootFolder.Stands:FindFirstChild(Name);
        assert(StandFolder, "Invalid Stand");
        local StandData = require(StandFolder.StandData);
        if not Model:IsDescendantOf(Player.Character) then
            Model.Parent = Player.Character;
        end
        _G.JojoCombatScripts.Stand = StandMod.new(Model, Util.PackToAnimList(StandData["Anims"]), Util.DeepCopy(StandData["Abilities"]), StandData.HoverOffset, char:WaitForChild("HumanoidRootPart"))
    else
        _G.JojoCombatScripts.Stand = nil;
    end
end)

EventsFolder:WaitForChild("Attack").OnClientEvent:Connect(function(target, damage, blocking)
    print(string.format("Successfully attacked %s for %s damage%s", target.Name, damage, blocking and ", but he blocked it!" or ""));
    if not blocking then
        _G.JojoCombatScripts.Data.DamageDealt += damage;
    end
end)

repeat task.wait() until _G.JojoCombatScripts ~= nil

local CombatMod = _G.JojoCombatScripts;
local ModEvents = CombatMod.Events;

EventsFolder:WaitForChild("Block").OnClientEvent:Connect(function()
    if _G.CharAnim and CombatMod.Data.Blocking and _G.CharAnim:IsAnimPlaying("Block") then
        _G.CharAnim:PlayAnim("BlockHit");
    end
end)

EventsFolder:WaitForChild("Ability").OnClientEvent:Connect(function(Stand:Model, Ability:string)
    ModEvents.FireSignal("Ability", Stand, Ability);
end)

ModEvents.GetEventSignal("Block"):Connect(function(active)
    if CombatMod.Data.Stunned then return; end
    CombatMod.Data.Blocking = active;
    EventsFolder:FindFirstChild("Block"):FireServer(active);
end)

ModEvents.GetEventSignal("Attack"):Connect(function(Target:Model, Stand:boolean)
    if CombatMod.Data.Stunned then return; end
    EventsHandler.RegisterEvent("AttackCallback");
    local res = EventsFolder:FindFirstChild("AttackFunc"):InvokeServer(Target, Stand);
    EventsHandler.FireEvent("AttackCallback", res);
    RS.Heartbeat:Wait();
    EventsHandler.DestroyEvent("AttackCallback");
end)

ModEvents.GetEventSignal("Knockback"):Connect(function(part, power)
    local HRP = Player.Character.HumanoidRootPart;
    local dir = (HRP.Position - part.Position).unit;
    dir = Vector3.new(dir.X, 0, dir.Z);
    Player.Character.HumanoidRootPart:ApplyImpulse(dir*HRP.AssemblyMass*power);
end)