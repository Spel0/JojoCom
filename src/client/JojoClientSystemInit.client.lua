local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local RS = game:GetService"RunService";

--[[local Stand = require(RSRootFolder.Stand);
local StandsData = require(RSRootFolder.StandsData);

Player.AttributeChanged:Connect(function(att)
    if att == "JoJoStand" then
        if Player:GetAttribute(att) ~= nil then
            local Stand = Player.Character:FindFirstChild("JoJoStand");
            Stand.new(Stand, StandsData[Stand:GetAttribute("StandName")]["Anims"]);
        end
    end
end)--]]

_G.JojoCombatScripts = require(RSRootFolder.JojoCombatMod);
_G.JojoCombatScripts.Events = require(RSRootFolder.EventsHandler);

local function onCharacterAdded(char)
    repeat task.wait() until _G.CharAnim
    local hum = char:WaitForChild("Humanoid");
    local con;
    con = RS.Heartbeat:Connect(function()
        if _G.CharAnim:IsAnimPlaying("Idle") and ((char.Humanoid.MoveDirection.Magnitude > 0 and _G.GlobalFunc.IsOnGround(char)) or (not _G.GlobalFunc.IsOnGround(char) and hum.Jumping)) then
            _G.CharAnim:StopAnim("Idle");
        elseif not _G.CharAnim:IsAnimPlaying("Idle") and char.Humanoid.MoveDirection.Magnitude == 0 and _G.GlobalFunc.IsOnGround(char) then
            _G.CharAnim:PlayAnim("Idle");
        end
    end)
    hum.Died:Connect(function()
        con:Disconnect();
        local anim;
        if not Player:GetAttribute("SpecialDeath") then
            anim = _G.CharAnim:PlayAnim("Death");
        end
        if _G.JojoCombatScripts.Stand ~= nil then
            _G.JojoCombatScripts.Stand:SetIdle(false);
            _G.JojoCombatScripts.Stand:GetAnimMod():PlayAnim("Defeat")
            Player.CharacterRemoving:Once(function()
                if _G.JojoCombatScripts.Stand.Alive then
                    _G.JojoCombatScripts.Stand:Destroy();
                end
                _G.JojoCombatScripts.Stand = nil;
            end)
        end
        if not anim then return; end
        anim.Stopped:Once(function()
            anim:Play();
            anim:AdjustSpeed(0);
            anim.TimePosition = anim.Length-0.1;
        end)
    end)
    workspace:WaitForChild("PlayersStuff"):WaitForChild(Player.Name):WaitForChild("FinisherPart"):Destroy();
end

if Player.Character then onCharacterAdded(Player.Character); end
Player.CharacterAdded:Connect(onCharacterAdded);

print("Jojo Combat Mod Successfully loaded on Client!")