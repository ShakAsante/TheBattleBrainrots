local Upgrades = {}
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Promise = require(Root.Shared.Packages.Promise)

local TableUtil = require(Root.Shared.Packages.TableUtil)

local RunService = game:GetService("RunService")
Upgrades.Data = {}

--local UpgradesTemplate = {
--	BaseAbilityPower = 1,
--	CashGeneration = 1,
--	WalletCapacity = 1,
--}

local UpgradeData = require(Root.Assets.Upgrades)

local UpgradesTemplate = {}

for UpgradeName, _ in pairs(UpgradeData) do
	UpgradesTemplate[UpgradeName] = 1
end
local Remotes = Root.Remotes

function Upgrades.GameStart()
	Data = require("./Data")
	
	Players.PlayerAdded:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		
		Upgrades.Data[Player] = TableUtil.Reconcile(Profile.Data.Upgrades, UpgradesTemplate)
		
		Remotes.Upgrade:InvokeClient(Player, "Loaded", Upgrades.Data[Player])
	end)	
	
	Players.PlayerRemoving:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		
		Profile.Data.Upgrades = Upgrades.Get(Player)
		Upgrades.Data[Player] = nil
	end)
	
	local Listeners = {
		["Upgrade"] = function(Player, UpgradeName)
			local PlayerData = Upgrades.Get(Player)
			local UpgradeCost = UpgradeData[UpgradeName].Costs[PlayerData[UpgradeName]]
			--print(UpgradeCost)
			local Sucess, Profile = Data.GetProfile(Player):await() 
			if not Sucess or not Profile then return end

			--if not UpgradeCost then return end
			if Profile.Data.XP >= UpgradeCost then
				Profile.Data.XP -= UpgradeCost
				Upgrades.Upgrade(Player, UpgradeName)
				return true
			end
			return false
		end,
	}
	
	Remotes.Upgrade.OnServerInvoke = function(Player, Listener, ...)
		if Listeners[Listener] then
			return Listeners[Listener](Player, ...)
		end
	end
end

function Upgrades.Upgrade(Player, UpgradeName)
	local Upgrades = Upgrades.Data[Player]
	if Upgrades[UpgradeName] == nil then return end
	local UpgradeLevel = Upgrades[UpgradeName]
	if UpgradeLevel < 10 then
		Upgrades[UpgradeName] += 1
	end
end

function Upgrades.Get(Player)
	return Upgrades.Data[Player]
end

return Upgrades