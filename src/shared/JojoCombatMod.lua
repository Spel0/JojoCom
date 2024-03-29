--[[
    JoJo Bizzare Adventure Combat Module
    Features: Player Combat with Customizable Stands
    Author: Spelo1 (@SpeloDev)
    Created: 14.12.2022 (DD/MM/YYYY)
--]]

--[=[
    @class Main

    Initializes the whole system and exposes methods to control it
]=]
local init = {}
init.__root = game:GetService("ReplicatedStorage"):FindFirstChild("JojoCombatScripts");
assert(init.__root, "Couldn't find root folder for the system, please ensure that the system folder is located in Replicated Storage");
init.Events = require(script.Parent.EventsHandler);
init.Data = require(script.Parent.Data)
init.StandsData = require(script.Parent.StandsData);

local RS = game:GetService"RunService";
local AnimMod = require(script.Parent.Dependencies.AnimController);
local Events = init.Events;
local Data = init.Data;
local StandsData = init.StandsData;

--[=[
    @within Main
    @client
    @ignore

    Initialize player character animations
]=]
local function initAnimControl()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait();
    local animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator");
    local anims = {
        {
            Name = "Death",
            ID = "rbxassetid://11843234866"
        },
    }
    return AnimMod.new(animator, anims);
end

local function cloneServerScripts()
    local scriptFolder = Instance.new("Folder");
    scriptFolder.Name = "JojoCombatScripts";
    scriptFolder.Parent = game:GetService("ServerScriptService");
    for _,v in init.__root.serverScripts:GetChildren() do
        if v:IsA("Script") then
            local clone = v:Clone();
            clone.Parent = scriptFolder
        end
    end
end

local function clonePlayerScripts()
    local plr = game.Players.LocalPlayer;
    local scriptFolder = Instance.new("Folder");
    scriptFolder.Name = "JojoCombatScripts";
    scriptFolder.Parent = plr:WaitForChild("PlayerScripts");

    for _,v in init.__root.clientScripts:GetChildren() do
        if v:IsA("LocalScript") then
            local clone = v:Clone();
            clone.Parent = plr:FindFirstChild("PlayerScripts") or plr:WaitForChild("PlayerScripts");
        end
    end
end

--[[ 
    Methods
--]]
if RS:IsServer() then

    --[=[
        @within Main
        @server

        Summons a Stand and automatically tells the player to initiate and control it
    ]=]
    function init.SummonStand(Player:Player, Stand:string)
        local Model = StandsData[Stand].Model;
        assert(Model.PrimaryPart, "Please specify a primary part of a Stand");
        Model.Archivable = true;
        local StandClone = Model:Clone();
        if StandClone:FindFirstChild("Humanoid") ~= nil and StandClone.Humanoid:FindFirstChildOfClass("Animator") == nil then
            Instance.new("Animator", StandClone.Humanoid);
        end
        local PlayerData = Data.getPlayerData(Player);
        PlayerData.Stand.Model = StandClone;
        PlayerData.Stand.Original = Model;
        PlayerData.Stand.Abilities = StandsData[Stand].Abilities;
        PlayerData.Stand.Finisher = StandsData[Stand].Finisher;
        --StandClone.Name = "JoJoStand";
        StandClone.Parent = Player.Character or Player.CharacterAdded:Wait();
        if not Player.Character:IsDescendantOf(workspace) then
            Player.Character.AncestryChanged:Wait();
        end
        StandClone.PrimaryPart:SetNetworkOwner(Player);
        --Player:SetAttribute("JoJoStand", true);
        init.__root:FindFirstChild("Events"):FindFirstChild("StandInit"):FireClient(Player, true, Stand, StandClone);
    end

    --[=[
        @within Main
        @server

        Removes the Player Stand
    ]=]
    function init.RemoveStand(Player:Player)
        if Data.getPlayerData(Player).Stand.Model ~= nil then
            init.__root:FindFirstChild("Events"):FindFirstChild("StandInit"):FireClient(Player, false);
            table.clear(Data.getPlayerData(Player).Stand);
        end
    end

    --[=[
        @within Main
        @server

        Gets the Player Stand or nil if none is found
    ]=]
    function init.GetStand(Player:Player): Model
        return Data.getPlayerData(Player).Stand.Model;
    end

    --[=[
        @within Main
        @server

        Gets the folder that the module is located in
    ]=]
    function init.GetModFolder(): Folder
        return init.__root;
    end

    --[=[
        @within Main
        @server

        Returns 2 signals:
        Finisher Signal - Activates upon the Finisher being triggered, passes 3 arguments: Attacker (The one who triggered the finisher), Target (The unfortunate soul with low hp) and the Stand Finisher
        Finisher Finale Signal - Should be fired when the Finisher is done to kill the Target and return the Attacker to the normal state
        ```lua
            local finisher, finisherComplete
            finisher, finisherComplete = JojoCombatMod.GetFinisherSignal():Connect(function(Attacker:Player, Target:Player, Finisher:string)
                --Make animations and such play out
                Animation.Finished:Wait()
                finisherComplete.Fire()
            end)
        ```
    ]=]
    function init.GetFinisherSignal(): (Events.Signal, Events.Signal)
        return Events.GetEventSignal("Finisher"), Events.GetEventSignal("FinsiherFinale");
    end

    --[=[
        @within Main
        @server

        Gets Player Data of a particular player
    --]=]
    function init.GetPlayerData(plr:Player): Data.PlayerData
        return Data.getPlayerData(plr);
    end

    --[=[
        @within Main
        @server

        Sets a player invincible status in the Player Data
    ]=]
    function init.MakePlayerInvincible(plr:Player, active:boolean)
        Data.getPlayerData(plr).Invincible = active;
    end

elseif RS:IsClient() then
    
    --[=[
        @within Main
        @client

        Gets Block Event Signal which passes a boolean argument to indicate if Block is activated or not
        ```lua
            _G.JojoCombatMod.GetBlockSignal():Connect( (Active:boolean)=>() )
        ```
    ]=]
    function init.GetBlockSignal()
        return Events.GetEventSignal("Block");
    end

    --[=[
        @within Main
        @client

        Gets Attack Event Signal
    ]=]
    function init.GetAttackSignal()
        return Events.GetEventSignal("Attack");
    end

    --[=[
        @within Main
        @client

        Gets Ability Event Signal
    ]=]
    function init.GetAbilitySignal()
        return Events.GetEventSignal("Ability");
    end

end

--[=[
    @within Main

    Used to fire an Event
]=]
function init.Fire(Name:string, ...:any)
    return Events.FireSignal(Name, ...);
end

--[[
    System Setup
--]]
do 
    if (RS:IsServer()) then

        local eventFolder = Instance.new("Folder");
        eventFolder.Name = "Events";
        eventFolder.Parent = init.__root;
        
        local AbilityEvent = Instance.new("RemoteEvent");
        AbilityEvent.Name = "Ability";
        AbilityEvent.Parent = eventFolder;

        local AttackEvent = Instance.new("RemoteEvent");
        AttackEvent.Name = "Attack";
        AttackEvent.Parent = eventFolder;

        local BlockEvent = Instance.new("RemoteEvent");
        BlockEvent.Name = "Block";
        BlockEvent.Parent = eventFolder;

        local StandEvent = Instance.new("RemoteEvent");
        StandEvent.Name = "StandInit";
        StandEvent.Parent = eventFolder;

        task.delay(0, cloneServerScripts);

        Events.RegisterEvent("Finisher");
        Events.RegisterEvent("FinisherFinale");
    elseif (RS:IsClient()) then
        game.Players.LocalPlayer.CharacterAdded:Connect(function()
            init.CharAnim = initAnimControl();
        end)
        if game.Players.LocalPlayer.Character then
            init.CharAnim = initAnimControl();
        end

        task.delay(0, clonePlayerScripts);

        Events.RegisterEvent("Block");
        Events.RegisterEvent("Attack");
        Events.RegisterEvent("Ability");
    end

end

return init;