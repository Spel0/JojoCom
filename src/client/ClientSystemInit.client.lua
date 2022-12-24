local Player = game.Players.LocalPlayer;
local RS = game:GetService"ReplicatedStorage";
local RSRootFolder = RS:WaitForChild"JojoCombatScripts";

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
_G.JojoCombatScripts.StandsData = require(RSRootFolder.StandsData);

local function onCharacterAdded(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        local anim;
        if not Player:GetAttribute("SpecialDeath") then
            anim = _G.JojoCombatScripts.CharAnim:PlayAnim("Death");
        end
        if _G.JojoCombatScripts.Stand ~= nil then
            _G.JojoCombatScripts.Stand:SetIdle(false);
            _G.JojoCombatScripts.Stand:GetAnimMod():PlayAnim("Defeat")
            Player.CharacterRemoving:Once(function()
                _G.JojoCombatScripts.Stand:Destroy();
                _G.JojoCombatScripts.Stand = nil;
            end)
        end
        if not anim then return; end
        anim.Stopped:Connect(function()
            anim:Play();
            anim:AdjustSpeed(0);
            anim.TimePosition = anim.Length;
        end)
    end)
    workspace:WaitForChild("PlayersStuff"):WaitForChild(Player.Name):WaitForChild("FinisherPart"):Destroy();
end

if Player.Character then onCharacterAdded(Player.Character); end
Player.CharacterAdded:Connect(onCharacterAdded);

print("Jojo Combat Mod Successfully loaded on Client!")