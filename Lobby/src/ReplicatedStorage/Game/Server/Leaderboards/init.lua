local DataStore = game:GetService("DataStoreService")
local Prefix = "Leaderboard_"
local DataTemplate = require("./Data/Template")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Utils = require(Assets.Utils)
local WEEK_NUMBER = Utils.GetWeek()
local Remotes = Root.Remotes

local Leaderboards = {}
Leaderboards.Data = {}

for StatName, _ in pairs(DataTemplate.Stats) do
	Leaderboards.Data[StatName] = DataStore:GetOrderedDataStore(Prefix .. StatName) :: OrderedDataStore
end

for StatName in pairs(DataTemplate.Stats) do
	local WeeklyVariant = "Weekly" .. StatName
	print(Prefix..WeeklyVariant)
	Leaderboards.Data[WeeklyVariant] =
		DataStore:GetOrderedDataStore(Prefix .. WeeklyVariant, WEEK_NUMBER)
end

local LeaderboardFormat  = {
	["WeeklyPlaytime"] = function(seconds)
		if seconds < 60 then
			return math.floor(seconds) .. "s"
		end

		local minutes = seconds / 60
		if minutes < 60 then
			return math.floor(minutes) .. "m"
		end

		local hours = minutes / 60
		if hours < 24 then
			return math.floor(hours) .. "h"
		end

		local days = hours / 24
		if days < 7 then
			return math.floor(days) .. "d"
		end

		local weeks = days / 7
		return math.floor(weeks) .. "w"
	end,
	["Playtime"] = function(seconds)	
		if seconds < 60 then
			return math.floor(seconds) .. "s"
		end

		local minutes = seconds / 60
		if minutes < 60 then
			return math.floor(minutes) .. "m"
		end

		local hours = minutes / 60
		if hours < 24 then
			return math.floor(hours) .. "h"
		end

		local days = hours / 24
		if days < 7 then
			return math.floor(days) .. "d"
		end

		local weeks = days / 7
		return math.floor(weeks) .. "w"
	end,
}

local LeaderboardInfo = {
	["WeeklyPlaytime"] = {
		Name = "Weekly Playtime"
	},
	["WeeklyRobuxSpent"] = {
		Name = "Weekly Robux Spent"
	},
	["WeeklyGamesWon"] = {
		Name = "Weekly Games Won"
	},
	["Playtime"] = {
		Name = "Global Playtime"
	},
	["RobuxSpent"] = {
		Name = "Global Robux Spent"
	},
	["GamesWon"] = {
		Name = "Global Games Won"
	},
	["ItemsGifted"] = {
		Name = "Global Items Gifted"
	},
	["WeeklyItemsGifted"] = {
		Name = "Weekly Items Gifted"
	},
}

--local function GetPlayerRank(userId: number, maxScan: number?)
--	maxScan = maxScan or 100 -- how many leaderboard entries to scan

--	local success, pages = pcall(function()
--		return OrderedStore:GetSortedAsync(false, maxScan)
--	end)

--	if not success then
--		return nil
--	end

--	local rank = 1

--	for _, entry in ipairs(pages:GetCurrentPage()) do
--		if entry.key == tostring(userId) then
--			return rank
--		end
--		rank += 1
--	end

--	return nil -- player not in top maxScan
--end

function Leaderboards.GetRank(Leaderboard, UserId)
	local Data = Leaderboards.Data[Leaderboard]
	local Success, Pages = pcall(function()
		return Data:GetSortedAsync(false, 100)
	end)
	
	if not Success then
		return
	end
	
	local Rank = 1
	
	for _, Entry in pairs(Pages:GetCurrentPage()) do
		if Entry.key == "Player_" .. tostring(UserId) then
			return Rank
		end
		Rank += 1
	end
	
	return nil
end

function Leaderboards.GameStart()
	Data = require("./Data")
	PlayerStats = require("./Stats")
	
	Players.PlayerAdded:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		
		if Sucess and Profile then
			for StatName, StatValue in pairs(Profile.Data.Stats) do
				Leaderboards.Data[StatName]:SetAsync("Player_" .. Player.UserId, StatValue)
				PlayerStats.AddWeekly(Player,StatName, 0)
			end
			
			--for Name, _ in pairs(Leaderboards.Data) do
			--	--print(Name)
			--	--task.spawn(function()
			--		--local Rank = Leaderboards.GetRank(Name, Player.UserId)
			--		----print(Rank)
			--		--if Rank then
			--		--Remotes.Replicate:FireClient(Player, "Notification", `You are #{Rank} in {LeaderboardInfo[Name] and LeaderboardInfo[Name].Name or Name}`)
			--		--	wait(1)
			--		--end
			--		--if Rank then
			--			--Player.DisplayName = `#{Rank}: {Player.DisplayName}`
			--		--end
			--	--end)
			--end
		else
			return
		end
	end)
	
	
	Leaderboards.Refresh()
	
	while true do
		Leaderboards.Refresh()
		wait(60 * 10)
	end
end


function Leaderboards.Refresh()
	local LeaderboardsInMap = workspace.Map:WaitForChild("Structures").Leaderboards:GetChildren()

	for _, Board in pairs(LeaderboardsInMap) do
		local LeaderboardData = Leaderboards.Get(Board.Name)

		local Rig = Board.Rig

		local Humanoid = Rig:WaitForChild("Humanoid") :: Humanoid
		local Animator = Humanoid:WaitForChild("Animator")
		local Emotes = Assets.Anims.Emotes:GetChildren()

		local Anim = Animator:LoadAnimation(Emotes[math.random(1, #Emotes)])
		
		wait()
		
		local Tracks = Animator:GetPlayingAnimationTracks()
		
		for _, Track in pairs(Tracks) do
			Track:Stop()
		end
		
		local Interface = Board.Board.Primary:FindFirstChildOfClass("SurfaceGui")
		Anim:Play()

		local List = Interface.List

		local ClearAllVisibleFrames = function()
			for _, Frame in pairs(List:GetChildren()) do
				if Frame:IsA("Frame") and Frame.Visible == true then
					Frame:Destroy()
				end
			end
		end

		Humanoid.DisplayName = "#1: ???"

		local List = Interface.List
		
		ClearAllVisibleFrames()

		for Rank, Data in pairs(LeaderboardData) do
			local Name = Data.key
			local Value = Data.value
			local UserId = string.split(Name, "_")[2]
			local PlayerName = Players:GetNameFromUserIdAsync(UserId)
			local PlayerIsInServer = Players:GetPlayerByUserId(UserId)
			
			if PlayerIsInServer then
				Remotes.Replicate:FireClient(PlayerIsInServer, "Notification", `You are #{Rank} in {LeaderboardInfo[Board.Name] and LeaderboardInfo[Board.Name].Name or Board.Name}`)
			end
			
			if Rank == 1 then
				local Appearance = Players:GetHumanoidDescriptionFromUserIdAsync(UserId)
				Humanoid.DisplayName = "#1: ".. PlayerName
				Humanoid:ApplyDescriptionResetAsync(Appearance)
			end

			local Template = List.Template:Clone()
			Template.Parent = List
			Template.Visible = true 
			Template.Icon.Image = `rbxthumb://type=AvatarHeadShot&id={UserId}&w=420&h=420`

			Template.Body.UserName.Text = PlayerName
			Template.Rank.Text = `#{Rank}`
			Template.Value.Label.Text = LeaderboardFormat[Board.Name] ~= nil and LeaderboardFormat[Board.Name](Value) or Value
			Template.LayoutOrder = Rank
			
			wait(.1)
		end
	end
end

function Leaderboards.Get(Name, Scope)
	return Leaderboards.Data[Name] and Leaderboards.Data[Name]:GetSortedAsync(false, 10):GetCurrentPage() or {}
end

return Leaderboards