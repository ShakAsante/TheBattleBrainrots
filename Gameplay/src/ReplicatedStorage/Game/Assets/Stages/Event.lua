-- Event Stages
local Stages = {}
local SoundService = game:GetService("SoundService")

Stages[1] = {
	EnemyBaseHealth = 500,
	SoundTrack = SoundService.Tracks.CrabRave,
	StageName = "A Warming Welcome",
	Desc = "Learn the basics.",
	Scenery = "OceanSide",
	Difficulty = 1,
	Enemies = {
		{ Name = "ChefCabra", Level = 1, Limit = 3, Interval = 11, Modifiers = {} },
	},
	Rewards = {
		{ Type = "Brainrot", Name = "ChefCabra", Amount = 1 },
		{ Type = "Gems", Data = { Amount = 75 } },
	}
}

return Stages