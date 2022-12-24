local CAS = game:GetService"ContextActionService";
local Player = game.Players.LocalPlayer;

local mouseLockController = Player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController");
local obj = mouseLockController:FindFirstChild("BoundKeys")
if obj then
	obj.Value = "LeftAlt, RightShift"
else
	obj = Instance.new("StringValue")
	obj.Name = "BoundKeys"
	obj.Value = "LeftAlt, RightShift"
	obj.Parent = mouseLockController
end

local Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Sprint");
_G.IsRunning = false;

CAS:BindAction("Sprint", function()
    _G.IsRunning = not _G.IsRunning;
    Event:FireServer(_G.IsRunning);
    Player.Character.Humanoid.WalkSpeed = _G.IsRunning and 28 or 16;
    if not _G.CharAnim then return; end
    if _G.IsRunning then
        _G.CharAnim:PlayAnim("Sprint");
    else
        _G.CharAnim:StopAnim("Sprint");
    end
end, true, Enum.KeyCode.LeftShift);
CAS:SetTitle("Sprint", "Sprint");