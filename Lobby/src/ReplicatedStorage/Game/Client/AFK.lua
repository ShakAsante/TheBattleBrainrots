local AFK = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root.Assets
local Remotes = Root.Remotes

local ZonePlus = require(Root.Shared.Packages.Zone)
local TeleportService = game:GetService("TeleportService")
local Teleports = require(Assets.Teleports)

function AFK.GameStart()
	local TeleportBoxes = workspace.Terrain:WaitForChild("Zones")
	local Zone = ZonePlus.new(TeleportBoxes:WaitForChild("AFK"))
	
	Zone.localPlayerEntered:Connect(function()
		TeleportService:Teleport(Teleports.AFK, game.Players.LocalPlayer, nil, Assets.TeleportGui)
	end)
end

return AFK