local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Visual = {}
local Trove = require(Root.Shared.Packages.Trove)
local EmitTools = require(Root.Client.EmitTools)
local RandomGen = Random.new()
--local Salt = require(Root.Shared.Packages.Salt)
local RunService = game:GetService("RunService")

Visual["Explosion"] = function(Position, Scale)
	local Explosion = Assets.Gameplay.Explosion:Clone()
	local Scale = Scale or Explosion:GetScale()
	
	Explosion.Parent = workspace.Effects
	wait()
	Explosion:PivotTo(Position)

	Explosion:ScaleTo(Scale)
	
	EmitTools.Do(Explosion)
end

Visual["WaterExplosion"] = function(Position, Scale)
	local Explosion = Assets.Gameplay.Splash:Clone()
	local Scale = Scale or Explosion:GetScale()
print("explode")
	Explosion.Parent = workspace.Effects
	wait()
	Explosion:PivotTo(Position)

	Explosion:ScaleTo(Scale)

	EmitTools.Do(Explosion)
end

Visual["Parry"] = function(Position, Scale)
	local Effect = Assets.Gameplay.Parry:Clone()
	local Scale = Scale or Effect:GetScale()
	
	Effect.Parent = workspace.Effects

	wait()
	
	Effect:PivotTo(Position)
	Effect:ScaleTo(Scale)

	EmitTools.Do(Effect)
end

Visual["Death"] = function(Position, Scale)
	local Effect = Assets.Gameplay.Death:Clone()
	--local Scale = Scale or Effect:GetScale()
	
	Effect.Parent = workspace.Effects
	wait()
	Effect:PivotTo(Position)
	--Effect:ScaleTo(Scale)
	EmitTools.Do(Effect)
end

Visual["Hit"] = function(Position, Scale)
	local Effect = Assets.Gameplay.HitEffect:Clone()
	local Scale = Scale or Effect:GetScale()

	Effect.Parent = workspace.Effects

	wait()

	Effect:PivotTo(Position)
	Effect:ScaleTo(Scale)

	EmitTools.Do(Effect)
end


Visual["BFlash"] = function(Position, Scale)
	local Effect = Assets.Gameplay.BFlashEffect:Clone()
	local Scale = Scale or Effect:GetScale()

	Effect.Parent = workspace.Effects
	wait()
	Effect:PivotTo(Position)
	Effect:ScaleTo(Scale)

	EmitTools.Do(Effect)
end

Visual["IceExplosion"] = function(Position, Scale)
	local Explosion = Assets.Gameplay.IceExplosion:Clone()
	local Scale = Scale or Explosion:GetScale()

	Explosion.Parent = workspace.Effects
	wait()
	Explosion:PivotTo(Position)
	Explosion:ScaleTo(Scale)

	EmitTools.Do(Explosion)
end


Visual["LoadScenery"] = function(TargetScenery)
	local CurrentScenery = workspace.Map:FindFirstChild("Scenery"):GetChildren()[1]
	if CurrentScenery == nil then return end

	if CurrentScenery.Name == TargetScenery then
		return
	else
		CurrentScenery:Destroy()

		local TargetScenery = ReplicatedStorage.Assets.Gameplay.Scenery:WaitForChild(TargetScenery):Clone()
		TargetScenery.Parent = workspace.Map.Scenery
	end
end 

--Visual["LBolt"] = function(Position)
--	local Bolt = Salt.createLightningPath({
--		StartPosition = Position + Vector3.new(0, 50, 0), 
--		EndPosition = Position, 
--		Color = "Electric blue",     
--		Width = 1,        
--		Amount = 10,         

--		TweenTime = 0.4,               
--		StaggerTime = 0.05,            
--		Animate = true,
--		OffsetRange = 5,
--		Parent = workspace.Effects,          
--		AutoCleanup = true,             
--		CleanupTime = .1,   
--	})
	
--	local BoltSound = Assets.Sounds.Bolt:Clone()
--	BoltSound.Parent = workspace.Camera
	
--	wait()
	
--	BoltSound:Play()
--	--local TotalCleanup = Trove.new()
--end

--Visual["MoneyDrop"] = function(From, To)
--	--local TotalCleanup = Trove.new()

--	--for i=1, 3 do
--	--	task.spawn(function()
--	--		local CashCleanup = Trove.new()
--	--		local Scale = (RandomGen:NextNumber() * 1.5) + 1
--	--		local Deadline = tick() + 5

--	--		local Cash = script.Cash:Clone()
--	--		Cash.PrimaryPart.CollisionGroup = "Effect"
--	--		Cash:ScaleTo(Scale)
--	--		CashCleanup:Add(Cash)

--	--		Cash.Parent = workspace.Camera

--	--		Cash:PivotTo(From)
--	--		Cash.PrimaryPart.Velocity = Vector3.new(math.random(-1, 1)/2, 1, math.random(-1, 1)/2) * 35

--	--		wait(1)

--	--		local BodyVelocity = Instance.new("BodyVelocity", Cash.PrimaryPart)
--	--		BodyVelocity.MaxForce = Vector3.one * math.huge

--	--		CashCleanup:Add(BodyVelocity)

--	--		CashCleanup:Add(RunService.RenderStepped:Connect(function()
--	--			local Diff = (Cash:GetPivot().p - To.p)
--	--			BodyVelocity.Velocity = Diff.Unit * -80

--	--			if Diff.Magnitude < 2 or (Deadline - tick()) <= 0 then
--	--				CashCleanup:Destroy()
--	--				local CashSound = Assets.Sounds.CashGained:Clone()
--	--				CashSound.Parent = workspace.Camera
--	--				CashSound:Play()
--	--				CashSound.Ended:Wait()
--	--				CashSound:Destroy()
--	--			end
--	--		end))
--	--	end)
--	--end
--end


return Visual