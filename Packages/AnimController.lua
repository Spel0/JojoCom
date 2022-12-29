--!nonstrict

--Made by: Spelo1 (@SpeloDev)
--https://www.roblox.com/library/10976536057/AnimController
--Controls particular Humanoid animations, one Track per Animation
--Must be Required on Server at least once for Animation Syncing to work

local module = {}
module.__index = module;

local RS = game:GetService("RunService");
local CP = game:GetService("ContentProvider");

export type animList = { --How anims table should be sctructured, ID can be both a number or rbxassetid string
	Name: string,
	ID: string|number|Animation
};

if RS:IsServer() then --Add events into the "ServerSync" script for them to replicate
	local Folder = game.ServerScriptService:FindFirstChild("CustomModuleScripts") or Instance.new("Folder");
	Folder.Name = "CustomModuleScripts";
	Folder.Parent = game.ServerScriptService;
	local Func = script:FindFirstChild("AnimSyncFunc") or Instance.new("RemoteFunction", script);
	Func.Name = "AnimSyncFunc"
	local Remote = script:FindFirstChild("AnimSyncRemote") or Instance.new("RemoteEvent", script);
	Remote.Name = "AnimSyncRemote";
	script.Parent.ServerSync:SetAttribute("RemoteFunc", Func:GetFullName());
	script.Parent.ServerSync:SetAttribute("RemoteEvent", Remote:GetFullName());
	script.Parent.ServerSync.Parent = Folder;
end

local function Length(Table)
	local counter = 0 
	for _, v in pairs(Table) do
		counter = counter + 1
	end
	return counter
end

function module.new(Animator:Animator|AnimationController, anims:{animList}?, dynamicMoveSpeed:boolean?, moveSpeed:number?)
	local self = setmetatable(
		{
			Animator = Animator,
			Anims = {},
			GameWalkSpeed = moveSpeed or game:GetService("StarterPlayer").CharacterWalkSpeed,
			UseDynamicMoveSpeed = dynamicMoveSpeed or false, --Adjust "Movement" priority animations speed according to the moveSpeed or Default Game WalkSpeed
			AnimCount = 0
		}, module);
	
	if anims ~= nil then
		self:AddAnims(anims, true);
	end
	
	if RS:IsClient() then
		local Func = script:FindFirstChild("AnimSyncFunc");
		if Func then
			Func.OnClientInvoke = function(ID:string, Speed:number)
				for i,v in pairs(self.Anims) do
					if v.Animation.AnimationId == ID then
						if v.Track.Speed ~= Speed then
							return false, v.Track.TimePosition, v.Track.Speed;
						else
							return true, nil, nil;
						end
					end
				end
				return false, nil, nil;
			end
		end
	end
	
	return self;
end

function module:AddAnims(anims:{animList}, perm:boolean?):{}?
	perm = perm or false;
	local toPreload = perm and {} or nil; --Preloading animations for future use
	local toReturn = {};
	if #anims == 0 then return; end
	for _,v in ipairs(anims) do
		if typeof(v.ID) ~= "Instance" and tonumber(v.ID) ~= nil then
			v.ID = "rbxassetid://"..v.ID;
		elseif typeof(v.ID) == "Instance" and v.ID.ClassName == "Animation" then
			v.ID = v.ID.AnimationId;
		end
		self.Anims[v.Name] = {};
		local key = self.Anims[v.Name];
		key.Animation = typeof(v.ID) == "Instance" and v.ID or Instance.new("Animation");
		key.Animation.AnimationId = tostring(v.ID);
		if perm then
			key.Track = self.Animator:LoadAnimation(key.Animation);
			table.insert(toPreload, key.Animation);
		end
		key.ConEvents = {};
		table.insert(toReturn, key.Track);
		self.AnimCount += 1;
	end
	if perm then
		CP:PreloadAsync(toPreload);
	end
	return #toReturn ~= 1 and toReturn or toReturn[1];
end

function module:PlayAnim(Name:string, onComplete: ()->()?):AnimationTrack? --Supports onComplete callback
	local key = self.Anims[Name];
	if key ~= nil then
		if key.Track ~= nil and key.Track.IsPlaying then
			key.Track:Stop();
		elseif not key.Track then
			assert(key.Animation, "Animation not found, critical error");
			key.Track = self.Animator:LoadAnimation(key.Animation);
		end
		key.Track:Play();
		if self.UseDynamicMoveSpeed and key.Track.Priority == Enum.AnimationPriority.Movement and self.Animator.Parent:IsA("Humanoid") then
			self:ChangeSpeed(Name, self.Animator.Parent.WalkSpeed/self.GameWalkSpeed);
		end
		if RS:IsClient() and script:FindFirstChild("AnimSyncRemote") ~= nil then
			script.AnimSyncRemote:FireServer(self.Animator, key.Track.Animation.AnimationId);
		end
		if onComplete ~= nil then
			local con;
			con = key.Track.Stopped:Connect(function()
				onComplete();
				con:Disconnect();
			end);
		end
		return key.Track;
	else
		warn("Animation "..Name.." isn't found, playing aborted");
		return nil;
	end
end

function module:StopAnim(Name:string, fadeTime:number?):boolean
	local key = self.Anims[Name];
	if key ~= nil then
		if key.Track ~= nil and key.Track.IsPlaying then
			key.Track:Stop(fadeTime or 0.1);
			return true;
		end
	end
	warn("Animation "..Name.." doesn't exist");
	return false;
end

function module:IsAnimPlaying(Name:string):boolean
	local key = self.Anims[Name];
	if key ~= nil then
		if key.Track ~= nil and key.Track.IsPlaying then
			return true;
		else
			return false;
		end
	end
	warn("Animation "..Name.." doesn't exist");
	return false;
end

function module:ChangeSpeed(Name:string, Speed:number):boolean
	local key = self.Anims[Name];
	if key ~= nil then
		if key.Track ~= nil then
			key.Track:AdjustSpeed(Speed);
			return true;
		end
	end
	return false;
end

function module:ChangeTimePos(Name:string, Pos:number):boolean
	local key = self.Anims[Name];
	if key ~= nil then
		if key.Track ~= nil then
			key.Track.TimePosition = Pos;
			return true;
		end
	end
	return false;
end

function module:ReloadAnim(Name:string):boolean --In case the animation needs to be reloaded
	local key = self.Anims[Name];
	if key ~= nil and key.Track ~= nil then
		local loop = key.Track.Looped;
		local priority = key.Track.Priority;
		local speed = key.Track.Speed;
		local position = key.Track.TimePosition;
		key.Track = self.Animator:LoadAnimation(key.Animation)
		key.Track.Looped = loop;
		key.Track.Priority = priority;
		key.Track:AdjustSpeed(speed);
		key.Track.TimePosition = position;
		return true;
	else
		warn("Animation "..Name.." isn't found, reloading aborted");
		return false;
	end
end

function module:ChangeAnim(Name:string, ID:string|number, Play:boolean?):AnimationTrack? --Replace animation with a new one
	Play = Play or false;
	local key = self.Anims[Name];
	if key ~= nil and key.Track ~= nil then
		key.Animation:Destroy();
		key.Track:Stop();
		key.Track:Destroy();
	end
	self:AddAnims({Name, tostring(ID)});
	if Play then return self:PlayAnim(Name); end
	return nil;
end

function module:AddEvent(AnimName:string, MarkName:string, Callback:(string?)->()):RBXScriptSignal? --Keyframe Marker events
	local key = self.Anims[AnimName];
	if key ~= nil and key.Track ~= nil then
		if key.ConEvents[MarkName] ~= nil then
			key.ConEvents[MarkName]:Disconnect();
		end
		key.ConEvents[MarkName] = key.Track:GetMarkerReachedSignal(MarkName):Connect(Callback);
		if RS:IsClient() and script:FindFirstChild("AnimSyncRemote") ~= nil then
			script.AnimSyncRemote:FireServer(self.Animator, key.Track.Animation.AnimationId);
		end
		return key.ConEvents[MarkName];
	else
		warn("Animation "..AnimName.." isn't found, adding event aborted");
		return nil;
	end
end

function module:SetDynamicSpeed(enabled:boolean, speed:number?):boolean
	self.UseDynamicMoveSpeed = enabled;
	self.GameWalkSpeed = speed or self.GameWalkSpeed;
	return true;
end

function module:GetDynamicSpeed():number --For manual speed changing
	if self.Animator.Parent:IsA("Humanoid") then
		return self.Animator.Parent.WalkSpeed/self.GameWalkSpeed;
	else
		warn("Animator is not parented to Humanoid");
		return self.GameWalkSpeed;
	end
end

function module.ChangeDefaultClientAnim(Name:string, ID:string|number) --Not recommended to do as this wouldn't properly preload animation plus no dynamic speed change based on WalkSpeed
	if RS:IsClient() then
		if tonumber(ID) ~= nil then
			ID = "rbxassetid://"..ID;
		end
		game.Players.LocalPlayer.Character:WaitForChild("Animate"):FindFirstChild(Name):FindFirstChildWhichIsA("Animation").AnimationId = ID;
	end
end

module.__newindex = function() error("This class is read-only") end;
module.__metatable = true;
return module