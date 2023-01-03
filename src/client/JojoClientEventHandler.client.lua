local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local EventsHandler = require(RSRootFolder.EventsHandler)
local StandMod = require(RSRootFolder.Stand);

local function PackToAnimList(Table)
    local toReturn = {};
    for i,v in Table do
        table.insert(toReturn, {
            Name = i,
            ID = v
        })
    end
    return toReturn
end

EventsFolder:WaitForChild("StandInit").OnClientEvent:Connect(function(active:boolean, Name:string?, Model:Model?)
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
    active = active and true or false;
    if _G.JojoCombatScripts.Stand ~= nil and _G.JojoCombatScripts.Stand.Alive then
        _G.JojoCombatScripts.Stand:Destroy();
    end
    local hoverOffset:CFrame;
    if Name == "The World" then
        hoverOffset = CFrame.new(2, 1, 2);
    end
    if active then
        local StandFolder = RSRootFolder.Stands:FindFirstChild(Name);
        assert(StandFolder, "Invalid Stand");
        local StandData = require(StandFolder.StandData);
        _G.JojoCombatScripts.Stand = StandMod.new(Model, PackToAnimList(StandData["Anims"]), StandData["Abilities"], hoverOffset, char:WaitForChild("HumanoidRootPart"))
    else
        _G.JojoCombatScripts.Stand = nil;
    end
end)

EventsFolder:WaitForChild("Attack").OnClientEvent:Connect(function(target, damage, blocking)
    print(string.format("Successfully attacked %s for %s damage%s", target.Name, damage, blocking and ", but he blocked it!" or ""));
end)

repeat task.wait() until _G.JojoCombatScripts ~= nil

local CombatMod = _G.JojoCombatScripts;
local ModEvents = CombatMod.Events;

EventsFolder:WaitForChild("Ability").OnClientEvent:Connect(function(Stand:Model, Ability:string)
    ModEvents.FireSignal("Ability", Stand, Ability);
end)

ModEvents.GetEventSignal("Block"):Connect(function()
    EventsFolder:FindFirstChild("Block"):FireServer();
end)

ModEvents.GetEventSignal("Attack"):Connect(function(Target:Model, Stand:boolean)
    EventsHandler.RegisterEvent("AttackCallback");
    local res = EventsFolder:FindFirstChild("AttackFunc"):InvokeServer(Target, Stand);
    EventsHandler.FireEvent("AttackCallback", res);
    RS.Heartbeat:Wait();
    EventsHandler.DestroyEvent("AttackCallback");
end)