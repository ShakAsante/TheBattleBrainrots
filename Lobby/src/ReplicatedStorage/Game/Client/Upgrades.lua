local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Upgrades = Fusion.scoped(Fusion)
local Assets = Root:WaitForChild("Assets")
local UpgradeList = require(Assets.Upgrades)

local Remotes = Root.Remotes
local Effects = require("./Effects")

Upgrades.Focused = Upgrades:Value(false)

Upgrades.Data = {}

function Upgrades.GameStart()
	local InterfaceTools = require("./InterfaceTools")
	local Prompt = require("./Prompt")
	local UpgradeInterface = InterfaceTools.GetInterface("Upgrades")
	
	local Stages =  UpgradeInterface.Main.Stages
	local UIPage = Stages.UIPageLayout
	
	UIPage:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		Upgrades.Focused:set(UIPage.CurrentPage)
	end)
	
	for UpgradeName, UpgradeData in pairs(UpgradeList) do
		Upgrades.Data[UpgradeName] = {
			Level = Upgrades:Value(1),
		}
		
		local UpgradeTemplate = Stages.Template:Clone()
		
		Upgrades:Hydrate(UpgradeTemplate) {
			Size = Upgrades:Spring(Upgrades:Computed(function(Use)
				return Use(Upgrades.Focused) == UpgradeTemplate and UDim2.fromScale(1, 0.3) or UDim2.fromScale(1, 0.2)
			end), 25, .5)
		}
		
		Upgrades:Hydrate(UpgradeTemplate) {
			Name = UpgradeName,
			Parent = UpgradeInterface.Main.Stages
		}
		
		Upgrades:Hydrate(UpgradeTemplate.Inner.Title) {
			Text = Upgrades:Computed(function(Use)
				local IsMaxLevel = Use(Upgrades.Data[UpgradeName].Level) >= #UpgradeData.Costs
				return `{UpgradeData.Name} (Lv. {IsMaxLevel and "MAX" or Use(Upgrades.Data[UpgradeName].Level)})`
			end)
		}
		
		local Actions = UpgradeTemplate.Inner.Actions
		local Back = UpgradeTemplate.Back
		
		local IconExists = Back.Icon:FindFirstChild(UpgradeData.Icon)
		
		if IconExists then
			IconExists.Visible = true
		end
		
		Upgrades:Hydrate(Actions) {
			Visible = true
		}
		
		local CostLabel = Actions.Upgrade.Inner.Body.Cost
		
		Upgrades:Hydrate(CostLabel) {
			Text = Upgrades:Computed(function(Use)
				return `Cost: {Use(UpgradeData.Costs[Use(Upgrades.Data[UpgradeName].Level)])}`
			end)
		}
		
		Upgrades:Hydrate(Actions.Upgrade) {
			Visible = Upgrades:Computed(function(Use)
				return Use(Upgrades.Data[UpgradeName].Level) < #UpgradeData.Costs
			end),
			
			[Fusion.OnEvent("Activated")] = function()
				local _, Success = Prompt.new({
					Desc = "Purchase Upgrade?",
					XPCost = UpgradeData.Costs[Fusion.peek(Upgrades.Data[UpgradeName].Level)],
				}):await()
				
				if Success then
					local Success = Remotes.Upgrade:InvokeServer("Upgrade", UpgradeName)
					
					if Success then
						Effects:DoEffect("UpgradeEffect", UpgradeTemplate)
						Upgrades.Data[UpgradeName].Level:set(Fusion.peek(Upgrades.Data[UpgradeName].Level) + 1)
					end
				end
			end,
		}
		
		UpgradeTemplate.Inner.Desc.Text = UpgradeData.Desc
		UpgradeTemplate.Visible = true
	end
	
	local Listeners= {
		["Loaded"] = function(UpgradeData)
			for Upgrade, Value in pairs(UpgradeData) do
				Upgrades.Data[Upgrade].Level:set(Value)
			end
		end,
	}
	
	Remotes.Upgrade.OnClientInvoke = function(Listener,...)
		if Listeners[Listener] then
			Listeners[Listener](...)
		end
	end
end

return Upgrades