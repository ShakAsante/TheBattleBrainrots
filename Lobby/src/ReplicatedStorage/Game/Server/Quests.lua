local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Assets = Root:WaitForChild("Assets")
local Remotes = Root.Remotes
local Fusion = require(Root.Shared.Packages.Fusion)
local QuestData = require(Root.Shared.Data.Quests)
local Utils = require(Assets.Utils)
local Http = game:GetService("HttpService")

local Types = require(Root.Shared.Types)

local Quests = Fusion:scoped()
Quests.Data = {}

local TableUtil = require(Root.Shared.Packages.TableUtil)

local function Deserialize(QuestsData)
	local Data = {}

	for _, Quest in QuestsData do
		local NewQuestData = {}

		for Attribute, Value: Fusion.UsedAs<Number> in pairs(Quest) do
			NewQuestData[Attribute] = Fusion.peek(Value)
		end

		table.insert(Data, NewQuestData)
	end

	return Data
end

function Quests.Generate(Type, Config)
	local function GenerateQuests(Type, Config)
		local QuestList = {}
		local QuestFolder = QuestData[Type] ~= nil and QuestData[Type] or QuestData["DailyQuests"]
		local n = math.min(Config.Amount or 5, #QuestFolder)

		local used = {}
		local index = 0

		while #QuestList < (Type == "LifetimeQuests" and #QuestFolder or n) do
			index = Type == "LifetimeQuests" and index + 1 or math.random(1, #QuestFolder)
			if QuestFolder[index] == nil then
				break
			end

			if not used[index] then
				used[index] = true

				local QuestTemplate = QuestFolder[index]
				local Quest = table.clone(QuestTemplate)

				Quest.Progress = 0
				Quest.Completed = false
				Quest.UUID = Http:GenerateGUID(false)

				table.insert(QuestList, Quest)
			end
		end

		return QuestList
	end
	
	return GenerateQuests(Type, Config)
end

function Quests.Remove(Player, UUID)
	local PlayerData = Quests.Data[Player]
	if not PlayerData then return end
	
	local function Remove(QuestType, UUID)
		local QuestsData = PlayerData[QuestType]
		if not QuestsData then return end
		
		for i, Quest in QuestsData do
			if Quest.UUID == UUID then
				table.remove(QuestsData, i)
				break
			end
		end
	end
	
	Remove("DailyQuests", UUID)
	Remove("WeeklyQuests", UUID)
	Remove("LifetimeQuests", UUID)
	Remove("SeasonQuests", UUID)
end

function Quests.GameStart()
	Data = require("./Data")
	Rewards = require("./Rewards")
	SeasonTools = require("./SeasonTools")
	Boosts = require("./Boosts")
	
	Remotes.Quests.Claim.OnServerInvoke = function(Player, QuestID)
		local PlayerData = Quests.Data[Player]
		if not PlayerData then return end
		
		local Section = "DailyQuests"
		
		for QuestType, QuestsData in PlayerData do
			if typeof(QuestsData) ~= "table" then continue end
			for Quest = 1, #QuestsData do
				if QuestsData[Quest].UUID == QuestID then
					if Fusion.peek(QuestsData[Quest].Progress) >= QuestsData[Quest].Goal then
						Section = QuestType
						
						if QuestsData[Quest].Completed then
							continue
						end			
						
						QuestsData[Quest].Completed = true

						if Section == "SeasonQuests" then
							local ShouldDouble = Boosts.Has(Player, "DoubleXP")
							SeasonTools.AddExp(Player, QuestsData[Quest].Reward * (ShouldDouble and 2 or 1))
						else
							local ShouldDouble = Boosts.Has(Player, "DoubleGems")
							Rewards.Give(Player, "Gems", {
								Amount = QuestsData[Quest].Reward * (ShouldDouble and 2 or 1)
							})
						end
					
						break
					end
				end
			end
		end
		
		Remotes.Quests:FireClient(Player, "Update" .. Section, Deserialize(PlayerData[Section]))
		
		return true
	end
	
	Players.PlayerAdded:Connect(function(Player)
		local _, Profile = Data.GetProfile(Player):await()
		
		local function CheckForQuests(QuestType, Config)
			return #TableUtil.Keys(Profile.Data[QuestType] or {}) > 0 and Profile.Data[QuestType] or Quests.Generate(QuestType, Config)
		end
		
		local LastLoginDay = Profile.Data.LastLoginDay
		local LastLoginWeek = Profile.Data.LastLoginWeek

		Quests.Data[Player] = {
			LastLoginDay = LastLoginDay,
			DailyQuests = CheckForQuests("DailyQuests", {Amount = 5}),
			WeeklyQuests = CheckForQuests("WeeklyQuests", {Amount = 10, IsWeekly = true}),
			LifetimeQuests = CheckForQuests("LifetimeQuests", {IsLifetime = true}),
			SeasonQuests = CheckForQuests("SeasonQuests", {IsDaily = true})
		}

		local function Handle(PlayerData, EventName)
			for _, Quest in pairs(PlayerData) do
				Quest["Progress"] = Quests:Value(Fusion.peek(Quest["Progress"]) or 0)
				
				Quests:Observer(Quest.Progress):onChange(function()
					Remotes.Quests:FireClient(Player, EventName, Deserialize(PlayerData))
				end)
			end
			
			--print(EventName, Deserialize(PlayerData))
			Remotes.Quests:FireClient(Player, EventName, Deserialize(PlayerData))
		end
		
		if LastLoginDay ~= os.date("*t").wday then
			Quests.RefreshDailies(Player)
			Profile.Data.LastLoginDay = os.date("*t").wday
		end

		if LastLoginWeek ~= Utils.GetWeek() then
			Quests.RefreshWeekly(Player)
			Profile.Data.LastLoginWeek = Utils.GetWeek()
		end
		
		Handle(Quests.Data[Player].DailyQuests, "UpdateDailyQuests")
		Handle(Quests.Data[Player].WeeklyQuests, "UpdateWeeklyQuests")
		Handle(Quests.Data[Player].LifetimeQuests, "UpdateLifetimeQuests")
		Handle(Quests.Data[Player].SeasonQuests, "UpdateSeasonQuests")
		
		
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		local _, Profile = Data.GetProfile(Player):await()		
		
		Profile.Data.DailyQuests = Deserialize(Quests.Data[Player].DailyQuests)
		Profile.Data.WeeklyQuests = Deserialize(Quests.Data[Player].WeeklyQuests)
		Profile.Data.LifetimeQuests = Deserialize(Quests.Data[Player].LifetimeQuests)
		Profile.Data.SeasonQuests = Deserialize(Quests.Data[Player].SeasonQuests)
		
		local QuestsData = Quests.Data[Player]
		if QuestsData then
			
			Quests.Data[Player] = nil
		end
	end)
end

function Quests.RefreshDailies(Player: Player)
	local QuestsData = Quests.Data[Player]
	QuestsData.DailyQuests = Quests.Generate("DailyQuests", {Amount = 5})
	QuestsData.SeasonQuests = Quests.Generate("SeasonQuests", {IsDaily = true})
	
	Remotes.Quests:FireClient(Player, "UpdateDailyQuests", Deserialize(QuestsData.DailyQuests))
	Remotes.Quests:FireClient(Player, "UpdateSeasonQuests", Deserialize(QuestsData.SeasonQuests))
end

function Quests.RefreshWeekly(Player)
	Quests.WeeklyQuests = Quests.Generate("WeeklyQuests", {Amount = 10, IsWeekly = true})
	Remotes.Quests:FireClient(Player, "UpdateWeeklyQuests", Deserialize(Quests.WeeklyQuests))
end

--function Quests.Give(Player, QuestData)
--end

function Quests.Progress(Player, QuestID)
	local PlayerQuests = Quests.Data[Player]
	
	for QuestType, QuestList in pairs(PlayerQuests) do
		if typeof(QuestList) ~= "table" then continue end
		for _, QuestData in pairs(QuestList) do
			if QuestData.Id == QuestID then
				local Old = Fusion.peek(QuestData.Progress)
				local Max = QuestData.Goal
				QuestData.Progress:set(math.clamp(Old + 1, 0, Max))
			else
				continue
			end
		end
	end
end

return Quests