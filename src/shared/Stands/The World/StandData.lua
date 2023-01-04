return {
	Model = game.ReplicatedStorage.Stands:FindFirstChild("The World"), --Insert path to model here
	Anims = {
		Idle = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Idle"),
		Barrage = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Barrage"),
		Attack1 = 12014149238,
		Attack2 = 12014157397,
		Attack3 = 12014159195,
		Attack4 = 12014161996
	},
	Abilities = {
		["Time Stop"] = {
			Type = "Util",
			Cooldown = 60,
			Distance = 50,
			Duration = 10,
			Anim = nil,
			BindKey = Enum.KeyCode.H
		},
		["Barrage"] = {
			Type = "Damage",
			Cooldown = 120,
			BlockNegate = .6,
			Anim = true,
			BindKey = Enum.KeyCode.E
		},
		["Rage"] = {
			Type = "Buff",
			Anim = nil,
			NeedDamage = 100,
			ActiveFor = 30,
			BindKey = Enum.KeyCode.G
		},
		["Teleport"] = {
			Type = "Util",
			Cooldown = 30,
			MaxDistance = 50,
			Anim = nil,
			BindKey = Enum.KeyCode.Z
		},
		["Heavy Punch"] = {
			Type = "Damage",
			Cooldown = 30,
			Damage = 45,
			Anim = true,
			KnockbackPower = 200,
			BindKey = Enum.KeyCode.R
		}
	},
	Finisher = "Road Roller", --Or {"Road Roller", "Something Else"}
}
