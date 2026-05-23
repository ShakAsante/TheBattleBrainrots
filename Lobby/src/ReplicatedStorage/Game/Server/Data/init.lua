local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Packages = Root.Shared.Packages
local Assets = Root:WaitForChild("Assets")
local Fusion = require(Packages.Fusion)
local Data = Fusion.scoped(Fusion)
local Players = game:GetService("Players")
local ProfileStore = require(Packages.ProfileStore)
local Promise = require(Packages.Promise)
local RunService = game:GetService("RunService")
local Template = require("@self/Template")
local MainStore = RunService:IsStudio() and ProfileStore.New("Main", Template).Mock or  ProfileStore.New("Main", Template)
local Teleports = require(Assets.Teleports)
local TeleportService = game:GetService("TeleportService")

local Remotes = Root.Remotes

function Data.HandleData(Player, Profile)
	local LeaderStats = Data:New("Folder") {
		Name = "player_data",
		Parent = Player
	}

	local Gems = Data:Value(0)
	local XP = Data:Value(0)
	local Money = Data:Value(0)

	local GemDisplay = Data:New("NumberValue") {
		Name = "Gems",
		Value = Gems,
		Parent = LeaderStats
	}

	local MoneyDisplay = Data:New("NumberValue") {
		Name = "Money",
		Value = Money,
		Parent = LeaderStats
	}

	local XPDisplay = Data:New("NumberValue") {
		Name = "XP",
		Value = XP,
		Parent = LeaderStats
	}

	Remotes.Inventory:InvokeClient(Player, "TeamLoaded", Profile.Data.Team)

	while Player:IsDescendantOf(Players) do
		if Profile and Profile.Data then
			Gems:set(Profile.Data.Gems)
			Money:set(Profile.Data.Money)
			XP:set(Profile.Data.XP)
		end

		wait(.1)
	end
end

function Data.GameStart()
	Data.Profiles = {}
	
	Players.PlayerAdded:Connect(function(Player)
		local Profile =  MainStore:StartSessionAsync("Player_"..Player.UserId, {
			Cancel = function()
				return Player.Parent ~= Players
			end,
		})
			
		if not Profile then
			Player:Kick("Data failed to load, If this persists, contact the devs!")
		end
		
		Profile:Reconcile()
		Profile:AddUserId(Player.UserId)

		Profile.OnSessionEnd:Connect(function()
			Data.Profiles[Player] = nil
		end)
	
		Data.Profiles[Player] = Profile
		
		if not Profile.Data.Tutorial.IsBattleCompleted then
			if RunService:IsStudio() then
				
			else
				local TeleportGui = Assets.TeleportGui:Clone()
				TeleportGui.Parent = Player.PlayerGui
				TeleportGui.Enabled = true
				
				local ReservedServer = TeleportService:ReserveServer(Teleports.Battles)
				TeleportService:TeleportToPrivateServer(Teleports.Battles, ReservedServer, {Player}, nil, {
					Story = {
						Chapter = 1,
						Stage = 1,
					},

					Tutorial = true
				}, Assets.TeleportGui)
			end
		end

		task.spawn(function()
			Data.HandleData(Player, Profile)
		end)
		
		task.spawn(function()
			wait(5)
			game.ReplicatedStorage.Game.Remotes.Replicate:FireClient(Player, "Notification", "Sorry for the bugs, they will be fixed", true)
			game.ReplicatedStorage.Game.Remotes.Replicate:FireClient(Player, "Notification", "Tomorrow at 5pm", true)
			game.ReplicatedStorage.Game.Remotes.Replicate:FireClient(Player, "Notification", "Aware of the bugs with units", true)
			game.ReplicatedStorage.Game.Remotes.Replicate:FireClient(Player, "Notification", "Use code MBALL for 500 gems", true)
		end)
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		local Profile = Data.Profiles[Player] :: ProfileStore.Profile
		if Profile then
			Profile:EndSession()
		end
	end)
end


function Data.GetProfile(Player)
	return Promise.new(function(Resolve, Reject)
		local Sucessful, Exists = pcall(function()
			return Data.Profiles[Player]
		end)

		if Sucessful and Exists then
			Resolve(Exists :: Template.PlayerData)
		else
			local Timeout = 10

			while Timeout > 0 do
				if Data.Profiles[Player] ~= nil then
					break
				end
				
				Timeout -= wait()
			end

			if Data.Profiles[Player] then
				Resolve(Data.Profiles[Player] :: Template.PlayerData)
			else
				Reject(`Profile does not exist: {Player.Name}`)
			end
		end
	end) 
end


return Data