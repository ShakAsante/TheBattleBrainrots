local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Fusion = require(Root.Shared.Packages.Fusion)
local PlayerStats = Fusion.scoped(Fusion)
local Data = require("./Data")
local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Utils = require(Assets.Utils)
local WEEK_NUMBER = Utils.GetWeek()
local PlayerStatsTemplate = require(Root.Shared.Data.PlayerStats)

local Stores = {}

local PREFIX = "Leaderboard_"

for Stat, Value in pairs(PlayerStatsTemplate) do
	Stores[`Weekly{Stat}`] = DSS:GetOrderedDataStore(`{PREFIX}Weekly{Stat}`, WEEK_NUMBER)
end

function PlayerStats.GameStart()
	Players.PlayerAdded:Connect(function(Player)
		local Success, Profile = Data.GetProfile(Player):await()

		if Success and Profile then
			local Stats = Profile.Data.Stats


			local Elapsed = 0

			while Player:IsDescendantOf(Players) do
				Stats.Playtime += 1
				Elapsed += 1

				if Elapsed % 5 ==0 then
					PlayerStats.AddWeekly(Player, "Playtime", 5)
				end

				wait(1)
			end
		end
	end)
end

	
function PlayerStats.Add(Player, StatName, Value)
	Value = Value or 1
	local _, Profile = Data.GetProfile(Player):await()
	local StatExists = Profile.Data.Stats[StatName]

	if StatExists then
		Profile.Data.Stats[StatName] += Value
	end
end

function PlayerStats.AddWeekly(Player, StatName, Value)
	local StoreName = `Weekly{StatName}`
	local Store = Stores[StoreName]
	Value = Value or 1

	local Current = Store:GetAsync("Player_" .. Player.UserId) or 0
	Store:SetAsync("Player_" .. Player.UserId, Current + Value)
end

return PlayerStats