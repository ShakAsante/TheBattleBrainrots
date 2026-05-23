local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Player = game:GetService("Players").LocalPlayer
local PGui = Player.PlayerGui
local Fusion = require(Root.Shared.Packages.Fusion)

local TweenService = game:GetService("TweenService")
local Trove = require(Root.Shared.Packages.Trove)
local Create = Fusion.scoped(Fusion)

local DialogueController = require("../Dialogue")

return {
	IntroDefault = function()
		local Scope = Fusion.scoped(Fusion)
		
		local Intro = script.Intro:Clone()
		
		local Banner = Intro.Banner
		
		local BannerScale = Scope:Value(UDim2.fromScale(1, 0))
		
		Scope:Hydrate(Banner) {
			Size = Scope:Spring(BannerScale, 15, .9)
		}
		
		local TransparencyValues = {}
		
		for Index, Letter in pairs(Banner:GetChildren()) do
			if not Letter:IsA("Frame") then continue end
			
			local Size = Scope:Value(2)
			
			local Transparency = Scope:Value(1)
			table.insert(TransparencyValues, Transparency)
			
			local Scale = Scope:New("UIScale") {
				Scale = Scope:Spring(Size, 15, .9),
				Parent = Letter.Label
			}
			
			Scope:Hydrate(Letter.Label) {
				TextTransparency = Scope:Spring(Transparency, 15, .9),
			}
			
			task.spawn(function()
				wait(Index / 3)
				Size:set(1)
				Transparency:set(0)
			end)
		end
		
		wait(.15)

		BannerScale:set(UDim2.fromScale(1, .25))
		Intro.Parent = PGui
		
		wait(2.6)
		
		for _, Transparency in pairs(TransparencyValues) do
			Transparency:set(1)
		end
		
		wait(.5)
		
		BannerScale:set(UDim2.fromScale(1, 0))
		
		wait(1)
		
		Banner:Destroy()
		Scope:doCleanup()
	end,
	
	MobSpawnDangerous = function(FromBase)
		local Bases = workspace.Map.Bases
		local Base = Bases:FindFirstChild("2")
		local MobSpawn = Base.UnitSpawnPoint
		local ImpactVFX = script.Impact:Clone()
		--local ImpactSound = Assets.Sounds.DangerousMob:Clone()
		--ImpactSound.Parent = game.SoundService
		--ImpactSound:Play()
		ImpactVFX.Parent = MobSpawn
		wait()
		ImpactVFX:Emit(1)
		
		local ImpactFrame = Instance.new("ColorCorrectionEffect")
		ImpactFrame.Saturation = -1
		ImpactFrame.Contrast = 100
		ImpactFrame.Brightness = 1
		ImpactFrame.Parent = game.Lighting
		wait(.1)
		ImpactFrame:Destroy()
		local WhiteFrame = Instance.new("ColorCorrectionEffect")
		WhiteFrame.Saturation = -1
		WhiteFrame.Contrast = -100
		WhiteFrame.Brightness = 1
		WhiteFrame.Parent = game.Lighting
		wait(.1)
		WhiteFrame:Destroy()
	end, 
	
	Dialogue = function(ID)
		DialogueController.Start(ID)
	end,
	
	UpgradeEffect = function(Frame)
		local Scale = Create:New("UIScale") {
			Parent = Frame,
			Scale = .7
		}

		local LevelUpSound = Assets.Sounds.Level_up:Clone()
		LevelUpSound.Parent = Frame

		local Tween = TweenService:Create(Scale, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Scale = 1})
		Tween:Play()

		wait()

		LevelUpSound:Play()

		local HasCornerRadius = Frame:FindFirstChildOfClass("UICorner")
		HasCornerRadius = HasCornerRadius and HasCornerRadius:Clone() or nil

		local Cleanup = Trove.new()

		Cleanup:Add(Scale)

		local Glow = Create:New("Frame") {
			Parent = Frame;
			Size = UDim2.fromScale(1, 1),
			Transparency = 1;
			ZIndex = 3, 
		}

		Cleanup:Add(Glow)

		if HasCornerRadius then
			HasCornerRadius.Parent = Glow
		end

		local Tween = TweenService:Create(Glow, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Transparency = 0})
		Tween:Play()

		local Stroke = Create:New("UIStroke") {
			Parent = Glow;
			Transparency = 0.5;
			BorderOffset = UDim.new(0, 0),
			Thickness = 5,
			Color = Color3.fromRGB(255, 255, 255);
		}

		Cleanup:Add(Stroke)

		wait(.125)

		local Tween = TweenService:Create(Stroke, TweenInfo.new(1, Enum.EasingStyle.Circular), {Transparency = 1, BorderOffset = UDim.new(.1, 0)})
		Tween:Play()

		wait(.05)

		local Tween = TweenService:Create(Glow, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Transparency = 1})
		Tween:Play()

		--local Outline = Create:New("UIStroke") {
		--Parent = Glow,
		--}
		Tween.Completed:Wait()
		Cleanup:Destroy()
	end,
	Notification = function(Message, IsError)
		local NotificationGui = PGui:WaitForChild("Notifs")

		local Template = NotificationGui.Main.Template:Clone()
		Template.Parent = NotificationGui.Main
		Template.Text = Message
		Template.Visible = true

		if IsError then
			Template.TextColor3 = Color3.fromRGB(255, 0, 0)
			Template.UIStroke.Color = Color3.new(0.333333, 0, 0)

			Template.Good.Enabled = false

			Template.Glow.ImageColor3 = Color3.new(1, 0, 0)
			Template.Bad.Enabled = true
		end

		local Scale = Instance.new("UIScale", Template)
		Scale.Scale = 0
		local Tween = TweenService:Create(Scale, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Scale = 1})
		Tween:Play()
		Tween.Completed:Wait()
		wait(2)
		Tween = TweenService:Create(Scale, TweenInfo.new(0.2, Enum.EasingStyle.Circular), {Scale = 0})
		Tween:Play()
		Tween.Completed:Wait()
		Template:Destroy()
	end,
}