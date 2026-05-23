local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Upgrades = {}
local Players = game:GetService("Players")

local Promise = require(Root.Shared.Packages.Promise)

local RunService = game:GetService("RunService")
Upgrades.Data = {}

local TableUtil = require(Root.Shared.Packages.TableUtil)

--local UpgradesTemplate = {
--	BaseAbilityPower = 1,
--	CashGeneration = 1,
--	WalletCapacity = 1,
--	BaseAbility = "Cannon",
--}
local UpgradeData = require(Root.Assets.Upgrades)

local UpgradesTemplate = {}

for UpgradeName, _ in pairs(UpgradeData) do
	UpgradesTemplate[UpgradeName] = 1
end

function Upgrades.GameStart()
	Data = require("./Data")
	TableUtil = require(Root.Shared.Packages.TableUtil)
	
	Players.PlayerAdded:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		
		Profile.Data.Upgrades = TableUtil.Reconcile(Profile.Data.Upgrades, UpgradesTemplate)
		Upgrades.Data[Player] = #TableUtil.Keys(Profile.Data.Upgrades) > 0 and Profile.Data.Upgrades or UpgradesTemplate
	end)	
	
	Players.PlayerRemoving:Connect(function(Player)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		
		Profile.Data.Upgrades = Upgrades.Get(Player)
		Upgrades.Data[Player] = nil
	end)
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
	return Upgrades.Data[Player] or {}
end

return Upgrades