local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Prompt = Fusion.scoped(Fusion)

local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local Promise = require(Root.Shared.Packages.Promise)

function Prompt.new(Options)
	return Promise.new(function(Resolve, Reject)
		local PromptGui = script.Prompt:Clone()
		PromptGui.Parent = PlayerGui
		
		local Desc = Options.Desc or "Some Prompt"
		local Option1 = Options.Option1 or "No"
		local Option2 = Options.Option2 or "Yes"
		local GemCost = Options.GemCost
		local XPCost = Options.XPCost
		local MoneyCost = Options.MoneyCost
		
		if GemCost then
			PromptGui.Inner.Gems.Visible = true
			PromptGui.Inner.Gems.Number.Text = GemCost
		else
			PromptGui.Inner.Gems.Visible = false
		end
		
		if MoneyCost  then
			PromptGui.Inner.Money.Visible = true
			PromptGui.Inner.Money.Number.Text = MoneyCost
		else
			PromptGui.Inner.Money.Visible = false
		end
		
		if XPCost then
			PromptGui.Inner.XP.Visible = true
			PromptGui.Inner.XP.Number.Text = XPCost
		else
			PromptGui.Inner.XP.Visible = false
		end
		
		PromptGui.Inner.Desc.Text = Desc
		
		local Button1 = PromptGui.Inner.Options.Option1
		local Button2 = PromptGui.Inner.Options.Option2	
		
		Button1.TextLabel.Text = Option1
		Button2.TextLabel.Text = Option2
		
		Prompt:Hydrate(Button1) {
			[Fusion.OnEvent("Activated")] = function()
				Resolve(false)
				PromptGui:Destroy()
			end,
		}
		
		Prompt:Hydrate(Button2) {
			[Fusion.OnEvent("Activated")] = function()
				Resolve(true)
				PromptGui:Destroy()
			end,
		}
	end) 
end

return Prompt