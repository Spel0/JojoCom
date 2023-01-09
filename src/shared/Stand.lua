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
local JojoCombat = require(game.ReplicatedStorage.JojoCombatScripts.JojoCombatMod);

--[=[
    @class Stand
    @client

    Stand Constructor

    ```lua
    Stand.new(game.ReplicatedStorage.Stands["The World"], AnimList)
    ```
]=]
function stand.new(Stand:Model, Anims:AnimMod.animList, Abilities:{}, HoverOffset:CFrame?, PrimaryPart:Part?)
    local self = setmetatable({
        __stand = Stand,
        __animmod = AnimMod.new(Stand:WaitForChild("AnimationController", 10):WaitForChild("Animator", 10), Anims),
        __idle = true,
        __primaryPart = PrimaryPart,
        __offset = HoverOffset or CFrame.new(2.5, 2.5, 3),
        Alive = true,
        Abilities = Abilities,
        UsingAbility = false
    }, stand);

    local Task = coroutine.create(function()
            --[[local vel = Instance.new("BodyVelocity"); --Make Stand stay in place
            vel.Parent = self.__stand.PrimaryPart;
            vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge);
            vel.Velocity = Vector3.new(0, 0, 0);--]]

            self.__animmod:PlayAnim("Idle");
            task.spawn(self.__update, self);
    end)
    
    if not self.__stand:IsDescendantOf(workspace) then
        self.__stand.AncestryChanged:Once(function()
            task.spawn(Task);
        end)
    else
        task.spawn(Task);
    end

    return self;
end

function stand:__update()
    assert(self.__stand.PrimaryPart, "Please specify the primary part of the Stand model");
    while self.Alive do
        if self.__idle then
            self.__stand.PrimaryPart.CFrame = (self.__primaryPart and self.__primaryPart.CFrame or Player.Character.PrimaryPart.CFrame) * self.__offset;
        end
        RS.Heartbeat:Wait();
    end
end

--[=[
    @within Stand
    @client

    Use Stand Ability if it Exists and Cooldown isn't in Effect with Unlimited Additional Checks as an Optional Parameters
]=]
function stand:UseAbility(Name:string, ...)
    if table.find({...}, true) then return; end
    if self.Abilities and self.Abilities[Name] then
        if not self.Abilities[Name].Cooldown or (self.Abilities[Name].Cooldown and os.clock() - (self.Abilities[Name].LastUsed or 0) > self.Abilities[Name].Cooldown) then
            JojoCombat.Fire("Ability", self.__stand.Name, Name);
            self.UsingAbility = true;
            task.delay(self.Abilities[Name].Duration or 0, function()
                self.UsingAbility = false;
            end)
            self.Abilities[Name].LastUsed = os.clock();
        end
    end
end

--[=[
    @within Stand
    @client

    Get Stand Idle Status
]=]
function stand:GetIdle()
    return self.__idle;
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
    self.Alive = false;
    setmetatable(self, {__index = function() error("The Stand was already Destroyed, please use \"Stand.Alive\" property if you want to check if it's active") end});
end

table.freeze(stand);
return setmetatable({}, stand);