local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local Tutorial = Fusion.scoped(Fusion)
local Live = require("./Live")

--Tutorial.CanSpawnUnit = false
Tutorial.IsActive = Tutorial:Value(false)
	
local Players = game:GetService("Players")

function Tutorial.Start()
	Match = require("./Match")
	Tutorial.IsActive:set(true)
	for _, Player in pairs(Players:GetPlayers()) do
		Tutorial.Do(Player)
	end
end

local RunService = game:GetService("RunService")


function Tutorial.Do(Player)
	--wait(1)
	Remotes.Game:InvokeClient(Player, "Disable", "Ability",  true)
	Remotes.Game:InvokeClient(Player, "Disable", "Spawning",  true)
	Remotes.Replicate:FireAllClients("CameraFreeze", true)
	Remotes.Replicate:FireAllClients("Notification", "Tutorial Activated!")
	wait(1)
	Remotes.Replicate:FireAllClients("Dialogue", "NoobPizza_1")
	Match.TimeScale:set(0)

	wait(6)
	
	--wait(3)

	local FirstEnemy = Live.EnemyUnits[1]

	Match.TimeScale:set(0)

	Remotes.Replicate:FireAllClients("CameraScrollTo", FirstEnemy.Model.Body)
	Remotes.Replicate:FireAllClients("CameraZoom", 1)

	wait(1)

	Remotes.Replicate:FireAllClients("Dialogue", "NoobPizza_2")

	wait(8)

	local MyBase = workspace.Map.Bases:WaitForChild("1")

	Remotes.Replicate:FireAllClients("CameraZoom", 0)
	Remotes.Replicate:FireAllClients("CameraScrollTo", MyBase.Body)

	Remotes.Replicate:FireAllClients("Dialogue", "NoobPizza_3")
	
	wait(12)
	
	Remotes.Game:InvokeClient(Player, "Disable", "Spawning",  false)
	Remotes.Replicate:FireAllClients("Notification", "Spawn a brainrot!")
	Remotes.Replicate:FireAllClients("CameraFreeze", false)

	Remotes.Replicate:FireClient(Player, "FocusBrainrotInTeam", 1)

	repeat 
		Remotes.Replicate:FireAllClients("Notification", "Spawn a brainrot!")
		wait(1)
	until #Live.Units > 1

	Match.TimeScale:set(1)

	wait(8)

	Match.TimeScale:set(0)

	local MainInterface = Player.PlayerGui.Main
	local Actions = MainInterface.Actions

	Remotes.Replicate:FireClient(Player, "SpotlightFocus", Actions.Wallet, 5)

	Remotes.Replicate:FireAllClients("Notification", ("You can upgrade your wallet to hold more cash!"))
	
	wait(2)
	
	Match.TimeScale:set(1)
	
	wait(4)
	
	Match.TimeScale:set(0)
	
	Remotes.Replicate:FireClient(Player, "SpotlightFocus", Actions.Ability, 5)

	Remotes.Replicate:FireAllClients("Notification", ("You can also use your base ability"))

	wait(2)
	
	Remotes.Replicate:FireAllClients("Notification", ("it does heavy damage towards mobs and bases!"))
	
	wait(2)
	
	Match.TimeScale:set(1)
	
	Remotes.Game:InvokeClient(Player, "Disable", "Ability",  false)
	
	wait(2)
	Match.TimeScale:set(0)
	
	Remotes.Replicate:FireAllClients("Dialogue", "NoobPizza_4")
	
	wait(8)

	Match.TimeScale:set(1)
end

return Tutorial