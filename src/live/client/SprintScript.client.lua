if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local JojoCombat = _G.JojoCombatScripts;
local CAS = game:GetService"ContextActionService";
local Player = game.Players.LocalPlayer;
local RS = game:GetService("RunService");

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

CAS:BindAction("Sprint", function(_, inputState)
    if inputState ~= Enum.UserInputState.Begin or not JojoCombat.Data.AllowSprint or JojoCombat.Data.Stunned then return; end
    _G.IsRunning = not _G.IsRunning;
    Event:FireServer(_G.IsRunning);
    local character = Player.Character;
    character.Humanoid.WalkSpeed = _G.IsRunning and 28 or 16;
   --[[ if not _G.CharAnim then return; end
    local con; con = RS.Heartbeat:Connect(function()
        if not _G.IsRunning then 
            con:Disconnect(); 
            if _G.CharAnim:IsAnimPlaying("Sprint") then
                _G.CharAnim:StopAnim("Sprint");
            end
            return; 
        end
        if character.Humanoid.MoveDirection.Magnitude > 0 and not _G.CharAnim:IsAnimPlaying("Sprint") and _G.GlobalFunc.IsOnGround(character) then
            _G.CharAnim:PlayAnim("Sprint");
        elseif (character.Humanoid.MoveDirection.Magnitude == 0 and _G.CharAnim:IsAnimPlaying("Sprint")) or not _G.GlobalFunc.IsOnGround(character) then
            if _G.CharAnim:IsAnimPlaying("Sprint") then
                _G.CharAnim:StopAnim("Sprint");
            end
        end
    end)--]]
end, true, Enum.KeyCode.LeftShift);
CAS:SetTitle("Sprint", "Sprint");