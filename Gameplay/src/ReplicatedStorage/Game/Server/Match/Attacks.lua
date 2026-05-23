local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Attacks = {}
local Live = require("../Live")
local Units = require(Assets.UnitInfo)

local Targeting = require(Root.Shared.Packages.SpatialQueries)

local Tag = require("./Tag")
local EmitTools = require(Root.Client.EmitTools)
local Tweaks = require(Root.Tweaks)
local Fusion = require(Root.Shared.Packages.Fusion)

local function QuadBezier(i: number, p1: Vector3, p2: Vector3, p3: Vector3)
	local A = p1:Lerp(p2, i)
	local B = p2:Lerp(p3, i)
	return A:Lerp(B, i)
end

local RunService = game:GetService("RunService")

local AttackTypes = {
	["AOE"] = function(Info)
		local Unit = Info.Unit
		local Target = Info.Target
		local IsEnemy = Info.IsEnemy
		local Range = Info.Range
		local Damage = Info.Damage
		local Statuses = Info.Statuses
		local Level = Info.Level
		
		local DamageBoost = Tweaks.StatBoostPerLevel(Level) or 1
		Damage = Damage * DamageBoost
		Damage *= Fusion.peek(Info.ActiveStatuses.StrUp) and 1.5 or 1
		
		
		for _, Enemy in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
			local UnitHasBody = Enemy.Model:FindFirstChild("Body")

			if UnitHasBody then
				local IsInDistance = Target and (Unit.Body.CFrame.Position - UnitHasBody.CFrame.Position).Magnitude < (Range or 10)

				if IsInDistance then
					Tag(Enemy, {BaseDamage = Damage * 2, PostureDamage = Damage}, Statuses)
				else
					continue
				end
			end
		end
	end,

	["LOS"] = function(Info)
		local Unit = Info.Unit
		local Target = Info.Target
		local IsEnemy = Info.IsEnemy
		local Range = Info.Range
		local Damage = Info.Damage
		local Statuses = Info.Statuses
		local Level = Info.Level
		local OnTag = Info.OnTag
		
		local DamageBoost = Tweaks.StatBoostPerLevel(Level) or 1
		Damage = Damage * DamageBoost
		
		local Body = Unit:FindFirstChild("Body")
		if Body == nil then 
			return 
		end
		
		for _, Enemy in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
			local EnemyBody = Enemy.Model:FindFirstChild("Body")
			
			if EnemyBody == nil then continue end
			
			local IsInRange = Targeting:SimpleQuery(Body, EnemyBody, Range or 10, true)

			if IsInRange then
				Tag(Enemy, {BaseDamage = Damage * 2, PostureDamage = Damage}, Statuses)
				
				if OnTag then
					OnTag(Enemy.Model)
				end
			end
		end
	end,

	["Single"] = function(Info)
		local Unit = Info.Unit
		local Target = Info.Target
		local IsEnemy = Info.IsEnemy
		local Range = Info.Range
		local Damage = Info.Damage
		local Statuses = Info.Statuses
		local Level = Info.Level

		local DamageBoost = Tweaks.StatBoostPerLevel(Level) or 1
		Damage = Damage * DamageBoost

		local List = IsEnemy and Live.Units or Live.EnemyUnits
		for i=#List, 1, -1 do
			local Enemy = List[i]
			local EnemyHasBody = Enemy.Model:FindFirstChild("Body")
			local UnitHasBody = Unit:FindFirstChild("Body")
			
			if not UnitHasBody or not EnemyHasBody then continue end
			
			if EnemyHasBody then
				local IsInDistance = Target and (UnitHasBody.CFrame.Position - EnemyHasBody.CFrame.Position).Magnitude < (Range or 10)
				if IsInDistance then
					Tag(Enemy, {BaseDamage = Damage * 2, PostureDamage = Damage}, Statuses)
					break
				else
					continue
				end
			end
		end
	end,
}

Attacks["Kamikaze"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"

	local HitVisual = UnitInfo.HitVisual or "Hit"

	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")

	local ActiveStatuses = Info.ActiveStatuses

	if UnitBody == nil or TargetBody == nil then
		return
	end
	
	Animations.Attack:Play()

	wait(.15 / TimeScale)

	local Explosion = Assets.Gameplay.Explosion:Clone()
	Explosion.Parent = workspace
	Explosion:PivotTo(UnitBody.CFrame * CFrame.new(0, 0, -3))

	EmitTools.Do(Explosion)
	Unit.Health.Value = 0
end

Attacks["BarrageFast"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level
	
	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local HitVisual = UnitInfo.HitVisual or "Hit"

	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")
	
	local ActiveStatuses = Info.ActiveStatuses

	if UnitBody == nil or TargetBody == nil then
		return
	end
	Animations.Attack:Play()
	
	--Animations.Attack.Ended:Wait()
	wait(.15 / TimeScale)
	Animations.AttackHold:Play()
	
	local BarrageVFX = Assets.Gameplay.BarrageFX:Clone()
	BarrageVFX.Parent = workspace
	BarrageVFX:PivotTo(UnitBody.CFrame * CFrame.new(0, 0, -3))
	
	EmitTools.Do(BarrageVFX)
	ActiveStatuses.HyperArmor:set(true)
	
	local COUNT = 10
	
	for i=1, COUNT do
		AttackTypes["LOS"]({
			OnTag = function(Enemy)
				local Body = Enemy:FindFirstChild("Body")
				
				if Body == nil then
					return
				end
				
				Remotes.Replicate:FireAllClients("Hit", Enemy.Body:GetPivot())
			end,
			ActiveStatuses = Info.ActiveStatuses,
			Level = Level, 
			Unit = Unit,
			Target = Target,
			IsEnemy = IsEnemy,
			Range = UnitInfo.Range or 10,
			Damage = (UnitInfo.Damage or 10) / COUNT
		})
			
		wait(.2)
	end
	
	Animations.AttackHold:Stop()
	ActiveStatuses.HyperArmor:set(false)
	BarrageVFX:Destroy()
	EndAttack()
end

Attacks["Gattatino"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level
	
	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local HitVisual = UnitInfo.HitVisual or "Hit"
	local ActiveStatuses = Info.ActiveStatuses
	
	wait(AttackWindup / TimeScale)
	
	Animations.Attack:Play()

	ActiveStatuses.HyperArmor:set(true)

	--task.spawn(function()
		--Animations.Attack.Ended:Wait()
	--end)
	
	wait(DamageDelay / TimeScale)

	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")

	if UnitBody == nil or TargetBody == nil then
		return
	end

	local Origin = Unit:GetPivot()
	local Params = RaycastParams.new()
	local DownRay = workspace:Raycast(Origin.p, Vector3.new(0, -100, 0), Params)
	
	if not DownRay then
		return
	end
	
	local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)

	if IsStillInRange then
		AttackTypes["LOS"]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })

		Remotes.Replicate:FireAllClients("Hit", TargetBody.CFrame)
	end

	ActiveStatuses.HyperArmor:set(false)
	local Impact = Assets.Gameplay.Impact:Clone()
	Impact.Parent = workspace
	
	Impact:PivotTo(CFrame.new(DownRay.Position) * CFrame.new(-4, 0, 0))
	EmitTools.Do(Impact)
	EndAttack()
end


Attacks["Default"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level
	
	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local HitVisual = UnitInfo.HitVisual or "Hit"
	
	wait(AttackWindup / TimeScale)
	
	Animations.Attack:Play()
	
	task.spawn(function()
		Animations.Attack.Ended:Wait()
		EndAttack()
	end)
	
	wait(DamageDelay / TimeScale)
	
	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")
	
	if UnitBody == nil or TargetBody == nil then
		return
	end
	
	local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)
	
	if IsStillInRange then
		AttackTypes[AttackType]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })

		Remotes.Replicate:FireAllClients("Hit", TargetBody.CFrame)
	end
end
local Bubble = require(Root.Shared.BubbleModule)
Attacks["TralaledonRoar"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"

	local ActiveStatuses = Info.ActiveStatuses


	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")
	
	if UnitBody == nil or TargetBody == nil then
		return
	end
	
	local ShouldEnd = false
	Animations.Attack:Play()
	
	spawn(function()
		ActiveStatuses.HyperArmor:set(true)
		
		local Roar = Assets.Gameplay.TralaledonRoar:Clone()
		Roar.Parent = workspace.Effects
		Roar:PivotTo(UnitBody.CFrame )
		EmitTools.Do(Roar)
		
		repeat 
			Bubble.CreateBubble(UnitBody.CFrame, Vector3.zero, .8, Vector3.one * 130, 1) 
			
			for _, Unit in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
				if Unit == nil then continue end 
				if Unit and Unit.Model:IsDescendantOf(workspace) then
					local Distance = (Unit.Model:GetPivot().Position - UnitBody.CFrame.p).Magnitude
					if Distance <= 100 then	
						spawn(function()
							Tag(Unit, {
								PostureDamage = UnitInfo.Damage / 10,
								BaseDamage = UnitInfo.Damage / 20,
							}, {
								Slow = true
							})
						end)
						--break
					end
				end
			end
			
			wait(.25)
		until ShouldEnd == true
		Roar:Destroy()
		ActiveStatuses.HyperArmor:set(false)
		EndAttack()
	end)

	Animations.Attack.Ended:Wait()
	ShouldEnd = true
	

	--local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)

	--local AllyUnits = Live.Units

	--if IsStillInRange then
	--	for _, Unit in ipairs(AllyUnits) do
	--		if Unit.Statuses  then
	--			if Fusion.peek(Unit.Statuses.StrUp) then
	--				return
	--			end
				
	--			Unit.Statuses.StrUp:set(true)
				
	--			delay(10, function()
	--				Unit.Statuses.StrUp:set(false)
	--			end)
	--		end
	--	end
	--end
end

Attacks["TralaleroSplash"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"

	
	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")

	if UnitBody == nil or TargetBody == nil then
		return
	end

	
	local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)

	if IsStillInRange then
		Animations.Attack:Play()
		
		wait(.4)
		
		local CannonBall = Assets.Gameplay.Waterball:Clone()

		local P1 = UnitBody.CFrame.p
		local P3 = TargetBody.CFrame.p

		--local P2 = (P3 * CFrame.new((P1 - P3.p).Magnitude/2, 50, 0)).p

		local Dist = (P3 - P1).Magnitude
		local P2 = CFrame.new(P1.X + (Dist / 2) * (IsEnemy and 1 or -1), Dist * .65, 0).p

		local Index = 0

		local Loop 

		Loop = RunService.Heartbeat:Connect(function(Delta)
			local Position = QuadBezier(Index, P1, P2, P3)

			CannonBall.CFrame = CFrame.new(Position)

			Index += (Delta * .8) * TimeScale

			if Index > 1 then
				Loop:Disconnect()
				CannonBall:Destroy()

				Remotes.Replicate:FireAllClients("WaterExplosion", CFrame.new(Position))

				for _, Unit in pairs(IsEnemy and Live.Units or Live.EnemyUnits) do
					if Unit == nil then continue end 
					if Unit and Unit.Model:IsDescendantOf(workspace) then
						local Distance = (Unit.Model:GetPivot().Position - Position).Magnitude
						if Distance <= 15 then	
							spawn(function()
								Tag(Unit, {
									PostureDamage = UnitInfo.Damage,
									BaseDamage = UnitInfo.Damage / 2,
								}, {
									Slow = true
								})
							end)
						end
					end
				end

				return
			end
		end)

		CannonBall.Parent = workspace.Effects
		--AttackTypes[AttackType]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })
		EndAttack()
	end
	
end

Attacks["BFlash"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level
	
	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local HitVisual = UnitInfo.HitVisual or "Hit"
	
	local StrUp = Info.StrUp
	
	local CEnergy = Assets.Sounds.CEnergy:Clone()
	CEnergy.Parent = Unit.PrimaryPart
	
	CEnergy:Play()
	
	StrUp((DamageDelay + .5) / TimeScale)
	
	wait(AttackWindup / TimeScale)
	
	Animations.Attack:Play()

	task.spawn(function()
		Animations.Attack.Ended:Wait()
		CEnergy:Destroy()
		EndAttack()
	end)
	
	wait(DamageDelay / TimeScale)
	
	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")

	if UnitBody == nil or TargetBody == nil then
		return
	end
	
	local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)

	if IsStillInRange then
		AttackTypes[AttackType]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })

		Remotes.Replicate:FireAllClients("BFlash", TargetBody.CFrame)
	end
end

Attacks["Laser"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName

	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local UnitInfo = Units[UnitName][Form]
	Animations.Attack:Play()
	
	--local ChargeSound = ReplicatedStorage.Assets.Sounds.Laser_Charge:Clone()
	--ChargeSound.Parent = Unit.Body
	
	wait()
	
	--ChargeSound:Play()
	
	wait((Animations.Attack.Length * 0.835) / TimeScale)

	--local FireSound = ReplicatedStorage.Assets.Sounds["laser gun fire"]:Clone()
	--FireSound.Parent = Unit.Body
	
	wait()
	
	--FireSound:Play()
	
	local Laser = Instance.new("Part")
	Laser.CFrame = Unit.Body.CFrame * CFrame.new(0, 0, -1)
	Laser.Anchored = false
	Laser.CanCollide = false
	Laser.CanQuery = false
	Laser.CanTouch = false
	Laser.Transparency = 0
	Laser.Material = Enum.Material.Neon
	Laser.Color = Color3.fromRGB(255, 83, 86)
	Laser.Size = Vector3.new(.3, .3, 3)
	Laser.Parent = workspace
	
	local Velocity = Instance.new("BodyVelocity")
	Velocity.Velocity = Unit.Body.CFrame.LookVector * 120
	Velocity.MaxForce = Vector3.new(1, 1, 1) * math.huge
	Velocity.Parent = Laser
	
	game:GetService("Debris"):AddItem(Laser, 1)
	AttackTypes[AttackType]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })
	Animations.Attack.Ended:Wait()
	EndAttack()
end

Attacks["FlashFreeze"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local FlashFX = Unit:FindFirstChild("FlashFX", true)
	
	local FlashSound = ReplicatedStorage.Assets.Sounds.Flash:Clone()
	FlashSound.Parent = Unit.Body
	
	wait()

	FlashSound:Play()
	
	wait(.25/ TimeScale)
	
	local FreezeSound = ReplicatedStorage.Assets.Sounds.Freeze1:Clone()
	FreezeSound.Parent = Target.Body

	wait(.05/ TimeScale)
	
	FreezeSound:Play()

	task.spawn(function()
		FreezeSound.Ended:Wait()
		FreezeSound:Destroy()
		FlashSound:Destroy()
	end)
	
	AttackTypes[AttackType]({ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10, Statuses = {Freeze = true} })

	EndAttack()
end

Attacks["Slam"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"

	local HitVisual = UnitInfo.HitVisual or "Hit"
	local ActiveStatuses = Info.ActiveStatuses

	wait(AttackWindup / TimeScale)

	Animations.Attack:Play()

	--ActiveStatuses.HyperArmor:set(true)

	--task.spawn(function()
		--Animations.Attack.Ended:Wait()
	--end)

	wait(DamageDelay / TimeScale)
	
	local TargetBody = Target:FindFirstChild("Body")
	local UnitBody = Unit:FindFirstChild("Body")

	if UnitBody == nil or TargetBody == nil then
		return
	end

	local Origin = Unit:GetPivot()
	local Params = RaycastParams.new()
	local DownRay = workspace:Raycast(Origin.p, Vector3.new(0, -100, 0), Params)

	if not DownRay then
		return
	end

	local IsStillInRange = Target and (UnitBody.CFrame.Position - TargetBody.CFrame.Position).Magnitude < (UnitInfo.Range or 10)

	if IsStillInRange then
		AttackTypes["LOS"]({ ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10 })

		Remotes.Replicate:FireAllClients("Hit", TargetBody.CFrame)
	end
	
	--ActiveStatuses.HyperArmor:set(false)
	local Impact = Assets.Gameplay.ImpactHuge:Clone()
	Impact.Parent = workspace

	Impact:PivotTo(CFrame.new(DownRay.Position) * CFrame.new(-4, 0, 0))
	EmitTools.Do(Impact)
	EndAttack()
end

Attacks["UdinCharge"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]

	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	local Damage = UnitInfo.Damage or 10

	local DamageBoost = Tweaks.StatBoostPerLevel(Level) or 1
	Damage = Damage * DamageBoost

	wait(.3/TimeScale)
	
	Animations.Attack:Play()
	
	wait(2/TimeScale)	
	--Animations.Attack.Ended:Wait()
	
	for i=1, 3 do
		local Body = Unit:FindFirstChild("Body")

		if not Body then
			break
		end

		local DISTANCE = 5 * (i)

		local Position = IsEnemy and Unit.Body.CFrame * CFrame.new(0, 0, DISTANCE) or Unit.Body.CFrame * CFrame.new(0, 0, -DISTANCE)
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Include
		Params.FilterDescendantsInstances = {workspace.Map}
		local Raydown = workspace:Raycast(Position.Position, Vector3.new(0, -100, 0), Params)
		
		if Raydown then
			local Explosion = Assets.Gameplay.AllyWaveFX:Clone()
			Explosion.Parent = workspace.Effects
			
			Explosion:PivotTo(CFrame.new(Raydown.Position))
			
			wait()
			
			EmitTools.Do(Explosion)

			local TargetList = IsEnemy and Live.Units or Live.EnemyUnits

			for _, Unit in pairs(TargetList) do
				local IsInDistance = (Unit.Model.Body.Position - Position.Position).Magnitude <= 10

				if IsInDistance then
					if Unit.Statuses then
						if Fusion.peek(Unit.Statuses.Stunned) then
							continue
						end

						task.spawn(function()
							Unit.Knockback()
						end)
					end

					Tag(Unit, {PostureDamage = Damage})
				else
					continue
				end
			end
		end

		wait(.15/TimeScale)
	end
	
	EndAttack()
	
	--AttackTypes["Single"](Unit, Target, IsEnemy, UnitInfo.Range or 10, UnitInfo.Damage or 10)

end

Attacks["TripleHit"] = function(Info)
	local TimeScale = Fusion.peek(require(script.Parent).TimeScale)
	local Unit = Info.Unit
	local Target = Info.Target
	local IsEnemy = Info.IsEnemy
	local Form = Info.Form
	local Animations = Info.Animations
	local EndAttack = Info.EndAttack
	local UnitName = Info.UnitName
	local UnitInfo = Units[UnitName][Form]
	local Level = Info.Level

	local AttackWindup = UnitInfo.AttackWindup or 0
	local DamageDelay = UnitInfo.DamageDelay or 0
	local AttackType = UnitInfo.AttackType or "Single"
	
	Animations.Attack:Play()
	
	task.spawn(function()
		Animations.Attack.Ended:Wait()
		EndAttack()
	end)
	
	for i=1, 3 do
		AttackTypes[AttackType]({ActiveStatuses = Info.ActiveStatuses, Level = Level, Unit = Unit, Target = Target, IsEnemy = IsEnemy, Range = UnitInfo.Range or 10, Damage = UnitInfo.Damage or 10})
		--Remotes.Replicate:FireAllClients("Hit", Target.Body.CFrame)
		wait(.2/TimeScale)
	end	
end 

return Attacks