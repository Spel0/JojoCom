if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local JojoCombat = _G.JojoCombatScripts;
local CAS = game:GetService"ContextActionService";
local Player = game.Players.LocalPlayer;

local cooldown = 3;
local last = os.clock();
local multiplier = 150;
CAS:BindAction("Dash", function(_, inputState)
    if inputState ~= Enum.UserInputState.Begin or os.clock() - last < cooldown or JojoCombat.Stunned or JojoCombat.InSpecialAnim or not _G.GlobalFunc.IsAlive(Player.Character) then return; end
    local HRP = Player.Character.HumanoidRootPart;
    local MoveDir = Player.Character.Humanoid.MoveDirection;
    if MoveDir == Vector3.new() then return; end
    HRP:ApplyImpulse(MoveDir*HRP.AssemblyMass*multiplier);
    --[[if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
        HRP.Rotation = MoveDir;
    end--]]
    last = os.clock();
    if not _G.CharAnim then return; end
    local side = ((MoveDir:Dot(HRP.CFrame.LookVector * 1) >= .5 and "Front") or (MoveDir:Dot(HRP.CFrame.LookVector * -1) >= .5 and "Back")) or ((MoveDir:Dot(HRP.CFrame.RightVector * 1) >= .75 and "Right") or (MoveDir:Dot(HRP.CFrame.RightVector * -1) >= .75 and "Left"));
    _G.CharAnim:PlayAnim(string.format("Roll %s", side));
end, true, Enum.KeyCode.LeftControl);
CAS:SetTitle("Dash", "Dash");