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

function stand.new(Stand:Model, Anims:AnimMod.animList, PrimaryPart:Part?)
    local self = setmetatable({
        __stand = Stand,
        __animmod = AnimMod.new(Stand:WaitForChild("AnimationController", 10):WaitForChild("Animator", 10), Anims),
        __idle = true,
        __primaryPart = PrimaryPart
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
            self.__stand.PrimaryPart.CFrame = (self.__primaryPart and self.__primaryPart.CFrame or Player.Character.PrimaryPart.CFrame) * CFrame.new(2.5, 2.5, 3);
        end
        RS.Heartbeat:Wait();
    end
end

function stand:SetIdle(active:boolean)
    self.__idle = active;
end

function stand:GetAnimMod()
    return self.__animmod;
end

function stand:PlayAnim(Name:string)
    return self.__animmod:PlayAnim(Name);
end

function stand:StopAnim(Name:string)
    return self.__animmod:StopAnim(Name);
end

function stand:GetModel()
    return self.__stand;
end

function stand:Destroy()
    self.__stand:Destroy();
    table.clear(self);
    self = nil;
end

stand.__newindex = function() error("Read-only") end;
return setmetatable({}, stand);