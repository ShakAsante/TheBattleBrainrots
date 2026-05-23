local Inventory = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")

local Data = require("./Data")
local Remotes = Root.Remotes

local Tweaks = require(Root.Tweaks)

local Rewards = require("./Rewards")

local UnitInfo = require(Assets.UnitInfo)

local Players = game:GetService("Players")

function Inventory.GameStart()
	Quests = require("./Quests")
	
	local Listeners = {
		["PurchaseSlot"] = function(Player, Index)
			local Cost = 100 * Index
			local _, Profile = Data.GetProfile(Player):await()
			local Money = Profile.Data.Money
			if Money >= Cost then
				Profile.Data.Money -= Cost
				Inventory.UnlockBrainrotSlot(Player, Index)
				Inventory.UpdateTeamToClient(Player)
			else
				Remotes.Replicate:FireClient(Player, "Notification", "Insufficient cashs!", true)
			end
		end,
		
		["EquipBrainrot"] = function(Player, Brainrot, Slot)
			local _, Profile = Data.GetProfile(Player):await()
			
			local function BrainrotAlreadyEquipped()
				local IsTrue = false
				for Index, Data in pairs(Profile.Data.Team) do
					if Data.Name == Brainrot then
						IsTrue = true
						break
					end
				end
				
				return IsTrue
			end
			
			local function CalculateEmpty()
				local Target = nil
				
				for Index, Data in pairs(Profile.Data.Team) do
					if Data.IsLocked == true then continue end
					if Data.Name == "" then
						Target = Index
						break
					end
				end
				
				return Target
			end
			
			if CalculateEmpty() == nil then
				Remotes.Replicate:FireClient(Player, "Notification", "Unequip a brainrot first!", true)
				return
			end
			
			if BrainrotAlreadyEquipped() then
				Remotes.Replicate:FireClient(Player, "Notification", "This brainrot is already equipped", true)
				return 
			end
			
			Slot = Slot or CalculateEmpty()
			local BrainrotData = Profile.Data.Brainrots[Brainrot]
			if not BrainrotData then
				Remotes.Replicate:FireClient(Player, "Notification", "You don't have this brainrot!", true)
				return
			end
			
			Profile.Data.Team[Slot].Name = Brainrot
			--Profile.Data.Team[Slot].Form = BrainrotData.Form
			--Profile.Data.Team[Slot].Level = BrainrotData.Level
			
			Inventory.UpdateTeamToClient(Player)
		end,
		
		["UnequipBrainrotByIndex"] = function(Player, Index)
			local _, Profile = Data.GetProfile(Player):await()
			
			Profile.Data.Team[Index].Name = ""
			--Profile.Data.Team[Index].Form = "Base"
			--Profile.Data.Team[Index].Level = 1
			
			Inventory.UpdateTeamToClient(Player)
		end,
		
		["UnequipBrainrotByName"] = function(Player, BrainrotName)
			local _, Profile = Data.GetProfile(Player):await()
			for Index, Data in pairs(Profile.Data.Team) do
				if Data.Name == BrainrotName then
					Profile.Data.Team[Index].Name = ""
					--Profile.Data.Team[Index].Form = "Base"
					--Profile.Data.Team[Index].Level = 1
					break
				end
			end
			Inventory.UpdateTeamToClient(Player)
		end,
		
		["UpgradeBrainrot"] = function(Player, Brainrot)
			return Inventory.UpgradeBrainrot(Player, Brainrot)
		end,
		
		["ClaimFreeRewards"] = function(Player)
			local Sucess, Profile = Data.GetProfile(Player):await()
			if not Sucess and not Profile then
				return
			else
				local IsClaimed = Profile.Data.FreeRewardsClaimed
				
				if IsClaimed then
					Remotes.Replicate:FireClient(Player, "Notification", "You already claimed this reward!", true)
					return
				end	
				
				local RequirementsMet = Player:IsInGroup(Tweaks.GroupId) 
				
				if not RequirementsMet then
					Remotes.Replicate:FireClient(Player, "Notification", "Like the game & Join the group to claim this reward!", true)
					return
				end
				
				Remotes.Replicate:FireClient(Player, "Notification", "sucessfully claimed reward!")
				
				Profile.Data.FreeRewardsClaimed = true
				
				local Possible = Tweaks.FreeRewards
				
				for _, Reward in pairs(Possible) do
					local Type = Reward.Type
					local Data = Reward.Data
					Rewards.Give(Player, Type, Data)
				end
			end
		end,
	}
	
	Remotes.Inventory.OnServerInvoke = function(Player, Action, ...)
		local Args = {...}
		if Listeners[Action] then
			return Listeners[Action](Player, ...) or nil
		end
	end
	
	--Players.PlayerAdded:Connect(function(Player)
		--wait(3)
		--Inventory.UpdateToBrainrotsClient(Player)
	--end)
end

function Inventory.Give(Options)
	Options = Options or {
		Gems = 0, 
		SummonTickets = 0,
		
	}
end

function Inventory.UnlockBrainrotSlot(Player, Index)
	local _, Profile = Data.GetProfile(Player):await()
	
	if Profile then
		Profile.Data.Team[Index].IsLocked = false
	end
end

function Inventory.UnlockBrainrot(Player, BrainrotName)
	local _, Profile = Data.GetProfile(Player):await()
	if Profile then
		local AlreadyHas = Profile.Data.Brainrots[BrainrotName] ~= nil
		
		if AlreadyHas then
			return
		else
			Profile.Data.Brainrots[BrainrotName] = {
				Level = 1,
				Form = "Base",
			}
		end
	end
end

function Inventory.UpgradeBrainrot(Player, Name)
	local Sucess, Profile = Data.GetProfile(Player):await()
	
	if not Sucess or not Profile then
		return
	end
	
	local CurrentXP = Profile.Data.XP
	local BrainrotData = Profile.Data.Brainrots[Name]

	if BrainrotData then
		local Level = BrainrotData.Level 
		local Cost = Tweaks.PricePerLevel(BrainrotData.Level)

		if CurrentXP > Cost  then
			Quests.Progress(Player, "Upgrade")
			Profile.Data.XP -= Cost
			
			local HasEvolution = UnitInfo[Name].Evolved ~= nil
			
			local MaxLevel = Tweaks.MaxUnitLevel
			
			if HasEvolution then
				if Level <= MaxLevel + 10 then
					if Level == MaxLevel-1 then
						Quests.Progress(Player, "Evolve")
						BrainrotData.Form = "Evolved"
						Remotes.Replicate:FireClient(Player, "Notification", "You have evolved the brainrot!", true)
					end
				else
					BrainrotData.Level = math.clamp((BrainrotData.Level or 1) + 1, 1, Tweaks.MaxUnitLevel + 10)
				end
				
				BrainrotData.Level += 1
			else
				BrainrotData.Level = math.clamp((BrainrotData.Level or 1) + 1, 1, Tweaks.MaxUnitLevel)
			end
			
			--task.spawn(function()
			Inventory.UpdateToBrainrotsClient(Player)
			--end)
			
			return true
		else
			Remotes.Replicate:FireClient(Player, "Notification", "Insufficient XP!", true)
			return false
		end

	else
		Remotes.Replicate:FireClient(Player, "Notification", "Something bad happened...", true)
	end
end

function Inventory.UpdateToBrainrotsClient(Player)
	local _, Profile = Data.GetProfile(Player):await()
	if Profile then
		task.spawn(function()
			Remotes.Inventory:InvokeClient(Player, "BrainrotsLoaded", Profile.Data.Brainrots)
		end)
	end
end

function Inventory.HasBrainrot(Player, Name)
	local _, Profile = Data.GetProfile(Player):await()
	if Profile then
		return Profile.Data.Brainrots[Name] ~= nil
	end
	return false
end

function Inventory.UpdateTeamToClient(Player)
	local _, Profile = Data.GetProfile(Player):await()
	if Profile then
		task.spawn(function()
			Remotes.Inventory:InvokeClient(Player, "TeamLoaded", Profile.Data.Team)
		end)
	end
end

function Inventory.EquipBrainrot()
	
end

return Inventory