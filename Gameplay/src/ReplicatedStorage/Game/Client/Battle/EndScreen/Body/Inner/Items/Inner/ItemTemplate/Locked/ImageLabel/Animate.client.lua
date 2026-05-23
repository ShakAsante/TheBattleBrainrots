local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local InterfaceTools = require(Root.Client.InterfaceTools)

local Gradient = InterfaceTools.CreateGradient("Rainbow") {
	Parent = script.Parent,
	Rotation = 45
}