return {
	Model = game.ReplicatedStorage.Stands:FindFirstChild("The World"), --Insert path to model here
	Anims = {
		Idle = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Idle"),
	},
	Abilities = {
		["Time Stop"] = {
			Type = "Util",
			Cooldown = 60,
			Anim = nil,
		},
		["Barrage"] = {
			Type = "Damage",
			Cooldown = 120,
			Anim = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Barrage"),
		},
		["Rage"] = {
			Type = "Buff",
			Anim = nil,
		},
		["Teleport"] = {
			Type = "Util",
			Cooldown = 30,
			Anim = nil,
		},
	},
	Finisher = "Road Roller", --Or {"Road Roller", "Something Else"}
}
