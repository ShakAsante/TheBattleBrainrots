local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Tutorial = Fusion:scoped()
local Remotes = Root.Remotes

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

Tutorial.IsActive = Tutorial:Value(false)
Tutorial.ActiveTags = {}

local Dialogue = require("./Dialogue")

local RunService = game:GetService("RunService")

function Tutorial.GameStart()
	Loading = require("./Loading")
	Prompt = require("./Prompt")
	InterfaceTools = require("./InterfaceTools")
	
	Effects = require("./Effects")
	Stages = require("./Stage")
	
	local UISpotlight = require("./UISpotlight")
	local MainInterface = InterfaceTools.GetInterface("Main")
	local BrainrotInterface = InterfaceTools.GetInterface("Brainrots")
	local LeftBar = MainInterface.LeftBar
	local QuestsInterface = InterfaceTools.GetInterface("Quests")
	local SeasonInterface = InterfaceTools.GetInterface("Season")
	local UpgradeInterface = InterfaceTools.GetInterface("Upgrades")
	local StageInterface = InterfaceTools.GetInterface("Stages")
	
	local Listeners = {
		["TutorialStart"] = function()
			--local _, Accepted = Prompt.new({
			--	Desc =  "Would you like to do the Tutorial?",
			--}):await()

			--if Accepted then
			Tutorial.IsActive:set(true)
			Dialogue.Start("NoobPizza_Tutorial")
			wait(6)
			Remotes.Tutorial:FireServer("Sync", "TutorialBrainrots")
			--end
			

			--Remotes.Tutorial:FireServer("Skip")
		end,
		
		["TutorialEnd"] = function()
			Stages.Close()
			Tutorial.IsActive:set(false)
			Dialogue.Start("NoobPizza_TutorialEnd")
		end,
		
		--["DialogueStart"] = function(Name)
		--	Dialogue.Start(Name)
		--end,
		
		["TutorialBrainrots"] = function()
			Tutorial.ActiveTags = {"Brainrots"}
			Effects:DoEffect("Notification", "Open the brainrots menu");
			local BrainrotButton = LeftBar.Brainrots
			UISpotlight.Focus(BrainrotButton)
			BrainrotButton.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "These are your brainrots");
			wait(1)
			Effects:DoEffect("Notification", "They are upgradable");
			wait(1)
			Effects:DoEffect("Notification", "Some have evolutions at level 10+");
			wait(1)
			Effects:DoEffect("Notification", "Close the brainrots menu");
			local ExitButton = BrainrotInterface:FindFirstChild("Exit", true)
			UISpotlight.Focus(ExitButton)

			Tutorial.ActiveTags = {"ExitBrainrots"}
			ExitButton.Activated:Wait()
			UISpotlight.FocusOff()
			
			Remotes.Tutorial:FireServer("Sync", "TutorialQuests")
		end,
		
		["TutorialStages"] = function()
			Tutorial.ActiveTags = {"Stages"}
			Effects:DoEffect("Notification", "Open the stages");
			local Button = MainInterface.Team.Back.Play
			UISpotlight.Focus(Button)
			Button.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "This is the stages menu");
			wait(1)
			Effects:DoEffect("Notification", "There are different types of stages");
			wait(1)
			Effects:DoEffect("Notification", "Story, Event & Seasonal");
			wait(1)
			Effects:DoEffect("Notification", "Select, Story mode");
			local StoryModeButton = StageInterface.ContentSelect.Content:WaitForChild("Story")
			UISpotlight.Focus(StoryModeButton)
			Tutorial.ActiveTags = {"Story"}
			StoryModeButton.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "This is a chapter")
			wait(1)
			Effects:DoEffect("Notification", "At the top you can change chapters");
			wait(1)
			Effects:DoEffect("Notification", "You can unlock new stages & chapters");
			wait(2)
			Effects:DoEffect("Notification", "Each stage has their own difficulty, from 1 - 5");
			wait(2)
			Effects:DoEffect("Notification", "They also have their own rewards, from xp to brairots")
			wait(2)
			
			Remotes.Tutorial:FireServer("End")
			Remotes.Tutorial:FireServer("Sync", "TutorialEnd")
		end,

		["TutorialSeason"] = function()
			Tutorial.ActiveTags = {"Pass"}
			Effects:DoEffect("Notification", "Open the season menu");
			local Button = LeftBar.Pass
			UISpotlight.Focus(Button)
			Button.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "This is the seasonal pass");
			wait(1)
			Effects:DoEffect("Notification", "They give rewards");
			wait(1)
			Effects:DoEffect("Notification", "Different seasons will have different rewards");
			wait(1)
			Effects:DoEffect("Notification", "Theres a new season every month");
			wait(1)
			Effects:DoEffect("Notification", "Close the seasons menu");
			local ExitButton = SeasonInterface:FindFirstChild("Exit", true)

			UISpotlight.Focus(ExitButton)

			Tutorial.ActiveTags = {"ExitPass"}
			ExitButton.Activated:Wait()
			UISpotlight.FocusOff()

			Remotes.Tutorial:FireServer("Sync", "TutorialUpgrade")
		end,
		
		["TutorialUpgrade"] = function()
			Tutorial.ActiveTags = {"Upgrade"}
			Effects:DoEffect("Notification", "Open the upgrade menu");
			local Button = LeftBar.Upgrade
			UISpotlight.Focus(Button)
			Button.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "This is the upgrades menu");
			wait(1)
			Effects:DoEffect("Notification", "You can upgrade, your base");
			wait(1)
			Effects:DoEffect("Notification", "You can also upgrade your cannon, xp gain, etc...");
			wait(1)
			Effects:DoEffect("Notification", "Close the upgrades menu");

			local ExitButton = UpgradeInterface:FindFirstChild("Exit", true)

			Tutorial.ActiveTags = {"ExitUpgrades"}
			UISpotlight.Focus(ExitButton)
			ExitButton.Activated:Wait()
			UISpotlight.FocusOff()

			Remotes.Tutorial:FireServer("Sync", "TutorialStages")
		end,
				
		["TutorialQuests"] = function()
			Tutorial.ActiveTags = {"Quests"}
			Effects:DoEffect("Notification", "Open the quests menu");
			local Button = LeftBar.Quests
			UISpotlight.Focus(Button)
			Button.Activated:Wait()
			UISpotlight.FocusOff()
			wait(1)
			Effects:DoEffect("Notification", "These are your quests");
			wait(1)
			Effects:DoEffect("Notification", "They give gems...");
			wait(1)
			Effects:DoEffect("Notification", "Daily & Seasonal Quests Reset Daily!");
			wait(1)
			Effects:DoEffect("Notification", "Seasonal Quests give Season XP");
			wait(1)
			Effects:DoEffect("Notification", "Close the quests menu");
			local ExitButton = QuestsInterface:FindFirstChild("Exit", true)
		
			UISpotlight.Focus(ExitButton)

			ExitButton.Activated:Wait()
			UISpotlight.FocusOff()

			Tutorial.ActiveTags = {"ExitQuests"}
			Remotes.Tutorial:FireServer("Sync", "TutorialSeason")
		end,
	}
	
	Remotes.Tutorial.OnClientEvent:Connect(function(Action, ...)
		if Listeners[Action] then
			Listeners[Action](...)
		end
	end)
	
	Loading.Await():await()
	Tutorial.Start()
end

function Tutorial.Start()
	Remotes.Tutorial:FireServer("Start")
end

return Tutorial