local Quests = {}

-- DAILY QUESTS
Quests["DailyQuests"] = { 
	{
		Id = "Summon",
		Name = "Brainrot Summoner I",
		Description = "Summon 3 Times",
		Goal = 3,
		Reward = 75,
	},

	{
		Id = "Upgrade",
		Name = "Unit Upgrader I",
		Description = "Upgrade 5 Units",
		Goal = 5,
		Reward = 75,
	},

	{
		Id = "Upgrade",
		Name = "Unit Upgrader II",
		Description = "Upgrade 10 Units",
		Goal = 10,
		Reward = 150,
	},

	{
		Id = "Evolve",
		Name = "Brainrot Evolver",
		Description = "Evolve 1 Unit",
		Goal = 1,
		Reward = 100,
	},

	{
		Id = "Playtime",
		Name = "Small Player",
		Description = "Play for 5 minutes",
		Goal = 5,
		Reward = 50,
	},

	{
		Id = "Playtime",
		Name = "Dedicated Player",
		Description = "Play for 15 minutes",
		Goal = 15,
		Reward = 125,
	},

	{
		Id = "Playtime",
		Name = "Superior Player",
		Description = "Play for 30 minutes",
		Goal = 30,
		Reward = 250,
	},
	{
		Id = "StageClear",
		Name = "First Victory",
		Description = "Clear 1 Stage",
		Goal = 1,
		Reward = 75,
	},
	{
		Id = "StageClear",
		Name = "On a Roll",
		Description = "Clear 3 Stages",
		Goal = 3,
		Reward = 150,
	},
	{
		Id = "MobKill",
		Name = "Light Cleanup",
		Description = "Defeat 50 Enemies",
		Goal = 50,
		Reward = 100,
	},
	{
		Id = "CurrencyEarn",
		Name = "Brainrot Collector",
		Description = "Earn 500 Brainrot",
		Goal = 500,
		Reward = 125,
	},
	{
		Id = "UnitDeploy",
		Name = "Frontline Commander",
		Description = "Deploy Units 25 Times",
		Goal = 25,
		Reward = 100,
	},
	{
		Id = "AFK",
		Name = "Quick Scavenger",
		Description = "Scavenge in AFK for 10 Minutes",
		Goal = 10,
		Reward = 50,
	},
}

-- WEEKLY QUESTS
Quests["WeeklyQuests"] = {
	{
		Id = "MobKill",
		Name = "Brainrot Killer I",
		Description = "Kill 150 Brainrots",
		Goal = 150,
		Reward = 300,
	},
	{
		Id = "MobKill",
		Name = "Brainrot Killer II",
		Description = "Kill 250 Brainrots",
		Goal = 250,
		Reward = 450,
	},
	{
		Id = "AFK",
		Name = "AFK Progressor I",
		Description = "Scavenge in AFK for 30 minutes",
		Goal = 30,
		Reward = 100,
	},
	{
		Id = "AFK",
		Name = "AFK Progressor II",
		Description = "Scavenge in AFK for 120 minutes",
		Goal = 120,
		Reward = 350,
	},
	{
		Id = "AFK",
		Name = "AFK Progressor III",
		Description = "Scavenge in AFK for 300 minutes",
		Goal = 300,
		Reward = 750,
	},
	{
		Id = "StageClear",
		Name = "Campaign Crusher",
		Description = "Clear 25 Stages",
		Goal = 25,
		Reward = 500,
	},
	{
		Id = "StageClear",
		Name = "Stage Master",
		Description = "Clear 50 Stages",
		Goal = 50,
		Reward = 900,
	},
	{
		Id = "Upgrade",
		Name = "Army Improver",
		Description = "Upgrade 30 Units",
		Goal = 30,
		Reward = 600,
	},
	{
		Id = "Evolve",
		Name = "Evolution Expert",
		Description = "Evolve 5 Units",
		Goal = 5,
		Reward = 800,
	},
	{
		Id = "Discover",
		Name = "Brainrot Master",
		Description = "Discover 20 Brainrots",
		Goal = 10000,
		Reward = 1000,
	},
	{
		Id = "MobKill",
		Name = "Exterminator",
		Description = "Defeat 1,000 Enemies",
		Goal = 1000,
		Reward = 1200,
	},
}

Quests["SeasonQuests"] = { 
	{
		Id = "MobKill",
		Name = "Uber Killer",
		Description = "Kill 3 Uber Rarity Brainrots",
		Goal = 3,
		Reward = 300,
	},
	{
		Id = "MobFreeze",
		Name = "Frozen...",
		Description = "Freeze 3 Mobs...",
		Goal = 3,
		Reward = 200,
	},
	{
		Id = "DupeRoll",
		Name = "Duper",
		Description = "Roll 5 Dupes",
		Goal = 5,
		Reward = 500,
	},
}

-- LIFETIME QUESTS
Quests["LifetimeQuests"] = {}

local Root = game:GetService("ReplicatedStorage").Game
local StoryStages = require(Root.Assets.Stages.Story)

for Chapter, ChapterData in pairs(StoryStages) do
	for Stage in pairs(ChapterData.Stages) do
		table.insert(Quests["LifetimeQuests"], {
			Id = `StageClear_{Chapter}_{Stage}`,
			Name = "Story Conqueror",
			Description = `Clear Stage: Chapter {Chapter} - Stage {Stage}`,
			Goal = 1,
			Reward = 75,
		})
	end
end

table.insert(Quests["LifetimeQuests"], 	{
	Id = "ChapterClear_1",
	Name = "Frozen Beginnings",
	Description = "Clear all stages in Chapter 1",
	Goal = 1,
	Reward = 150,
})


table.insert(Quests["LifetimeQuests"], 	{
	Id = "ChapterClear_2",
	Name = "Heat Rising",
	Description = "Clear all stages in Chapter 2",
	Goal = 1,
	Reward = 150,
})

return table.freeze (Quests)
