local Purchases = {}
local Marketplace = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Products = require(Assets.Products)
local Remotes = Root.Remotes
local Data = require("./Data")
local PlayerStats = require("./Stats")

local SeasonTools = require("./SeasonTools")
local Seasons = require(Root.Seasons)
local Gifting = require("./Gifting")
local Tweaks = require(Root.Tweaks)
local Rewards = require("./Rewards")
local BundleTools = require("./BundleTools")

local Handlers = {
	[Products.DevProducts.Money.PackOne] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Cash", {
			Amount = Tweaks.ShopValues.Packs.Money.PackOne
		})
		return true
	end,	
	
	[Products.DevProducts.Money.PackTwo] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Cash", {
			Amount = Tweaks.ShopValues.Packs.Money.PackTwo
		})
		return true
	end,
	
	[Products.DevProducts.Money.PackThree] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Cash", {
			Amount = Tweaks.ShopValues.Packs.Money.PackThree
		})
		return true
	end,
	
	[Products.DevProducts.Money.PackFour] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Cash", {
			Amount = Tweaks.ShopValues.Packs.Money.PackFour
		})
		return true
	end,
	
	[Products.DevProducts.Gems.PackOne] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Gems", {
			Amount = Tweaks.ShopValues.Packs.Gems.PackOne
		})
		return true
	end,
	
	[Products.DevProducts.Gems.PackTwo] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Gems", {
			Amount = Tweaks.ShopValues.Packs.Gems.PackTwo
		})
		return true
	end,
	
	[Products.DevProducts.Gems.PackThree] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Gems", {
			Amount = Tweaks.ShopValues.Packs.Gems.PackThree
		})
		return true
	end,
	
	[Products.DevProducts.Gems.PackFour] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		Rewards.Give(GiftingTarget, "Gems", {
			Amount = Tweaks.ShopValues.Packs.Gems.PackFour
		})
		return true
	end,
	
	[Products.DevProducts.XP.PackOne] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)

		Rewards.Give(GiftingTarget, "XP", {
			Amount = Tweaks.ShopValues.Packs.XP.PackOne
		})

		return true
	end,
	[Products.DevProducts.XP.PackTwo] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)

		Rewards.Give(GiftingTarget, "XP", {
			Amount = Tweaks.ShopValues.Packs.XP.PackTwo
		})

		return true
	end,
	[Products.DevProducts.XP.PackThree] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)

		Rewards.Give(GiftingTarget, "XP", {
			Amount = Tweaks.ShopValues.Packs.XP.PackThree
		})

		return true
	end,
	[Products.DevProducts.XP.PackFour] = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)

		Rewards.Give(GiftingTarget, "XP", {
			Amount = Tweaks.ShopValues.Packs.XP.PackFour
		})

		return true
	end,
	
	[Products.DevProducts.SeasonPassLevelUp] = function(Player)
		SeasonTools.AddLevel(Player, 1)
		return true
	end,
	
	[Products.DevProducts.SeasonPassBuyAll] = function(Player)
		local MaxLevelForSeason = #Seasons[Tweaks.CurrentSeason]
		SeasonTools.SetLevel(Player, MaxLevelForSeason)
	end,
	
	[Products.DevProducts.SeasonPass] = function(Player)
		SeasonTools.SetType(Player, "Premium")
	end,
	--[]
}

for BundleName, Bundle in pairs(Products.DevProducts.Bundles)  do
	local Handle = function(Player)
		local GiftingTarget = Gifting.GetGiftTarget(Player)
		BundleTools.GiveBundle(GiftingTarget, BundleName)
		return true
	end
	
	Handlers[Bundle] = Handle
end

function Purchases.GameStart()
	Marketplace.ProcessReceipt = function(ReceiptInfo)
		local Player = game:GetService("Players"):GetPlayerByUserId(ReceiptInfo.PlayerId)
		
		if not Player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		local Handle = Handlers[ReceiptInfo.ProductId]
		
		if Handle then
			local GiftingTarget = Gifting.GetGiftTarget(Player)
			
			if GiftingTarget ~= Player then
				Remotes.Replicate:FireClient(GiftingTarget, "Notification", "You received a gift from "..Player.Name.."!")
			end
		
			local Success = Handle(Player)
			
			if Success then
				local PriceOfProduct = Marketplace:GetProductInfo(ReceiptInfo.ProductId, Enum.InfoType.Product).PriceInRobux
				PlayerStats.Add(Player, "RobuxSpent", PriceOfProduct)
				PlayerStats.AddWeekly(Player, "RobuxSpent", PriceOfProduct)
				Remotes.Replicate:FireClient(Player, "Notification", "Thank you for your purchase!")
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		--return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function Purchases.OwnsGamepass(Player, ID)
	return Marketplace:UserOwnsGamePassAsync(Player.UserId, ID) or false
end

return Purchases