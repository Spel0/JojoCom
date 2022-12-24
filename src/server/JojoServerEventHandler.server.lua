local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";
local EventsHandler = require(RSRootFolder.EventsHandler);
local ModSettings = require(RSRootFolder.ModSettings);
local Data = require(RSRootFolder.Data);
local EventsFolder = RSRootFolder:WaitForChild("Events");


EventsFolder.Attack.OnServerEvent:Connect(function(plr)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead then
        EventsHandler.FireEvent("Attack", plr);
    end
end)

EventsFolder.Block.OnServerEvent:Connect(function(plr)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead then
        if not PlayerData.Block.IsBlocking and os.time() - PlayerData.Block.LastBlock > ModSettings.BlockCooldown then
            PlayerData.Block.IsBlocking = true;
            EventsHandler.FireEvent("Block", plr, true);
        elseif PlayerData.Block.IsBlocking then
            PlayerData.Block.LastBlock = os.time();
            PlayerData.Block.IsBlocking = false;
            EventsHandler.FireEvent("Block", plr, false);
        end
    end
end)

EventsFolder.Ability.OnServerEvent:Connect(function(plr, Ability:string)
    local PlayerData = Data.getPlayerData(plr);
    if not PlayerData.IsDead and PlayerData.Stand.Model ~= nil then
        EventsHandler.FireEvent("Ability", plr, Ability);
    end
end)