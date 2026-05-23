local SoundService = game:GetService("SoundService")

local Chapter = {}
Chapter.Cost = 0

Chapter.Stages = {

	-- TEACHING PHASE (Difficulty 1 → Level 1)
	[1] = {
		EnemyBaseHealth = 500,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "A Warming Welcome",
		Desc = "Learn the basics.",
		Scenery = "Grasslands",
		Difficulty = 1,
		Enemies = {
			{ Name = "TungTungSahur", Level = 1, Limit = 3, Interval = 6, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 800 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[2] = {
		EnemyBaseHealth = 600,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "First Steps",
		Desc = "They are approaching...",
		Scenery = "Grasslands",
		Difficulty = 1,
		Enemies = {
			{ Name = "TungTungSahur", Level = 1, Limit = 3, Interval = 11, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 1, Limit = 2, Interval = 14, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 900 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[3] = {
		EnemyBaseHealth = 700,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Uneasy Silence",
		Desc = "Something feels off...",
		Scenery = "Grasslands",
		Difficulty = 1,
		Enemies = {
			{ Name = "TungTungSahur", Level = 1, Limit = 3, Interval = 10, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 1100 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[4] = {
		EnemyBaseHealth = 800,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Breaking In",
		Desc = "New enemies appear.",
		Scenery = "Grasslands",
		Difficulty = 2,
		Enemies = {
			{ Name = "TungTungSahur", Level = 2, Limit = 3, Interval = 10, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 2, Limit = 2, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 1200 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[5] = {
		EnemyBaseHealth = 950,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "First Trial",
		Desc = "Hold your ground.",
		Scenery = "Grasslands",
		Difficulty = 2,
		Enemies = {
			{ Name = "TungTungSahur", Level = 2, Limit = 3, Interval = 9, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 2, Limit = 3, Interval = 11, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 1500 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[6] = {
		EnemyBaseHealth = 1100,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Pushing Forward",
		Desc = "No turning back.",
		Scenery = "Grasslands",
		Difficulty = 2,
		Enemies = {
			{ Name = "TiTiTiSahur", Level = 2, Limit = 4, Interval = 9, Modifiers = {} },
			{ Name = "NoobPizza", Level = 3, Limit = 2, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 1800 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[7] = {
		EnemyBaseHealth = 1250,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Ambush",
		Desc = "They surround you.",
		Scenery = "Grasslands",
		Difficulty = 2,
		Enemies = {
			{ Name = "TungTungSahur", Level = 2, Limit = 3, Interval = 8, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 3, Limit = 2, Interval = 10, Modifiers = {} },
			{ Name = "NoobPizza", Level = 3, Limit = 2, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 2100 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[8] = {
		EnemyBaseHealth = 1400,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Unfamiliar Faces",
		Desc = "Stronger foes arrive.",
		Scenery = "Grasslands",
		Difficulty = 3,
		Enemies = {
			{ Name = "BanditoAxolito", Level = 3, Limit = 2, Interval = 12, Modifiers = {} },
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 9, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 2500 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[9] = {
		EnemyBaseHealth = 1550,
		SoundTrack = SoundService.Tracks.Grasslands,
		StageName = "Pressure Rising",
		Desc = "Don’t slip up.",
		Scenery = "Grasslands",
		Difficulty = 3,
		Enemies = {
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 9, Modifiers = {} },
			{ Name = "BanditoAxolito", Level = 3, Limit = 2, Interval = 11, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 3, Limit = 2, Interval = 10, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 2800 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[10] = {
		EnemyBaseHealth = 1700,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "Grasslands Stand",
		Desc = "A true test of strength.",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 8, Modifiers = {} },
			{ Name = "BanditoAxolito", Level = 3, Limit = 2, Interval = 10, Modifiers = {} },
			{ Name = "GangsterFootera", Level = 3, Limit = 1, Interval = 14, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 3100 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	-- HARDER PHASE (final stages, max player level 3)
	[11] = {
		EnemyBaseHealth = 1850,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "Aftershock",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "GangsterFootera", Level = 3, Limit = 2, Interval = 12, Modifiers = {} },
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 7, Modifiers = {} },
			{ Name = "CappuccinoAssasino", Level = 3, Limit = 2, Interval = 6, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 3500 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[12] = {
		EnemyBaseHealth = 2000,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "No Breathing Room",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 8, Modifiers = {} },
			{ Name = "TiTiTiSahur", Level = 3, Limit = 3, Interval = 7, Modifiers = {} },
			{ Name = "BanditoAxolito", Level = 3, Limit = 3, Interval = 10, Modifiers = {} },
			{ Name = "CappuccinoAssasino", Level = 3, Limit = 2, Interval = 6, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 3800 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[13] = {
		EnemyBaseHealth = 2200,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "Relentless",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "TungTungSahur", Level = 3, Limit = 3, Interval = 7, Modifiers = {} },
			{ Name = "GangsterFootera", Level = 3, Limit = 3, Interval = 9, Modifiers = {} },
			{ Name = "TimCheese", Level = 3, Limit = 1, Interval = 12, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 4100 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[14] = {
		EnemyBaseHealth = 2400,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "Crushing Force",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "BanditoAxolito", Level = 3, Limit = 3, Interval = 7, Modifiers = {} },
			{ Name = "GangsterFootera", Level = 3, Limit = 3, Interval = 9, Modifiers = {} },
			{ Name = "TimCheese", Level = 3, Limit = 1, Interval = 12, Modifiers = {} },
			{ Name = "CappuccinoAssasino", Level = 3, Limit = 2, Interval = 6, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 4400 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	[15] = {
		EnemyBaseHealth = 2700,
		SoundTrack = SoundService.Tracks.Kingdom,
		StageName = "Edge of Collapse",
		Scenery = "Kingdom",
		Difficulty = 3,
		Enemies = {
			{ Name = "TiTiTiSahur", Level = 3, Limit = 4, Interval = 7, Modifiers = {} },
			{ Name = "GangsterFootera", Level = 3, Limit = 3, Interval = 9, Modifiers = {} },
			{ Name = "TimCheese", Level = 3, Limit = 1, Interval = 12, Modifiers = {} },
			{ Name = "CappuccinoAssasino", Level = 3, Limit = 2, Interval = 6, Modifiers = {} },
		},
		Rewards = {
			{ Type = "XP", Data = { Amount = 4800 } },
			{ Type = "Gems", Data = { Amount = 20 } },
		}
	},

	--[16] = {
	--	EnemyBaseHealth = 2000,
	--	SoundTrack = SoundService.Tracks.Grasslands,
	--	StageName = "Grasslands Finale",
	--	Desc = "Mastery required.",
	--	Scenery = "Kingdom",
	--	Difficulty = 3,
	--	Enemies = {
	--		{ Name = "TungTungSahur", Level = 3, Limit = 4, Interval = 6, Modifiers = {} },
	--		{ Name = "BanditoAxolito", Level = 3, Limit = 4, Interval = 8, Modifiers = {} },
	--		{ Name = "GangsterFootera", Level = 3, Limit = 3, Interval = 10, Modifiers = {} },
	--		{ Name = "TimCheese", Level = 3, Limit = 1, Interval = 12, Modifiers = {} },
	--		{ Name = "CappuccinoAssasino", Level = 3, Limit = 2, Interval = 6, Modifiers = {} },
	--		{ Name = "KingTung", Level = 3, Limit = 2, SpawnTime = 20, Modifiers = {} },
	--	},
	--	SpawnOnce = {
	--		{ Name = "KingTung", Level = 3, Interval = 20, Modifiers = {} },
	--	},
	--	Rewards = {
	--		{ Type = "XP", Data = { Amount = 5200 } },
	--		{ Type = "Gems", Data = { Amount = 20 } },
	--		{ Type = "Brainrot", Data = { Name = "KingTung" } },
	--	}
	--},

}

return Chapter
