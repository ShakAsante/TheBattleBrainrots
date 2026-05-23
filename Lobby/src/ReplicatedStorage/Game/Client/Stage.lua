local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Assets = Root:WaitForChild("Assets")

local Fusion = require(Root.Shared.Packages.Fusion)

local Remotes = Root.Remotes
local UnitInfo = require(Assets.UnitInfo)
local Images = require(Assets.Images)
local GameStages = require(Assets.Stages)[1]

local StageSectionInfo = require(Assets.Stages)[2]
local Chapters = GameStages.Story
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Stage = Fusion.scoped(Fusion)

Stage.Stages = {}
Stage.CurrentChapter = Stage:Value(1)
Stage.Focused = Stage:Value(nil)
Stage.Data = {}
Stage.ShowStageSelection = Stage:Value(false)
Stage.ShowingType = Stage:Value("Story")

function Stage.GameStart()
	Team = require("./Team")
	Tutorial = require("./Tutorial")
	InterfaceTools = require("./InterfaceTools")
	Effects = require("./Effects")
	Interface = require("./Interface")
	
	StagesInterface = InterfaceTools.GetInterface("Stages")
	local Back = StagesInterface.Back
	local Stages = Back.Stages
	
	for Section, SectionData in pairs(GameStages) do
		Stage.Data[Section] = {}
		
		if Section == "Story" then
			for ChapterIndex, Chapter in pairs(SectionData) do
				Stage.Data[Section][ChapterIndex] = { Stages = {} }
				for StageIndex, StageData in pairs(Chapter.Stages) do
					Stage.Data[Section][ChapterIndex].Stages[StageIndex] = {
						Locked = Stage:Value(true),
						Completed = Stage:Value(false),
					}
				end
			end
		else
			for StageIndex, StageInfo in pairs(SectionData) do
				Stage.Data[Section][StageIndex] = {
					Locked = Stage:Value(false),
					Completed = Stage:Value(false),
				}
			end
		end
	end
	
	--for ChapterIndex, Chapter in pairs(Chapters) do
	--	Stage.Data[ChapterIndex] = {
	--		Stages = {},
	--		Locked = Stage:Value(false),
	--	}
		
	--	for StageIndex, StageInfo in pairs(Chapter.Stages) do
	--		Stage.Data[ChapterIndex].Stages[StageIndex] = {
	--			Locked = Stage:Value(true),
	--			Completed = Stage:Value(false),
	--		}
	--	end
	--end
	
	Stage:Hydrate(Stages) {
		Visible = Stage:Computed(function(Use)
			local Show = Use(Stage.ShowStageSelection)
			return Show
		end)
	}
	
	Remotes.Stages.OnClientInvoke = function(Data)
		for Section, Data in pairs(Data) do
			if Section == "Story" then
				for ChapterIndex, Chapter in pairs(Data) do
					for StageIndex, StageData in pairs(Chapter.Stages) do
						--print(StageData, ChapterIndex)
						--print(Stage.Data[Section][Chapter].Stages[StageIndex])
						Stage.Data[Section][ChapterIndex].Stages[StageIndex].Locked:set(StageData.IsLocked)
						wait(.01)
					end
					--Stage.Data[Section][ChapterIndex].Locked:set(Chapter.IsLocked)
				end
			else
				for StageIndex, StageData in pairs(Data) do
					Stage.Data[Section][StageIndex].Locked:set(StageData.IsLocked)
				end
			end
		end
		--for _Content, ContentData in pairs(Data) do
		--	if _Content == "Story" then
		--		for ChapterIndex, Chapter in pairs(ContentData) do
		--			--Stage.Data[_Content][ChapterIndex].Locked:set(Chapter.IsLocked)

		--			--for StageIndex, StageData in pairs(Chapter.Stages) do
		--				--Stage.Data[_Content][ChapterIndex].Stages[StageIndex].Locked:set(StageData.IsLocked)
		--				--Stage.Data[_Content][ChapterIndex].Stages[StageIndex].Completed:set(StageData.Completed)
		--			--end

		--			print(ChapterIndex, Chapter)
		--		end
		--	else
		--		for StageIndex, StageData in pairs(ContentData) do
		--			Stage.Data[_Content][StageIndex].Locked:set(StageData.IsLocked)
		--			Stage.Data[_Content][StageIndex].Completed:set(StageData.IsLocked)
		--		end
		--	end
		--end
		
		--Loading.Skip()
	end
	
	local TopInterface = StagesInterface.Top
	
	Stage:Observer(Stage.CurrentChapter):onChange(function()
		local Chapter = Fusion.peek(Stage.CurrentChapter)
		local PageLayout = TopInterface.Upper.Chapter:WaitForChild("UIPageLayout") :: UIPageLayout
		PageLayout:JumpTo(TopInterface.Upper.Chapter:WaitForChild(Chapter))
	end)
	--end)
	
	Stage.GenerateStages()

	Stage:Hydrate(StagesInterface) {
		Enabled = Interface.ShowStages
	}
	
	Stage:Hydrate(TopInterface) {
		Enabled = Stage:Computed(function(Use)
			return Use(Interface.ShowStages) and Use(Stage.ShowStageSelection) 
		end)
	}
	
	local TopbarChapterControls = TopInterface.Upper.Controls
	local TopbarChapterPreview = TopInterface.Upper.Chapter
	
	Stage:Hydrate(TopbarChapterControls) {
		Visible = Stage:Computed(function(Use)
			return Use(Stage.ShowingType) == "Story"
		end)
	}
	
	Stage:Hydrate(TopbarChapterPreview) {
		Visible = Stage:Computed(function(Use)
			return Use(Stage.ShowingType) == "Story"
		end)
	}

	
	local ReturnButtons = {
		TopInterface.Upper.Other.Return,
		StagesInterface.ContentSelect.Buttons.Return
	}
	
	for _, Button in pairs(ReturnButtons) do
		Stage:Hydrate(Button) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, "ExitStages") == nil then
					return
				end
				
				Stage.Close()
			end
		}
	end
	
	Stage:Hydrate(StagesInterface.ContentSelect) {
		Visible = Stage:Computed(function(Use)
			return not Use(Stage.ShowStageSelection) 
		end)
	}
	
	for SectionName, Info in pairs(StageSectionInfo) do
		local Template = (Info.Special and StagesInterface.ContentSelect.Content.SpecialTemplate:Clone() or StagesInterface.ContentSelect.Content.Template:Clone()) :: ImageButton
		Template.LayoutOrder = Info.LayoutOrder or 1
		Template.Parent =  StagesInterface.ContentSelect.Content
		Template.Name = SectionName
		
		local Label = Template.TextLabel
		Label.Text = Info.Desc
		Template.Visible = true
		
		
		local Requirements = Stage:Computed(function(Use)
			local ChapterOne = Stage.Data["Story"][1].Stages
			if SectionName == "Event" then
				return "Coming soon!..."
			end
			local ChapterOneComplete = Use(ChapterOne[#ChapterOne].Completed)
			--print("isCOmplete" .. ChapterOneComplete)
			
			if SectionName == "Event" and not ChapterOneComplete  then
				return "Finish All of Chapter 1!"
			end
			
			return nil
		end)
		
		local IsLocked = Stage:Computed(function(Use)
			--if RunService:IsStudio() then
				--return false
			--end
			
			return Use(Requirements) ~= nil  
		end)
		
		Stage:Hydrate(Template.Locked) {
			Visible = IsLocked
		}
		
		Stage:Hydrate(Template) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(IsLocked) then
					Effects:DoEffect("Notification", Fusion.peek(Requirements), true)
					return
				end

				if Fusion.peek(Tutorial.IsActive) and table.find(Tutorial.ActiveTags, SectionName) == nil then
					return
				end

				
				Stage.ShowStageSelection:set(true)
				Stage.ShowingType:set(SectionName)
				--print(SectionName)
			end,
		}
	end
	
	--local Locked = Stage:Computed(function(Use)
	--	local Chapter = Use(Stage.CurrentChapter)
	--	local CurrentStageIsLocked = Use(Stage.Data[Chapter].Locked)
	--	return CurrentStageIsLocked
	--end)
	
	--local LockedFrame = StagesInterface.Locked
	
	--Stage:Hydrate(LockedFrame) {
	--	Visible = Locked
	--}
	
	for Index, Chapter in pairs(Chapters) do
		local Template = TopInterface.Upper.Chapter.Template:Clone()
		Template.Parent = TopInterface.Upper.Chapter
		
		Template.Visible = true
		Template.Name = Index
		Template.LayoutOrder = Index
		Template.Label.Text = Index
	end
	
	local Prev = TopInterface.Upper.Controls.Prev
	local Next = TopInterface.Upper.Controls.Next

	local Back = StagesInterface.Back
	local Stages = Back.Stages
	
	local PageLayout = Stages.UIPageLayout :: UIPageLayout
	
	PageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		Stage.Focused:set(PageLayout.CurrentPage)
	end)
	
	Stage:Hydrate(Next) {
		[Fusion.OnEvent("Activated")] = function()
			if Fusion.peek(Stage.CurrentChapter) == #Chapters then
				Stage.CurrentChapter:set(1)
			else
				Stage.CurrentChapter:set(Fusion.peek(Stage.CurrentChapter) + 1)
			end
			
			PageLayout:JumpToIndex(1)
		end,
	}

	Stage:Hydrate(Prev) {
		[Fusion.OnEvent("Activated")] = function()
			if Fusion.peek(Stage.CurrentChapter) == 1 then
				Stage.CurrentChapter:set(#Chapters)
			else
				Stage.CurrentChapter:set(Fusion.peek(Stage.CurrentChapter) - 1)
			end
			
			PageLayout:JumpToIndex(1)
		end,
	}
	
end

function Stage.Open()
	InterfaceTools.CloseAll()
	Interface.ShowStages:set(true)
	Stage.HideCurrentContentSection()
	
end

function Stage.HideCurrentContentSection()
	
end

function Stage.ShowCurrentContentSection()
	
end

function Stage.Close()
	Interface.ShowStages:set(false)
	Stage.ShowStageSelection:set(false)
end

function Stage.GenerateStages()
	local Back = StagesInterface.Back
	local Stages = Back.Stages
	local PageElement = Stages.UIPageLayout

	task.spawn(function()
		for Chapter=1, #Chapters do
			for StageNumber=1, #Chapters[Chapter].Stages do
				local Template = Stages.Template:Clone()
				Template.Visible = true

				Stage:Hydrate(Template) {
					Parent = Stage:Computed(function(Use)
						local CurrentChapter = Use(Stage.CurrentChapter)
						local Type = Use(Stage.ShowingType)

						--if Type ~= "Story" then
						--return nil
						--end
						--print(Type, Type == "Story")
						if CurrentChapter == Chapter and Type == "Story" then
							return Stages
						end

						return nil

					end)
				}

				Template.Name = HttpService:GenerateGUID(false)

				local Scale = Stage:New("UIScale") {
					Parent = Template,
					Scale = Stage:Spring(Stage:Computed(function(Use)
						return Use(Stage.Focused) == Template and 1 or .9	
					end), 35, .5),
				}

				local Inner = Template.Inner

				local LevelName = Chapters[Chapter].Stages[StageNumber].StageName
				Inner.LevelName.Text = LevelName

				Inner.Preview.Image.Image = Images.Scenes[Chapters[Chapter].Stages[StageNumber].Scenery or "Grasslands"]

				local LevelDescription = Template:FindFirstChild("Desc", true)
				LevelDescription.Text = Chapters[Chapter].Stages[StageNumber].StageDesc or "???"

				local Locked = Template.Locked

				--local Hide = Stage:Computed(function(Use)
				--	return Use(Stage.CurrentChapter) == Chapter
				--end)

				--Stage:Hydrate(Template) {
					--Visible = Hide
				--}

				local Actions = Inner.Actions
				local EnterButton = Actions.Enter

				Stage:Hydrate(EnterButton) {
					[Fusion.OnEvent("Activated")] = function()
						if Fusion.peek(Stage.Data["Story"][Chapter].Stages[StageNumber].Locked) then
							return
						end
						
						if Fusion.peek(Tutorial.IsActive) then
							return
						end

						local TeamLength = Team.GetEquippedLength()

						if TeamLength == 0 then
							Effects:DoEffect("Notification", "Team is empty. Equip more units!", true)
							return
						end

						local TeleportGui = Assets.TeleportGui:Clone()
						TeleportGui.Parent = game.Players.LocalPlayer.PlayerGui
						TeleportGui.Enabled = true

						Remotes.Teleport:InvokeServer("Battles", {
							Chapter = Chapter,
							Stage = StageNumber,
						}, TeleportGui)
					end,
				}	

				local Difficulty = Inner:FindFirstChild("Difficulty", true)

				local CurrentStage = Chapters[Chapter].Stages[StageNumber]

				local CompleteText = Template.Completed

				Stage:Hydrate(CompleteText) {
					Visible = Stage.Data["Story"][Fusion.peek(Stage.CurrentChapter)].Stages[StageNumber].Completed
				}

				for i=1, 5 do
					local Star = Difficulty:FindFirstChild(i) 
					Star.Visible = CurrentStage.Difficulty >= i
				end

				local Locked = Template.Locked

				Stage:Hydrate(Locked) {
					Visible = Stage.Data["Story"][Chapter].Stages[StageNumber].Locked
				}

				local Rewards = CurrentStage.Rewards

				local RewardsFrame = Template.Inner.Preview.Rewards.Inner

				for _, RewardData in pairs(Rewards) do
					local Type = RewardData.Type
					local Data = RewardData.Data
					local Amount = Data.Amount or 1

					local Template = RewardsFrame.ItemTemplate:Clone()
					Template.Name = HttpService:GenerateGUID(false)
					Template.Item.Image = Images[Type] or ""
					Template.Title.Text = Type	
					Template.Amount.Text = `x{Amount}`
					Template.Parent = RewardsFrame
					Template.Visible = true
				end

				spawn(function()
					for i=1, 3 do
						local HasBrainrot = CurrentStage.Enemies[i]

						if not HasBrainrot then
							continue
						else
							local Name = HasBrainrot.Name
							local UnitInfo = UnitInfo[Name]
							local Form = "Base"
							local Skin = HasBrainrot.Skin or "Default"
							local Model = Assets.Rots:WaitForChild(Name):WaitForChild(Form):WaitForChild(Skin):Clone()

							local Which = {
								"Second",
								"First",
								"Third",
							}

							local Frame = Template.Inner.Preview.Banner:WaitForChild(Which[i])
							local Animations = UnitInfo.Animations
							local Animator = Model:WaitForChild("AnimationController").Animator
							local IdleAnimation = Animator:LoadAnimation(Animations[Form].Idle)
							IdleAnimation:Play()

							local Viewport = Frame.ViewportFrame
							local WorldModel = Viewport.WorldModel
							Frame.Visible = true

							Model.Body:PivotTo(CFrame.new(0,-1,-7) * CFrame.Angles(0, math.rad(-70), 0))

							local Original = Model.Body:GetPivot()
							local OriginalPos = Viewport.Position

							RunService.RenderStepped:Connect(function(Delta)
								Viewport.Position = OriginalPos + UDim2.fromOffset(0, math.sin(i == 1 and tick() / 2 or tick()) * 15)
								Model.Body:PivotTo(Original * CFrame.Angles(0,-math.rad(math.sin(tick())) * 5, math.rad(math.sin(tick() * i)) * 5))
							end)	

							local Body = Model:WaitForChild("Body")
							Model.Parent = WorldModel
							wait()

						end
					end
				end)
			end
		end
	end)
	
	task.spawn(function()
		for i=1, #GameStages.Event do
			local StageData = GameStages.Event[i]

			local Template = Stages.Template:Clone()
			Template.Visible = true

			Template.Name = HttpService:GenerateGUID(false)
			
			Stage:Hydrate(Template) {
				Parent = Stage:Computed(function(Use)
					local CurrentChapter = Use(Stage.CurrentChapter)
					local Type = Use(Stage.ShowingType)
					
					if  Type == "Event" then
						return Stages
					end

					return nil
				end)
			}
			
			local Scale = Stage:New("UIScale") {
				Parent = Template,
				Scale = Stage:Spring(Stage:Computed(function(Use)
					return Use(Stage.Focused) == Template and 1 or .9	
				end), 35, .5),
			}

			local Inner = Template.Inner

			local LevelName = StageData.StageName
			Inner.LevelName.Text = LevelName

			Inner.Preview.Image.Image = Images.Scenes[StageData.Scenery or "Grasslands"]

			local LevelDescription = Template:FindFirstChild("Desc", true)
			LevelDescription.Text = StageData.StageDesc or "???"

			--local Locked = Template.Locked

			local Actions = Inner.Actions
			local EnterButton = Actions.Enter

			Stage:Hydrate(EnterButton) {
				[Fusion.OnEvent("Activated")] = function()
					local TeamLength = Team.GetEquippedLength()

					if TeamLength == 0 then
						Effects:DoEffect("Notification", "Team is empty. Equip more units!", true)
						return
					end
					

					if Fusion.peek(Tutorial.IsActive) then
						return
					end


					local TeleportGui = Assets.TeleportGui:Clone()
					TeleportGui.Parent = game.Players.LocalPlayer.PlayerGui
					TeleportGui.Enabled = true

					Remotes.Teleport:InvokeServer("Battles", {
					--	Chapter = Chapter,
						EventStage = i,
					}, TeleportGui)
				end,
			}	
			
			spawn(function()
				for i=1, 3 do
					local HasBrainrot = StageData.Enemies[i]

					if not HasBrainrot then
						continue
					else
						local Name = HasBrainrot.Name
						local UnitInfo = UnitInfo[Name]
						local Form = "Base"
						local Skin = HasBrainrot.Skin or "Default"
						local Model = Assets.Rots:WaitForChild(Name):WaitForChild(Form):WaitForChild(Skin):Clone()

						local Which = {
							"Second",
							"First",
							"Third",
						}

						local Frame = Template.Inner.Preview.Banner:WaitForChild(Which[i])
						local Animations = UnitInfo.Animations
						local Animator = Model:WaitForChild("AnimationController").Animator
						local IdleAnimation = Animator:LoadAnimation(Animations[Form].Idle)
						IdleAnimation:Play()

						local Viewport = Frame.ViewportFrame
						local WorldModel = Viewport.WorldModel
						Frame.Visible = true

						Model.Body:PivotTo(CFrame.new(0,-1,-7) * CFrame.Angles(0, math.rad(-70), 0))

						local Original = Model.Body:GetPivot()
						local OriginalPos = Viewport.Position

						RunService.RenderStepped:Connect(function(Delta)
							Viewport.Position = OriginalPos + UDim2.fromOffset(0, math.sin(i == 1 and tick() / 2 or tick()) * 15)
							Model.Body:PivotTo(Original * CFrame.Angles(0,-math.rad(math.sin(tick())) * 5, math.rad(math.sin(tick() * i)) * 5))
						end)	

						local Body = Model:WaitForChild("Body")
						Model.Parent = WorldModel
						wait()

					end
				end
			end)
		end
	end)
	
end

function Stage.NextChapter()
	Stage.CurrentChapter:set(Fusion.peek(Stage.CurrentChapter) + 1)
end

return Stage