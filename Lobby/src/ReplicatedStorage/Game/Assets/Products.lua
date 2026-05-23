local Products = {}

Products.DevProducts = {
	--["StarterPack"] = -1,
	
	["Gems"] = {
		["PackOne"] = 3457825774,
		["PackTwo"] = 3457826792,
		["PackThree"] = 3457826936,
		["PackFour"] = 3459125281,
	},
	
	["XP"] = {
		["PackOne"] = 3479800316,
		["PackTwo"] = 3479800490,
		["PackThree"] = 3479800750,
		["PackFour"] = 3479801915,
	},
	
	["Money"] = {
		["PackOne"] = 3459125376,
		["PackTwo"] = 3459125429,
		["PackThree"] = 3459125479,
		["PackFour"] = 3459125530,
	},
	
	--["SummonTickets"] = {
	--	["PackOne"] = 3457828047,
	--	["PackTwo"] = 3457828848,
	--	["PackThree"] = 3457828425,
	--},

	["SummonBannerx1"] = {},
	["SummonBannerx10"] = {},
	
	["SeasonPass"] = 3517708067,
	
	["SeasonPassLevelUp"] = 3517709443,
	["SeasonPassBuyAll"] = 3517707543,
	
	["Revive"] = 3517726025,
	
	["Bundles"] = {
		["LegendsBundle1"] = 3517716870,
		["LegendsBundle2"] = 3517717602,
		["PurchasePicconeMacchina"] = 3517724590,
		["PurchaseTralalero"] = 3517724830,
	}
}

Products.Gamepasses = {
	["DoubleLuck"] = 1705562357,
	["DoubleGems"] = 1696833412,
	["DoubleXP"] = 1696905547,
}



return table.freeze(Products)