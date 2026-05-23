local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)

local Interface = Fusion.scoped(Fusion)
Interface.Interfaces = {}

local StarterGui = game:GetService("StarterGui")
local Player = game:GetService("Players").LocalPlayer
local PGui = Player.PlayerGui
local Prompt = require("./Prompt")
local Effects = require("./Effects")
local Tweaks = require(Root.Tweaks)
	
function Interface.AnimateUIS()
	for _, Interface in pairs(Player.PlayerGui:GetChildren()) do
		if Interface:IsA("ScreenGui") then
			InterfaceTools.AnimateInterface(Interface)
		end
	end
	
	wait(1)
	
	Player.PlayerGui.ChildAdded:Connect(function(Gui)
		if Gui:IsA("ScreenGui") then
			InterfaceTools.AnimateInterface(Gui)
		end
	end)
end

function Interface.GameStart()
	InterfaceTools = require("./InterfaceTools")
	
	Interface.WalletLevel = Interface:Value(1)
	
	local MainInterface = InterfaceTools.GetInterface("Main")

	local UpgradeButton = MainInterface.Actions.Wallet
	
	Interface:Observer(Interface.WalletLevel):onChange(function()
		Effects:DoEffect("UpgradeEffect", UpgradeButton)
	end)
	
	Interface:Hydrate(UpgradeButton) {
		[Fusion.OnEvent("Activated")] = function() 
			local _, Sucessful = Prompt.new({
				Desc = "Upgrade Wallet?",
				MoneyCost = Tweaks.WalletCost(Fusion.peek(Interface.WalletLevel)),
				Option1 = "CANCEL",
				Option2 = "BUY",
			}):await()
			
			if Sucessful then
				Interface.WalletLevel:set(Remotes.UpgradeWallet:InvokeServer())
			end
		end,
	}
	

	Interface.AnimateUIS()
end

return Interface