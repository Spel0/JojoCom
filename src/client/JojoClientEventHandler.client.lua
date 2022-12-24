local Player = game.Players.LocalPlayer;
local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local StandMod = require(RSRootFolder.Stand);
local StandsData = require(RSRootFolder.StandsData);

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
    if _G.JojoCombatScripts.Stand ~= nil then
        _G.JojoCombatScripts.Stand:Destroy();
    end
    _G.JojoCombatScripts.Stand = active and StandMod.new(Model, PackToAnimList(StandsData[Name]["Anims"]), char:WaitForChild("HumanoidRootPart")) or nil;
end)

repeat task.wait() until _G.JojoCombatScripts ~= nil

local CombatMod = _G.JojoCombatScripts;
local ModEvents = CombatMod.Events;

EventsFolder:WaitForChild("Ability").OnClientEvent:Connect(function(Ability:string)
    ModEvents.FireSignal("Ability", Ability);
end)

ModEvents.GetEventSignal("Block"):Connect(function()
    EventsFolder:FindFirstChild("Block"):FireServer();
end)

ModEvents.GetEventSignal("Attack"):Connect(function()
    EventsFolder:FindFirstChild("Attack"):FireServer();
end)

ModEvents.GetEventSignal("Ability"):Connect(function()
    EventsFolder:FindFirstChild("Ability"):FireServer();
end)