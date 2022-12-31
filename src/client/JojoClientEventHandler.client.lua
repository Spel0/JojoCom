local Player = game.Players.LocalPlayer;
local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
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
    if _G.JojoCombatScripts.Stand ~= nil then
        _G.JojoCombatScripts.Stand:Destroy();
    end
    local hoverOffset:CFrame;
    if Name == "The World" then
        hoverOffset = CFrame.new(2, 1, 2);
    end
    _G.JojoCombatScripts.Stand = active and StandMod.new(Model, PackToAnimList(require(RSRootFolder.Stands:FindFirstChild(Name).StandData)["Anims"]), hoverOffset, char:WaitForChild("HumanoidRootPart")) or nil;
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
    EventsFolder:FindFirstChild("Attack"):FireServer(Target, Stand);
end)