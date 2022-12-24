local CAS = game:GetService"ContextActionService";
local UIS = game:GetService"UserInputService";
local Player = game.Players.LocalPlayer;
local PlayerModule = require(game.Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"));
local Controls = PlayerModule:GetControls();

local cooldown = 3;
local last = os.time();
local multiplier = 150;
CAS:BindAction("Dash", function(_, inputState)
    if inputState ~= Enum.UserInputState.Begin or os.time() - last < cooldown then return; end
    local HRP = Player.Character.HumanoidRootPart;
    local MoveDir = Player.Character.Humanoid.MoveDirection;
    if MoveDir == Vector3.new() then return; end
    HRP:ApplyImpulse(MoveDir*HRP.AssemblyMass*multiplier);
    --[[if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        HRP.Rotation = MoveDir;
    end--]]
    last = os.time();
    if not _G.CharAnim then return; end
    local side = ((MoveDir:Dot(HRP.CFrame.LookVector * 1) >= .5 and "Front") or (MoveDir:Dot(HRP.CFrame.LookVector * -1) >= .5 and "Back")) or ((MoveDir:Dot(HRP.CFrame.RightVector * 1) >= .75 and "Right") or (MoveDir:Dot(HRP.CFrame.RightVector * -1) >= .75 and "Left"));
    print(side);
end, true, Enum.KeyCode.LeftControl);
CAS:SetTitle("Dash", "Dash");