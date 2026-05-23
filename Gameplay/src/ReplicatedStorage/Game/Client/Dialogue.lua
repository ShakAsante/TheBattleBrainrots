local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")

local Fusion = require(Root.Shared.Packages.Fusion)
local Trove = require(Root.Shared.Packages.Trove)

local Dialogue = {}
local Messages = {}
Dialogue.IsAnimated = false

local Images = require(Assets.Images)

local RunService = game:GetService("RunService")

function Dialogue.GameStart()
	Dialogues = require(Assets.Dialogues)

	local InterfaceTools = require("./InterfaceTools")
	DialogueInterface = InterfaceTools.GetInterface("Dialogue")
	MainInterface = InterfaceTools.GetInterface("Main")

	local Body = DialogueInterface.Body
	local Inner = Body.Inner
	local Speech = Inner.Speech
	local Which = Inner.Which

	local function QuadraticBezier(p0, p1, p2, t)
		return (1 - t)^2 * p0
			+ 2 * (1 - t) * t * p1
			+ t^2 * p2
	end

	task.spawn(function()
		while true do
			if Dialogue.IsAnimated then
				local Original = Which.Position 

				local P0 = Vector2.new(0, 0)
				local P1 = Vector2.new(0, 10)
				local P2 = Vector2.new(0, 0)

				local SEGMENTS = 5

				for i = 0, SEGMENTS do
					local t = i / SEGMENTS
					local pos = QuadraticBezier(P0, P1, P2, t)
					Which.Position = Original + UDim2.fromOffset(0, pos.Y)
					wait(.001)
				end
			else
				-- do nun
			end
			wait(.1)
		end
	end)

	while true do
		while #Messages > 0 do
			local Message = Messages[1][1]
			local Speaker = Messages[1][2]
			
			Which.Image = Images[Speaker] and Images[Speaker] or ""
			
			Dialogue.DoDialogue(Message, 1)

			table.remove(Messages, 1)
		end

		task.wait(1)
	end
end

function Dialogue.Start(DialogueId)
	local Data = Dialogues[DialogueId]

	if Data then
		for _, Message in pairs(Data.Data) do
			table.insert(Messages, {Message[1], Data.Speaker})
		end
	end
end

function Dialogue.DoDialogue(String, Duration)
	local Body = DialogueInterface.Body
	local Inner = Body.Inner
	local Speech = Inner.Speech

	local FullCleanup = Trove.new()
	local Cleaner = Trove.new()

	--local Data = Dialogues[DialogueID]

	local Modifiers = {
		IsShaking = false,
		IsRainbow = false,
	}

	MainInterface.Enabled = false
	DialogueInterface.Enabled = true

	local function QuadraticBezier(p0, p1, p2, t)
		return (1 - t)^2 * p0
			+ 2 * (1 - t) * t * p1
			+ t^2 * p2
	end

	local Words = string.split(String or ""," ")
	local Duration = Duration

	for _, Word in ipairs(Words) do
		local Chars = string.split(Word, "")

		local Template = Speech.Inner.Template:Clone()
		Template.Parent = Speech.Inner
		Template.Visible = true
		
		Dialogue.IsAnimated = true
		
		for Index, Char in ipairs(Chars) do
			if Char == "*" then 
				Modifiers.IsShaking = not Modifiers.IsShaking
				continue
			elseif Char == "^" then
				Modifiers.IsRainbow = not Modifiers.IsRainbow
				continue
			else
				local LabelTemplate = Template.Body:Clone()
				LabelTemplate.Parent = Template
				LabelTemplate.Label.Text = Char
				LabelTemplate.Visible = true

				local TypeSound = Assets.Sounds:FindFirstChild("Type"):Clone()
				TypeSound.Parent = LabelTemplate

				TypeSound:Play()

				if Modifiers.IsShaking then
					local OriginalPosition = LabelTemplate.Label.Position

					local ShakingLoop = RunService.Heartbeat:Connect(function(Delta)
						local t = tick() * math.random() * 15
						local offsetX = math.sin(t) * 2
						local offsetY = math.cos(t) * 2
						LabelTemplate.Label.Position = OriginalPosition + UDim2.fromOffset(offsetX, offsetY)
					end)

					Cleaner:Add(ShakingLoop)

					wait(.15)
				end

				if Modifiers.IsRainbow then
					local RainbowLoop =  RunService.Heartbeat:Connect(function()
						local time = tick()
						local offset = (Index / #Chars) * 1 
						local hue = (time / 5 + offset) % 1 
						local color = Color3.fromHSV(hue, 1, 1)
						LabelTemplate.Label.TextColor3 = color
					end)

					Cleaner:Add(RainbowLoop)
				end

				Cleaner:Add(Template)

				task.wait(.035)
			end
		end
		
		Dialogue.IsAnimated = false

		local Space = Template.Body:Clone()
		Space.Parent = Template
		Space.Label.Text = " "
		Space.Visible = true

		Cleaner:Add(Space)
	end

	wait(Duration)

	Cleaner:Destroy()

	--FullCleanup:Destroy()

	wait(.05)
	--end


	MainInterface.Enabled = true
	DialogueInterface.Enabled = false
end

return Dialogue