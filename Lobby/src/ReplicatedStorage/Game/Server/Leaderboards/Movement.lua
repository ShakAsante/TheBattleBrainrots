local Movement = {}
local Animations = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")

local Packages = Root.Shared.Packages
local Trove = require(Packages.Trove)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

function Movement.GameStart()
	Players.PlayerAdded:Connect(function(Player)
		local Handle = function(Player)
			local HasAnim = Animations[Player]
			local Character = Player.Character or Player.CharacterAdded:Wait()
			local Humanoid = Character:WaitForChild("Humanoid")

			if HasAnim then
				HasAnim.Anim:Stop()
				HasAnim.Cleanup:Destroy()
				Humanoid.WalkSpeed = 16
				Animations[Player] = nil
			else
				local SprintAnimation = Humanoid:LoadAnimation(Assets.Anims.Sprint)
				SprintAnimation:Play()

				local Cleanup = Trove.new()
				Animations[Player] = { Anim = SprintAnimation, Cleanup = Cleanup } 
				Humanoid.WalkSpeed = 32

				Cleanup:Add(RunService.Heartbeat:Connect(function()
					local MoveDirection = Humanoid.MoveDirection
					if MoveDirection.Magnitude <= .1  then
						if SprintAnimation.IsPlaying then
							SprintAnimation:Stop()
						end
					else
						if not SprintAnimation.IsPlaying then
							SprintAnimation:Play()
						end
					end
				end))
			end		
		end
		
		Player.CharacterAdded:Connect(function(Character)
			Handle(Player)
		end)
	end)
end

return Movement