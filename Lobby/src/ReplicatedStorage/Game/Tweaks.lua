return table.freeze {
	PricePerSlot = function(Index)
		local Prices = {
			-1,
			-1,
			-1,
			500,
			750,
			1650,
			3500,
			5750,
			8000,
			13000,
		}
		
		return Prices[Index] or Prices[#Prices]
	end,
	
	PricePerLevel = function(Level)
		local Prices = {
			1500,    -- 1 → 2
			3000,    -- 2 → 3
			4500,    -- 3 → 4
			6000,    -- 4 → 5
			8000,    -- 5 → 6
			10000,   -- 6 → 7
			12500,   -- 7 → 8
			15000,   -- 8 → 9
			17500,   -- 9 → 10
			21000,   -- 10 → 11
			25000,   -- 11 → 12
			30000,   -- 12 → 13
			36000,   -- 13 → 14
			43000,   -- 14 → 15
			51000,   -- 15 → 16
			60000,   -- 16 → 17
			70000,   -- 17 → 18
			82000,   -- 18 → 19
			95000,   -- 19 → 20
			110000,  -- 20 (max)
		}

		return Prices[Level] or Prices[#Prices]
	end,
	
	ExperienceRequiredPerSeasonLevel = function(Level)
		local Requirements = {
			2000, 
			3000, 
			4200, 
			5500,
			7000,
			8700, 
			10500,
			12500,
			14700,
			17000, 
		}

		return Requirements[Level + 1] or 17000 + (Level - 10) * 3500
	end,

	GameLikeGoal = 35,
	MaxUnitLevel = 10,
	BannerRotationTime = 86400 / 24,
	CurrentSeason = 1,
	
	ShopValues = {
		Packs = {
			Money = {
				PackOne = 500;
				PackTwo = 2000;
				PackThree = 4800;
				PackFour = 11000;
			};
			
			XP = {
				PackOne = 25000;
				PackTwo = 60000;
				PackThree = 200000;
				PackFour = 500000;
			},
			
			Gems = {
				PackOne = 150;
				PackTwo = 450;
				PackThree = 1500;
				PackFour = 5000;
			};
		}
	},
	
	SummonCost = 150,
	
	GroupId = 34496968, 
	
	FreeRewards = {
		{
			Type = "Cash",
			Data = { Amount = 100},
		},
		{
			Type = "Gems",
			Data = { Amount = 150},
		}
	},
	
	TeamSize = 8,
}