local Effect = {}
local Camera = require("../Camera")

local UISpotlight = require("../UISpotlight")
local Battle = require("../Battle")

function Effect.CameraZoom(Zoom)
	Camera.ZoomTo(Zoom)
end

function Effect.CameraScrollTo(Object)
	Camera.ScrollToObject(Object)
end

function Effect.CameraFreeze(State)
	if State then
		Camera.Freeze()
	else
		Camera.Unfreeze()
	end
end

function Effect.SpotlightFocus(Object, Dur)
	UISpotlight.Focus(Object, Dur)
end

function Effect.FocusBrainrotInTeam(Index)
	UISpotlight.Focus(Battle.Data[Index], 3)
end


return Effect