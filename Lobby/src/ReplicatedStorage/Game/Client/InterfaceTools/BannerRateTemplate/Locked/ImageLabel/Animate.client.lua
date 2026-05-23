local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local InterfaceTools = require(Root.Client.InterfaceTools)

local Gradient = InterfaceTools.CreateGradient("Rainbow") {
	Parent = script.Parent,
	Rotation = 45
}