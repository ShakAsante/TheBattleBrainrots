local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Utils = require(Root.Assets.Utils)

local PlayerStats = require(Root.Shared.Data.PlayerStats)

local Data = {
	Brainrots = {},
	Gems = 0,
	Money = 0,
	XP = 0,
	
	Upgrades = {},
	
	DailyQuest = {},
	WeeklyQuest = {},
	LifetimeQuests = {},
	
	Stats = PlayerStats,

	LastLoginDay = os.date("*t").day,
	LastLoginWeek = Utils.GetWeek(),

	FreeRewardsClaimed = false,
	SeasonData = {},
	UsedCodes = {},
	ChapterData = {},
	Tutorial = {
		IsBattleCompleted = false,
		IsLobbyCompleted = false,
	},

	Team = {},
}

local Tweaks = require(Root.Tweaks)

for UnitIndex=1, Tweaks.TeamSize do
	Data.Team[UnitIndex] = {
		Name = "",
		Form = "Base",
		IsLocked = true	
	}
end

Data.Team[1].Name = "TungTungSahur"
Data.Team[1].IsLocked = false
Data.Team[2].Name = "TiTiTiSahur"
Data.Team[2].IsLocked = false
Data.Team[3].Name = "GangsterFootera"
Data.Team[3].IsLocked = false

return Data