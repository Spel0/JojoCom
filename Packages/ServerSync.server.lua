local RemoteFunc = script:GetAttribute("RemoteFunc");
RemoteFunc = (function() 
	local toReturn = game;
	for _,v in ipairs(string.split(RemoteFunc, ".")) do 
		toReturn = toReturn[v]; 
	end 
	return toReturn;
end)()

local RemoteEvent = script:GetAttribute("RemoteEvent");
RemoteEvent = (function() 
	local toReturn = game;
	for _,v in ipairs(string.split(RemoteEvent, ".")) do 
		toReturn = toReturn[v]; 
	end 
	return toReturn;
end)()

local playingAnims = {};
local connections = {}

local function getIDs(Table)
	for i,v in Table do
		Table[i] = v.Animation.AnimationId;
	end
	return Table
end

local function syncTrack(track, UserId)
	table.insert(playingAnims[UserId], track);
		
	if track.Priority ~= Enum.AnimationPriority.Core then
		local last = track.Speed;
		while track do
			if track.Speed ~= last then
				local match, pos, speed = RemoteFunc:InvokeClient(game.Players:GetPlayerByUserId(UserId), track.Animation.AnimationId, track.Speed);
				if not match and pos ~= nil then
					track.TimePosition = pos;
					track:AdjustSpeed(speed);
				end
				last = track.Speed;
			end
			task.wait();
		end
	end
end

local function TrackEvents(track, ID)
	if connections[ID] == nil then
		connections[ID] = {};
	end
	local Events = { --Add your server keyframe marker events into here
		
		ChangeSpeed = function(speed)
			track:AdjustSpeed(speed);
		end
		
	}
	for i,v in pairs(Events) do
		if connections[ID][i] ~= nil then
			connections[ID][i]:Disconnect();
		end
		connections[ID][i] = track:GetMarkerReachedSignal(i):Connect(v);
	end
end

local function StartTrack(char)
	local UserId = game.Players:GetPlayerFromCharacter(char).UserId;
	playingAnims[UserId] = {};
	task.wait(1); --Let it loaddddd
	local hum = char:WaitForChild("Humanoid");
	if not hum:FindFirstChild("Animator") then
		local Animator = Instance.new("Animator");
		Animator.Parent = hum;
	end
	
	hum.Animator.AnimationPlayed:Connect(function(track)
		syncTrack(track, UserId);
	end)
end

RemoteEvent.OnServerEvent:Connect(function(plr, Animator, ID)
	local found = false;
	if Animator.Parent:IsA("Humanoid") then --Player Character
		for _,v in ipairs(playingAnims[plr.UserId]) do
			if v.Animation.AnimationId == ID then
				TrackEvents(v, ID);
				found = true;
			end
		end
	end
	if not found then --Player Network Owned Model or a Failsafe for above
		task.wait(0.05); --Let it replicate
		for _,v in ipairs(Animator:GetPlayingAnimationTracks()) do
			if v.Animation.AnimationId == ID then
				TrackEvents(v, ID);
			end
		end
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(StartTrack);
end)

for i,v in ipairs(game.Players:GetPlayers()) do
	if v.Character ~= nil then
		task.spawn(StartTrack, v.Character);
	end
	v.CharacterAdded:Connect(StartTrack);
end