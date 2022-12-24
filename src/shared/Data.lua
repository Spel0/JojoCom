--[=[
    @class Data

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

function interface.getPlayerData(plr:Player)
    if not data[plr.UserId] then
        data[plr.UserId] = {
            Character = plr.Character or nil,
            IsDead = false,
            Invincible = false,
            Stand = {
                Model = nil,
                Original = nil,
                Abilities = {},
                Finisher = nil
            },
            Block = {
                IsBlocking = false,
                LastBlock = 0
            },
            InSpecialAnim = false
        };
    end
    return data[plr.UserId];
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