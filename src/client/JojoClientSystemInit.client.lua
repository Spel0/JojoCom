local Player = game.Players.LocalPlayer;
local RepStorage = game:GetService"ReplicatedStorage";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RSRootFolder:WaitForChild("Events");
local RS = game:GetService"RunService";
local Util = require(RSRootFolder.Util);

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

local function initAnimControl()
    local Character = Player.Character or Player.CharacterAdded:Wait();
    local animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator");
    local anims = {Death = "rbxassetid://11843234866", Sprint = "11978499073", Idle = "12014000608", 
    Attack1 = "12014008263", Attack2 = "12014012047", Attack3 = "12014016019", Attack4 = "12014028461",
    Walk = "12071030047", TeleportAbil = "12071055741", ["Time Stop"] = 12071670672, Rage = 12071836394,
    Jump = 12103648246, Block = 12103825878, BlockHit = 12103852150, ["Roll Front"] = 12103943444,
    ["Roll Back"] = 12103947758, ["Roll Right"] = 12103950202, ["Roll Left"] = 12103952824};
    anims = Util.PackToAnimList(anims);
    return _G.JojoCombatScripts:GetAnimMod().new(animator, anims);
end

local function onCharacterAdded(char)
    _G.CharAnim = initAnimControl();
    local hum = char:WaitForChild("Humanoid");
    local con;
    con = RS.Heartbeat:Connect(function()
        if _G.GlobalFunc.IsOnGround(char) then
            if hum.MoveDirection.Magnitude > 0 then
                _G.CharAnim:StopAnim("Idle");
                if _G.IsRunning and not _G.CharAnim:IsAnimPlaying("Sprint") then
                    _G.CharAnim:StopAnim("Walk");
                    _G.CharAnim:PlayAnim("Sprint");
                elseif not _G.IsRunning and not _G.CharAnim:IsAnimPlaying("Walk") then
                    _G.CharAnim:StopAnim("Sprint");
                    _G.CharAnim:PlayAnim("Walk");
                end
            else
                if not _G.CharAnim:IsAnimPlaying("Idle") then
                    _G.CharAnim:PlayAnim("Idle");
                end
                _G.CharAnim:StopAnim("Walk");
                _G.CharAnim:StopAnim("Sprint");
            end
        else
            _G.CharAnim:StopAnim("Walk");
            _G.CharAnim:StopAnim("Sprint");
            _G.CharAnim:StopAnim("Idle");
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
    hum.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Jumping and not _G.CharAnim:IsAnimPlaying("Jump") then
            _G.CharAnim:PlayAnim("Jump");
        elseif (old == Enum.HumanoidStateType.Jumping or old == Enum.HumanoidStateType.Freefall) and new == Enum.HumanoidStateType.Landed and _G.CharAnim:IsAnimPlaying("Jump") then
            _G.CharAnim:StopAnim("Jump");
        end
    end)
    workspace:WaitForChild("PlayersStuff"):WaitForChild(Player.Name):WaitForChild("FinisherPart"):Destroy();
end

if Player.Character then onCharacterAdded(Player.Character); end
Player.CharacterAdded:Connect(onCharacterAdded);

print("Jojo Combat Mod Successfully loaded on Client!")