return {
	Model = game.ReplicatedStorage.Stands:FindFirstChild("The World"), --Insert path to model here,
	HoverOffset = CFrame.new(2, 1, 2), --Where the Stand needs to hover in relation to the Player model
	Anims = {
		Idle = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Idle"),
		Barrage = game.ReplicatedStorage.Stands:FindFirstChild("The World"):FindFirstChild("Anims"):FindFirstChild("Barrage"),
		Attack1 = 12014149238,
		Attack2 = 12014157397,
		Attack3 = 12014159195,
		Attack4 = 12014161996,
		["Time Stop"] = 12071653810
	},
	Abilities = {
		["Time Stop"] = {
			Type = "Util",
			Cooldown = 60,
			Distance = 50,
			Duration = 10,
			Anim = true,
			BindKey = Enum.KeyCode.H
		},
		["Barrage"] = {
			Type = "Damage",
			Cooldown = 120,
			Duration = 6,
			BlockNegate = .6,
			Damage = 5,
			Anim = true,
			BindKey = Enum.KeyCode.E,
			WalkSpeed = 6
		},
		["Rage"] = {
			Type = "Buff",
			Anim = nil,
			NeedDamage = 100,
			Duration = 30,
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
			Duration = 0.6,
			Damage = 45,
			Anim = true,
			KnockbackPower = 200,
			BindKey = Enum.KeyCode.R
		}
	},
	Finisher = "Road Roller", --Or {"Road Roller", "Something Else"}
}
