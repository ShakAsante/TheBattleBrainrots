local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local UISpotlight = Fusion.scoped(Fusion)

UISpotlight.Visible = UISpotlight:Value(false)
UISpotlight.Position = UISpotlight:Value(UDim2.new())
UISpotlight.Size = UISpotlight:Value(UDim2.new())

function UISpotlight.Focus(Object: Frame, Duration)
	UISpotlight.Visible:set(true)
	UISpotlight.Position:set(UDim2.fromOffset(Object.AbsolutePosition.X + (Object.AbsoluteSize.X / 2), Object.AbsolutePosition.Y + (Object.AbsoluteSize.Y / 2) ))
	UISpotlight.Size:set(UDim2.fromOffset(Object.AbsoluteSize.X,Object.AbsoluteSize.Y) + UDim2.fromOffset(20, 20))
	wait(Duration)
	UISpotlight.Visible:set(false)
end

function UISpotlight.GameStart()
	local Gui = script.Spotlight:Clone()
	Gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

	UISpotlight:Hydrate(Gui.Focus) {
		Visible = UISpotlight.Visible,
		Size = UISpotlight:Spring(UISpotlight.Size, 5, 1),
		Position = UISpotlight:Spring(UISpotlight.Position, 15, 1),
	}	
end

return UISpotlight