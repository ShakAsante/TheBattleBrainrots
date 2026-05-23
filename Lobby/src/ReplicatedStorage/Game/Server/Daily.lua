local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Daily = {}
local Root = ReplicatedStorage.Game
local Remotes = Root:WaitForChild("Remotes")

local DailyRewards = {
	[1] = {
		["Type"] = "Gems",
		["Data"] = {
			["Amount"] = 125
		}
	},
	[2] = {
		["Type"] = "Cash",
		["Data"] = {
			["Amount"] = 150
		}
	},
	[3] = {
		["Type"] = "Gems",
		["Data"] = {
			["Amount"] = 250
		}
	},
	[4] = {
		["Type"] = "Cash",
		["Data"] = {
			["Amount"] = 300
		}
	},
	[5] = {
		["Type"] = "Gems",
		["Data"] = {
			["Amount"] = 550
		}
	},
	[6] = {
		["Type"] = "Cash",
		["Data"] = {
			["Amount"] = 575
		}
	},
	[7] = {
		["Type"] = "Gems",
		["Data"] = {
			["Amount"] = 750
		}
	},
}

local Players = game:GetService("Players")

function Daily.GameStart()
	Data = require("./Data")
	Rewards = require("./Rewards")
	
	Players.PlayerAdded:Connect(function(Player)
		local Success, Profile = Data.GetProfile(Player):await()
		if not Success or not Profile then return end
		
		local LastLoginDay = Profile.Data.LastLoginDay
		local CurrentDay = os.date("!*t").wday
		
		if LastLoginDay == CurrentDay then
			return
		end
		
		local Reward = DailyRewards[CurrentDay]
		if not Reward then
			return
		end
		
		Remotes.Replicate:FireClient(Player, "Notification", "You have received x"..Reward.Data.Amount.." "..Reward.Type.." for logging in!")
		Rewards.Give(Player, Reward.Type, Reward.Data)
	end)
end

return Daily