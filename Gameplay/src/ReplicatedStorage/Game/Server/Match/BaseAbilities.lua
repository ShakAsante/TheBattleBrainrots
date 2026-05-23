local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local BaseAbilities = {}
local Live = require("../Live")
local EmitTools = require(Root.Client.EmitTools)
local Fusion = require(Root.Shared.Packages.Fusion)
local Create = Fusion.scoped(Fusion)
local Tween = game:GetService("TweenService")
local Trove = require(Root.Shared.Packages.Trove)
local RunService = game:GetService("RunService")
local Remotes = Root.Remotes
local Upgrades = require("../Upgrades")
local Players = game:GetService("Players")
local Tag = require("./Tag")

local function QuadBezier(i: number, p1: Vector3, p2: Vector3, p3: Vector3)
	local A = p1:Lerp(p2, i)
	local B = p2:Lerp(p3, i)
	return A:Lerp(B, i)
end

local function SmoothStep(a,b,c)
	return a + (b - a) * math.clamp(c, 0, 1) ^ 2
end

BaseAbilities["Cannon"] = function(IsEnemy)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Player = Players:GetPlayers()[1]
	local Base = workspace.Map.Bases:WaitForChild(IsEnemy and "2" or "1")
	local Cannon = Base.Ability.Cannon

	local Size = Create:New("NumberValue") {
		Value = 1,
	}
	
	local Cleanup = Trove.new()
	
	Cleanup:Add(RunService.Heartbeat:Connect(function()
		Cannon:ScaleTo(Size.Value)
	end))
	
	local CannonBall = Assets.Gameplay.CannonBall:Clone()
	
	local ChosenUnits = (IsEnemy and Live.Units or Live.EnemyUnits)
	
	local Len = #ChosenUnits
	local Target = Len > 1 and ChosenUnits[#ChosenUnits - 1] or ChosenUnits[#ChosenUnits]
	
	if Target == nil then
		return 
	end
	
	CannonBall.Fire:Play()
	
	local P1 = Cannon.PrimaryPart.Nozzle.WorldCFrame.p
	local P3 = Target.Model:GetPivot() 
	
	--local P2 = (P3 * CFrame.new((P1 - P3.p).Magnitude/2, 50, 0)).p

	local Dist = (P3.p - P1).Magnitude
	local P2 = CFrame.new(P1.X + (Dist / 2) * (IsEnemy and 1 or -1), Dist * .65, 0).p
	
	local Index = 0
	
	local Loop 
		
	Loop = RunService.Heartbeat:Connect(function(Delta)
		local Position = QuadBezier(Index, P1, P2, P3.p)
		
		CannonBall.CFrame = CFrame.new(Position)

		Index += (Delta * .8) * TimeScale
		
		if Index > 1 then
			Loop:Disconnect()
			CannonBall:Destroy()
			
			Remotes.Replicate:FireAllClients("Explosion", CFrame.new(Position))
			
			for _, Unit in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
				if Unit == nil then continue end 
				if Unit and Unit.Model:IsDescendantOf(workspace) then
					local Distance = (Unit.Model:GetPivot().Position - Position).Magnitude
					if Distance <= 15 then	
						spawn(function()
							Tag(Unit, {
								BaseDamage = 150 * (Upgrades.Get(Player).CannonPower or 1),
								Damage = 1
							}, {
								Knockback = true
							})
						end)
					end
				end
			end
			
			return
		end
	end)
	
	
	CannonBall.Parent = workspace
	

	local Tween = Tween:Create(Size, TweenInfo.new(.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
		Value = 1.2	
	})
		
	Tween:Play()
	Tween.Completed:Wait()
	Cleanup:Destroy()
end


BaseAbilities["BoltCannon"] = function(IsEnemy)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Player = Players:GetPlayers()[1]
	
	local Base = workspace.Map.Bases:WaitForChild(IsEnemy and "2" or "1")
	local Cannon = Base.Ability.Cannon
	
	local Enemies = (IsEnemy and Live.Units or Live.EnemyUnits)

	for i=1, 3 do
		local RandomEnemy = Enemies[math.random(1, #Enemies)]
		local Target = RandomEnemy.Model:GetPivot().Position
		Remotes.Replicate:FireAllClients("LBolt", Target)
		Tag(RandomEnemy, {Damage = 100})
		wait(i)
	end
end

BaseAbilities["IceCannon"] = function(IsEnemy)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Player = Players:GetPlayers()[1]

	local Base = workspace.Map.Bases:WaitForChild(IsEnemy and "2" or "1")
	local Cannon = Base.Ability.Cannon

	local Size = Create:New("NumberValue") {
		Value = 1,
	}

	local Cleanup = Trove.new()

	Cleanup:Add(RunService.Heartbeat:Connect(function()
		Cannon:ScaleTo(Size.Value)
	end))

	local CannonBall = Assets.Gameplay.CannonBall:Clone()
	local Target = (IsEnemy and Live.Units or Live.EnemyUnits)[1]

	if Target == nil then
		return 
	end

	CannonBall.Fire:Play()

	local P1 = Cannon.PrimaryPart.Nozzle.WorldCFrame.p
	local P3 = Target.Model:GetPivot() 

	--local P2 = (P3 * CFrame.new((P1 - P3.p).Magnitude/2, 50, 0)).p
	local P2 = CFrame.new(0, 50, 0).p
	local Index = 0

	local Loop 

	Loop = RunService.Heartbeat:Connect(function(Delta)
		local Position = QuadBezier(Index, P1, P2, P3.p)

		CannonBall.CFrame = CFrame.new(Position)

		Index += (Delta * .8) * TimeScale

		if Index > 1 then
			Loop:Disconnect()
			CannonBall:Destroy()
			
			Remotes.Replicate:FireAllClients("IceExplosion", CFrame.new(Position))

			for _, Unit in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
				if Unit == nil then continue end 
				if Unit and Unit.Model:IsDescendantOf(workspace) then
					local Distance = (Unit.Model:GetPivot().Position - Position).Magnitude
					if Distance <= 15 then	
						if Unit.Freeze then
							Unit.Freeze()
						end
						
						Tag(Unit, {
							BaseDamage = 75 * Upgrades.Get(Player).BaseAbilityPower,
							Damage = 0
						})
					end
				end
			end


			return
		end
	end)


	CannonBall.Parent = workspace


	local Tween = Tween:Create(Size, TweenInfo.new(.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true), {
		Value = 1.2	
	})

	Tween:Play()
	Tween.Completed:Wait()
	Cleanup:Destroy()
end

return BaseAbilities