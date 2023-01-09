if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local CAS = game:GetService"ContextActionService";
local Player = game.Players.LocalPlayer;
local JojoCombat = _G.JojoCombatScripts
local ModSettings = JojoCombat.GetModSettings();
local cooldown = ModSettings.BlockCooldown;
local last = os.clock();

local function action(_, inputState)
    if inputState ~= Enum.UserInputState.Begin or os.clock() - last < cooldown then return; end
    JojoCombat.Fire("Block", not JojoCombat.Data.Blocking);
    last = os.clock();
    if not _G.CharAnim then return; end
    if JojoCombat.Data.Blocking then
        local anim = _G.CharAnim:PlayAnim("Block");
        if anim then
            anim.Stopped:Once(function()
                if not JojoCombat.Data.Blocking then return; end
                anim:AdjustSpeed(0);
                anim:Play();
                anim.TimePosition = anim.Length;
            end)
        end
        task.wait(ModSettings.BlockWearOff);
        if JojoCombat.Data.Blocking then
            action(_, Enum.UserInputState.Begin);
        end
    else
        if _G.CharAnim:IsAnimPlaying("Block") then
            _G.CharAnim:StopAnim("Block");
        end
    end
end

CAS:BindAction("Block", action, true, Enum.KeyCode.F);
CAS:SetTitle("Block", "Block");