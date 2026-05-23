local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Fusion = require(Root.Shared.Packages.Fusion)
local Team = Fusion.scoped(Fusion)
local Remotes = Root.Remotes
local Interface = require("./Interface")
Team.Data = {}

local Tweaks = require(Root.Tweaks)

function Team.GameStart()
	for i=1, Tweaks.TeamSize do
		local UnitName = Team:Value("")
		local IsLocked = Team:Value(true)

		Team.Data[i] = {
			UnitName = UnitName,
			IsLocked = IsLocked,
		}
	end	
	
end

function Team.GetUnitName(Index)
	return Fusion.peek(Team.Data[Index].UnitName)
end

function Team.GetIsLocked(Index)
	return Fusion.peek(Team.Data[Index].IsLocked)
end

function Team.GetEquippedLength ()
	local Length = 0
	for i=1, Tweaks.TeamSize do
		if Team.GetUnitName(i) ~= "" and Team.GetIsLocked(i) == false then
			Length += 1
		end
	end
	return Length
end

return Team