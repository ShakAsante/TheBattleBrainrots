local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Purchases = {}
local Marketplace = game:GetService("MarketplaceService")
local Products = require(Assets.Products)
local Remotes = Root.Remotes

local PlayerStats = require("./Stats")

local Handlers = {
	[Products.DevProducts.Revive] = function()
		-- do revive
	end,
}

function Purchases.GameStart()
	Marketplace.ProcessReceipt = function(ReceiptInfo)
		local Player = game:GetService("Players"):GetPlayerByUserId(ReceiptInfo.PlayerId)
		
		if not Player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		local Handle = Handlers[ReceiptInfo.ProductId]
		
		if Handle then
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

function Purchases.OwnsGamepass(Player, id)
	return Marketplace:UserOwnsGamePassAsync(Player.UserId, id)
end

return Purchases