local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Bases = workspace:WaitForChild("Map").Bases
local PlayerBase = Bases:WaitForChild("1")
local EnemyBase = Bases:WaitForChild("2")
local Live = require("./Live")
local Fusion = require(Root.Shared.Packages.Fusion)
local Trove = require(Root.Shared.Packages.Trove)
local Match = Fusion.scoped(Fusion)
local Physics = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UnitInfo = require(Assets.UnitInfo)
local Tweaks = require(Root.Tweaks)
local Attacks = require("@self/Attacks")
local Analytics = game:GetService("AnalyticsService")
--local Chapters = require(Assets.Chapters)
local GameStages = require(Assets.Stages)[1]
local StoryChapters = GameStages.Story
local EventStages = GameStages.Event

local AdService = game:GetService("AdService")
local Products = require(Assets.Products)
local Teleports = require(Assets.Teleports)
local TeleportService = game:GetService("TeleportService")
local Rewards = require("./Rewards")
local TableUtils = require(Root.Shared.Packages.TableUtil)
local Data = require("./Data")
local Tutorial = require("./Tutorial")
local Http=  game:GetService("HttpService")
local BaseAbilities = require("@self/BaseAbilities")
local Music = require("./Music")


local MAX_WALLETLEVEL = 5


Match.TimeScale = Match:Value(1)
Match.Upgrades = {
	Wallet = Match:Value(RunService:IsStudio() and 5 or 1)
}

Match.Debounces = {
	BaseAbility = false,
	Team = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
		[10] = false,
	}
}

Match:Observer(Match.TimeScale):onChange(function()
	workspace.Gravity = 196.2 / Fusion.peek(Match.TimeScale)
end)

Match.Money = Match:Value(0)
Match.StageType = Match:Value("Story")
Match.EnemyIsDead = Match:Value(false)
Match.PlayerIsDead = Match:Value(false)
Match.Chapter = Match:Value(1)
Match.Stage = Match:Value(1)


function Match.HandleBases()
	local Player = Players:GetPlayers()[1]
	local StageData = Match.GetStageInfo(Fusion.peek(Match.StageType),{Chapter = Fusion.peek(Match.Chapter), Stage = Fusion.peek(Match.Stage)})
	local PlayerBase = Bases:WaitForChild("1")
	local EnemyBase = Bases:WaitForChild("2")
	
	local PlayerHealth = Match:New("IntConstrainedValue") {
		Name = "BaseHealth",
		MaxValue = (((Upgrades.Get(Player).BaseHealth - 1) or 0) * 250) + 500,
		Parent = PlayerBase,
	}
	
	PlayerHealth.Value = PlayerHealth.MaxValue

	local EnemyHealth = Match:New("IntConstrainedValue") {
		Name = "BaseHealth",
		MaxValue = StageData.EnemyBaseHealth or 500,
		Parent = EnemyBase,
	}
	
	EnemyHealth.Value = EnemyHealth.MaxValue
end

function Match.GetStageInfo(StageType, Args: {Chapter: number, Stage: number})
	if StageType == "Story" then
		--print(StoryChapters)
		local ChapterInfo = StoryChapters[Args.Chapter]
		local StageInfo = ChapterInfo.Stages[Args.Stage]

		return StageInfo
	else
		local StageInfo = EventStages[Args.Stage]
		return StageInfo
	end
end

function Match.HandleEvents()
	Remotes.PlaceUnit.OnServerEvent:Connect(function(Player, Index)
		local UnitInIndex = Match.Team[Index] 
		if not UnitInIndex then return false end
		local InfoFromTeam = UnitInIndex and Match.Team[Index]
		local UnitName = InfoFromTeam.Name
		local UnitInfo = UnitInfo[UnitName]
		local Level = InfoFromTeam.Level
		local Form = InfoFromTeam.Form
		
		local IsDebounce = Match.Debounces.Team[Index]
		
		if IsDebounce == true then return false end
		
		local CurrentMoney = Fusion.peek(Match.Money)
		local Cost = RunService:IsStudio() and 0 or UnitInfo.Cost 

		if CurrentMoney >= Cost then
			Match.SpawnUnit(UnitName, {
				Form = Form,
				Level = Level, 
			})
			Remotes.PlaceUnit:FireClient(Player, Index)

			Match.Debounces.Team[Index] = true

			task.delay(UnitInfo.Cooldown or 7, function()
				Match.Debounces.Team[Index] = false
			end)
			
			Quests.Progress(Player, "UnitDeploy")

			Match.Money:set(Fusion.peek(Match.Money) - Cost)
			
			return true
		end
		
		return false
	end)

	Remotes.UpgradeWallet.OnServerInvoke = function()
		local Level = Fusion.peek(Match.Upgrades.Wallet)
		local CurrentMoney = Fusion.peek(Match.Money)
		local Price = Tweaks.WalletCost(Level)
		
		if Level >= MAX_WALLETLEVEL then
			-- do nun
		else
			if CurrentMoney > Price then
				Match.Money:set(Fusion.peek(Match.Money) - Price)
				Match.Upgrades.Wallet:set(Fusion.peek(Match.Upgrades.Wallet) + 1)
				return Fusion.peek(Match.Upgrades.Wallet)
			end
		end

		return Fusion.peek(Match.Upgrades.Wallet)
	end

	Remotes.UseAbility.OnServerInvoke = function(Player)
		local BaseAbilityDebounce = Match.Debounces.BaseAbility
		
		if BaseAbilityDebounce then
			return false
		end
		
		Match.Debounces.BaseAbility = true
			
		local Type = Upgrades.Get(Player).BaseAbility or "Cannon"
		BaseAbilities[Type](false)
		
		task.delay(Tweaks.BaseAbilityCooldown or 30, function()
			Match.Debounces.BaseAbility = false
		end)
		
		return true
	end
	
	do
		local Listeners = {
			["RequestRevive"] = function(Player)
				--local IsSuccess, Result = pcall(function()
					--local Reward = AdService:CreateAdRewardFromDevProductId(Products.DevProducts.Revive)
					--return AdService:ShowRewardedVideoAdAsync(Player, Reward)
				--end)
				--if IsSuccess then
					--if Result then
				
			end,
			
			["RequestNextStage"] = function(Player)
				if Fusion.peek(Match.EnemyIsDead) then
					Match.NextStage()
				end
			end,
			
			["RequestLobby"] = function(Player)
				TeleportService:TeleportAsync(Teleports.Lobby, {Player})
			end,
		}
		
		Remotes.Game.OnServerInvoke = function(Player, EventName, ...)
			if Listeners[EventName] then
				Listeners[EventName](Player, ...)
			end
		end
	end
end

function Match.GameStart()
	Quests = require("./Quests")	
	PlayerStats = require("./Stats")
	Boosts = require("./Boosts")
	Physics:RegisterCollisionGroup("Unit")
	Physics:RegisterCollisionGroup("Effect")
	Physics:RegisterCollisionGroup("Base")
	Physics:CollisionGroupSetCollidable("Unit", "Unit", false)
	Physics:CollisionGroupSetCollidable("Effect", "Unit", false)
	Physics:CollisionGroupSetCollidable("Effect", "Base", false)
	
	Upgrades = require("./Upgrades")
	
	local Tutorial = require("./Tutorial")
	
	Player = Players:GetChildren()[1] or Players.PlayerAdded:Wait() 
	
	wait(3)
	
	local JoinData = Player:GetJoinData()
	local TeleportData = JoinData.TeleportData or {}
	--local Chapter = TeleportData.Chapter or 1
	local IsStory = TeleportData.Story and true or false
	local IsEvent = TeleportData.Event and true or false 
	--local Stage = if RunService:IsStudio() then if IsStory then TeleportData.Story.Stage else TeleportData.Event.Stage else 1
	local Stage = if RunService:IsStudio() then
		1
	else
		if IsStory then
			TeleportData.Story.Stage
		else
	 		TeleportData.Event.Stage
		
	local Chapter = if RunService:IsStudio() then
		1
	else 
		if IsStory then
			TeleportData.Story.Chapter
		else nil
		
		
	local ShowTutorial = TeleportData.Tutorial or false
	--ShowTutorial = if RunService:IsStudio() then true else ShowTutorial
	
	Match.StageType:set(IsStory and "Story" or IsEvent and "Event" or "Story")
	Match.Stage:set(Stage)
	Match.Chapter:set(Chapter)
	
	Match.HandleEvents()
	
	local PlayerJoin = function(Player)
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local MainInterface = game:GetService("StarterGui"):WaitForChild("Main"):Clone()
		local NotificationInterface = game:GetService("StarterGui"):WaitForChild("Notifs"):Clone()
		NotificationInterface.Parent = PlayerGui
		local Money = MainInterface:WaitForChild("Money")
		local UpgradeButton = MainInterface.Actions:WaitForChild("Wallet")
		
		local HealthInterface = game:GetService("StarterGui"):WaitForChild("Health"):Clone()
		HealthInterface.Parent = PlayerGui
		
		local DialogueInterface = game:GetService("StarterGui"):WaitForChild("Dialogue"):Clone()
		DialogueInterface.Parent = PlayerGui
		DialogueInterface.Enabled = false

		Match:Hydrate(UpgradeButton.Level) {
			Text = Match:Computed(function(Use)
				return `{Use(Match.Upgrades.Wallet)}`
			end)
		}

		MainInterface.Parent = PlayerGui

		Match:Hydrate(Money) {
			Text = Match:Computed(function(Use)
				local MaxMoney = Tweaks.CalcMaxMoney(Use(Match.Upgrades.Wallet))
				return `${Use(Match.Money)}/${MaxMoney}`
			end)
		}
	end
	
	PlayerJoin(Player)
	
	local Sucess, Profile = Data.GetProfile(Player):await()
	
	if not Sucess or not Profile then
		return
	end
	
	Match.Team = table.clone(Profile.Data.Team)
	
	if ShowTutorial then
		--Match.Team = {{Name = "TungTungSahur", Form = "Base"}, {Name = "TiTiTiSahur", Form = "Base"}, {Name = "GangsterFootera", Form = "Base"}}
	end
	
	if RunService:IsStudio() then
		--Match.Team = {{Name="CarrotiniBrainini", Form = "Base"}, {Name="ExtinctTralalero", Form = "Base"}}
		Match.Team = {{Name = "Tralalero", Form = "Base"},{Name = "OdinDinDinDun", Form = "Base"}, {Name = "Tralalero", Form = "Evolved"} }
	end

	for Index, Unit in pairs(Match.Team) do
		if Unit.Name == "" or Unit.Name == nil then
			continue
		end

		local BrainrotData = Profile.Data.Brainrots[Unit.Name]

		if BrainrotData then
			Unit.Level = BrainrotData.Level
			Unit.Form = BrainrotData.Form
		else
			Unit.Level = Unit.Level or 1
			Unit.Form = Unit.Form or "Base"
		end
	end

	Match.HandleBases()
	
	Match.LoadScenery()
	
	print("scenery loaded")

	wait(3)

	for _, Player in pairs(Players:GetChildren()) do
		Remotes.Game:InvokeClient(Player,"Starting", Match.Team)
	end
	
	wait(3)
	
	Match.GenerateMoney()
	Match.StartWaves()
	
	task.spawn(function()
		for _, Player in pairs(Players:GetPlayers()) do
			Remotes.Game:InvokeClient(Player, "Running")
		end
	end)
	
	local StageInfo = Match.GetStageInfo(Fusion.peek(Match.StageType), {Chapter = Fusion.peek(Match.Chapter), Stage = Fusion.peek(Match.Stage)})
	
	Music:Set(StageInfo.SoundTrack)
	Music:Play()
	
	if ShowTutorial then
		Tutorial.Start()
	end
end

function Match.ResetWallet()
	Match.Upgrades.Wallet:set(0)
	Remotes.Game:InvokeClient(Player, "ResetWallet")
end

function Match.Revive()
	
end

function Match.LoadScenery()
	local StageInfo = Match.GetStageInfo(Fusion.peek(Match.StageType),{Chapter = Fusion.peek(Match.Chapter), Stage = Fusion.peek(Match.Stage)})
	local TargetScenery = StageInfo.Scenery or "Grasslands"
	
	Remotes.Replicate:FireAllClients("LoadScenery", TargetScenery)
end

function Match.StopGeneratingMoney()
	local LoopAlreadyExists = Match.__GeneratingMoney :: thread
	if LoopAlreadyExists then
		coroutine.close(LoopAlreadyExists)
		Match.__GeneratingMoney = nil
	end
end

function Match.NextStage()
	Match.LoadScenery()
	Live.ClearAll()
	Match.StopGeneratingMoney()
	Match.ResetWallet()

	Match.EnemyIsDead:set(false)
	Match.PlayerIsDead:set(false)
	Match.Money:set(0)
	Match.Upgrades.Wallet:set(1)
	
	task.spawn(function()
		for _, Player in pairs(Players:GetPlayers()) do
			Remotes.Game:InvokeClient(Player, "Running")
		end
	end)
	
	local CurrentChapter = Fusion.peek(Match.Chapter)
	local Length = #StoryChapters[CurrentChapter].Stages
	local NextStage = Fusion.peek(Match.Stage) + 1
	
	if NextStage > Length then
		--Match.Chapter:set(CurrentChapter + 1)
		NextStage = 1
	end
	
	Match.Stage:set(NextStage)	
	
	local CurrentStageInfo = Match.GetStageInfo(Fusion.peek(Match.StageType),{Chapter =Fusion.peek(Match.Chapter), Stage =Fusion.peek(Match.Stage)} )
	
	local Bases = workspace.Map.Bases
	local PlayerBase = Bases:WaitForChild("1")
	local EnemyBase = Bases:WaitForChild("2")

	local PlayerHealth = PlayerBase:WaitForChild("BaseHealth")
	local EnemyHealth = EnemyBase:WaitForChild("BaseHealth")

	PlayerHealth.Value = PlayerHealth.MaxValue
	EnemyHealth.MaxValue = CurrentStageInfo.EnemyBaseHealth or 500
	EnemyHealth.Value = EnemyHealth.MaxValue
	
	task.delay(3, function()
		Match.GenerateMoney()
		Match.StartWaves()
	end)
end

function Match.StopSpawning()
	local LoopAlreadyExists = Match.__WaveSpawning :: thread

	if LoopAlreadyExists then
		coroutine.close(LoopAlreadyExists)
		Match.__WaveSpawning = nil
	end
end

function Match.StartWaves()
	local Chapter = Fusion.peek(Match.Chapter)
	local Stage = Fusion.peek(Match.Stage)
	
	local function GetUnitCount(Name)
		local Count = 0
		for _, Unit in pairs(Live.EnemyUnits) do
			if Unit.Name and Unit.Name == Name then
				Count += 1
			else
				continue
			end
		end
		return Count
	end	
	
	local LoopAlreadyExists = Match.__WaveSpawning :: thread
	
	if LoopAlreadyExists then
		Match.StopSpawning()
	end
	
	local Elapsed = 0
	
	Match.__WaveSpawning = task.spawn(function()
		local IsAlive = not Fusion.peek(Match.EnemyIsDead)
		
		while IsAlive do
			IsAlive = not Fusion.peek(Match.EnemyIsDead)
			
			local StageData = Match.GetStageInfo(Fusion.peek(Match.StageType), {Chapter = Chapter, Stage = Stage})
			local PossibleEnemies = StageData.Enemies
			
			local TimeScale = Fusion.peek(Match.TimeScale)
			
			for i=1, #PossibleEnemies do
				local Enemy = PossibleEnemies[i]
				local Count = GetUnitCount(Enemy.Name)
				local Interval = Enemy.Interval or 10
				local Limit = Enemy.Limit or 1
				local Spawned = Count >= Limit
				local TimeShouldSpawn = Enemy.SpawnTime 
				local ShouldSpawn = --[[((math.round(Elapsed) % Interval) == 0) or ((math.round(Elapsed)) == TimeShouldSpawn)and ]]  not Spawned
				local Level = Enemy.Level or 1
				local Form = Enemy.Form or "Base"	

				if TimeScale == 0 then
					continue
				end
				
				if ShouldSpawn then
					wait(Interval / TimeScale)
					Match.SpawnUnit(Enemy.Name, { Enemy = true, Form = Form, Level = Level })
					continue
				end
			end
			
			Elapsed += wait(1 / TimeScale)
		end
	end)
	
	Match.HandleDeath()
end

function Match.HandleDeath()	
	local Bases = workspace.Map.Bases
	local EnemyBase = Bases:WaitForChild("2")
	local PlayerBase = Bases:WaitForChild("1")

	local PlayerHealth = PlayerBase:WaitForChild("BaseHealth")
	local EnemyHealth = EnemyBase:WaitForChild("BaseHealth")

	local CurrentStageInfo = Match.GetStageInfo(Fusion.peek(Match.StageType), {Chapter=Fusion.peek(Match.Chapter), Stage=Fusion.peek(Match.Stage)})

	
	local function UnlockNextStage()
		local Success, Profile = Data.GetProfile(Player):await()
		
		if not Success then
			return false
		end
		
		local CurrentChapter = Fusion.peek(Match.Chapter)
		local CurrentStage = Fusion.peek(Match.Stage)
		local NextStage = CurrentStage + 1
		
		local TotalStagesInChapter = #StoryChapters[CurrentChapter].Stages
		local IsLastStage = CurrentStage == TotalStagesInChapter
		
		if not IsLastStage then
			Profile.Data.ChapterData[Fusion.peek(Match.StageType)][CurrentChapter].Stages[NextStage].IsLocked = false	
		end
	end
	
	local function CheckIfAlreadyClaimed()
		local Player = Players:GetPlayers()[1]
		local Success, Profile = Data.GetProfile(Player):await()
		
		if not Success then
			return false
		end
		
		local CurrentChapter = Fusion.peek(Match.Chapter)
		local CurrentStage = Fusion.peek(Match.Stage)
		
		local Sucess, IsClaimed = pcall(function()
			return Profile.Data.ChapterData[Fusion.peek(Match.StageType)][CurrentChapter].Stages[CurrentStage].Completed
		end)
		
		if Sucess and IsClaimed then
			return true
		else
			return false 
		end
	end

	local function GiveRewards()
		local AlreadyClaimed = CheckIfAlreadyClaimed()
		
		if AlreadyClaimed then
			return 
		end
		
		for _, Player in pairs(Players:GetPlayers()) do
			for _, Reward in pairs(CurrentStageInfo.Rewards) do
				local ShouldDoubleGems = Boosts.Has(Player, "DoubleGems")
				local ShouldDoubleXP = Boosts.Has(Player, "DoubleXP")
				--local ShouldDoubleLuck = Boosts.Has("DoubleLuck")
				
				local DataCopy = table.clone(Reward)
				DataCopy.Data.Amount = (DataCopy.Type == "Gems" and ShouldDoubleGems) and math.round(DataCopy.Data.Amount * 2) or DataCopy.Data.Amount
				DataCopy.Data.Amount = (DataCopy.Type == "XP" and ShouldDoubleXP) and math.round(DataCopy.Data.Amount * 2) or DataCopy.Data.Amount
					
				Rewards.Give(Player, DataCopy.Type, DataCopy.Data)
			end
		end
	end
	
	local function CompleteStage()
		local Success, Profile = Data.GetProfile(Player):await()
		
		if not Success then
			return 
		end
		
		Quests.Progress(Player, "StageClear")
		
		local CurrentChapter = Fusion.peek(Match.Chapter)
		local CurrentStage = Fusion.peek(Match.Stage)
		
		local StageType = Fusion.peek(Match.StageType)
		local Success, StageInfo = pcall(function()
			return Profile.Data.ChapterData[Fusion.peek(Match.StageType)][CurrentChapter].Stages[CurrentStage]
		end)
		
		if Fusion.peek(Match.StageType) == "Story" then
			Quests.Progress(Player, `StoryStageClear_{Fusion.peek(Match.Chapter)}_{Fusion.peek(Match.Stage)}`)
		end
		
		if Success and StageInfo then
			StageInfo.Completed = true
		end
	end
	
	local function HasNextStageUnlocked()
		local Player = Players:GetPlayers()[1]
		local Success, Profile = Data.GetProfile(Player):await()
		
		local StageType = Fusion.peek(Match.StageType)

		
		if not Success then
			return false
		end
		
		if Fusion.peek(Tutorial.IsActive)  then
			return false
		end
		
		local Success, OverTotalChapters = pcall(function()
			local CurrentChapter = Fusion.peek(Match.Chapter)
			local CurrentStage = Fusion.peek(Match.Stage)
			local NextStage = CurrentStage + 1
			
			local TotalStagesInChapter = if StageType == "Story" then #StoryChapters[CurrentChapter].Stages else #EventStages
			
			return NextStage > TotalStagesInChapter 
		end)
		
		if Success then
			if OverTotalChapters then
				return false
			else
				local Sucess, IsUnlocked = pcall(function()
					local CurrentChapter = Fusion.peek(Match.Chapter)
					local CurrentStage = Fusion.peek(Match.Stage)
					local NextStage = CurrentStage + 1
					local TotalStagesInChapter = #StoryChapters[CurrentChapter].Stages	
					return if StageType == "Story" then Profile.Data.ChapterData[Fusion.peek(Match.StageType)][CurrentChapter].Stages[NextStage].IsLocked == false else false
				end)
				
				if not Success or not IsUnlocked then
					return false
				end
				
				return IsUnlocked
			end
		else
			return false
		end
	end

	local Events = {}
	
	Events[1] = PlayerHealth.Changed:Connect(function() -- death cond
		if PlayerHealth.Value == 0 then	
			Events[1]:Disconnect()
			Events[2]:Disconnect()

			Match.PlayerIsDead:set(true)
			
			for _, Player in pairs(Players:GetPlayers()) do
				task.spawn(function()
					Remotes.Game:InvokeClient(Player, "End", {Failed = true, Rewards = {}})
				end)
			end
		end
	end)

	Events[2] = EnemyHealth.Changed:Connect(function() -- win cond
		if EnemyHealth.Value == 0 then	
			Events[1]:Disconnect()
			Events[2]:Disconnect()

			Match.EnemyIsDead:set(true)
			
			spawn(function()
				PlayerStats.Add(Player, "GamesWon", 1)
				PlayerStats.AddWeekly(Player, "GamesWon", 1)
			end)
			
			if Fusion.peek(Tutorial.IsActive) then
				spawn(function()
					for _, Player in pairs(Players:GetPlayers()) do
						local Sucess, Profile = Data.GetProfile(Player):await()
						if Sucess and Profile then
							Profile.Data.Tutorial.IsBattleCompleted = true
						end
					end
				end)
			end
			
			local IsCompleted = CheckIfAlreadyClaimed() 
			
			GiveRewards()
			CompleteStage()
			UnlockNextStage()
			
			--spawn(function()
			--end)
			
			--print("")

			for _, Player in pairs(Players:GetPlayers()) do
				task.spawn(function()
					Remotes.Game:InvokeClient(Player, "End", {Failed = false, IsNextStage = HasNextStageUnlocked(), Rewards = IsCompleted and {} or CurrentStageInfo.Rewards})
				end)
			end
		end
	end)
end

function Match.GenerateMoney()
	Match.__GeneratingMoney = task.spawn(function()
		while wait(.1/Fusion.peek(Match.TimeScale)) do
			local BankSize = Tweaks.CalcMaxMoney(Fusion.peek(Match.Upgrades.Wallet))
			local MaxMoney = BankSize + (BankSize * ((Upgrades.Get(Player).Income or 1) * 0.05))
			Match.Money:set(math.clamp(Fusion.peek(Match.Money) + (1 * (Upgrades.Get(Player).Income	 or 1)), 0, MaxMoney))
		end
	end)	
end

function Match.SpawnUnit(UnitName, Config)
	local ZOffset = math.random(-3.5, 3.5)
	
	local IsEnemy = Config and Config.Enemy or false
	local Form = Config and Config.Form or "Base"
	local Level = Config and Config.Level or 1
	local Skin = Config and Config.Skin or "Default"
	
	local Statuses = {
		Frozen = Match:Value(false),
		Stunned = Match:Value(false),
		Slow = Match:Value(false),
		HyperArmor = Match:Value(false),
		StrUp = Match:Value(false),
	}
	
	local UnitInfo = UnitInfo[UnitName]
	
	local Unit = Assets.Rots:WaitForChild(UnitName):WaitForChild(Form):WaitForChild(Skin):Clone()
	Unit.Parent = workspace.Live
	
	do
		local Dump = Trove.new()

		Match:Observer(Statuses.StrUp):onChange(function()
			local State = Fusion.peek(Statuses.StrUp)
			local CursedAura = Assets.Gameplay.Cursed:Clone()
			if State == true then
				local Limbs = Unit:GetDescendants()
				for _, Limb in pairs(Limbs) do
					if Limb:IsA("BasePart") then
						for _, Aura in pairs(CursedAura:GetChildren()) do
							local Clone = Aura:Clone()
							Clone.Parent = Limb
							Dump:Add(Clone)
						end
					end
				end
			else
				Dump:Destroy()
			end
		end)
	end
	
	local UnitOutline = Unit:FindFirstChildOfClass("Highlight")
	
	assert(UnitOutline, `Unit does not have a outline: {UnitName}`)
	
	Match:Hydrate(UnitOutline) {
		FillColor = Match:Computed(function(Use)
			local Slowed = Use(Statuses.Slow)
			
			if Slowed then
				return Color3.new(1, 0.333333, 1)
			end
			
			return Use(Statuses.Frozen) and Color3.new(0, .8, .9) or Color3.new(1,1,1)
		end),
		
		FillTransparency =  Match:Computed(function(Use)
			return (Use(Statuses.Frozen) or Use(Statuses.Slow)) and 0.5 or 1
		end)
	}

	local StatusUI = Assets.Gameplay.StatusesUI:Clone()
	StatusUI.Parent = Unit
	
	--task.spawn(function()
		for Name, Status in pairs(Statuses) do
			local Image = StatusUI.Inner:FindFirstChild(Name)
			if Image then
				Match:Hydrate(Image) {
					Visible = Status
				}
			end
		end
	--end)

	--task.spawn(function()
	for _, Part in pairs(Unit:GetChildren()) do
		if Part:IsA("BasePart") then
			Part.CollisionGroup = "Unit"
		end
	end
	--end)

	local Cleaner = Trove.new()
	local UnitScope = Fusion.scoped(Fusion)
	
	local Base = IsEnemy and workspace.Map.Bases["2"] or workspace.Map.Bases["1"]  
	local EnemyBase = IsEnemy and workspace.Map.Bases["1"] or workspace.Map.Bases["2"]
	
	Unit:PivotTo(Base.UnitSpawnPoint.WorldCFrame)

	local FrozenWhen = -1
	local SlowedWhen = -1
	local StrUpWhen = -1
	
	local Animations = {}
	
	local function Freeze(Duration)
		Duration = Duration or 5
		local IsFrozen = Fusion.peek(Statuses.Frozen)
		local IsStunned = Fusion.peek(Statuses.Stunned)
		if IsStunned then
			return 
		end

		FrozenWhen = tick()

		if IsFrozen then
			return
		end

		Statuses.Frozen:set(true)
		
		task.delay(Duration, function() 
			IsFrozen = Fusion.peek(Statuses.Frozen)
			if IsFrozen then
				local Diff = tick() - FrozenWhen
				if Diff >= Duration then
					Statuses.Frozen:set(false)
				end
			end
		end)
	end
	
	local function Knockback()
		if Fusion.peek(Statuses.HyperArmor) then
			--local ParrySound = Assets.Sounds.Parry:Clone()
			--ParrySound.Parent = Unit

			Remotes.Replicate:FireAllClients("Parry", Unit.Body:GetPivot())

			--wait(.1)
			
			--ParrySound:Play()
			
			--ParrySound.Ended:Connect(function()
				--ParrySound:Destroy()
			--end)
			return
		end
		
		Animations.Knockback.Priority = Enum.AnimationPriority.Action4
		Animations.Knockback:Play()

		local Unit = Unit :: Model
		local Body = Unit:FindFirstChild("Body")

		if Body and Unit then
			Unit.PrimaryPart.Velocity = Vector3.xAxis *  (IsEnemy and 1 or -1) * -20 + Vector3.new(0, 55, 0)
		else
			return
		end

		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = { workspace.Live }
		Params.RespectCanCollide = true
		Params.IgnoreWater = true

		Statuses.Stunned:set(true) 

		local GroundRay = workspace:Raycast(Body.Position, Vector3.new(0, -10, 0), Params)

		repeat 
			GroundRay = workspace:Raycast(Body.Position, Vector3.new(0, -10, 0), Params) 
			wait(1)
		until  GroundRay ~= nil

		wait(.15)

		Statuses.Stunned:set(false) 

		Animations.Knockback:Stop()
	end
	
	local function StrUp(Duration)
		Duration = Duration or 5
		local IsStrong = Fusion.peek(Statuses.StrUp)
		StrUpWhen = tick()

		if IsStrong then
			return
		end

		Statuses.StrUp:set(true)	
		
		task.delay(Duration, function()
			IsStrong = Fusion.peek(Statuses.StrUp)
			if IsStrong then
				local Diff = tick() - StrUpWhen
				print(Diff)
				if Diff >= Duration then
					Statuses.StrUp:set(false)
				end
			end
		end)
	end
	
	local function Slow(Duration)
		Duration = Duration or 5
		local IsSlowed = Fusion.peek(Statuses.Slow)
		local IsStunned = Fusion.peek(Statuses.Stunned)
		if IsStunned then
			return 
		end
		SlowedWhen = tick()

		if IsSlowed then
			return
		end

		Statuses.Slow:set(true)	
		
		task.delay(Duration, function() 
			IsSlowed = Fusion.peek(Statuses.Slow)
			if IsSlowed then
				local Diff = tick() - SlowedWhen
				if Diff >= Duration then
					Statuses.Slow:set(false)
				end
			end
		end)
	end
	
	Cleaner:Add(Unit)
	
	local UniqueData = {
		Name = UnitName,
		Model = Unit,
		Statuses = Statuses,
		Freeze = Freeze,
		Slow = Slow,
		Knockback = Knockback,
		Cleaner = Cleaner,
		Level = Level,
		UUID = Http:GenerateGUID(false),
	}

	Unit.Name = UniqueData.UUID

	table.insert(IsEnemy and Live.EnemyUnits or Live.Units, 1, UniqueData)
	

	local Animator = Unit:WaitForChild("AnimationController"):WaitForChild("Animator") :: Animator

	for AnimationName, Animation in pairs(UnitInfo.Animations[Form]) do
		Animations[AnimationName] = Animator:LoadAnimation(Animation)
		
		Animations[AnimationName].Priority = if AnimationName == "Idle" or AnimationName == "Walk" then
			Enum.AnimationPriority.Movement
		else
			Enum.AnimationPriority.Action4
	end
	
	Animations.Walk:Play()
	
	local Posture = UnitScope:New("IntConstrainedValue") {
		Name = "Posture", 
		Value = UnitInfo[Form].Posture,
		MaxValue = UnitInfo[Form].Posture,
		MinValue = 0,
		Parent = Unit
	}

	local Health = UnitScope:New("IntConstrainedValue") {}

	UnitScope:Hydrate(Health) {
		Name = "Health",
		Value = UnitInfo[Form].Health,
		MaxValue = UnitInfo[Form].Health,
		MinValue = 0,
		Parent = Unit,
		[Fusion.OnEvent("Changed")] = function()
			--if Statuses.Knockback then
			Knockback()
			
			local Origin = Unit:GetPivot()
			
			--local DeathEffects = 
			
			if Health.Value <= 0 then
				local ChosenList = IsEnemy and Live.EnemyUnits or Live.Units
				for Index, Enemy in pairs(ChosenList) do
					if Enemy.Model == Unit then
						--ChosenList[Index] = nil
						Remotes.Replicate:FireAllClients("Death", Origin)
						Cleaner:Destroy()
						--Unit:Destroy()
						table.remove(ChosenList, Index)
					else
						continue
					end
				end
				
				if IsEnemy then
					Match.Money:set(math.floor(Fusion.peek(Match.Money) + UnitInfo.Cost / 2))
					Quests.Progress(Player, "MobKill")
				end
			end
		end,
	}

	Cleaner:Add(task.spawn(function()
		local function GetTarget()
			local Units = IsEnemy and Live.Units or Live.EnemyUnits
			local Closest = nil
			local ClosestDistance = math.huge
			local Range = UnitInfo[Form].Range or 10
			local UnitPos = Unit:GetPivot().Position

			for i = 1, #Units do
				local Enemy = Units[i]
				local EnemyBody = Enemy.Model:FindFirstChild("Body")
				if not EnemyBody then continue end

				local Distance = (EnemyBody.Position - UnitPos).Magnitude
				if Distance <= Range and Distance < ClosestDistance then
					ClosestDistance = Distance
					Closest = Enemy.Model
				end
			end

			return Closest
		end
		
		local InRangeOfTarget = false
		local Target = nil
		local LastTimeSinceAttack = -1
		local IsAttacking = false
		
		Cleaner:Add(RunService.Heartbeat:Connect(function()
			--local IsFrozen = Fusion.peek(Statuses.Frozen)
			--local IsSlowed = Fusion.peek(Statuses.Slow)

			Target = GetTarget()
			
			local Body = Unit:FindFirstChild("Body")

			if Body == nil then
				Cleaner:Destroy()
				return
			end

			local CFrame_ = Body.CFrame
			local x, y, z = CFrame_:ToOrientation()
			Unit:PivotTo(CFrame.new(Unit:GetPivot().p) * CFrame.Angles(0, not IsEnemy and math.rad(180) or 0, 0))
			
			local Position = Unit:GetPivot().Position 
			local BaseSpawnPosition = Base.UnitSpawnPoint.CFrame.p
			local Rotation = Unit:GetPivot().Rotation
				
			Unit:PivotTo(CFrame.new(Position.X, Position.Y, BaseSpawnPosition.Z + ZOffset) * Rotation)
			
			if Target then
				local UnitHasBody = Target:FindFirstChild("Body")
				local UnitRange = UnitInfo[Form].Range or 10
				if UnitHasBody then
					InRangeOfTarget = Target and (Unit.Body.CFrame.Position - UnitHasBody.CFrame.Position).Magnitude < (UnitRange)
				else
					InRangeOfTarget = false
				end
			end
		end))
		
		while Unit:IsDescendantOf(workspace.Live) do
			local Target = GetTarget()
			
			if Fusion.peek(Statuses.Slow) then
				for _, Animation in pairs(Animations) do
					Animation:AdjustSpeed(0.25)
				end
			elseif Fusion.peek(Statuses.Frozen) == true then
				for _, Animation in pairs(Animations) do
					Animation:AdjustSpeed(0)
				end

				wait(.1 / Fusion.peek(Match.TimeScale))
				continue 
			else
				for AnimationName, Animation in pairs(Animations) do
					local RightSpeed = UnitInfo.Animations.Speed[AnimationName] or 1
					Animation:AdjustSpeed(Fusion.peek(Match.TimeScale) * RightSpeed)
				end
			end
		
			
			if IsAttacking then
				wait(.1 / Fusion.peek(Match.TimeScale))
				continue
			end
			
			if Fusion.peek(Statuses.Stunned) == true then 
				wait(0.1 / Fusion.peek(Match.TimeScale))
			continue end
			
			if InRangeOfTarget and Target then
				Unit.Body.Velocity = Vector3.new(0, 0, 0)
				
				if Fusion.peek(Statuses.Stunned) == true or Fusion.peek(Statuses.Frozen) == true then
					wait(0.1 / Fusion.peek(Match.TimeScale))
				continue end
			
				if Animations.Walk.IsPlaying then
					Animations.Walk:Stop()
				end
				
				if not Animations.Idle.IsPlaying then
					Animations.Idle:Play()
				end
				
				if (tick() - LastTimeSinceAttack > (((UnitInfo[Form].AttackSpeed or 1) / Fusion.peek(Match.TimeScale))) / (Fusion.peek(Statuses.Slow) and .25 or 1)) and not IsAttacking then
					IsAttacking = true

					if Fusion.peek(Statuses.Stunned) == true or Fusion.peek(Statuses.Frozen) == true then 
						wait(0.1 / Fusion.peek(Match.TimeScale))
					continue end

					--if Animations.Walk.IsPlaying then
					--	Animations.Walk:Stop()
					--end

					--if Animations.Idle.IsPlaying then
					--	Animations.Idle:Stop()
					--end
					
					task.spawn(function()
						Attacks[UnitInfo[Form].AttackVisual or "Default"]({ 
							Unit = Unit,
							UnitName = UnitName, 
							Target = Target, 
							IsEnemy = IsEnemy, 
							Animations = Animations,
							Form = Form,
							Level = Level,
							
							Freeze = Freeze,
							Knockback = Knockback,
							Slow = Slow,
							StrUp = StrUp,
							
							ActiveStatuses = Statuses,
							
							EndAttack = function()
								IsAttacking = false
								LastTimeSinceAttack = tick()
							end,
						})
					end)
				end
			else
				if not Animations.Walk.IsPlaying then
					Animations.Walk:Play()
				end
				
				if Animations.Attack.IsPlaying then
					Animations.Attack:Stop()
					LastTimeSinceAttack = tick()
				end
				
				if not Fusion.peek(Statuses.Stunned) then
					Unit.PrimaryPart.Velocity = Vector3.xAxis * (Fusion.peek(Match.TimeScale) * UnitInfo[Form].Speed or 5) * (IsEnemy and 1 or -1) / (Fusion.peek(Statuses.Slow) and 2 or 1)
				end
			end
		
			wait(0.1 / Fusion.peek(Match.TimeScale))
		end
	end))
end

return Match