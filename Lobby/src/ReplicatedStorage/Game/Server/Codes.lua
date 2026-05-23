local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root.Remotes
local Rewards = require("./Rewards")

local Data = require("./Data")
local Codes = {}

Codes.Entries = {
	["RELEASE"] = {
		function(Player)
			Rewards.Give(Player, "Gems", { 
				Amount = 500,
			})
		end,
		
		--DateTime.fromUniversalTime().UnixTimestamp
	}, 	
	["MBALL"] = {
		function(Player)
			Rewards.Give(Player, "Gems", { 
				Amount = 500,
			})
		end,
	},
	
	["CATS"] = {
		function(Player)
			Rewards.Give(Player, "Gems", { 
				Amount = 250,
			})
		end,
	},
	["ROCK"] = {
		function(Player)
			Rewards.Give(Player, "XP", { 
				Amount = 20000,
			})
		end,
	}
}

function Codes.GameStart()
	Remotes.RedeemCode.OnServerInvoke = function(Player, CodeName)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end

		local CodeAlreadyUsed = Profile.Data.UsedCodes[CodeName] == true
		local Code = Codes.Entries[CodeName]
		
		if Code == nil then
			Remotes.Replicate:FireClient(Player, "Notification", "Invalid code", true)
			return
		end
		
		local CodeExpired = Code[2] and Code[2] < DateTime.now().UnixTimestamp or false
		
		if CodeExpired then
			Remotes.Replicate:FireClient(Player, "Notification", "Code Expired!", true)
			return
		end
		
		if Code and CodeAlreadyUsed then
			Remotes.Replicate:FireClient(Player, "Notification", "Code Already Used!", true)
			return
		end
		
		if not Code then
			Remotes.Replicate:FireClient(Player, "Notification", "Invalid code", true)
			return
		else
			Code[1](Player)
			Profile.Data.UsedCodes[CodeName] = true
			Remotes.Replicate:FireClient(Player, "Notification", "Code redeemed!")
			return
		end
	end
end

return Codes