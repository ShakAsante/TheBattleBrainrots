local Gifting = {}
Gifting.Targets = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root.Remotes

local Players = game:GetService("Players")

function Gifting.GameStart()
	Players.PlayerAdded:Connect(function(Player)
		Gifting.Targets[Player] = Player
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		Gifting.Targets[Player] = nil
	end)
	
	local Listeners = {
		["Set"] = function(Player, Target)
			Gifting.Targets[Player] = Target
			return true
		end,
	}

	Remotes.Gift.OnServerInvoke = function(Player, Event, ...)
		if Listeners[Event] then
			return Listeners[Event](Player, ...) 
		end
	end
end

function Gifting.GetGiftTarget(Player)
	return Gifting.Targets[Player]
end

function Gifting.SetGiftTarget(Player, TargetPlayer)
	Gifting.Targets[Player] = TargetPlayer
end

return Gifting