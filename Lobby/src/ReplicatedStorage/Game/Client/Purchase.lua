local Purchase = {}
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

function Purchase.PromptProduct(ProductId)
	MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, ProductId)
	
	local Await = script:WaitForChild("Await"):Clone()
	Await.Parent = PlayerGui
	
	MarketplaceService.PromptProductPurchaseFinished:Wait()
	Await:Destroy()
end

return Purchase