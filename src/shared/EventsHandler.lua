--[=[
    @class EventHandler

    Handles events for the system
    @tag Events
]=]

local module = {
    __events = {}
}
local interface = {};

local Signal = require(script.Parent.Dependencies.signal);
local Promise = require(script.Parent.Dependencies.promise);
export type Signal = typeof(Signal);
type Promise = typeof(Promise);

--[=[
    @within EventHandler

    Registers a new Event Signal connection if none is found
    ```lua
    Events.RegisterEvent("Hit")
    ```
]=]
function interface.RegisterEvent(Name:string): Signal
    if module.__events[Name] then module.__events[Name]:Destroy() end
    module.__events[Name] = Signal.new();
    return module.__events[Name];
end

--[=[
    @within EventHandler

    Returns Event Signal if found
]=]
function interface.GetEventSignal(Name:string): Signal|nil
    return module.__events[Name];
end

--[=[
    @within EventHandler

    Fires the specified Event with arguments

    Alternative: FireSignal
    ```lua
    Events.FireEvent("Hit", game.Players["Someone"], 30)
    --OR
    Events.FireSignal("Hit", game.Players["Someone"], 30)
    ```
]=]
function interface.FireEvent(Name:string, ...:any)
    local args = {...};
    local res = Promise.try(function()
            return assert(module.__events[Name]);
        end)
        :andThen(function() 
            module.__events[Name]:Fire(unpack(args));
        end)
        :catch(function()
            warn(string.format("Event %q not found", Name));
            return false;
        end)
end

function interface.FireSignal(Name:string, ...:any)
    return interface.FireEvent(Name, ...);
end

--[=[
    @within EventHandler

    Destroys an Event signal
    ```lua
    Events.DestroyEvent("Hit")
    ```
]=]
function interface.DestroyEvent(Name:string)
    Promise.try(function()
            return assert(module.__events[Name].Destroy);
        end)
        :andThen(function()
            module.__events[Name]:Destroy();
        end)
        :catch()
        :finally(function()
            module.__events[Name] = nil;
        end)
end

table.freeze(interface);
return interface;