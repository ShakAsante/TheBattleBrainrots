local Stages = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Root = ReplicatedStorage.Game
local Remotes = Root.Remotes
local Assets = Root:WaitForChild("Assets")

local GameStages= require(Assets.Stages)[1]
local StoryChapters = GameStages.Story
local EventStages = GameStages.Event

local TableUtils = require(Root.Shared.Packages.TableUtil)

local Template = {}

Template["Story"] = {}
Template["Event"] = {}

for CIndex, Chapter in pairs(StoryChapters) do
	Template["Story"][CIndex] = {
		Stages = {}
	}
	
	for SIndex, Stage in pairs(Chapter.Stages) do
		Template["Story"][CIndex].Stages[SIndex] = {
			IsLocked = true,
			Completed = false,
			TimeCompleted = 0,
		}
	end
end

for EIndex, EStage in pairs(EventStages) do
	--Template["Event"][EIndex] = 

	--for SIndex, Stage in pairs(EStage) do
	Template["Event"][EIndex] = {
		IsLocked = true,
		Completed = false,
		TimeCompleted = 0,
	}
	--end
end


Template["Story"][1].Stages[1].IsLocked = false

local Teleports = require(Assets.Teleports)


local Teleports = require(Assets.Teleports)
local TeleportService = game:GetService("TeleportService")

function Stages.GameStart()
	Data = require("./Data")
	
	Players.PlayerAdded:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		
		if not Sucess then return end
		
		Profile.Data.ChapterData = TableUtils.Reconcile(Profile.Data.ChapterData, Template)
		Remotes.Stages:InvokeClient(Player, Profile.Data.ChapterData)
	end)
	
	Remotes.Teleport.OnServerInvoke = function(Player, Where, Options)
		local Location = Teleports[Where]
		
		if Location == Teleports.Battles then
			local Reserved = TeleportService:ReserveServer(Location)
			
			TeleportService:TeleportToPrivateServer(Location, Reserved, {Player},nil, {
				Story = {
					Chapter = Options.Chapter,
					Stage = Options.Stage
				},
				Event = {
					Stage = Options.EventStage
				}
			}, Assets.TeleportGui)
			
			return true
		else
			TeleportService:Teleport(Location, Player, {
				Story = {
					Chapter = Options.Chapter,
					Stage = Options.Stage
				},
				Event = {
					Stage = Options.EventStage
				}
			}, Assets.TeleportGui)
		end
	end
end

return Stages