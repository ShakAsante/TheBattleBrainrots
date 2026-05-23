local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local Camera = Fusion.scoped(Fusion)

local CurrentCamera = workspace.CurrentCamera
local CameraPart = script.CameraPart
local RunService = game:GetService("RunService")

local UserInput = game:GetService("UserInputService")

local CAMERA_RANGE = 30

local IsMobile = Camera:Value(not UserInput.KeyboardEnabled and not UserInput.GamepadEnabled)

Camera.Frozen = false
Camera.__movedir = 0 
Camera.Zoom = Camera:Value(0)

function Camera.GameStart()
	InterfaceTools = require("./InterfaceTools")
	
	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CurrentCamera.CFrame = CFrame.new(0, 0, 0)
	Camera.XOffset = 0
	Camera.Offset = CFrame.new(0, 0, 0)
	CurrentCamera.FieldOfView = 45 - (Fusion.peek(Camera.Zoom) * 10)
	
	RunService:BindToRenderStep("Camera",Enum.RenderPriority.Camera.Value, function()
		local Target = CameraPart.CFrame * Camera.Offset * CFrame.new(0, 0, -Fusion.peek(Camera.Zoom) * 20)
		CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(Target, .3)
		Camera.Offset = CFrame.new(Camera.XOffset, 0, 0) 
		
		CurrentCamera.FieldOfView = 45 - (Fusion.peek(Camera.Zoom) * 10)

		local LeftDown = UserInput:IsKeyDown(Enum.KeyCode.A)
		local RightDown = UserInput:IsKeyDown(Enum.KeyCode.D)

		Camera.__movedir = (LeftDown and not RightDown) and -1 or ((RightDown and not LeftDown) and 1 or 0)
		Camera.XOffset += not Camera.Frozen and Camera.__movedir or 0
		Camera.XOffset = math.clamp(Camera.XOffset, -CAMERA_RANGE, CAMERA_RANGE)
	end)
	
	local MainInterface = InterfaceTools.GetInterface("Main")
	
	Camera:Hydrate(MainInterface.MobileInput) {
		Visible = IsMobile
	}
	
	Camera:Hydrate(MainInterface.MobileInput.RightArrow) {
		[Fusion.OnEvent("Activated")] = function()
			Camera.MoveRight()
		end,
	}

	Camera:Hydrate(MainInterface.MobileInput.LeftArrow) {
		[Fusion.OnEvent("Activated")] = function()
			Camera.MoveLeft()
		end,
	}
	
	UserInput.InputChanged:Connect(function(Input)
		if Camera.Frozen then return end
		if Input.UserInputType == Enum.UserInputType.MouseWheel	 then
			Camera.Zoom:set(math.clamp(Fusion.peek(Camera.Zoom) + (Input.Position.Z/10), 0, 1))
		end
	end)
end

function Camera.ZoomTo(Zoom)
	Camera.Zoom:set(Zoom)
end

function Camera.MoveLeft()
	if Camera.Frozen then return end
	Camera.XOffset -= 5
end

function Camera.Freeze()
	Camera.Frozen = true
end

function Camera.Unfreeze()
	Camera.Frozen = false
end

function Camera.ScrollToObject(Target)
	local RelativePosition = Target.CFrame.Position - CurrentCamera.CFrame.Position
	local TargetX = math.clamp(RelativePosition.X, -CAMERA_RANGE, CAMERA_RANGE)
	
	Camera.XOffset = TargetX
end

function Camera.MoveRight()
	if Camera.Frozen then return end
	Camera.XOffset += 5
end

function Camera.MoveTo(X)
	Camera.XOffset = X
end

return Camera