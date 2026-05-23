local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Fusion = require(Root.Shared.Packages.Fusion)
local Shop = Fusion.scoped(Fusion)

local InterfaceTools = require(Root.Client.InterfaceTools)
local Players = game:GetService("Players")
local Products = require(Assets.Products)
local Purchase = require(Root.Client.Purchase)
local MarketPlace = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

Shop.CurrentPage = Shop:Value("Home")
Shop.__GiftingFrames = {}
Shop.ShowGifting = Shop:Value(false)
Shop.GiftingTarget = Shop:Value(nil)

Shop.Content = {
	Home = {
		{
			"SeasonPass", 
			{
				Product =  Products.DevProducts.SeasonPass,
				IsBundle = true,
				
				OnHover = function(Element)
					local Body = Element.Inner.Body
					Body.Display.Visible = false
					Body.Preview.ImageColor3 = Color3.fromRGB(0, 0, 0)
					Body.Preview.ImageTransparency = .7
					Body.Items.Visible = true
				end,
				
				OffHover = function(Element)
					local Body = Element.Inner.Body
					Body.Preview.ImageTransparency = 0
					Body.Preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Body.Display.Visible = true
					Body.Items.Visible = false
				end,
				
				Alias = "Seasonal Pass"
			}
		},
		{
			"LegendsBundle1", 
			{
				Product =  Products.DevProducts.Bundles.LegendsBundle1,
				IsBundle = true,

				OnHover = function(Element)
					local Body = Element.Inner.Body
					Body.Display.Visible = false
					Body.Preview.ImageColor3 = Color3.fromRGB(0, 0, 0)
					Body.Preview.ImageTransparency = .7
					Body.Items.Visible = true
				end,

				OffHover = function(Element)
					local Body = Element.Inner.Body
					Body.Preview.ImageTransparency = 0
					Body.Preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Body.Display.Visible = true
					Body.Items.Visible = false
				end,

				Alias = ""
			}
		},
		{
			"PurchasePicconeMacchina", 
			{
				Product =  Products.DevProducts.Bundles.PurchaseTralalero,
				IsBundle = false,
				Alias = ""
			}
		},
		{
			"PurchaseTralalero", 
			{
				Product =  Products.DevProducts.Bundles.PurchasePicconeMacchina,
				IsBundle = false,
				Alias = ""
			}
		},
		{
			"LegendsBundle2", 
			{
				Product =  Products.DevProducts.Bundles.LegendsBundle2,
				IsBundle = true,

				OnHover = function(Element)
					local Body = Element.Inner.Body
					Body.Display.Visible = false
					Body.Preview.ImageColor3 = Color3.fromRGB(0, 0, 0)
					Body.Preview.ImageTransparency = .7
					Body.Items.Visible = true
				end,

				OffHover = function(Element)
					local Body = Element.Inner.Body
					Body.Preview.ImageTransparency = 0
					Body.Preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Body.Display.Visible = true
					Body.Items.Visible = false
				end,

				Alias = "Release Bundle"
			}
		},
	},
	Gems = {
		{"PackOne", 
			{
				Product =  Products.DevProducts.Gems.PackOne,
				Alias = "Gems Pack #1"
			}
		},
		{"PackTwo", 
			{
				Product =  Products.DevProducts.Gems.PackTwo,
				Alias = "Gems Pack #2"
			}
		},
		{"PackThree",
			{
				Product =  Products.DevProducts.Gems.PackThree,
				Alias = "Gems Pack #3"
			}
		},
		{"PackFour", 
			{
				Product =  Products.DevProducts.Gems.PackFour,
				Alias = "Gems Pack #4"
			}
		},
	},
	XP = {
		{"PackOne", 
			{
				Product =  Products.DevProducts.XP.PackOne,
				Alias = "XP Pack #1"
			}
		},
		{"PackTwo",
			{
				Product =  Products.DevProducts.XP.PackTwo,
				Alias = "XP Pack #2"
			}
		},
		{"PackThree", 
			{
				Product =  Products.DevProducts.XP.PackThree,
				Alias = "XP Pack #3"
			}
		},
		{"PackFour", 
			{
				Product =  Products.DevProducts.XP.PackFour,
				Alias = "XP Pack #4"
			}
		},
	},
	Money = {
		{"PackOne",
			{
				Product =  Products.DevProducts.Money.PackOne,
				Alias = "Money Pack #1"
			}
		},
		{"PackTwo", 
			{
				Product =  Products.DevProducts.Money.PackTwo,
				Alias = "Money Pack #2"
			}
		},
		{"PackThree", 
			{
				Product =  Products.DevProducts.Money.PackThree,
				Alias = "Money Pack #3"
			}
		},
		{"PackFour", 
			{
				Product =  Products.DevProducts.Money.PackFour,
				Alias = "Money Pack #4"
			}
		},	
	},
}

function Shop.GameStart()
	ShopInterface = InterfaceTools.GetInterface("Shop", 5)
	UISpotlight = require("./UISpotlight")
	
	local Interface = require("./Interface")
	
	Shop:Observer(Interface.ShowShop):onChange(function()
		if not Fusion.peek(Interface.ShowShop) then
			UISpotlight.FocusOff()
		end
	end)

	Shop.HandleCodes()
	Shop.HandleShop()
	Shop.HandlePageMovement()
	Shop.HandleGifting()
end

function Shop.HandleCodes()
	local ShopBody = ShopInterface.Body.Shop.Inner
	local HomeSection = ShopBody:WaitForChild("Home")
	
	local CodeBody = HomeSection:WaitForChild("CodesBody")
	local Input = CodeBody:WaitForChild("Input")
	
	local RedeemButton = CodeBody:WaitForChild("Redeem")
	
	Shop:Hydrate(RedeemButton) {
		[Fusion.OnEvent("Activated")] = function()
			local Captured = Input.Text
			Input.Text = ""
			Root.Remotes.RedeemCode:InvokeServer(Captured)
		end,
	}
end

function Shop.HandleShop()
	local ShopBody = ShopInterface.Body.Shop.Inner
	
	for Name, SectionData in pairs(Shop.Content) do
		local Section = ShopBody:WaitForChild(Name)
		for _, Pass in pairs(SectionData) do
			local HasButton = Section:FindFirstChild(Pass[1], true)
			
			if HasButton and HasButton:IsA("ImageButton") then
				Shop:Hydrate(HasButton) {
					[Fusion.OnEvent("Activated")] = function()
						Purchase.PromptProduct(Pass[2].Product)
					end,

					[Fusion.OnEvent("MouseEnter")] = function()
						if Pass[2].OnHover then
							Pass[2].OnHover(HasButton)
						end
					end,
					
					[Fusion.OnEvent("MouseLeave")] = function()
						if Pass[2].OffHover then
							Pass[2].OffHover(HasButton)
						end
					end
				}
				
				if Pass[2].IsBundle then
					Shop:Hydrate(HasButton) {
						[Fusion.OnEvent("MouseEnter")] = function()
							UISpotlight.Focus(HasButton)
						end,

						[Fusion.OnEvent("MouseLeave")] = function()
							UISpotlight.FocusOff()
						end,
					}
				end
				
				local CostValue = HasButton:FindFirstChild("CostValue", true)
				
				if CostValue then
					local ProductInfo = MarketPlace:GetProductInfo(Pass[2].Product, Enum.InfoType.Product)
					CostValue.Text = ProductInfo.PriceInRobux or 0
				end
			end
		end
	end
end

function Shop.HandlePageMovement()
	local SelectStroke = Shop:New("UIStroke") {
		Thickness = 0.08,
		Transparency = .7,
		Color = Color3.new(1, 1, 1), 
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Parent = Shop:Computed(function(Use)
			local Button = ShopInterface.Body.Shop.Header:WaitForChild(Use(Shop.CurrentPage))
			return Button
		end)
	}

	local Inner = ShopInterface.Body.Shop.Inner

	Shop:Observer(Shop.CurrentPage):onChange(function()
		local PageElement = Inner.UIPageLayout :: UIPageLayout
		
		if Fusion.peek(Shop.CurrentPage) == "Exit" then
			return
		else			
			PageElement:JumpTo(Inner:WaitForChild(Fusion.peek(Shop.CurrentPage)))
		end
	end)

	local Header = ShopInterface.Body.Shop.Header
	local Buttons = Header:GetChildren()

	for _, Button in pairs(Buttons) do
		if Button:IsA("ImageButton") then
			--InterfaceTools.AnimateButton(Button)

			Shop:Hydrate(Button) {
				[Fusion.OnEvent("Activated")] = function()
					Shop.CurrentPage:set(Button.Name)
				end,
			}
		end
	end
end

function Shop.HandleGifting()
	local GiftInterface = ShopInterface.Body.Gifting
	Shop:Hydrate(GiftInterface.Header.Inner.Who) {
		Text = Shop:Computed(function(Use)
			local Target = Use(Shop.GiftingTarget)
			return Target and `@{Target.Name}` or "???"
		end)
	}
	
	local GiftBody = GiftInterface.Body
	
	for _, Section in pairs(Shop.Content) do
		for _, Pass in pairs(Section) do
			local Template = GiftBody.Template:Clone()
			Template.Name = HttpService:GenerateGUID(false)

			Shop:Hydrate(Template) {
				Parent = GiftBody,
				Visible = true,
				[Fusion.OnEvent("Activated")] = function()
					Purchase.PromptProduct(Pass[2].Product)
				end,
			}
			
			Shop:Hydrate(Template.PassName) {
				Text = Pass[2].Alias or "???"
			}
			
			local CostValue = Template:FindFirstChild("CostValue", true)
			if CostValue then
				local ProductInfo = MarketPlace:GetProductInfo(Pass[2].Product, Enum.InfoType.Product)
				CostValue.Text = ProductInfo.PriceInRobux or 0
			end
		end
	end

	local ReturnButton = GiftInterface.Header.Exit

	Shop:Hydrate(ReturnButton) {
		[Fusion.OnEvent("Activated")] = function()
			Root.Remotes.Gift:InvokeServer("Set", nil)
			Shop.GiftingTarget:set(nil)
			Shop.ShowGifting:set(false)
		end,
	}

	Shop:Hydrate(GiftInterface) {
		Visible = Shop.ShowGifting	
	}

	local ShopSection = ShopInterface.Body.Shop

	Shop:Hydrate(ShopSection) {
		Visible = Shop:Computed(function(Use)
			return not Use(Shop.ShowGifting)
		end)
	} 
	
	local GiftSection = ShopInterface.Body.Shop.Inner.Gift

	local function HandleForPlayer(Player)
		local Template = GiftSection.GiftTemplate:Clone()
		Template.Name = HttpService:GenerateGUID(false)
		Template.Visible = true
		Template.Info.Icon.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
		
		local NameLabel = Template.Info.Labels:WaitForChild("Name")
		NameLabel.Text = Player.Name
		local DisplayLabel = Template.Info.Labels:WaitForChild("Display")
		DisplayLabel.Text = Player.DisplayName
		
		Template.Parent = GiftSection

		Shop:Hydrate(Template.StartGift) {
			[Fusion.OnEvent("Activated")] = function()
				Shop.PromptGift(Player)
			end,
		}

		Shop.__GiftingFrames[Player] = Template
	end

	Players.PlayerAdded:Connect(function(Player)	
		HandleForPlayer(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		local FrameExists = Shop.__GiftingFrames[Player]
		if not FrameExists then return end
		Shop.__GiftingFrames[Player]:Destroy()
	end)

	for _, Player in pairs(Players:GetPlayers()) do
		if Player == LocalPlayer then continue end
		HandleForPlayer(Player)
	end

	--Shop:Hydrate(GiftSection) {
	--	[Fusion.Children] = Shop:Computed(function(Use)
	--		local Elements = {}

	--		for _, Player in pairs(Use(Shop.Players)) do
	--			local Template = GiftSection.GiftTemplate:Clone()
	--			Template.Visible = true
	--			Template.Info.Icon.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
	--			Template.Parent = GiftSection

	--			Shop:Hydrate(Template.StartGift) {
	--				[Fusion.OnEvent("Activated")] = function()
	--					Shop.PromptGift(Player)
	--				end,
	--			}
	--		end

	--		return Elements 
	--	end)
	--}
end

function Shop.PromptGift(Player)
	local GiftInterface = ShopInterface.Body.Gifting
	Shop.GiftingTarget:set(Player)
	Root.Remotes.Gift:InvokeServer("Set", Player)
	Shop.ShowGifting:set(true)
end

return Shop