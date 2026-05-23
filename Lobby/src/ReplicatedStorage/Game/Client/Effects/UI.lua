local Player = game:GetService("Players").LocalPlayer
local PGui = Player.PlayerGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Assets = Root:WaitForChild("Assets")
local Fusion = require(Root.Shared.Packages.Fusion)
local TweenService = game:GetService("TweenService")
local Trove = require(Root.Shared.Packages.Trove)
local Create = Fusion.scoped(Fusion)
local HttpService = game:GetService("HttpService")

Interface = require("../Interface")

return {
	Notification = function(Message, IsError)
		local NotificationGui = PGui:WaitForChild("Notifs")
		local ShouldBeTop = not Fusion.peek(Interface.InInterface)
		

		local Template = NotificationGui.Template:Clone()
		Template.Name = HttpService:GenerateGUID(false)
		Template.Parent = ShouldBeTop and NotificationGui.Top or NotificationGui.Bottom
		Template.Text = Message
		Template.Visible = true
		
		if IsError then
			Template.TextColor3 = Color3.fromRGB(255, 0, 0)
			Template.UIStroke.Color = Color3.new(0.333333, 0, 0)
			
			--Template...Enabled = false
			
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
			ZIndex = 9999, 
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
}