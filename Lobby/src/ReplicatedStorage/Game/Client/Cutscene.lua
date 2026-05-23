local Cutscene = {}
local Player = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Character = Player.Character or Player.CharacterAdded:Wait()

function Cutscene.Start(Name)
	local CutsceneData = script:WaitForChild(Name)  

	local CurrentCameraCFrame = workspace.CurrentCamera.CFrame
	local FrameTime = 0
	local Connection

	Character.Humanoid.AutoRotate = false
	Camera.CameraType = Enum.CameraType.Scriptable


	Connection = RunService.RenderStepped:Connect(function(DT)
		FrameTime += (DT * 60) 

		local NeededFrame = CutsceneData.Frames:FindFirstChild(tonumber(math.ceil(FrameTime)))

		if NeededFrame then
			Camera.CFrame = NeededFrame.Value 
		else
			Connection:Disconnect()
			Character.Humanoid.AutoRotate = true
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CFrame = CurrentCameraCFrame	
		end
	end)
end

function Cutscene:GetCutscene(Name)
	return script:WaitForChild(Name)	
end

function Cutscene:GetKeyframe(Name, Index)
	return script:WaitForChild(Name).Frames:FindFirstChild(Index)
end

return Cutscene