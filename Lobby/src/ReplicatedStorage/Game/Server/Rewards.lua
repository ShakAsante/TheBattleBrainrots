local Rewards = {}
local Data = require("./Data")


local Handlers = {
	["Cash"] = function(Player, RewardData)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		Profile.Data.Money += RewardData.Amount
	end,
	
	["Gems"] = function(Player, RewardData)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		Profile.Data.Gems += RewardData.Amount
	end,
	
	["XP"] = function(Player, RewardData)
		local Sucess, Profile = Data.GetProfile(Player):await()
		if not Sucess or not Profile then return end
		Profile.Data.XP += RewardData.Amount
	end,
	 
	["Brainrot"] = function(Player, RewardData)
		InventoryTools.UnlockBrainrot(Player, RewardData.Name)
	end,
}


function Rewards.GameStart()
	InventoryTools = require("./InventoryTools")
end

function Rewards.Give(Player, RewardType, RewardData)
	if Handlers[RewardType] then
		Handlers[RewardType](Player, RewardData)
	end
end

return Rewards