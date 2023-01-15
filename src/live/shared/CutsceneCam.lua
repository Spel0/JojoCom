local RS = game:GetService"RunService";
if not RS:IsClient() then error("Client only module") end
local HTTPService = game:GetService"HttpService";

local module = {}
module.__index = module;

export type CutCamArgs = {
    ["ReferenceModel"] : Model?,
    ["ReferencePart"] : BasePart?,
    ["RefModelAnimID"] : string|number?,
    ["Moon2CamFolder"] : Folder?,
    ["Camera"] : Camera
}

function module.new(UseMoon2Cam:boolean, args:CutCamArgs)
    local self = setmetatable({
        __moon2Cam = UseMoon2Cam,
        __moon2Folder = args["Moon2CamFolder"],
        __cam = args["Camera"],
        __camFolder = args["Moon2CamFolder"],
        __refPart = args["ReferencePart"],
        __refModel = args["ReferenceModel"],
        __uniqueID = HTTPService:GenerateGUID(),
        __frame = 0,
        Playing = false,
        Alive = true
    }, module);

    assert(self.__cam, "No Camera was Provided");
    self.__camOldType = self.__cam.CameraType;

    if self.__moon2Cam then
        assert(self.__moon2Folder, "Please provide Moon 2 Camera Folder");
    else
        assert(self.__refPart, "Please provide Reference Part for Camera to Follow, or use Moon 2 Camera");
        if args["RefModelAnimID"] then
            assert(self.__refModel, "Please provide the Model that the Animation was created on");
            local anim = Instance.new("Animation");
            anim.AnimationId = tonumber(args["RefModelAnimID"]) ~= nil and `rbxassetid://{args["RefModelAnimID"]}` or args["RefModelAnimID"];
            local animator = self.__refModel:FindFirstChildOfClass("AnimationController") or Instance.new("AnimationController", self.__refModel);
            self.__refAnim = animator:LoadAnimation(anim);
            local con; con = self.__refAnim.Stopped:Connect(function()
                if self.Alive then
                    self:Stop();
                else
                    con:Disconnect();
                end
            end)
        end
    end

    return self;
end

function module:__update(dt)
    if not self.Alive or not self.Playing then return; end
    self:__camCheck();
    if self.__moon2Cam then
        self.__frame += dt * self.__animSpeed * 60;
        local frameInstance = self.__moon2Folder.Frames:FindFirstChild(tonumber(math.ceil(self.__frame)));
        if frameInstance then
            self.__cam.CFrame = frameInstance.CFrame;
        else
            self:Stop();
        end
    else
        self.__cam.CFrame = self.__refPart.CFrame;
    end
end

function module:__camCheck()
    if self.__cam.CameraType ~= Enum.CameraType.Scriptable then
        self.__cam.CameraType = Enum.CameraType.Scriptable;
    end
end

function module:Play(Speed:number?): AnimationTrack
    self.__animSpeed = Speed or 1;
    if self.__refAnim then
        self.__refAnim:AdjustSpeed(self.__animSpeed);
        if not self.__refAnim.IsPlaying then
            self.__refAnim:Play();
        end
    end
    self.Playing = true;
    RS:BindToRenderStep("CutsceneCamera_"..self.__uniqueID, Enum.RenderPriority.Camera.Value + 1, function(dt)
        self:__update(dt);
    end)
    return self.__refAnim;
end

function module:Pause()
    self.Playing = false;
    if self.__refAnim then
        self.__refAnim:AdjustSpeed(0);
    end
end

function module:Stop()
    self.Playing = false;
    self.__frame = 0;
    self.__cam.CameraType = self.__camOldType;
    if self.__refAnim and self.__refAnim.IsPlaying then
        self.__refAnim:Stop();
    end
end

function module:SetTimePos(Seconds:number)
    if self.__moon2Cam then
        self.__frame = Seconds;
    else
        if not self.__refAnim.IsPlaying then
            self.__refAnim:AdjustSpeed(0);
            self.__refAnim:Play();
        end
        self.__refAnim.TimePosition = Seconds;
    end
end

function module:Destroy()
    RS:UnbindFromRenderStep("CutsceneCamera_"..self.__uniqueID);
    self.__cam.CameraType = self.__camOldType;
    if self.__refAnim then
        self.__refAnim:Destroy();
    end

    table.clear(self);
    self.Alive = false;
end

table.freeze(module);
return module;