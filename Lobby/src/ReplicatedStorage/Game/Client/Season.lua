local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Root = ReplicatedStorage.Game
local Seasons = require(Root.Seasons)
local Assets = Root:WaitForChild("Assets")
local InterfaceTools = require("./InterfaceTools")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Tweaks = require(Root.Tweaks)
local Fusion = require(Root.Shared.Packages.Fusion)
local SeasonPass = Fusion.scoped(Fusion)
local Remotes = Root.Remotes
local Purchase = require("./Purchase")
local Images = require(Assets.Images)
local Products = require(Assets.Products)
local Effects = require("./Effects")
local UnitInfo = require(Assets.UnitInfo)

local Utils  = require(Assets.Utils)

SeasonPass.Data = {}
SeasonPass.Level = SeasonPass:Value(0)
SeasonPass.EXP = SeasonPass:Value(35)
SeasonPass.MEXP = SeasonPass:Value(100)
SeasonPass.Type = SeasonPass:Value("Basic")


function SeasonPass.GameStart()
	local CurrentSeason = Tweaks.CurrentSeason or 1
	local SeasonUI = InterfaceTools.GetInterface("Season")
	
	local Body = SeasonUI.Main.Inner.Body
	
	for Level, Data in pairs(Seasons[CurrentSeason]) do
		local Template = Body.Template:Clone()
		Template.Name = HttpService:GenerateGUID(false)
		Template.Parent = Body
		Template.Visible = true
		
		local Items = Template.Items
		
		SeasonPass:Hydrate(Template.LevelRequired.Level) {
			Text = Level
		}
		
		SeasonPass:Hydrate(Template.LevelRequired.Level.Shadow) {
			Text = Level
		}
		
		local TypeHandlers = {
			["Default"] = function(ItemTemplate, Type, Data)
				ItemTemplate.Item.Image = Images[Type] ~= nil and Images[Type] or ""
			end,
			
			["Brainrot"] = function(ItemTemplate, Type, Data)
				local Viewport = ItemTemplate.ViewportFrame
				local Brainrot = Assets.Rots:WaitForChild(Data.Name):WaitForChild("Base"):WaitForChild(Data.Skin or "Default"):Clone()
				Brainrot.Parent = Viewport:FindFirstChild("WorldModel")
				
				local AnimationController = Brainrot:WaitForChild("AnimationController") :: AnimationController
				local Animator = AnimationController.Animator
				local UnitInfo = UnitInfo[Data.Name]
				
				local IdleAnimation = UnitInfo.Animations.Base.Idle
				IdleAnimation = Animator:LoadAnimation(IdleAnimation)
				IdleAnimation:Play()

				wait()
				
				local Body = Brainrot:WaitForChild("Body")	
				Body:PivotTo(CFrame.new(0,-3,-7) * CFrame.Angles(0, math.rad(-70), 0))
			end,
		}
		
		do 
			local BasicItem = Data[1]
			local BasicItemHandler = TypeHandlers[BasicItem.Type] ~= nil and TypeHandlers[BasicItem.Type] or TypeHandlers["Default"]
			BasicItemHandler(Items.Basic, BasicItem.Type, BasicItem.Data)
		end
		
		do 
			local PremiumItem = Data[2]
			local BasicItemHandler = TypeHandlers[PremiumItem.Type] ~= nil and TypeHandlers[PremiumItem.Type] or TypeHandlers["Default"]
			BasicItemHandler(Items.Premium, PremiumItem.Type, PremiumItem.Data)
		end
		
		local BasicItem = Items.Basic
		local PremiumItem = Items.Premium

		SeasonPass:Hydrate(BasicItem.Title) {
			Text = Data[1].Type
		}
	

		SeasonPass:Hydrate(BasicItem.Amount) {
			Text = `x{Utils.Abbreviate(Data[1].Data.Amount or 1)}`
		}

		SeasonPass:Hydrate(PremiumItem.Title) {
			Text = Data[2].Type
		}
		
		SeasonPass:Hydrate(PremiumItem.Amount) {
			Text = `x{Utils.Abbreviate(Data[2].Data.Amount or 1)}`
		}
		
		local IsLocked = SeasonPass:Computed(function(Use)
			return Use(SeasonPass.Level) < Level
		end)

		local IsBasicClaimed = SeasonPass:Value(not Fusion.peek(IsLocked))
		local IsPremiumClaimed = SeasonPass:Value(not Fusion.peek(IsLocked))
		
		SeasonPass.Data[Level] = { 
			IsBasicClaimed,
			IsPremiumClaimed,
			Ref = Template,	
		}
		
		SeasonPass:Hydrate(BasicItem.Locked) {
			Visible = IsLocked
		}
		
		SeasonPass:Hydrate(PremiumItem.Locked) {
			Visible = SeasonPass:Computed(function(Use)
				return Use(IsLocked) or Use(SeasonPass.Type) ~= "Premium"
			end)
		}

		SeasonPass:Hydrate(BasicItem.Claimed) {
			Visible = IsBasicClaimed
		}

		SeasonPass:Hydrate(PremiumItem.Claimed) {
			Visible = IsPremiumClaimed
		}
	end
	
	
	local Bottom = SeasonUI.Main.Bottom
	local LevelBar = Bottom.Bar
	local LevelFrame = LevelBar.CurrentLevel
	
	local BuyLevelButton = Bottom.Bar.BuyLevel
	local BuyAllButton = Bottom.Buttons.BuyAll
	local BuyPassButton = SeasonUI.Main.Inner.Purchase.PurchaseButton
	
	local ClaimButton = Bottom.Buttons.Claim
	
	SeasonPass:Hydrate(ClaimButton) {
		[Fusion.OnEvent("Activated")] = function()
			Remotes.Season:InvokeServer("Claim")
		end,
	}
	
	SeasonPass:Hydrate(BuyPassButton) {
		[Fusion.OnEvent("Activated")] = function()
			Purchase.PromptProduct(Products.DevProducts.SeasonPass)
		end,
	}
	
	SeasonPass:Hydrate(BuyAllButton) {
		[Fusion.OnEvent("Activated")] = function()
			Purchase.PromptProduct(Products.DevProducts.SeasonPassBuyAll)
		end,
	}

	SeasonPass:Hydrate(BuyLevelButton) {
		[Fusion.OnEvent("Activated")] = function()
			Purchase.PromptProduct(Products.DevProducts.SeasonPassLevelUp)
		end,
	}
	
	SeasonPass:Hydrate(LevelFrame.TextLabel) {
		Text = SeasonPass.Level
	}
	
	SeasonPass:Hydrate(LevelBar.Bar.Label) {
		Text = SeasonPass:Computed(function(Use)
			return `{Use(SeasonPass.EXP)}/{Use(SeasonPass.MEXP)}`
		end)	
	}
	
	SeasonPass:Hydrate(LevelBar.Bar.Progress) {
		Size = SeasonPass:Computed(function(Use)
			return UDim2.fromScale(Use(SeasonPass.EXP)/Use(SeasonPass.MEXP),1)
		end)
	}
	
	
	SeasonPass:Observer(SeasonPass.Level):onChange(function()
		local ItemFrame = SeasonPass.Data[Fusion.peek(SeasonPass.Level)].Ref
		local PassType = Fusion.peek(SeasonPass.Type)
		Effects:DoEffect("UpgradeEffect", ItemFrame.Items.Basic)
		
		if PassType == "Premium" then
			Effects:DoEffect("UpgradeEffect", ItemFrame.Items.Premium)
		end
		
	end)
	
	Remotes.Season.OnClientInvoke = function(Data)
		local Level = Data.Level
		local Exp = Data.Exp

		SeasonPass.Level:set(Level)
		SeasonPass.EXP:set(Exp)
		SeasonPass.MEXP:set(Tweaks.ExperienceRequiredPerSeasonLevel(Level))
		SeasonPass.Type:set(Data.Type)

		for Level, ClaimStatus in pairs(Data.ClaimedLevels) do
			SeasonPass.Data[Level][1]:set(ClaimStatus >= 1)
			SeasonPass.Data[Level][2]:set(ClaimStatus >= 2)
		end
	end
end

return SeasonPass