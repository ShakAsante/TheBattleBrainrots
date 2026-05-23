local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Remotes = Root:WaitForChild("Remotes")

local Boosts = {}
Boosts.Data = {}

local Players = game:GetService("Players")

local BoostsInfo = {
	["DoubleGems"] = {
		["Name"] = "x2 Gems",
	},
	["DoubleXP"] = {
		["Name"] = "x2 XP",
	},
	["DoubleLuck"] = {
		["Name"] = "x2 Luck",
	},
}

function Boosts.GameStart()
	Products = require(Root.Assets.Products)
	Purchases = require("./Purchases")

	Players.PlayerAdded:Connect(function(Player)
		Boosts.Data[Player] = {
			DoubleGems = Purchases.OwnsGamepass(Player, Products.Gamepasses.DoubleGems),
			DoubleXP = Purchases.OwnsGamepass(Player, Products.Gamepasses.DoubleXP),
			DoubleLuck = Purchases.OwnsGamepass(Player, Products.Gamepasses.DoubleLuck),
		}

		for BoostName, Boost in pairs(Boosts.Data[Player]) do
			Remotes.Replicate:FireClient(Player, "Notification", BoostsInfo[BoostName].Name.." is active!")
		end
	end)
end

function Boosts.Has(Player, BoostName)
	return Boosts.Data[Player] ~= nil and Boosts.Data[Player][BoostName] ~= nil or false
end

return Boosts