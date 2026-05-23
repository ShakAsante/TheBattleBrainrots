local SoundService = game:GetService("SoundService")

local Chapter = {}
Chapter.Stages = {

	[1] = {
		EnemyBaseHealth = 700,
		SoundTrack = SoundService.Tracks.BossFight,
		StageName = "Cold Awakening",
		Desc = "The snow begins to fall.",
		Scenery = "Winterlands",
		Difficulty = 1,
		Enemies = {
			{ Name = "NoobPizza", Skin = "Default", Level = 3, Limit = 3, Interval = 11, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 5000 } },
			{ Type = "Gems", Data = { Amount = 30 } },
		}
	},

	-- DEEPER SNOW
	[2] = {
		EnemyBaseHealth = 700,
		SoundTrack = SoundService.Tracks.BossFight,
		StageName = "Snowed In",
		Desc = "Movement slows in the cold.",
		Scenery = "Winterlands",
		Difficulty = 2,
		Enemies = {
			{ Name = "NoobPizza", Skin = "Default", Level = 3, Limit = 3, Interval = 10, Modifiers = {} },
			{ Name = "Fragola", Skin = "Default", Level = 2, Limit = 2, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 6500 } },
			{ Type = "Gems", Data = { Amount = 35 } },
		}
	},

	-- ICE FORMS
	[3] = {
		EnemyBaseHealth = 950,
		SoundTrack = SoundService.Tracks.BossFight,
		StageName = "Frozen Path",
		Desc = "Ice hardens their resolve.",
		Scenery = "Winterlands",
		Difficulty = 3,
		Enemies = {
			{ Name = "Fragola", Skin = "Frozen", Level = 3, Limit = 3, Interval = 10, Modifiers = {} },
			{ Name = "TiTiTiSahur", Skin = "Default", Level = 2, Limit = 2, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 8000 } },
			{ Type = "Gems", Data = { Amount = 40 } },
		}
	},
}

return Chapter
