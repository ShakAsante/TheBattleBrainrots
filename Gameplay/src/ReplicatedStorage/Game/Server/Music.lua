local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local Music = Fusion.scoped(Fusion)
Music.CurrentSong = Music:Value(nil)

function Music.GameStart()
	
end

function Music:Set(Song: Sound)
	Music:Stop()
	Music.CurrentSong:set(Song)
end

function Music:Play()
	local CurrentSong = Fusion.peek(Music.CurrentSong)
	if CurrentSong then
		CurrentSong:Play()
	end
end

function Music:Stop()
	local CurrentSong = Fusion.peek(Music.CurrentSong)
	if CurrentSong then
		CurrentSong:Stop()
	end
end

return Music