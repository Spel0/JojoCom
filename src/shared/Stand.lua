--[=[
    @class Stand
    @client
    
    Organizes local Stand logic
]=]
local stand = {}
stand.__index = stand;

local AnimMod = require(game.ReplicatedStorage.JojoCombatScripts.Dependencies.AnimController);
local RS = game:GetService"RunService";
local Player = game.Players.LocalPlayer;

--[=[
    @class Stand
    @client

    Stand Constructor

    ```lua
    Stand.new(game.ReplicatedStorage.Stands["The World"], AnimList)
    ```
]=]
function stand.new(Stand:Model, Anims:AnimMod.animList, HoverOffset:CFrame?, PrimaryPart:Part?)
    local self = setmetatable({
        __stand = Stand,
        __animmod = AnimMod.new(Stand:WaitForChild("AnimationController", 10):WaitForChild("Animator", 10), Anims),
        __idle = true,
        __primaryPart = PrimaryPart,
        __offset = HoverOffset or CFrame.new(2.5, 2.5, 3),
        Alive = true
    }, stand);

    local vel = Instance.new("BodyVelocity"); --Make Stand stay in place
	vel.Parent = self.__stand.PrimaryPart;
	vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
	vel.Velocity = Vector3.new(0, 0, 0);

    self.__animmod:PlayAnim("Idle");
    task.spawn(self.__update, self);

    return self;
end

function stand:__update()
    assert(self.__stand.PrimaryPart, "Please specify the primary part of the Stand model");
    while self do
        if self.__idle then
            self.__stand.PrimaryPart.CFrame = (self.__primaryPart and self.__primaryPart.CFrame or Player.Character.PrimaryPart.CFrame) * self.__offset;
        end
        RS.Heartbeat:Wait();
    end
end


--[=[ 
    @within Stand
    @client

    Sets Stand Idle Status (To make him orbit the Player or not)
]=]
function stand:SetIdle(active:boolean)
    self.__idle = active;
end

--[=[
    @within Stand
    @client

    Get Stand Anim Module
]=]
function stand:GetAnimMod()
    return self.__animmod;
end

--[=[
    @within Stand
    @client
]=]
function stand:PlayAnim(Name:string)
    return self.__animmod:PlayAnim(Name);
end

--[=[
    @Within Stand
    @client
]=]
function stand:StopAnim(Name:string)
    return self.__animmod:StopAnim(Name);
end

--[=[
    @within Stand
    @client

    Gets Stand Model in the World
]=]
function stand:GetModel()
    return self.__stand;
end

--[=[
    @within Stand
    @client

    Remove Stand
]=]
function stand:Destroy()
    self.__stand:Destroy();
    table.clear(self);
    setmetatable(self, {__index = function() error("The Stand was already Destroyed, please use \"Stand.Alive\" property if you want to check if it's active") end});
end

stand.__newindex = function() error("Read-only") end;
return setmetatable({}, stand);