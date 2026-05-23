local SeasonTools = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root.Remotes
local Data = require("./Data")
local Tweaks = require(Root.Tweaks)
local Seasons = require(Root.Seasons)
local Players = game:GetService("Players")
local Rewards = require("./Rewards")

function SeasonTools.SetType(Player, Type)
	local Success, Profile = Data.GetProfile(Player):await()
	local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]

	if CurrentSeasonExistsInData then
		CurrentSeasonExistsInData.Type = Type
		SeasonTools.UpdateToClient(Player)
	end
end

function SeasonTools.GameStart()
	Boosts = require("./Boosts")
	
	local Listeners = {
		["Claim"] = function(Player)
			SeasonTools.ClaimAll(Player)
		end,
	}
	
	Remotes.Season.OnServerInvoke = function(Player, Action, ...)
		local Args = {...}
		if Listeners[Action] then
			return Listeners[Action](Player, ...) or nil
		end
	end
	
	Players.PlayerAdded:Connect(function(Player)
		local Success, Profile = Data.GetProfile(Player):await()
		if not Success or not Profile then return end
		
		print(Profile.Data)
		
		local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]
		
		if not CurrentSeasonExistsInData then
			local ClaimLevels = {}
			
			local Season = Seasons[Tweaks.CurrentSeason]
			
			for _, Level in pairs(Season) do
				table.insert(ClaimLevels, 0)
			end
			
			Profile.Data.SeasonData[Tweaks.CurrentSeason] = {
				Level = 0,
				Exp = 0,
				Type = "Basic",
				ClaimedLevels = ClaimLevels,
			}
		end
		
		SeasonTools.UpdateToClient(Player)
	end)
end

function SeasonTools.UpdateToClient(Player)
	local Success, Profile = Data.GetProfile(Player):await()
	if not Success or not Profile then return end

	Remotes.Season:InvokeClient(Player, Profile.Data.SeasonData[Tweaks.CurrentSeason])
end

function SeasonTools.SetLevel(Player, Level)
	local Success, Profile = Data.GetProfile(Player):await()
	if not Success or not Profile then return end
	
	local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]
	
	if CurrentSeasonExistsInData then
		CurrentSeasonExistsInData.Level = Level
		SeasonTools.UpdateToClient(Player)
	end
end

function SeasonTools.AddExp(Player, Amount)
	local Success, Profile = Data.GetProfile(Player):await()
	if not Success or not Profile then return end
	
	local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]
	
	if CurrentSeasonExistsInData then
		local Max = Tweaks.ExperienceRequiredPerSeasonLevel(CurrentSeasonExistsInData.Level + 1)
		if CurrentSeasonExistsInData.Exp > Max then
			SeasonTools.AddLevel(Player, 1)
			CurrentSeasonExistsInData.Exp = 0
		else
			CurrentSeasonExistsInData.Exp += Amount
		end

		SeasonTools.UpdateToClient(Player)
	end
end

function SeasonTools.GetLevel(Player)
	local Success, Profile = Data.GetProfile(Player):await()
	if not Success or not Profile then return end
	
	local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]
	
	if CurrentSeasonExistsInData then
		return CurrentSeasonExistsInData.Level
	end
	
	return 0
end

function SeasonTools.AddLevel(Player, Amount)
	Amount = Amount or 1
	SeasonTools.SetLevel(Player, SeasonTools.GetLevel(Player) + Amount)
end

function SeasonTools.SkipLevel(Player)
	SeasonTools.AddLevel(Player, 1)
end

function SeasonTools.ClaimAll(Player)
	local Success, Profile = Data.GetProfile(Player):await()
	if not Success or not Profile then return end
	local ShouldDoubleGems = Boosts.Has(Player, "DoubleGems")
	local ShouldDoubleXP =  Boosts.Has(Player, "DoubleXP")
				
	local CurrentSeasonExistsInData = Profile.Data.SeasonData[Tweaks.CurrentSeason]
	
	if CurrentSeasonExistsInData then
		local Level = SeasonTools.GetLevel(Player)
		local HasPremium = CurrentSeasonExistsInData.Type == "Premium"
		
		local function HasClaimedAll()
			local HasClaimed = true
			
			for TargetLevel, Claimed in pairs(CurrentSeasonExistsInData.ClaimedLevels) do
				if TargetLevel > Level then
					continue
				end
				
				if HasPremium then
					if Claimed == 0 or Claimed == 1 then
						HasClaimed = false
						break
					end
				else
					if Claimed == 0 then
						HasClaimed = false
						break
					end
				end
			end
			
			return HasClaimed
		end
		
		if HasClaimedAll() then
			Remotes.Replicate:FireClient(Player, "Notification", "You have already claimed all levels!", true)
			return
		end
		
		for TargetLevel, _ in pairs(CurrentSeasonExistsInData.ClaimedLevels) do
			if Level < TargetLevel then 
				continue 
			else
				CurrentSeasonExistsInData.ClaimedLevels[TargetLevel] = HasPremium and 2 or 1
				local RewardsForThisLevel = Seasons[Tweaks.CurrentSeason][TargetLevel]
				
				if HasPremium then	
					local BasicRewardCopy = table.clone(RewardsForThisLevel[1])
					BasicRewardCopy.Data.Amount = (BasicRewardCopy.Type == "Gems" and ShouldDoubleGems) and math.round(BasicRewardCopy.Data.Amount * 2) or BasicRewardCopy.Data.Amount
					BasicRewardCopy.Data.Amount = (BasicRewardCopy.Type == "XP" and ShouldDoubleXP) and math.round(BasicRewardCopy.Data.Amount * 2) or BasicRewardCopy.Data.Amount
					
					local PremiumRewardCopy = table.clone(RewardsForThisLevel[2])
					PremiumRewardCopy.Data.Amount = (PremiumRewardCopy.Type == "Gems" and ShouldDoubleGems) and math.round(PremiumRewardCopy.Data.Amount * 2) or PremiumRewardCopy.Data.Amount
					PremiumRewardCopy.Data.Amount = (PremiumRewardCopy.Type == "XP" and ShouldDoubleXP) and math.round(PremiumRewardCopy.Data.Amount * 2) or PremiumRewardCopy.Data.Amount

					Rewards.Give(Player, BasicRewardCopy.Type, BasicRewardCopy.Data)
					Rewards.Give(Player, PremiumRewardCopy.Type, PremiumRewardCopy.Data)
				else
					local BasicRewardCopy = table.clone(RewardsForThisLevel[1])
					BasicRewardCopy.Data.Amount = (BasicRewardCopy.Type == "Gems" and ShouldDoubleGems) and math.round(BasicRewardCopy.Data.Amount * 2) or BasicRewardCopy.Data.Amount
					BasicRewardCopy.Data.Amount = (BasicRewardCopy.Type == "XP" and ShouldDoubleXP) and math.round(BasicRewardCopy.Data.Amount * 2) or BasicRewardCopy.Data.Amount

					Rewards.Give(Player, BasicRewardCopy.Type, BasicRewardCopy.Data)
				end
			end
		end
		SeasonTools.UpdateToClient(Player)
	end
end

return SeasonTools