--[=[
    @class Data
    @server

    Stores neccessary information for the system
]=]
local data = {}
local interface = {}
local meta = {
    __index = data,
    __newindex = function(_, i, v)
        data[i] = v;
    end
}

local Promise = require(script.Parent.Dependencies.promise);
local Events = require(script.Parent.EventsHandler);

export type PlayerData = {
    Character: Model|nil,
    IsDead: boolean,
    Invincible: boolean,
    Stand: {
        Model: Model|nil,
        Original: Model|nil,
        Abilities: {},
        Finisher: nil
    },
    Block: {
        IsBlocking: boolean,
        LastBlock: number
    },
    InSpecialAnim: boolean
}

--[=[
    @within Data
]=]
function interface.getPlayerData(plr:Player)
    if not data[plr.UserId] then
        data[plr.UserId] = {
            Character = plr.Character or nil,
            IsDead = false,
            Invincible = false,
            Stand = {
                Model = nil,
                Original = nil,
                Name = nil,
                Abilities = {},
                Finisher = nil
            },
            Block = {
                IsBlocking = false,
                LastBlock = 0
            },
            InSpecialAnim = false,
            LastAttack = 0,
            DamageMult = 1,
            DamageDealt = 0
        };
    end
    return data[plr.UserId];
end

--[=[
    @within Data
]=]
function interface.getBlockDataFromPlayer(plr:Player): {}
    local data = interface.getPlayerData(plr);
    return data.Block;
end

--[=[
    @within Data
]=]
function interface.getAbilityDataFromPlayer(plr:Player, Ability: string): {}
    local data = interface.getPlayerData(plr);
    return data.Stand.Abilities;
end

--[=[
    @within Data
]=]
function interface.getStandDataFromPlayer(plr:Player): {}
    local data = interface.getPlayerData(plr);
    return data.Stand;
end

--[=[
    @within Data

    Add or Substract Damage Multiplier Buff for the Player (in %)
    ```lua
        Data.applyDamageMult(game.Players.Someone, 0.5) -- Adds 50% Damage Buff, or "-0.5" to Substract it
    ```
]=]
function interface.applyDamageMult(plr:Player, amount:number)
    local data = interface.getPlayerData(plr);
    data.DamageMult += amount;
end

--[=[
    @within Data

    Gets Player Damage Multiplier
]=]
function interface.getDamageMult(plr:Player): number
    local data = interface.getPlayerData(plr);
    return data.DamageMult;
end

--[=[
    @within Data
    @param plrKey number -- Player ID

    Clear specified player ID from the session table
    ```lua
        Data.clearPlayerData(123456);
    ```
]=]
function interface.clearPlayerData(plrKey:number)
    local event = nil;
    Promise.try(function()
        event = Events.GetEventSignal("DataRemoving");
        assert(event);
    end)
        :andThen(function()
            event:Fire(plrKey, data[plrKey]);
        end)
        :catch()
        :finally(function()
            data[plrKey] = nil;
        end)
end

return setmetatable(interface, meta);