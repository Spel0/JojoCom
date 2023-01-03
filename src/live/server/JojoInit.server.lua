local JojoMod = require(game.ReplicatedStorage.JojoCombatScripts.JojoCombatMod);
--require(game.ReplicatedStorage.JojoCombatScripts.Dependencies.AnimController);

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1);
        JojoMod.SummonStand(plr, "The World");
    end)
end)