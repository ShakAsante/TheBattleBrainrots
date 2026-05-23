local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local InterfaceTools = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Fusion = require(Root.Shared.Packages.Fusion)
local Interface = require("./Interface")
local RunService = game:GetService("RunService")
local Trove = require(Root.Shared.Packages.Trove)
local Images = require(Assets.Images)

function InterfaceTools.GetInterface(Name)
	return LocalPlayer.PlayerGui:WaitForChild(Name)
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
	
	return Interface:Hydrate(Template)
end

function InterfaceTools.CreateGradient(Name)
	local Interface = Fusion.scoped(Fusion)
	
	local Gradients = {}
	Gradients.Rainbow = function()
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
	end
		
	Gradients.Normal = function()
		return Interface:New("UIGradient")
	end
	
	Gradients.LegendRare = function()
		return Gradients.Rainbow()
	end
	
	return Gradients[Name] and Gradients[Name]() or Gradients["Normal"]()
end

function InterfaceTools.AnimateButton(button: ImageButton)
	local Button = Fusion.scoped(Fusion)
	local Sound = Assets.Sounds.UIClick:Clone()

	Button:Hydrate(Sound) {
		--Parent = button
	}

	local Scale = Button:New("UIScale") {
		Parent = button
	}

	local Size = Button:Value(1)

	Button:Hydrate(Scale) { 
		Scale = Button:Spring(Size, 35,  1),
	}

	Button:Hydrate(button) {
		[Fusion.OnEvent("MouseEnter")] = function()
			Size:set(1.05)
		end,

		[Fusion.OnEvent("MouseButton1Down")] = function()
			Size:set(.9)
			Sound:Play()
		end,
		[Fusion.OnEvent("MouseButton1Up")] = function()
			Size:set(1)
		end,

		[Fusion.OnEvent("MouseLeave")] = function()
			Size:set(1)
		end,
	}
end

function InterfaceTools.CloseAll()
	Interface.ShowShop:set(false)
	Interface.ShowBrainrot:set(false)
	Interface.ShowSummon:set(false)
	Interface.ShowSeason:set(false)
end


function InterfaceTools.AnimateInterface(Interface: ScreenGui)
	for _, Button in pairs(Interface:GetDescendants()) do
		if Button:IsA("ImageButton") or Button:IsA("TextButton") then
			InterfaceTools.AnimateButton(Button)
		end
	end
	
	wait(1)
	
	Interface.DescendantAdded:Connect(function(Button)
		if Button:IsA("ImageButton") or Button:IsA("TextButton") then
			InterfaceTools.AnimateButton(Button)
		end
	end)
end

return InterfaceTools