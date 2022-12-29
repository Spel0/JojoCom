local module = {};
local meta = {__index = module};

local RS = game:GetService("RunService");

local function unpackParts(Table:{})
    local toReturn = {};
    for _,value in Table do
        if typeof(value) == "table" then
            for _,v in unpackParts(value) do
                table.insert(toReturn, v);
            end
            continue;
        elseif typeof(value) == "Instance" and (value:IsA("Model") or value:IsA("Folder")) then
            for _,v in value:GetDescendants() do
                if v:IsA("BasePart") then
                    table.insert(toReturn, v);
                end
            end
            continue;
        end
        table.insert(toReturn, value);
    end
    return toReturn;
end

local function disconnectEvent(event:RBXScriptSignal|nil)
    if event then
        event:Disconnect();
    end
end

function module.new(origin:Vector3, direction:Vector3, sizeX:number, sizeY:number, distance:number, duration:number, ignoreList:{}?, visualize:boolean?)
    local self = setmetatable({
        Alive = true,
        __hitEvent = nil,
        __followEvent = nil,
        __ignoreList = unpackParts(ignoreList and ignoreList or {})
    }, meta);

    local hit = Instance.new("Part");
    hit.Anchored = true;
    hit.Color = Color3.new(1, 0, 0);
    hit.Material = Enum.Material.SmoothPlastic;
    hit.Transparency = visualize and 0.8 or 1;
    hit.CanCollide = false;
    hit.CanTouch = true;
    hit.CanQuery = false;
    hit.Size = Vector3.new();
    hit:Resize(Enum.NormalId.Left, sizeX/2);
    hit:Resize(Enum.NormalId.Right, sizeX/2);
    hit:Resize(Enum.NormalId.Top, sizeY/2);
    hit:Resize(Enum.NormalId.Bottom, sizeY/2);
    hit:Resize(Enum.NormalId.Front, distance);
    hit.CFrame = CFrame.new(origin, direction);
    hit.Parent = workspace;


    self.__hitbox = hit;
    task.delay(duration, self.Destroy, self);

    return self;
end

function module:registerHit(callback:(Model)->(), oncePerModel:boolean?, cooldownBetweenHits:number?)
    local hitTable = {};
    cooldownBetweenHits = cooldownBetweenHits or 0;
    disconnectEvent(self.__hitEvent);
    local params = OverlapParams.new(); params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = self.__ignoreList; params.RespectCanCollide = false;
    self.__hitEvent = RS.Heartbeat:Connect(function()
        if not self.Alive then return; end
        for _,v in workspace:GetPartsInPart(self.__hitbox, params) do
            local Model = v:FindFirstAncestorWhichIsA("Model");
            if not Model or not Model:FindFirstChildWhichIsA("Humanoid") or (hitTable[Model] and (oncePerModel or os.clock() - cooldownBetweenHits < hitTable[Model].LastHit)) then return; end
            hitTable[Model] = {
                LastHit = os.clock();
            }
            callback(Model);
        end
        RS.Heartbeat:Wait();
    end)
    return self;
end

function module:setFollowTarget(target:BasePart, offset:Vector3?)
    disconnectEvent(self.__followEvent);
    offset = offset or Vector3.new();
    self.__followEvent = RS.Heartbeat:Connect(function()
        if not self.Alive then return; end
        local Frame = CFrame.new(target.CFrame * offset, (target.CFrame*CFrame.new(0, 0, -99999)).Position);
        self.__hitbox.CFrame = Frame;
    end)
    return self;
end

function module:Destroy()
    disconnectEvent(self.__hitEvent);
    disconnectEvent(self.__followEvent);
    self.__hitbox:Destroy();
    table.clear(self);
    setmetatable(self, {
        __index = function() error("The Method of a Destroyed Hitbox was Called, did you forget to check if it was valid to use with \"hitbox.Alive\"?"); end
    });
end

table.freeze(module);
return module;