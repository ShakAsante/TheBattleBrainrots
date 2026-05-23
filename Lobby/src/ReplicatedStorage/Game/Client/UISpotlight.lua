local Root = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local UISpotlight = Fusion.scoped(Fusion)

UISpotlight.Visible = UISpotlight:Value(false)
UISpotlight.Position = UISpotlight:Value(UDim2.new())
UISpotlight.Size = UISpotlight:Value(UDim2.new())
UISpotlight.Object = UISpotlight:Value(nil)

local RunService = game:GetService("RunService")

function UISpotlight.Focus(Object: Frame)
	UISpotlight.Visible:set(true)
	UISpotlight.Object:set(Object)
end

function UISpotlight.FocusOff()
	UISpotlight.Visible:set(false)
	UISpotlight.Position:set(UDim2.new(0, 0))
	UISpotlight.Size:set(UDim2.new(0, 0))
end

function UISpotlight.FocusTimed(Object, Duration)
	UISpotlight.Focus(Object)
	wait(Duration)
	UISpotlight.FocusOff()
end

function UISpotlight.GameStart()
	local Gui = script.Spotlight:Clone()
	Gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

	UISpotlight:Hydrate(Gui.Focus) {
		Visible = UISpotlight.Visible,
		Size = UISpotlight:Spring(UISpotlight.Size, 25, .9),
		Position = UISpotlight:Spring(UISpotlight.Position, 25, .9),
	}	
	
	RunService.RenderStepped:Connect(function()
		local Object = Fusion.peek(UISpotlight.Object)
		
		if Object then
			UISpotlight.Position:set(UDim2.fromOffset(Object.AbsolutePosition.X + (Object.AbsoluteSize.X / 2), Object.AbsolutePosition.Y + (Object.AbsoluteSize.Y / 2) ))
			UISpotlight.Size:set(UDim2.fromOffset(Object.AbsoluteSize.X,Object.AbsoluteSize.Y) + UDim2.fromOffset(20, 20))
		end
	end)
end

return UISpotlight