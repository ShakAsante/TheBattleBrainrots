local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Fusion = require(Root.Shared.Packages.Fusion)
local Assets = Root:WaitForChild("Assets")
local UnitInfo = require(Assets.UnitInfo)
local Trove = require(Root.Shared.Packages.Trove)
local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local Tween = game:GetService("TweenService")

local Root = ReplicatedStorage.Game

local SoundService = game:GetService("SoundService")

local Cutscene = require(Root.Client.Cutscene)
local Camera = workspace.CurrentCamera
local Interface = require(Root.Client.Interface)
local InterfaceTools = require(Root.Client.InterfaceTools)
local EmitTools = require(Root.Client.EmitTools)

return {
	SimulateEggOpening = function(Names, Config)
		Config = Config or {}
		--Name = Name or "TimCheese"
		
		local VFXOffset = CFrame.new(0, 3, 0)
		
		local Scenery = Config.Scenery or "Grass"
		
		local SceneryModel = script.Scenery:WaitForChild(Scenery):Clone()
		SceneryModel.Parent = workspace.Effects
		
		Interface.HideInterface:set(true)
		
		local BigCleanup = Trove.new()

		local CameraPosition = script.SummonCamera.CFrame
		
		local Opening = Fusion.scoped(Fusion)
		local StartingPosition = script.SummonPart:GetPivot()
		
		local Egg = script.Egg:Clone()
		Egg.Parent = workspace.Effects
		
		local EggPosition = Opening:New("CFrameValue") {
			Value = StartingPosition * CFrame.new(0, 10, 0)
		}
		
		Egg:PivotTo(EggPosition.Value)
		
		BigCleanup:Add(RunService.RenderStepped:Connect(function()
			Egg:PivotTo(EggPosition.Value)
		end))
		
		Tween:Create(EggPosition, TweenInfo.new(1, Enum.EasingStyle.Back), {Value = StartingPosition}):Play()
		
		Camera.CameraType = Enum.CameraType.Scriptable

		BigCleanup:Add(RunService.RenderStepped:Connect(function()
			Camera.CFrame = CameraPosition
		end))
		
		local function ImpactFrame()
			local Impact = script.SummonImpact:Clone()
			Impact.Parent = LocalPlayer.PlayerGui
			wait(.1)
			Impact.Back.BackgroundColor3 = Color3.new(0,0,0)
			Tween:Create(Impact.Flash, TweenInfo.new(.15), {Size = UDim2.fromScale(2, 2), Rotation = 360}):Play()
			Impact.Flash.ImageColor3 = Color3.new(1, 1, 1)
			wait(.1)
			Impact:Destroy()
		end

		local function GetPossible()
			local PossibleUnits = {}
			
			for UnitName, Unit in UnitInfo do
				table.insert(PossibleUnits, UnitName)
			end
			
			return PossibleUnits
		end
		
		wait(1)
		
		Egg:Destroy()
		
		local PossibleUnits = GetPossible()
		local Shine = script.Shine:Clone()
		Shine.Parent = workspace.Effects
		
		Shine:PivotTo(StartingPosition * VFXOffset)
		
		BigCleanup:Add(Shine)
		BigCleanup:Add(SceneryModel)

		local TargetFOV = 75

		for i=1, 15 do
			Interface.FieldOfView:set(TargetFOV)
			TargetFOV = math.lerp(TargetFOV, 35, .1)
			local Cleanup = Trove.new()
			local Unit = PossibleUnits[math.random(1, #PossibleUnits)]
			local Reference = Assets.Rots:WaitForChild(Unit).Base.Default
			
			local Sound = Assets.Sounds["LevelUpSuspense"]:Clone()
			--Sound.Parent = Shine
			Sound.PlaybackSpeed = 1 + (i / 15)
			
			SoundService:PlayLocalSound(Sound)
			
			wait()
			
			--Sound:Play()
			
			--Cleanup:Add(Sound)
			
			local UnitModel = Assets.Rots:WaitForChild(Unit).Base.Default:Clone() :: Model
			UnitModel.PrimaryPart.Anchored = true
			
			Cleanup:Add(UnitModel)
			
			local Scale = Opening:New("NumberValue") {
				Name = "Scale",
				Value = 0.1
			}
			
			Cleanup:Add(Scale)
			
			Cleanup:Add(RunService.RenderStepped:Connect(function()
				UnitModel:ScaleTo(Scale.Value)
			end))
			
			Tween:Create(Scale, TweenInfo.new(1 / i, Enum.EasingStyle.Quint), {Value = Reference:GetScale()}):Play()
			
			for _, Part in ipairs(UnitModel:GetChildren()) do
				if not Part:IsA("Part") and not Part:IsA("MeshPart") and not Part:IsA("UnionPart") then continue end
				Part.CanCollide = false
				Part.Anchored = true
			end

			local Silloute = Opening:New("Highlight") {
				FillTransparency = 0,
				FillColor = Color3.new(0.141176, 0.141176, 0.207843),
				OutlineTransparency = 1,
				Parent = UnitModel
			}
			
			local Idle = UnitModel:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(UnitInfo[Unit].Animations.Base.Idle)
			Idle:Play()
			
			UnitModel.Parent = workspace.Effects
			UnitModel:PivotTo(StartingPosition)
			
			task.wait(.5 / i)
			
			Cleanup:Destroy()
		end
		
		ImpactFrame()
		
		do
			local BounceBackValue = Opening:New("NumberValue") {
				Value = TargetFOV,
			}
			
			BigCleanup:Add(RunService.RenderStepped:Connect(function()
				Interface.FieldOfView:set(BounceBackValue.Value)
			end))
			
			local Tween = Tween:Create(BounceBackValue, TweenInfo.new(.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Value = 80})
			Tween:Play()
		end
		
		for _, Name in ipairs(Names) do
			local Reference = Assets.Rots:WaitForChild(Name).Base.Default


			SoundService:PlayLocalSound(Assets.Sounds.Level_up)
			
			
--local Sound = Assets.Sounds["Level_up"]:Clone()
			--Sound.Parent = game.SoundService
			--Sound:Play()

			local UnlockVFX = script.Unlock:Clone()
			UnlockVFX.Parent = workspace.Effects

			UnlockVFX:PivotTo(StartingPosition * VFXOffset)
			BigCleanup:Add(UnlockVFX)
			EmitTools.Do(UnlockVFX)

			local Scale = Opening:New("NumberValue") {
				Name = "Scale",
				Value = Reference:GetScale() + 5
			}

			Tween:Create(Scale, TweenInfo.new(.3, Enum.EasingStyle.Quint), {Value = Reference:GetScale()}):Play()

			local UnitModel = Assets.Rots:WaitForChild(Name).Base.Default:Clone()

			local BrainrotHud = Assets.Gameplay.BrainrotDisplay:Clone()
			BrainrotHud.Parent = UnitModel
			
			BrainrotHud:WaitForChild("Name").Text = UnitInfo[Name].Base.DisplayName
			BrainrotHud:WaitForChild("Cost").Text = `${UnitInfo[Name].Cost or 0}`
			
			local UnitRarity = UnitInfo[Name].Rarity
			
			local RarityText = BrainrotHud:WaitForChild("Rarity")
			RarityText.Text = UnitRarity
			
			local Gradient = InterfaceTools.CreateGradient(UnitRarity)
			{ Parent = RarityText }

			UnitModel.PrimaryPart.Anchored = true
			
			local Idle = UnitModel:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(UnitInfo[Name].Animations.Base.Idle)
			Idle:Play()

			BigCleanup:Add(UnitModel)

			BigCleanup:Add(RunService.RenderStepped:Connect(function()
				UnitModel:ScaleTo(Scale.Value)
			end))

			for _, Part in ipairs(UnitModel:GetChildren()) do
				if not Part:IsA("Part") and not Part:IsA("MeshPart") and not Part:IsA("UnionPart") then continue end
				Part.CanCollide = false
				Part.Anchored = true
			end

			UnitModel.Parent = workspace.Effects
			UnitModel:PivotTo(StartingPosition)

			wait(1)
			
			UnitModel:Destroy()
		end
		
		local function RevertCamera()
			Camera.CameraType = Enum.CameraType.Follow
			Camera.CameraSubject = Humanoid
		end
		RevertCamera()

		BigCleanup:Destroy()
		--wait(1)

		Interface.ShowSummon:set(true)

		Interface.HideInterface:set(false)
	end,
}