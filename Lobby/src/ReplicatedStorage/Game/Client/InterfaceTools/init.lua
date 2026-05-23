
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Assets = Root:WaitForChild("Assets")
local Interface = require("./Interface")
local RunService = game:GetService("RunService")
local Trove = require(Root.Shared.Packages.Trove)
local Images = require(Assets.Images)
local UnitInfo = require(Assets.UnitInfo)
local InterfaceTools = {}

local SoundService = game:GetService("SoundService")


local Collection = game:GetService("CollectionService")

function InterfaceTools.GetInterface(Name, Timeout)
	return LocalPlayer.PlayerGui:WaitForChild(Name, Timeout)
end

function InterfaceTools.CreateItemFrame(ItemInfo: {Type: string, Data: {}})
	local Interface = Fusion.scoped(Fusion)
	local Template = script.ItemTemplate:Clone()
	
	local ItemType = ItemInfo.Type
	local Data = ItemInfo.Data
	
	local Image = Images[ItemType] or ""
	
	Interface:Hydrate(Template.Item) {
		Image = Image
	}
	
	Interface:Hydrate(Template.Title) {
		Text = ItemType
	}
	
	Interface:Hydrate(Template.Amount) {
		Text = Data.Amount and `x{Data.Amount}` or 0,
		Visible = Data.Amount ~= 0 or Data.Amount ~= nil
	}
	
	local TypeHandlers = {
		["Default"] = function(ItemTemplate, Type, Data)
			ItemTemplate.Item.Image = Images[Type] ~= nil and Images[Type] or ""
		end,

		["Brainrot"] = function(ItemTemplate, Type, Data)
			local Viewport = ItemTemplate.ViewportFrame
			--print(Data.Name)
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
			Body:PivotTo(CFrame.new(0,-2,-7) * CFrame.Angles(0, math.rad(-70), 0))
		end,
	}
	
	local ItemHandler = TypeHandlers[ItemType] ~= nil and TypeHandlers[ItemType] or TypeHandlers["Default"]
	ItemHandler(Template, ItemType, Data)

	return Interface:Hydrate(Template)
end

function InterfaceTools.CreateBannerItem(ItemInfo: {Type: string, Data: {}})
	local ItemType = ItemInfo.Type
	local Data = ItemInfo.Data

	local Image = Images[ItemType] or ""
	
	local TypeHandlers = {
		["Default"] = function(ItemTemplate, Type, Data)
			ItemTemplate.Item.Image = Images[Type] ~= nil and Images[Type] or ""
		end,

		["Brainrot"] = function(ItemTemplate, Type, Data)
			local Viewport = ItemTemplate.ViewportFrame
			--print(Data.Name)
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
			Body:PivotTo(CFrame.new(0,-2,-7) * CFrame.Angles(0, math.rad(-70), 0))
		end,
	}

	local ItemHandler = TypeHandlers[ItemType] ~= nil and TypeHandlers[ItemType] or TypeHandlers["Default"]
	--ItemHandler(Template, ItemType, Data)
end

function InterfaceTools.CreateGradient(Name)
	local Interface = Fusion.scoped(Fusion)
	
	local Gradients = {
		Rainbow = function()
			local Gradient = Interface:New("UIGradient") {}
			--local Cleanup = Trove.new()
			
			local  Saturation, Value = 1, 1
			
			local NumOfKeypoints = 7
			local Spread = 0.65
			
			RunService.RenderStepped:Connect(function(dt)
				local currentHue = (tick() * 0.1) % 1

				local keypointsArray = {}

				if NumOfKeypoints < 2 then
					local color = Color3.fromHSV(currentHue, Saturation, Value)
					table.insert(keypointsArray, ColorSequenceKeypoint.new(0, color))
					table.insert(keypointsArray, ColorSequenceKeypoint.new(1, color))
				else
					for i = 0, NumOfKeypoints - 1 do
						local fraction = i / (NumOfKeypoints - 1)

						-- shift each keypoint to create the seamless rolling effect
						local hue = (currentHue + fraction * Spread) % 1
						local color = Color3.fromHSV(hue, Saturation, Value)

						table.insert(keypointsArray, ColorSequenceKeypoint.new(fraction, color))
					end
				end

				Gradient.Color = ColorSequence.new(keypointsArray)
			end)
			
			return Interface:Hydrate(Gradient)
		end,
		
		LegendRare = function()
			local Gradient = script.Gradients.LegendRare:Clone()
			
			local RunService = game:GetService("RunService")
			
			RunService.RenderStepped:Connect(function()
				Gradient.Offset = Vector2.new(-.3 + (math.sin(tick()) * .6))
			end)
			
			return Interface:Hydrate(Gradient)
		end,
		
		Normal = function()
			return Interface:Hydrate(script.Gradients.Normal:Clone())
		end,

		Special = function()
			return Interface:Hydrate(script.Gradients.Special:Clone())
		end,	

		Rare = function()
			return Interface:Hydrate(script.Gradients.Rare:Clone())
		end,

		SuperRare = function()
			return Interface:Hydrate(script.Gradients.SuperRare:Clone())
		end,
		
		UberRare = function()
			return Interface:Hydrate(script.Gradients.UberRare:Clone())
		end,
	}
	
	local HasGradient = Gradients[Name]
	
	if HasGradient then
		return HasGradient()
	else
		return Gradients["Normal"]()
	end
end

--function InterfaceTools.AnimateButton(button: ImageButton | TextButton)
--	local AlreadyIsAnimated = Collection:HasTag(button, "Animated")
--	if AlreadyIsAnimated then
--		return
--	end
--	Collection:AddTag(button, "Animated")
	
--	local Button = Fusion.scoped(Fusion)
--	local ClickSound = Assets.Sounds.UIClick:Clone()
--	local HoverSound = Assets.Sounds.UIHover:Clone()

--	Button:Hydrate(ClickSound) {
--		Parent = button
--	}

--	Button:Hydrate(HoverSound) {
--		Parent = button
--	}

--	local Scale = Button:New("UIScale") {
--		Parent = button
--	}

--	local Size = Button:Value(1)

--	Button:Hydrate(Scale) { 
--		Scale = Button:Spring(Size, 25,  .5),
--	}

--	Button:Hydrate(button) {
--		[Fusion.OnEvent("MouseEnter")] = function()
--			Size:set(.9)
--			HoverSound:Play()
--		end,

--		[Fusion.OnEvent("MouseButton1Down")] = function()
--			Size:set(.8)
--			ClickSound:Play()
--		end,
--		[Fusion.OnEvent("MouseButton1Up")] = function()
--			Size:set(1)
--		end,

--		[Fusion.OnEvent("MouseLeave")] = function()
--			Size:set(1)
--		end,
--	}
--end

function InterfaceTools.CloseAll()
	Interface.ShowShop:set(false)
	Interface.ShowBrainrot:set(false)
	Interface.ShowSummon:set(false)
	Interface.ShowSeason:set(false)
	Interface.ShowUpgrades:set(false)
end


--function InterfaceTools.AnimateInterface(Interface: ScreenGui)
--	Interface.DescendantAdded:Connect(function(Button)
--		if Button:IsA("ImageButton") or Button:IsA("TextButton") then
--			InterfaceTools.AnimateButton(Button)
--		end
--	end)
	
--	for _, Button in pairs(Interface:GetDescendants()) do
--		if Button:IsA("ImageButton") or Button:IsA("TextButton") then
--			InterfaceTools.AnimateButton(Button)
--		end
--	end
--end


function InterfaceTools.AnimateInterfaces()
	local Interfaces = LocalPlayer.PlayerGui:GetChildren()
	for _, Interface in pairs(Interfaces) do
		if Interface:IsA("ScreenGui") then
			InterfaceTools.AnimateButtons(Interface)
		end
	end

	LocalPlayer.PlayerGui.ChildAdded:Connect(function(Interface)
		if Interface:IsA("ScreenGui") then
			InterfaceTools.AnimateButtons(Interface)
		end
	end)
end

function InterfaceTools.AnimateButtons(UI: ScreenGui)
	local Descendants = UI:GetDescendants()


	local function HandleButton(Descendant)	
		--local ClickSound = Root.Assets.Sounds.UIClick:Clone()
		--ClickSound.Parent = Descendant
		--local HoverSound = Root.Assets.Sounds.UIHover:Clone()
		--HoverSound.Parent = Descendant
		
		local ButtonScope = Fusion:scoped()

		local Scale = ButtonScope:Value(1)

		local UIScale = ButtonScope:New "UIScale" {
			Parent = Descendant,
			Scale = ButtonScope:Spring(Scale, 25, .5)
		}

		ButtonScope:Hydrate(Descendant)
		{
			[Fusion.OnEvent "MouseButton1Down"] = function()
				Scale:set(0.8)
			end,
			[Fusion.OnEvent "Activated"] = function()
				SoundService:PlayLocalSound(Assets.Sounds.UIClick)
			end,
			[Fusion.OnEvent "MouseButton1Up"] = function()
				Scale:set(1)
			end,
			[Fusion.OnEvent "MouseEnter"] = function()
				Scale:set(.9)
				SoundService:PlayLocalSound(Assets.Sounds.UIHover)
			end,
			[Fusion.OnEvent "MouseLeave"] = function()
				Scale:set(1)
			end,
		}
	end

	for _, Descendant in pairs(Descendants) do
		if Descendant:IsA("TextButton") or Descendant:IsA("ImageButton") then
			HandleButton(Descendant)
		end
	end

	UI.DescendantAdded:Connect(function(Descendant)
		if Descendant:IsA("TextButton") or Descendant:IsA("ImageButton") then
			HandleButton(Descendant)
		end
	end)
end

return InterfaceTools