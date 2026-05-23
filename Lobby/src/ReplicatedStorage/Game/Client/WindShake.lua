local Shake = {}

local Root = game:GetService("ReplicatedStorage"):WaitForChild("Game")

function Shake.GameStart()
	local WindShake = require(Root.Shared.Packages.WindShake)
	WindShake:Init()
end

return Shake