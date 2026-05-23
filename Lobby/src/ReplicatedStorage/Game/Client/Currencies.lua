local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Currencies = Fusion:scoped()

Currencies.Gems = Currencies:Value(0)
Currencies.XP = Currencies:Value(0)
Currencies.Cash = Currencies:Value(0)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


function Currencies.GameStart ()
	InterfaceTools = require("./InterfaceTools")
	
	local LeaderStats = Player:WaitForChild("player_data", 10)
	local GemStat = LeaderStats:WaitForChild("Gems", 3)
	local MoneyStat = LeaderStats:WaitForChild("Money", 3)
	local XPStat = LeaderStats:WaitForChild("XP", 3)
	
	Currencies.Gems:set(GemStat.Value)
	Currencies.Cash:set(MoneyStat.Value)
	Currencies.XP:set(XPStat.Value)
	
	GemStat.Changed:Connect(function()
		Currencies.Gems:set(GemStat.Value)
	end)

	MoneyStat.Changed:Connect(function()
		Currencies.Cash:set(MoneyStat.Value)
	end)
	
	XPStat.Changed:Connect(function()
		Currencies.XP:set(XPStat.Value)
	end)
	
	Currencies.HydrateToInterface()
end

function Currencies.HydrateToInterface()
	local MainInterface = InterfaceTools.GetInterface("Main")
	local BrainrotInterface = InterfaceTools.GetInterface("Brainrots")
	local SummonInterface = InterfaceTools.GetInterface("Summon")
	local UpgradeInterface = InterfaceTools.GetInterface("Upgrades")
	
	local GemText = MainInterface.Currency.Gems.Amount

	Currencies:Hydrate(GemText) {
		Text = Currencies.Gems
	}
	
	local MoneyText = MainInterface.Currency.Money.Amount

	local XPText = BrainrotInterface.Currency.XP.Amount

	Currencies:Hydrate(MoneyText) { 
		Text = Currencies.Cash
	}

	Currencies:Hydrate(XPText) { 
		Text = Currencies.XP
	}
	
	local GemText = SummonInterface.Back.Currency.Gems.Amount
	
	Currencies:Hydrate(GemText) {
		Text = Currencies.Gems
	}
	
	local XPText = UpgradeInterface.Currency.XP.Amount
	
	Currencies:Hydrate(XPText) { 
		Text = Currencies.XP
	}
end

return Currencies