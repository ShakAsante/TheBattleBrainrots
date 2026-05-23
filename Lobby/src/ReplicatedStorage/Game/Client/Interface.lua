local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)

local Loading = require("./Loading")
local Interface = Fusion.scoped(Fusion)

Interface.InInterface = Interface:Value(false)
Interface.ShowSummon = Interface:Value(false)
Interface.ShowShop = Interface:Value(false)
Interface.ShowQuests = Interface:Value(false)
Interface.ShowBrainrot = Interface:Value(false)
Interface.IsMobile = Interface:Value(not game.UserInputService.KeyboardEnabled and not game.UserInputService.GamepadEnabled)
Interface.ShowSeason = Interface:Value(false)
Interface.HideInterface = Interface:Value(false)
Interface.FieldOfView = Interface:Value(75)
Interface.ShowFreeRewards = Interface:Value(false)
Interface.ShowStages = Interface:Value(false)
Interface.ShowUpgrades = Interface:Value(false)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Assets = Root:WaitForChild("Assets")

local UnitInfo = require(Assets.UnitInfo)
local Tweaks = require(Root.Tweaks)
local Player = game:GetService("Players").LocalPlayer
local Remotes = Root.Remotes
local Camera = workspace.CurrentCamera
local Tween = game:GetService("TweenService")

local ZonePlus = require(Root.Shared.Packages.Zone)
local Effects = require("./Effects")

Interface.Brainrots = {}
Interface.FocusedBrainrot = Interface:Value(nil)
Interface.BrainrotFilter = Interface:Value("Normal")

function Interface.AnimateUIS()
	InterfaceTools.AnimateInterfaces()
end

function Interface.HandleInterfaceExit()
	do
		local ExitButton = QuestInterface.Body.Exit

		Interface:Hydrate(ExitButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitQuests") == nil then
					return
				end

				Interface.ShowQuests:set(false)
			end,
		}
	end



	do
		local ExitButton = ShopInterface.Body.Shop.Header.Exit

		Interface:Hydrate(ExitButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitShop") == nil then
					return
				end
				
				Interface.ShowShop:set(false)
			end,
		}
	end

	do
		local ExitButton = BrainrotInterface.Exit

		Interface:Hydrate(ExitButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitBrainrots") == nil then
					return
				end
				
				Interface.ShowBrainrot:set(false)
			end,
		}
	end

	do 
		local ExitButton = SeasonPass.Main.Top.Actions.Exit

		Interface:Hydrate(ExitButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitPass") == nil then
					return
				end
				
				Interface.ShowSeason:set(false)
			end,
		}
	end
	
	do 
		local ExitButton = UpgradesInterface.Main.Stages.Back.Exit
		Interface:Hydrate(ExitButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitUpgrades") == nil then
					return
				end
				
				Interface.ShowUpgrades:set(false)
			end,
		}
	end
end

function Interface.HandleStageUI()
	local Stage = require("./Stage")

	local PlayButton = MainInterface.Team.Back.Play

	Interface:Hydrate(PlayButton) {
		[Fusion.OnEvent("Activated")] = function()
			Stage.Open()
		end,
	}
	--Stage.Open()
end

function Interface.GameStart()
	Currencies = require("./Currencies")
	local UIBlur = Lighting:WaitForChild("UIBlur")
	InterfaceTools = require("./InterfaceTools")
	
	Tutorial = require("./Tutorial")
	Prompt = require("./Prompt")
	Team = require("./Team")

	MainInterface = InterfaceTools.GetInterface("Main")
	
	BrainrotInterface = InterfaceTools.GetInterface("Brainrots")
	SeasonPass = InterfaceTools.GetInterface("Season")
	ShopInterface = InterfaceTools.GetInterface("Shop")
	SummonInterface = InterfaceTools.GetInterface("Summon")
	--TeleportInterface = InterfaceTools.GetInterface("Teleports")
	QuestInterface = InterfaceTools.GetInterface("Quests")
	SeasonInterface = InterfaceTools.GetInterface("Season")
	FreeRewardInterface = InterfaceTools.GetInterface("FreeRewards")
	UpgradesInterface = InterfaceTools.GetInterface("Upgrades")
	
	Interface.AnimateUIS()

	Interface.HandleInterfaceExit()

	Interface.HandleBrainrotInterfaceData()

	wait(5)

	Interface.HandleBrainrotInterface()

	Interface.HandleBrainrotInterfaceEvents()


	Interface.HandleFreeRewardsInterface()

	Interface.HandleStageUI()


	local LeftBar = MainInterface.LeftBar

	Interface:Hydrate(UIBlur) { 
		Size = Interface:Spring(Interface:Computed(function(Use)
			return Use(Interface.InInterface) and 24 or 0
		end), 15, .5)
	}

	Interface:Hydrate(Camera) {
		FieldOfView = Interface:Spring(Interface:Computed(function(Use)
			return Use(Interface.InInterface) and 60 or Use(Interface.FieldOfView)
		end), 25, .9)
	}

	--do
	--	Interface:Observer(Interface.InInterface):onChange(function() 
	--		--local State = Fusion.peek(Interface.InInterface)

	--		--if State then	

	--		--else
	--		--	for Index, Button in pairs(MainInterface:GetDescendants()) do
	--		--		if Button:IsA("ImageButton") then
	--		--			local Scale = Button:FindFirstChildOfClass("UIScale")
	--		--			Scale.Scale = 0

	--		--			if Scale then
	--		--				Tween:Create(Scale, TweenInfo.new(0.25 + math.log(Index + 1) / 8, Enum.EasingStyle.Back), {Scale = 1}):Play()
	--		--			end
	--		--		else
	--		--			continue
	--		--		end
	--		--	end
	--		--end
	--	end)
	--end
	
	Interface:Observer(Interface.ShowUpgrades):onChange(function()
		local State = Fusion.peek(Interface.ShowUpgrades)
		Interface.InInterface:set(State)
	end)

	Interface:Observer(Interface.ShowSummon):onChange(function()
		local State = Fusion.peek(Interface.ShowSummon)
		Interface.InInterface:set(State)

		task.spawn(function()
			local UISound = State and Assets.Sounds.UIShow:Clone() or Assets.Sounds.UIHide:Clone()
			UISound.Parent = ShopInterface

			wait()

			UISound:Play()
			UISound.Ended:Wait()
			UISound:Destroy()
		end)

		local Scale = SummonInterface.Main.UIScale
		local TargetScale = State and 1 or 0.5

		Scale.Scale = State and 0 or 1
		Tween:Create(Scale, TweenInfo.new(.5, Enum.EasingStyle.Back), {Scale = TargetScale}):Play()

		local BannerItems = SummonInterface.Main.Body.Inner.Banner

		for Index, Unit in pairs(BannerItems:GetChildren()) do
			if Unit:IsA("Frame") then
				if State == true then
					Unit.UIScale.Scale = 0
					Tween:Create(Unit.UIScale, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, .2 + (Index / 10)), {Scale = TargetScale}):Play()

					--local Desc = Unit.Desc
					--local Rarity = Desc.Rarity
				else
					Unit.UIScale.Scale = 1
					Tween:Create(Unit.UIScale, TweenInfo.new(.3, Enum.EasingStyle.Back), {Scale = TargetScale}):Play()
				end			
			end
		end
	end)

	Interface:Observer(Interface.ShowFreeRewards):onChange(function()
		Interface.InInterface:set(Fusion.peek(Interface.ShowFreeRewards))

		local Scale = FreeRewardInterface.Main.UIScale
		local TargetScale = Fusion.peek(Interface.ShowFreeRewards) and 1 or 0.5

		Tween:Create(Scale, TweenInfo.new(.3, Enum.EasingStyle.Back), {Scale = TargetScale}):Play()
	end)

	Interface:Observer(Interface.ShowStages):onChange(function()
		Interface.InInterface:set(Fusion.peek(Interface.ShowStages))
	end)

	Interface:Observer(Interface.ShowShop):onChange(function()
		local State = Fusion.peek(Interface.ShowShop)

		Interface.InInterface:set(State)

		task.spawn(function()
			local UISound = State and Assets.Sounds.UIShow:Clone() or Assets.Sounds.UIHide:Clone()
			UISound.Parent = ShopInterface
			wait()
			UISound:Play()
			UISound.Ended:Wait()
			UISound:Destroy()
		end)

		local HeaderScale = ShopInterface.Body.Shop.Header.UIScale
		local BodyScale = ShopInterface.Body.Shop.Inner.UIScale


		if State == true then
			HeaderScale.Scale = .5
			BodyScale.Scale = .5
			Tween:Create(HeaderScale, TweenInfo.new(0.5 + math.log(1) / 6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Scale = 1}):Play()
			Tween:Create(BodyScale, TweenInfo.new(0.25 + math.log(2 + 1) / 6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Scale = 1}):Play()
		else
			Tween:Create(HeaderScale, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Scale = 0.5}):Play()
			Tween:Create(BodyScale, TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, 0, false, .1), {Scale = 0.5}):Play()
		end

		--local TargetScale = Fusion.peek(Interface.ShowShop) and 1 or 0.5

		--Tween:Create(Scale, TweenInfo.new(.3, Enum.EasingStyle.Back), {Scale = TargetScale}):Play()
	end)

	Interface:Observer(Interface.ShowQuests):onChange(function()
		Interface.InInterface:set(Fusion.peek(Interface.ShowQuests))
	end)

	Interface:Observer(Interface.ShowBrainrot):onChange(function()
		Interface.InInterface:set(Fusion.peek(Interface.ShowBrainrot))
	end)

	Interface:Observer(Interface.ShowSeason):onChange(function()
		local State = Fusion.peek(Interface.ShowSeason)
		Interface.InInterface:set(State)

		local Scale = SeasonInterface.Main.UIScale
		local TargetScale = State and 1 or 0.5

		Tween:Create(Scale, TweenInfo.new(.5, Enum.EasingStyle.Back), {Scale = TargetScale}):Play()

		local Items = SeasonInterface.Main.Inner.Body

		for Index, Item in pairs(Items:GetChildren()) do
			if Item:IsA("Frame") then
				local Scale = Item.UIScale
				Scale.Scale = State and 0 or 1 
				Tween:Create(Scale, TweenInfo.new((.5/(Index/10)), Enum.EasingStyle.Back), {Scale = State and 1 or .5}):Play()
			end
		end
	end)

	Interface:Hydrate(MainInterface) {
		Enabled = Interface:Computed(function(Use)
			local ShouldHide = Use(Interface.HideInterface)

			if ShouldHide then
				return false
			end

			return not Use(Interface.InInterface)
		end)
	}

	Interface:Hydrate(LeftBar.Brainrots) {
		[Fusion.OnEvent("Activated")] = function()
			if  Fusion.peek(Tutorial.IsActive) and  table.find(Tutorial.ActiveTags, "Brainrots") == nil then
				return
			end
			
			Interface.ShowBrainrot:set(true)
		end,
	}

	Interface:Hydrate(LeftBar.Shop) {
		[Fusion.OnEvent("Activated")] = function()
			if  Fusion.peek(Tutorial.IsActive) and  table.find(Tutorial.ActiveTags, "Shop") == nil then
				return
			end
			
			Interface.ShowShop:set(true)
		end,
	}

	Interface:Hydrate(LeftBar.Quests) {
		[Fusion.OnEvent("Activated")] = function()
			if  Fusion.peek(Tutorial.IsActive) and  table.find(Tutorial.ActiveTags, "Quests") == nil then
				return
			end
			Interface.ShowQuests:set(true)
		end,
	}

	Interface:Hydrate(LeftBar.Pass) {
		[Fusion.OnEvent("Activated")] = function()
			if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "Pass") == nil then
				return
			end
			
			Interface.ShowSeason:set(true)
		end,
	}
	

	Interface:Hydrate(LeftBar.Upgrade) {
		[Fusion.OnEvent("Activated")] = function()
			if  Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "Upgrade") == nil then
				return
			end

			Interface.ShowUpgrades:set(true)
		end,
	}


	Interface:Hydrate(BrainrotInterface) {
		Enabled = Interface.ShowBrainrot
	}

	Interface:Hydrate(QuestInterface) {
		Enabled = Interface.ShowQuests
	}

	Interface:Hydrate(SummonInterface) {
		Enabled = Interface.ShowSummon
	}

	Interface:Hydrate(ShopInterface) {
		Enabled = Interface.ShowShop	
	}

	Interface:Hydrate(FreeRewardInterface) {
		Enabled = Interface.ShowFreeRewards
	}

	Interface:Hydrate(SeasonInterface) {
		Enabled = Interface.ShowSeason
	}

	Interface:Hydrate(UpgradesInterface) {
		Enabled = Interface.ShowUpgrades
	}

	local FreeRewardZone = ZonePlus.new(workspace.Terrain:WaitForChild("Zones").FreeRewards)

	FreeRewardZone.localPlayerEntered:Connect(function(Player)
		if Fusion.peek(Interface.ShowStages) then return end
		if Fusion.peek(Tutorial.IsActive) then return end
		InterfaceTools.CloseAll()
		Interface.ShowFreeRewards:set(true)
	end)

	FreeRewardZone.localPlayerExited:Connect(function(Player)
		Interface.ShowFreeRewards:set(false)
	end)

	Loading.Skip()
end

function Interface.HandleBrainrotInterfaceEvents()

	local Listeners = {
		["TeamLoaded"] = function(Data)
			for Index, Unit in pairs(Data) do
				local UnitName = Unit.Name
				local IsLocked = Unit.IsLocked
				--local Form = 

				Team.Data[Index].UnitName:set(UnitName)
				Team.Data[Index].IsLocked:set(IsLocked)
			end
		end,

		["BrainrotsLoaded"] = function(Rots)
			for RotName, Data in pairs(Rots) do
				local UIData = Interface.Brainrots[RotName]
				print(Data)
				if UIData then
					UIData.IsUnlocked:set(true)
					UIData.Level:set(Data.Level or 1)
					UIData.Form:set(Data.Form or "Base")
				else
					continue
				end
			end
		end,
	}

	Remotes.Inventory.OnClientInvoke = function(EventName, Data)
		if Listeners[EventName] then
			task.spawn(function()
				Listeners[EventName](Data)
			end)
		end
	end
end

function Interface.HandleFreeRewardsInterface()
	local PossibleRewards = Tweaks.FreeRewards


	local Body = FreeRewardInterface.Main.Body

	local Inner = FreeRewardInterface.Main.Inner

	Interface:Hydrate(Inner.Redeem) {
		[Fusion.OnEvent("Activated")] = function()
			Remotes.Inventory:InvokeServer("ClaimFreeRewards")
		end,
	}

	for _, Reward in pairs(PossibleRewards) do
		local Template = InterfaceTools.CreateItemFrame(Reward) {
			Name = HttpService:GenerateGUID(false),
			Parent = Inner.Rewards
		}
	end
end


function Interface.HandleBrainrotInterfaceData()
	--task.spawn(function()
	--local Index = 1
	
	local RarityInfo = {
		Normal={},
		LegendRare={},
		Rare={},
		Special={},
		SuperRare={},
		UberRare={},
	}
	
	for Name, Data in pairs(UnitInfo) do
		if Data.Rarity then
			table.insert(RarityInfo[Data.Rarity], Name)
		else
			continue
		end
	end
	
	for Rarity, Items in pairs(RarityInfo) do
		for Index, NameOfUnit in pairs(Items) do
			local Unit = UnitInfo[NameOfUnit]
			local Template = BrainrotInterface.Main.Body.Template:Clone()
			
			local IsFound = Interface:Value(false)
			
			Interface:Hydrate(Template) {
				Parent = Interface:Computed(function(Use)
					local Filter = Use(Interface.BrainrotFilter)
					return Filter == Rarity and BrainrotInterface.Main.Body or nil
				end),
				LayoutOrder = Interface:Computed(function(Use)
					return Index + (not Use(IsFound) and 1000 or 0)
				end),
				Name = NameOfUnit,
				Visible = Interface:Computed(function(Use)
					return Use(Interface.BrainrotFilter) == Unit.Rarity
				end)
			}
			
			local Scale = Interface:New("UIScale") {
				Parent = Template,
				Scale = Interface:Spring(Interface:Computed(function(Use)
					return Use(Interface.FocusedBrainrot) == Template and 1 or .9	
				end), 35, .5),
			}

			local ViewportFrame = Template.ViewportFrame

			local Form = Interface:Value("Base")

			local function UpdateModel()
				ViewportFrame.WorldModel:ClearAllChildren()

				local Rots = Assets.Rots
				local BrainrotFolder = Rots:WaitForChild(NameOfUnit)
				local FormFolder = BrainrotFolder:FindFirstChild(Fusion.peek(Form))

				if FormFolder == nil then
					FormFolder = BrainrotFolder:WaitForChild("Base")
				end

				local Animations = UnitInfo[NameOfUnit].Animations[Form]

				if Animations == nil then
					Animations = UnitInfo[NameOfUnit].Animations.Base
				end

				local Skin = "Default"
				local SkinVariation = FormFolder:WaitForChild(Skin)

				local Model = SkinVariation:Clone()
				Model.Parent = ViewportFrame.WorldModel
				--Model.Body:PivotTo()
				
				local Original = CFrame.new(-2,-2,-5) * CFrame.Angles(0, math.rad(-50), 0)
				
				RunService.RenderStepped:Connect(function()
					Model.Body:PivotTo(Original * CFrame.Angles(0,-math.rad(math.sin(tick())) * 5, math.rad(math.sin(tick() * Index)) * 5))
				end)

				local Idle = Model:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(Animations.Idle)
				Idle:Play()
			end

			UpdateModel()

			Interface:Observer(Form):onChange(function()
				UpdateModel()
			end)

			local UnitInfoFrame = Template.UnitInfo
			local UnitNameFrame = Template.UnitName

			Interface:Hydrate(UnitNameFrame) {
				Text = Interface:Computed(function(Use)
					local Form = Use(Form)
					return Use(IsFound) and Unit[Form].DisplayName or "???"
				end),
			}

			Interface:Hydrate(UnitInfoFrame) {
				Visible = IsFound
			}	

			local UnitLevelFrame = Template:FindFirstChild("UnitLevel", true)
			local Level = Interface:Value(1)

			local LevelLabel = UnitLevelFrame:FindFirstChild("Level")

			Interface:Hydrate(LevelLabel) {
				Text = Level
			}

			Interface:Hydrate(UnitLevelFrame) {
				Visible = IsFound
			}

			Interface:Hydrate(ViewportFrame) {
				ImageColor3 = Interface:Computed(function(Use)
					return Use(IsFound) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
				end)
			}

			--Interface:Hydrate(Template) {
			--	LayoutOrder = Interface:Computed(function(Use)
			--		local Rarity = Unit.Rarity or "Normal"
			--		local RarityPlacings = {
			--			["Normal"] = 1,
			--			["Rare"] = 10,
			--			["SuperRare"] = 20,
			--			["UberRare"] = 30,
			--			["LegendRare"] = 40,
			--			["Special"] = 50,
			--		}
			--		local ChosenPlacement = RarityPlacings[Rarity] or 1
			--		return Use(IsFound) and ChosenPlacement or ChosenPlacement * 2 
			--	end)
			--}

			local Price = Unit.Cost or 0

			Interface:Hydrate(Template:FindFirstChild("Cost", true)) {
				Text = `${Price}`
			}

			Interface.Brainrots[NameOfUnit] = {
				IsUnlocked = IsFound,
				Form = Form,
				Level = Level,
				--Index= Index,
			}
		end
	end


end

function Interface.HandleBrainrotInterface()
	local BrainrotInterface = InterfaceTools.GetInterface("Brainrots")
	local ShowControlsForUnit = Interface:Value(true)
	local Team = require("./Team")

	local PageLayout = BrainrotInterface.Main.Body.UIPageLayout :: UIPageLayout
	--PageLayout:JumpToIndex(0)
	local Sections = BrainrotInterface.Main.Sections

	for _, Section in pairs(Sections:GetChildren()) do
		if Section:IsA("ImageButton") then
			Interface:Hydrate(Section) {
				[Fusion.OnEvent("Activated")] = function()
					Interface.BrainrotFilter:set(Section.Name)
					--PageLayout:JumpToIndex(0)
					--local FirstUnitOfRarity = 
				end,
			}
		end
	end

	local UnitOptions = BrainrotInterface.Options


	Interface:Hydrate(UnitOptions.Upgrade) {
		[Fusion.OnEvent("Activated")] = function()
			local UnitName = PageLayout.CurrentPage.Name
			local UIData = Interface.Brainrots[UnitName]
			local Level = Fusion.peek(UIData.Level)
			local IsEvolved = Fusion.peek(UIData.Form) == "Evolved"
			local UnitCanEvolve = UnitInfo[UnitName].Evolved ~= nil

			local IsMaxLevel = (UnitCanEvolve) and (Level == Tweaks.MaxUnitLevel + 10) or (Level == Tweaks.MaxUnitLevel)

			if IsMaxLevel then
				Effects:DoEffect("Notification", "Unit is Max Level Already", true)
				return
			end

			local _, Accepted = Prompt.new({
				Desc = (Level == Tweaks.MaxUnitLevel - 1 and UnitCanEvolve) and "Evolve Brainrot?" or "Upgrade Brainrot?",
				XPCost = Tweaks.PricePerLevel(Level),
			}):await()

			if Accepted then
				local IsSucessful = Root.Remotes.Inventory:InvokeServer("UpgradeBrainrot", PageLayout.CurrentPage.Name)

				if IsSucessful then
					Effects:DoEffect("UpgradeEffect", PageLayout.CurrentPage)
				end
			end
		end,
	}

	Interface:Hydrate(UnitOptions.Equip) {
		[Fusion.OnEvent("Activated")] = function()
			Root.Remotes.Inventory:InvokeServer("EquipBrainrot", PageLayout.CurrentPage.Name)
		end,
	}


	Interface:Hydrate(UnitOptions) {
		Visible = ShowControlsForUnit
	}

	local MobileControls = BrainrotInterface.Main.Controls

	local IsMobile = Interface:Computed(function(Use)
		return Use(Interface.IsMobile)
	end)

	Interface:Hydrate(MobileControls) {
		Visible = IsMobile
	}

	Interface:Hydrate(MobileControls.Previous) {
		[Fusion.OnEvent("Activated")] = function()
			PageLayout:Previous()
		end,
	}

	Interface:Hydrate(MobileControls.Next) {
		[Fusion.OnEvent("Activated")] = function()
			PageLayout:Next()
		end,
	}

	PageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		--if PageLayout.CurrentPage.Name ~= "" then return end 
		--local UnitIsLocked = not Fusion.peek(Interface.Brainrots[PageLayout.CurrentPage.Name].IsUnlocked)
		--ShowControlsForUnit:set(not UnitIsLocked)
		Interface.FocusedBrainrot:set(PageLayout.CurrentPage)
	end)

	task.spawn(function()
		local TeamData = Team.Data

		local TeamFrame = BrainrotInterface.Team

		for Index, Data in pairs(TeamData) do
			local SelectedFrame = TeamFrame:FindFirstChild(Index)
			local DataName = Data.Name ~= "" and Data.Name or nil
			local CurrentForm = DataName ~= nil and Fusion.peek(Interface.Brainrots[DataName].Form) or nil

			local Form = Interface:Value(DataName ~= nil and CurrentForm or "Base")

			local function Update()
				local View = SelectedFrame.View
				View.WorldModel:ClearAllChildren()
				local UnitName = Fusion.peek(TeamData[Index].UnitName)
				if UnitName == "" then return end
				local Rots = Assets.Rots
				local BrainrotFolder = Rots:FindFirstChild(UnitName)
				local Form = Fusion.peek(Form)
				local FormFolder = BrainrotFolder:FindFirstChild(Form)

				if not FormFolder then
					FormFolder = Rots:FindFirstChild("Base")
				end

				local Skin = FormFolder:FindFirstChild("Default")

				if Skin then
					Skin = Skin:Clone()
				else
					return
				end

				Skin.Parent = SelectedFrame.View.WorldModel 

				local Original = CFrame.new(-2,-2,-5) * CFrame.Angles(0, math.rad(-50), 0)
				Skin.Body:PivotTo(Original)

				local Animations = UnitInfo[UnitName].Animations[Form]

				local IdleAnimation = Animations ~= nil and Animations.Idle or nil

				local Animator = Skin:WaitForChild("AnimationController").Animator

				if IdleAnimation then
					IdleAnimation = Animator:LoadAnimation(IdleAnimation)
					IdleAnimation:Play()
				end
			end

			Update()

			Interface:Observer(TeamData[Index].UnitName):onChange(function()
				Update()

				local NameOfBrainrot = Fusion.peek(TeamData[Index].UnitName)

				if NameOfBrainrot == "" then

				else
					local Scope = Fusion.scoped(Fusion)
					Scope:Observer(Interface.Brainrots[NameOfBrainrot].Form):onChange(function()
						Form:set(Fusion.peek(Interface.Brainrots[NameOfBrainrot].Form))
						Update()
					end)
				end
			end)

			Interface:Hydrate(SelectedFrame.Locked) {
				Visible = TeamData[Index].IsLocked
			}

			local IsHovering = Interface:Value(false)

			Interface:Hydrate(SelectedFrame:WaitForChild("Remove")) {
				Visible = Interface:Computed(function(Use)
					return Use(IsHovering) and Use(Data.UnitName) ~= ""
				end)
			}

			Interface:Hydrate(SelectedFrame) {
				[Fusion.OnEvent("Activated")] = function()
					local UnitInThisSlot = Fusion.peek(Data.UnitName)

					if UnitInThisSlot ~= "" then
						Remotes.Inventory:InvokeServer("UnequipBrainrotByIndex", Index)
					end
				end,
			}

			Interface:Hydrate(SelectedFrame) {
				[Fusion.OnEvent("MouseEnter")] = function()
					IsHovering:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					IsHovering:set(false)
				end,
			}

			Interface:Hydrate(SelectedFrame.Price) {
				Text = Interface:Computed(function(Use)
					local Exists = UnitInfo[Use(TeamData[Index].UnitName)] 
					return Exists and `${Exists.Cost}` or "" 
				end)
			}

			Interface:Hydrate(SelectedFrame) {
				[Fusion.OnEvent("Activated")] = function()
					local IsLocked = Fusion.peek(TeamData[Index].IsLocked)

					if IsLocked then
						local _, ShouldAttemptPurchase = Prompt.new({
							Desc = "Purchase slot?",
							MoneyCost = Tweaks.PricePerSlot(Index),
							--Option1 = ""
						}):await()

						if ShouldAttemptPurchase then
							Remotes.Inventory:InvokeServer("PurchaseSlot", Index)
						end
					end
				end,
			}
		end
	end)

	task.spawn(function()
		local TeamData = Team.Data

		local TeamFrame = MainInterface.Team

		for Index, Data in pairs(TeamData) do
			local SelectedFrame = TeamFrame:FindFirstChild(Index)
			local DataName = Data.Name ~= "" and Data.Name or nil
			local CurrentForm = DataName ~= nil and Fusion.peek(Interface.Brainrots[DataName].Form) or nil

			local Form = Interface:Value(DataName ~= nil and CurrentForm or "Base")

			local function Update()
				local View = SelectedFrame.View
				View.WorldModel:ClearAllChildren()
				local UnitName = Fusion.peek(TeamData[Index].UnitName)
				if UnitName == "" then return end
				local Rots = Assets.Rots
				local BrainrotFolder = Rots:FindFirstChild(UnitName)
				local Form = Fusion.peek(Form)
				local FormFolder = BrainrotFolder:FindFirstChild(Form)

				if not FormFolder then
					FormFolder = Rots:FindFirstChild("Base")
				end

				local Skin = FormFolder:FindFirstChild("Default")

				if Skin then
					Skin = Skin:Clone()
				else
					return
				end

				Skin.Parent = SelectedFrame.View.WorldModel 

				local Original = CFrame.new(-2,-2,-5) * CFrame.Angles(0, math.rad(-50), 0)
				Skin.Body:PivotTo(Original)

				local Animations = UnitInfo[UnitName].Animations[Form]

				local IdleAnimation = Animations ~= nil and Animations.Idle or nil

				local Animator = Skin:WaitForChild("AnimationController").Animator

				if IdleAnimation then
					IdleAnimation = Animator:LoadAnimation(IdleAnimation)
					IdleAnimation:Play()
				end
			end

			Update()

			Interface:Observer(TeamData[Index].UnitName):onChange(function()
				Update()

				local NameOfBrainrot = Fusion.peek(TeamData[Index].UnitName)

				if NameOfBrainrot == "" then

				else
					local Scope = Fusion.scoped(Fusion)
					Scope:Observer(Interface.Brainrots[NameOfBrainrot].Form):onChange(function()
						Form:set(Fusion.peek(Interface.Brainrots[NameOfBrainrot].Form))
						Update()
					end)
				end
			end)

			Interface:Hydrate(SelectedFrame.Locked) {
				Visible = TeamData[Index].IsLocked
			}

			Interface:Hydrate(SelectedFrame) {
				[Fusion.OnEvent("Activated")] = function()
					local IsLocked = Fusion.peek(TeamData[Index].IsLocked)

					if IsLocked then
						local _, ShouldAttemptPurchase = Prompt.new({
							Desc = "Purchase slot?",
							MoneyCost = Tweaks.PricePerSlot(Index),
							--Option1 = ""
						}):await()

						print(ShouldAttemptPurchase)
						if ShouldAttemptPurchase then
							Remotes.Inventory:InvokeServer("PurchaseSlot", Index)
						end
					end
				end,
			}

			Interface:Hydrate(SelectedFrame.Price) {
				Text = Interface:Computed(function(Use)
					local Exists = UnitInfo[Use(TeamData[Index].UnitName)] 
					return Exists and `${Exists.Cost}` or "" 
				end)
			}
		end
	end)
end

return Interface