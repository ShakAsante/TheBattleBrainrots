local Tips = {}
local ChatService = game:GetService("TextChatService")
local Channels = ChatService:WaitForChild("TextChannels")
local RBXGeneral = Channels:WaitForChild("RBXGeneral") :: TextChannel
local RBXSystem = Channels:WaitForChild("RBXSystem") :: TextChannel

local PossibleTips = {
	"For more updates join the discord server!",
	"You can evolve some brainrots after a certain level!",
	"Like the game and join the game for a free reward!",
	"You can unlock tomatoes after getting a higher score in campaign!",
	"This game is heavily inspired off the Battle Cats!",
	"Stronger brainrots appear in later stages—keep upgrading yours!",
	"Try mixing different brainrots for unique synergies!",
	"Some enemies have special resistances… plan your lineup wisely!",
	"Leveling up units can unlock hidden abilities!",
	"Boss stages might look impossible—until you get that one clutch upgrade.",
	"Remember: placement and timing can win the game, not just strength!",
	"Evolving a unit can completely change its attack style—experiment!",
	"You're actually brainrotted",
	"Touch grass after this stage. You’ve earned it.",
	"Even the weakest brainrot can shine with enough upgrades!",
	"Collect EXP to unlock more units faster!",
	"Certain stages reward rare items—keep an eye out!",
	"Enemies get tougher as the stage progresses. Don’t slack!",
	"Think you’ve beaten it all? Wait for the next update 👀",
	"Report bugs to the discord server!",
	"Use CODE RELEASE..."
}


function Tips.GameStart()
	while wait(60) do
		Tips.DoTip()
	end
end

function Tips.DoTip()
	local Tip = PossibleTips[math.random(1, #PossibleTips)]	
	RBXGeneral:DisplaySystemMessage(`<font color="rgb(0,155,255)">[TIP]: {Tip}</font>`)
end

return Tips