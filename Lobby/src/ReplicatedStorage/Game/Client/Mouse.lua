local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Mouse = Fusion.scoped(Fusion)

function Mouse.GameStart()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")

	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local MouseGui = Mouse:New("ScreenGui") {
		Name = "_fx",
		DisplayOrder = 1000,
		Parent = PlayerGui
	}

	local particlePool = {}
	local POOL_SIZE = 15
	local MAX_PARTICLES_PER_CLICK = 5

	local TWEEN_CONFIG = {
		MOVE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		FADE = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	}

	local function createParticlePool()
		for i = 1, POOL_SIZE do
			local particle = Instance.new("Frame")
			local corner = Instance.new("UICorner")

			particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			particle.BackgroundTransparency = 1
			particle.Visible = false

			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = particle

			particle.Parent = MouseGui
			table.insert(particlePool, particle)
		end
	end

	local function getParticleFromPool()
		for _, particle in ipairs(particlePool) do
			if not particle.Visible then
				return particle
			end
		end
		return nil
	end

	local function returnParticleToPool(particle)
		particle.Visible = false
		particle.BackgroundTransparency = 1
	end

	local function createClickEffect(position)
		local numParticles = math.random(3, MAX_PARTICLES_PER_CLICK)

		for i = 1, numParticles do
			task.spawn(function()
				local particle = getParticleFromPool()
				if not particle then return end

				local size = math.random(5, 8)
				particle.Size = UDim2.new(0, size, 0, size)
				particle.Position = UDim2.new(0, position.X - size/2, 0, position.Y - size/2)
				particle.BackgroundTransparency = 0
				particle.Visible = true

				local randomOffset = UDim2.new(0, math.random(-50, 50), 0, math.random(-50, 50))
				local moveTween = TweenService:Create(
					particle,
					TWEEN_CONFIG.MOVE,
					{ Position = particle.Position + randomOffset }
				)
				moveTween:Play()

				task.delay(0.2, function()
					local fadeTween = TweenService:Create(
						particle,
						TWEEN_CONFIG.FADE,
						{ BackgroundTransparency = 1 }
					)
					fadeTween:Play()

					task.delay(0.5, function()
						returnParticleToPool(particle)
					end)
				end)
			end)
		end
	end

	createParticlePool()

	UserInputService.InputBegan:Connect(function(input, isGpe)
		if not isGpe then
			return
		end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			createClickEffect(input.Position)
		end
	end)
end

return Mouse