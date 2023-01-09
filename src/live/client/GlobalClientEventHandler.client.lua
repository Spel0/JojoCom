if not _G.JojoCombatScripts then repeat task.wait() until _G.JojoCombatScripts end
local JojoCombat = _G.JojoCombatScripts;
local Player = game.Players.LocalPlayer;
local Debris = game:GetService("Debris")
local RepStorage = game:GetService"ReplicatedStorage";
local RS = game:GetService"RunService";
local CAS = game:GetService"ContextActionService";
local TS = game:GetService"TweenService";
local RSRootFolder = RepStorage:WaitForChild"JojoCombatScripts";
local EventsFolder = RepStorage:WaitForChild("Events");
local CombatModEventFolder = RSRootFolder:WaitForChild"Events";

local sound = Instance.new("Sound", workspace);
sound.SoundId = "rbxassetid://5326246476";
game:GetService("ContentProvider"):PreloadAsync({sound});

CombatModEventFolder:WaitForChild("Knockback").OnClientEvent:Connect(function(part, power)
    JojoCombat.Fire("Knockback", part, power);
end)

EventsFolder:WaitForChild("TimeStop").OnClientEvent:Connect(function(active, duration)
    local con;
    if active then
        JojoCombat.Data.Attacking = true;
        local last = Player.Character.Humanoid.WalkSpeed;
        Player.Character.Humanoid.WalkSpeed = 0;
        local Animator = Player.Character.Humanoid.Animator;
        for _,v in Animator:GetPlayingAnimationTracks() do
            v:AdjustSpeed(0);
        end
        con = Animator.AnimationPlayed:Connect(function(track)
            track:AdjustSpeed(0);
        end)
        task.delay(duration, function()
            con:Disconnect();
            for _,v in Animator:GetPlayingAnimationTracks() do
                v:AdjustSpeed(1);
            end
            JojoCombat.Data.Attacking = false;
            Player.Character.Humanoid.WalkSpeed = last;
        end)
    end
    local Corr = Instance.new("ColorCorrectionEffect", game.Lighting);
    TS:Create(Corr, TweenInfo.new(3), {Contrast = -3}):Play();
    sound:Play();
    task.wait(duration);
    sound.PlaybackSpeed = 2;
    sound:Play();
    local pitch = Instance.new("PitchShiftSoundEffect",sound);
    pitch.Octave = 0.5;
    Debris:AddItem(pitch, 1.5);
    TS:Create(Corr, TweenInfo.new(1.5), {Contrast = 0}):Play();
    task.wait(1.5);
    sound.PlaybackSpeed = 1;
end)