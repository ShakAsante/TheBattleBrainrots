local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Assets = Root:WaitForChild("Assets")
local Summon = Fusion.scoped(Fusion)
local ZonePlus = require(Root.Shared.Packages.Zone)
local Map = workspace:WaitForChild("Map")
local Structures = Map:WaitForChild("Structures")
local RunService = game:GetService("RunService")
local UnitInfo = require(Assets.UnitInfo)

Summon.Now = Summon:Value(-1)
Summon.Banner = Summon:Value(1)
Summon.Data = {}
Summon.InAnim = Summon:Value(false)

local Remotes = Root.Remotes

local Prompt = require("./Prompt")
local Tweaks = require(Root.Tweaks)

local Banners = require(Root.Banners)

local Utils = require(Assets.Utils)
local Images = require(Assets.Images)

function Summon.GameStart()
	Interface = require("./Interface")
	InterfaceTools = require("./InterfaceTools")
	Effects = require("./Effects")
	Tutorial = require("./Tutorial")
	
	Summon.HandleVisbility()
	Summon.HandleInterface()
	Summon.HandleBoard()
	
	local function UpdateBanner()
		local Banner = Fusion.peek(Summon.Banner)
		local BannerData = Banners[Banner]
		local BannerContent = BannerData.Content
		local Form = "Base"

		for Current=1, #Summon.Data do
			local CurrentName = BannerContent[Current] or nil
			print(CurrentName, BannerContent)
			Summon.Data[Current]:set(CurrentName)			
		end
	end
	
	Summon:Observer(Summon.Banner):onChange(function()
		UpdateBanner()
	end)
	
	UpdateBanner()
	
	while task.wait(1) do
		Summon.Now:set(tick())
		local Cycle = math.floor(tick() / Tweaks.BannerRotationTime)
		local SEED = math.randomseed(123 + Cycle)
		local Banner = math.random(1, #Banners)
		Summon.Banner:set(Banner)
	end
end

function Summon.HandleBoard()
	local SurfaceInterface = InterfaceTools.GetInterface("CurrentSummonBanners")
	local Body = SurfaceInterface.Main.Body
	local Inner = Body.Inner
	local BannerFrame = Inner.Banner
	local Effects = Body.Effect
	local Header = Effects.Header
	local ResetsInLabel = Header.ResetsIn

	Summon:Hydrate(ResetsInLabel) {
		Text = Summon:Computed(function(Use)
			local Now = Use(Summon.Now)
			local DaysInSeconds = Tweaks.BannerRotationTime
			return `NEW BANNER IN: {Utils.FormatTime(DaysInSeconds - (Now % DaysInSeconds))}`
		end)
	}

	local Frames = {
		BannerFrame.First,
		BannerFrame.Second,
		BannerFrame.Third
	}

	local Form = "Base"

	for Current=1, #Frames do
		local UnitFrame = Frames[Current]
		local UnitName = Summon.Data[Current]
		local Viewport = UnitFrame.ViewportFrame
		
		Viewport.WorldModel:ClearAllChildren()
		
		local function UpdateModel()
			local ModelName = Fusion.peek(UnitName)
			local DataExists = UnitInfo[ModelName]
			
			Viewport.WorldModel:ClearAllChildren()
			if not DataExists then
				return
			end

			local Rot = Assets.Rots:FindFirstChild(ModelName)

			if Rot then
				local Skin = Rot:WaitForChild(Form):WaitForChild("Default"):Clone()
				Skin.Parent  = Viewport.WorldModel

				local Body = Skin.Body
				local AnimationController = Skin:WaitForChild("AnimationController") :: AnimationController
				local Animator = AnimationController.Animator

				local IdleAnimation = DataExists.Animations.Base.Idle
				IdleAnimation = Animator:LoadAnimation(IdleAnimation)
				IdleAnimation:Play()

				Body:PivotTo(CFrame.new(0,-1,-7) * CFrame.Angles(0, Current == 1  and math.rad(-90) or (Current == 2 and math.rad(-115) or math.rad(-75)), 0))

				local Original = Body:GetPivot()

				RunService.RenderStepped:Connect(function()
					Body:PivotTo(Original * CFrame.Angles(0,-math.rad(math.sin(tick())) * 5, math.rad(math.sin(tick() * Current)) * 5))
				end)	
			end
		end

		Summon:Observer(UnitName):onChange(function()
			UpdateModel()
		end)

		UpdateModel()

		local Desc = UnitFrame.Desc

		Summon:Hydrate(Desc.UnitName) {
			Text = Summon:Computed(function(Use)
				local DataExists = UnitInfo[Use(UnitName)]

				if not DataExists then
					return "???"
				end

				return DataExists[Form].DisplayName or "???"
			end)
		}

		Summon:Hydrate(Desc.Rarity) {
			Text = Summon:Computed(function(Use)
				local DataExists = UnitInfo[Use(UnitName)]

				if not DataExists then
					return "???"
				end

				return DataExists.Rarity or "???"
			end)
		}

	end
end

function Summon.HandleInterface()
	local SummonInterface = InterfaceTools.GetInterface("Summon")
	local Body = SummonInterface.Main.Body
	local Inner = Body.Inner
	local BannerFrame = Inner.Banner
	local Effect = Body.Effect
	local Header = Effect.Header
	local ResetsInLabel = Header.ResetsIn
	local Actions = Inner.Actions
	
	local BackgroundImage = Body.Background
	
	Summon:Hydrate(BackgroundImage) {
		Image = Summon:Computed(function(Use)
			local Banner = Use(Summon.Banner)
			local BannerData = Banner and Banners[Banner]
			local Image = (BannerData and BannerData.SummonScene) and Images.Scenes[BannerData.SummonScene] or ""
			
			return Image
		end)
	}
	
	Summon:Hydrate(Actions.Summon1) {
		[Fusion.OnEvent("Activated")] = function()
			local Success, Value = Prompt.new({
				Desc= "Summon x1?",
				GemCost = Tweaks.SummonCost,
			}):await()
			
			if Value then
				local Info = Remotes.Summon:InvokeServer(Fusion.peek(Summon.Banner), "Single")
				local IsSuccess = Info[1]
				
				if IsSuccess then
					InterfaceTools.CloseAll()
					local SummonedUnit = Info[2]
					Effects:DoEffect("SimulateEggOpening", SummonedUnit)
				end
			end
		end,
	}
	
	Summon:Hydrate(Actions.Summon5) {
		[Fusion.OnEvent("Activated")] = function()
			local Success, Value = Prompt.new({
				Desc = "Summon x5?",
				GemCost = Tweaks.SummonCost * 5,
			}):await()

			if Value then
				local Info = Remotes.Summon:InvokeServer(Fusion.peek(Summon.Banner), "Multi")
				local IsSuccess = Info[1]

				if IsSuccess then
					InterfaceTools.CloseAll()
					Effects:DoEffect("SimulateEggOpening", Info[2])
				end
			end
		end,
	}
	
	--local InspectContentButton
	
	do
		local CostInButtonOne = Actions.Summon1:FindFirstChild("Cost", true)
		local CostInButtonTwo = Actions.Summon5:FindFirstChild("Cost", true)
		CostInButtonOne.Text = Tweaks.SummonCost
		CostInButtonTwo.Text = Tweaks.SummonCost * 5
	end
	
	Summon:Hydrate(ResetsInLabel) {
		Text = Summon:Computed(function(Use)
			local Now = Use(Summon.Now)
			local DaysInSeconds = Tweaks.BannerRotationTime
			return `NEW BANNER IN: {Utils.FormatTime(DaysInSeconds - (Now % DaysInSeconds))}`
		end)
	}
	
	local Frames = {
		BannerFrame.First,
		BannerFrame.Second,
		BannerFrame.Third
	}

	local Form = "Base"
	
	for Current=1, #Frames do
		local UnitFrame = Frames[Current]
		local Viewport = UnitFrame.ViewportFrame
		local UnitName = Summon:Value(nil)
		
		local Desc = UnitFrame.Desc
		
		local OriginalPos = Viewport.Position
		
		Viewport.Rotation = Current == 1 and 0 or (Current == 2 and -5 or 5)
		--local = Original
		RunService.RenderStepped:Connect(function(Delta)
			Viewport.Position = OriginalPos + UDim2.fromOffset(0, math.sin(Current == 1 and tick() / 2 or tick()) * 15)
		end)
		
		local function UpdateModel()
			local ModelName = Fusion.peek(UnitName)
			local DataExists = UnitInfo[ModelName]

			Viewport.WorldModel:ClearAllChildren()
			
			if not DataExists then
				return
			end
			
			local HasGradient = Desc.Rarity:FindFirstChildOfClass("Gradient")
			
			if HasGradient then
				HasGradient:Destroy()
				
				InterfaceTools.CreateGradient(DataExists.Rarity) {
					Parent = Desc.Rarity
				}
			else
				InterfaceTools.CreateGradient(DataExists.Rarity) {
					Parent = Desc.Rarity
				}
			end
			
			local Rot = Assets.Rots:FindFirstChild(ModelName)
			
			if Rot then
				local Skin = Rot:WaitForChild(Form):WaitForChild("Default"):Clone()
				Skin.Parent  = Viewport.WorldModel
					
				local Body = Skin.Body
				local AnimationController = Skin:WaitForChild("AnimationController") :: AnimationController
				local Animator = AnimationController.Animator
				
				local IdleAnimation = DataExists.Animations.Base.Idle
				IdleAnimation = Animator:LoadAnimation(IdleAnimation)
				IdleAnimation:Play()
				
				Body:PivotTo(CFrame.new(0,-1,-7) * CFrame.Angles(0, Current == 1  and math.rad(-90) or (Current == 2 and math.rad(-115) or math.rad(-75)), 0))
				local Original = Body:GetPivot()

				RunService.RenderStepped:Connect(function()
					Body:PivotTo(Original * CFrame.Angles(0,-math.rad(math.sin(tick())) * 5, math.rad(math.sin(tick() * Current)) * 5))
				end)		
			end
		end

		Summon:Observer(UnitName):onChange(function()
			UpdateModel()
		end)
		
		UpdateModel()
		
		Summon:Hydrate(Desc.UnitName) {
			Text = Summon:Computed(function(Use)
				local DataExists = UnitInfo[Use(UnitName)]
				
				if not DataExists then
					return "???"
				end
			

				return DataExists[Form].DisplayName or "???"
			end)
		}
		
		Summon:Hydrate(Desc.Rarity) {
			Text = Summon:Computed(function(Use)
				local DataExists = UnitInfo[Use(UnitName)]
				
				if not DataExists then
					return "???"
				end

				local Displays = {
					["Normal"] = "Normal",
					["Rare"] = "Rare",
					["UberRare"] = "Uber Rare",
					["SuperRare"] = "Super Rare",
					["Special"] = "Special",
					["LegendRare"] = "Legend Rare"
				}
				return Displays[DataExists.Rarity] or "???"
			end)
		}
		
		Summon.Data[Current] = UnitName
	end
end

function Summon.HandleVisbility()
	local SummonZone = ZonePlus.new(workspace.Terrain:WaitForChild("Zones").SummonShop)

	SummonZone.localPlayerEntered:Connect(function(Player)
		if Fusion.peek(Interface.ShowStages) or  Fusion.peek(Summon.InAnimation) then return end
		if Fusion.peek(Tutorial.IsActive) then return end
		InterfaceTools.CloseAll()
		Interface.ShowSummon:set(true)
	end)

	SummonZone.localPlayerExited:Connect(function(Player)
		Interface.ShowSummon:set(false)
	end)
end

return Summon