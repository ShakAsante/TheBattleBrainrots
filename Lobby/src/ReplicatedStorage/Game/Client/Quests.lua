local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Packages = Root:WaitForChild("Shared"):WaitForChild("Packages")
local Fusion = require(Packages.Fusion)

local Quests = Fusion:scoped()
Quests.DailyQuests = Quests:Value({})
Quests.WeeklyQuests = Quests:Value({})
Quests.LifetimeQuests = Quests:Value({})
Quests.SeasonQuests = Quests:Value({})

Quests.NotifDaily = Quests:Value(false)
Quests.NotifWeekly = Quests:Value(false)
Quests.NotifSeason = Quests:Value(false)
Quests.NotifLifetime = Quests:Value(false)
Quests.CurrentSection = Quests:Value("Daily")

local Remotes = Root:WaitForChild("Remotes")

local function QuestItem(Value, Section)
	local QuestName = Quests:Computed(function()
		return Value.Name
	end)

	local QuestDescription = Quests:Computed(function()
		return Value.Description
	end)

	local QuestGoal = Quests:Computed(function()
		return Value.Goal
	end)

	local QuestProgress = Quests:Computed(function()
		return Value.Progress
	end)

	local QuestCompleted = Quests:Computed(function(Use)	
		return Use(QuestProgress) >= Use(QuestGoal)
	end)
	
	local IsSeasonal = Section == "Season"

	local Template = script.Template:Clone()

	Quests:Hydrate(Template.Body.Header) {
		Text = QuestName
	}

	Quests:Hydrate(Template.Body.Info) {
		Text = QuestDescription
	}

	Quests:Hydrate(Template.Complete) {
		Visible = Value.Completed
	}

	local Inner = Template.Body.Inner
	local Claim = Inner.Claim
	local Reward = Inner.Reward
	local QuestBar = Template.Body.QuestProgress
	local Bar = QuestBar.Bar


	Quests:Hydrate(Reward.Seasonal) {
		Enabled = IsSeasonal
	}
	
	Quests:Hydrate(Reward.Normal) {
		Enabled = not IsSeasonal
	}

	local ProgressText = Quests:Computed(function(Use)
		local Ratio = math.clamp(Use(QuestProgress) / Use(QuestGoal), 0, 1)
		return `{Use(QuestProgress)}/{Use(QuestGoal)} ({math.floor(Ratio * 100) }%)`
	end)

	Quests:Hydrate(QuestBar.TextLabel) {
		Text = ProgressText
	}

	Quests:Hydrate(Bar) {
		Size = Quests:Spring(Quests:Computed(function(Use)
			return UDim2.new(math.clamp(Use(QuestProgress) / Use(QuestGoal),0,1), 0, 1, 0)
		end), 25, .5)
	}

	Quests:Hydrate(Claim) {
		Visible = QuestCompleted or not Value.Completed,
		[Fusion.OnEvent("Activated")] = function()
			if Value.Completed then
				return
			end
			
			Remotes.Quests.Claim:InvokeServer(Value.UUID)
		end,
	}

	Quests:Hydrate(Template) {
		Visible = Quests:Computed(function(Use)
			return Use(Quests.CurrentSection) == Section
		end),
		LayoutOrder = Quests:Computed(function(Use)
			return Use(QuestCompleted) and -1 or 1
		end)
	}

	Quests:Hydrate(Reward) {
		Text = `+{Value.Reward} {IsSeasonal and "Season XP" or "Gems"}`
	}

	return Template
end

function Quests.GameStart()
	Purchase = require("./Purchase")
	Interface = require("./Interface")
	InterfaceTools = require("./InterfaceTools")
	Products = require(Root.Assets.Products)
	
	MainInterface = InterfaceTools.GetInterface("Main")
	
	local LeftButtons = MainInterface.LeftBar
	local QuestButton = LeftButtons.Quests
	
	local ShouldShowNotif = Quests:Computed(function(Use)
		return Use(Quests.NotifDaily) or  Use(Quests.NotifWeekly) or Use(Quests.NotifLifetime)
	end)
	
	Quests:Hydrate(QuestButton.Upper.Notification) {
		Visible = ShouldShowNotif
	}
	

	local Listeners = {
		["UpdateDailyQuests"] = function(QuestData)
			for _, Data in pairs(QuestData) do
				if Data.Progress >= Data.Goal then
					Quests.NotifDaily:set(true)
				else
					continue
				end
			end
			
			Quests.DailyQuests:set(QuestData)
		end,
		
		["UpdateWeeklyQuests"] = function(QuestData)
			for _, Data in pairs(QuestData) do
				if Data.Progress >= Data.Goal then
					Quests.NotifWeekly:set(true)
				else
					continue
				end
			end


			Quests.WeeklyQuests:set(QuestData)
		end,
		
		["UpdateLifetimeQuests"] = function(QuestData)
			for _, Data in pairs(QuestData) do
				if Data.Progress >= Data.Goal then
					Quests.NotifLifetime:set(true)
				else
					continue
				end
			end

			Quests.LifetimeQuests:set(QuestData)
		end,
		
		["UpdateSeasonQuests"] = function(QuestData)
			for _, Data in pairs(QuestData) do
				if Data.Progress >= Data.Goal then
					Quests.NotifSeason:set(true)
				else
					continue
				end
			end

			--print(QuestData)
			Quests.SeasonQuests:set(QuestData)
		end,
	}
	
	Remotes.Quests.OnClientEvent:Connect(function(Event, ...)
		local Callback = Listeners[Event]
		if Callback then
			Callback(...)
		end
	end)
	
	local QuestInterface = InterfaceTools.GetInterface("Quests")
	local Body = QuestInterface.Body
	
	local QuestFrame = Body.Quests
	local QuestInner = QuestFrame.Inner
	
	local QuestSectionButtons = Body.LeftHeader

	local SectionButtons = {
		Daily = QuestSectionButtons.DailyQuests,
		Weekly = QuestSectionButtons.WeeklyQuests,
		Lifetime = QuestSectionButtons.LifeTimeQuests,
		Season = Body.RightHeader.Season
	}
	

	local PurchasePassButton = QuestInterface:FindFirstChild("PurchasePass", true)
	
	if PurchasePassButton then
		Quests:Hydrate(PurchasePassButton) {
			[Fusion.OnEvent("Activated")] = function()
				Purchase.PromptProduct(Products.DevProducts.SeasonPass)
			end,
		}
	end
	
	Quests:New("UIStroke") {
		Thickness = .06,
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = .5,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		Parent = Quests:Computed(function(Use)
			local CurrentSection = Use(Quests.CurrentSection)
			return SectionButtons[CurrentSection]
		end)
	}
	
	Quests:Hydrate(SectionButtons.Daily.Notification)
	{
		Visible = Quests.NotifDaily
	}
	

	Quests:Hydrate(SectionButtons.Season.Notification)
	{
		Visible = Quests.NotifSeason
	}

	Quests:Hydrate(SectionButtons.Weekly.Notification)
	{
		Visible = Quests.NotifWeekly
	}

	Quests:Hydrate(SectionButtons.Lifetime.Notification)
	{
		Visible = Quests.NotifLifetime
	}
	
	Quests:Hydrate(SectionButtons.Daily)
	{
		[Fusion.OnEvent("Activated")] = function()
			Quests.NotifDaily:set(false)
			Quests.CurrentSection:set("Daily")
		end,
	}
	
	Quests:Hydrate(SectionButtons.Weekly)
	{
		[Fusion.OnEvent("Activated")] = function()
			Quests.NotifWeekly:set(false)
			Quests.CurrentSection:set("Weekly")
		end,
	}
	
	Quests:Hydrate(SectionButtons.Season) {
		[Fusion.OnEvent("Activated")] = function()
			Quests.NotifSeason:set(false)
			Quests.CurrentSection:set("Season")
		end
	}
	
	Quests:Hydrate(SectionButtons.Lifetime)
	{
		[Fusion.OnEvent("Activated")] = function()
			Quests.NotifLifetime:set(false)
			Quests.CurrentSection:set("Lifetime")
		end,
	}
	
	Quests:Hydrate(QuestInner) {
		[Fusion.Children] = { 
			Quests:ForValues(Quests.DailyQuests, function(Use, _, Value)
				return QuestItem(Value, "Daily")
			end),	
			Quests:ForValues(Quests.SeasonQuests, function(Use, _, Value)
				return QuestItem(Value, "Season")
			end),
			Quests:ForValues(Quests.WeeklyQuests, function(Use, _, Value)
				return QuestItem(Value, "Weekly")
			end),
			Quests:ForValues(Quests.LifetimeQuests, function(Use, _, Value)
				return QuestItem(Value, "Lifetime")
			end)
		}
	}
end

return Quests