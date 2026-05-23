local OriginalPosition = script.Parent.Position
local TargetPosition= OriginalPosition + UDim2.fromOffset(0, -10)
local TweenSerivce = game:GetService("TweenService")
local Tween = TweenSerivce:Create(script.Parent, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = TargetPosition})
Tween:Play()

local RunService = game:GetService("RunService")

local StartRotation = script.Parent.Rotation
local Offset = math.random() * 5

RunService.RenderStepped:Connect(function(Delta)
	script.Parent.Rotation = StartRotation + (math.sin(tick() * Offset / 15) * 30)
end)