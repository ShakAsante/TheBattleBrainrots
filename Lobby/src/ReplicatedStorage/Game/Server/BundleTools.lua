local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Bundles = require(Root.Bundles)
local Util = {}
local Rewards = require("./Rewards")
local InventoryTools = require("./InventoryTools")

function Util.GiveBundle(Player, Bundle)
	local BundleData = Bundles[Bundle]
	
	for _, Reward in pairs(BundleData) do
		Rewards.Give(Player, Reward.Type, Reward.Data)
	end
	
	InventoryTools.UpdateToBrainrotsClient(Player)
end

return Util