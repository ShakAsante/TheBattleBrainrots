local Tutorial = {}
local InventoryTools = require("./InventoryTools")
local Players = game:GetService("Players")
local Remotes  = game:GetService("ReplicatedStorage").Game.Remotes
local RunService = game:GetService("RunService")

function Tutorial.GiveDefaults(Player)
	InventoryTools.UnlockBrainrotSlot(Player, 1)
	InventoryTools.UnlockBrainrotSlot(Player, 2)
	InventoryTools.UnlockBrainrotSlot(Player, 3)

	InventoryTools.UnlockBrainrot(Player, "TungTungSahur")
	InventoryTools.UnlockBrainrot(Player, "TiTiTiSahur")
	InventoryTools.UnlockBrainrot(Player, "GangsterFootera")
	InventoryTools.UpdateToBrainrotsClient(Player)
	InventoryTools.UpdateTeamToClient(Player)
end

function Tutorial.GameStart()
	Data = require("./Data")
	
	local Listeners = {
		["Start"] = function(Player)
			local _, Profile = Data.GetProfile(Player):await()
			Tutorial.GiveDefaults(Player)
			
			if RunService:IsStudio() then
				return
			end
			
			if Profile.Data.Tutorial.IsLobbyCompleted == false then
				Remotes.Tutorial:FireClient(Player, "TutorialStart")	
			end
		end,
		
		["End"] = function(Player)
			local _, Profile = Data.GetProfile(Player):await()
			Profile.Data.Tutorial.IsLobbyCompleted = true
		end,
		
		["Sync"] = function(Player, ...)
			Remotes.Tutorial:FireClient(Player, ...)
		end,
	}
	
	Remotes.Tutorial.OnServerEvent:Connect(function(Player, Event, ...)
		if Listeners[Event] then
			Listeners[Event](Player, ...)
		end
	end)
	
	--Players.PlayerAdded:Connect(function(Player)
		--Tutorial.Start(Player)
		--Player.CharacterAdded:Wait()
	--end)
end

return Tutorial