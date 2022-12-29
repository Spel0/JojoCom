local JojoMod = require(game.ReplicatedStorage.JojoCombatScripts.JojoCombatMod);

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.3);
        JojoMod.SummonStand(plr, "The World");
    end)
end)