local RunService = game:GetService("RunService")
local Image = script.Parent
RunService.RenderStepped:Connect(function(Delta)
	Image.Rotation += 15 * Delta
end)