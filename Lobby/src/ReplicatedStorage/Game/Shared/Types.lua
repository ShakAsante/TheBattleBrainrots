export type PlayerData = {
	Brainrots: {[string]: number},
	Gems: number,
	Money: number,
	XP: number,

	Upgrades: {[string]: number},

	DailyQuest: {[string]: number},
	WeeklyQuest: {[string]: number},
	LifetimeQuests: {[string]: number},

	Stats: {
		Playtime: number,
		RobuxSpent: number,
		GamesWon: number,
		ItemsGifted: number,
	},

	LastLoginDay: number,
	LastLoginWeek: number,

	FreeRewardsClaimed: boolean,
	SeasonData: {[string]: number},
	UsedCodes: {[string]: boolean},
	ChapterData: {[string]: number},
	Tutorial: {
		IsCompleted: boolean,
	},

	Team: {
		[number]: {
			Name: string,
			Form: string,
			IsLocked: boolean,
		},
	},
}

return {}