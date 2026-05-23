local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Shake = {}

function Shake.GameStart()
	local WindShake = require(Root.Shared.Packages.WindShake)
	WindShake:Init()
end

return Shake