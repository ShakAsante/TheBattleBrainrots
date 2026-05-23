local Banners = {}
local Images = require("./Assets/Images")

-- =========================
-- Banner 1: Grasslands Clash
-- =========================
export type Banner = {
	Name: string,
	SummonScene: string,
	Rarities: {
		Rare: number,
		SuperRare: number,
		UberRare: number,
		LegendRare: number,
	},
	Content: {string},
}

Banners[1] = {
	Name = "Grasslands Clash",
	SummonScene = "Grasslands",

	Rarities = {
		Rare = 100/100,
		SuperRare = 70/100,
		UberRare = 50/100,
		LegendRare = 10/100,
	},

	Content = {
		-- === Banner Display (Top 3) ===
		"OdinDinDinDun",       -- UberRare
		"TimCheese",          -- Rare
		"CappuccinoAssasino", -- Rare

		-- === Main Pool ===
		"ChimpBanana",
		"TimCheese",
		"GangsterFootera",
		"TiTiTiSahur",
		"TungTungSahur",
		"NoobPizza",

		-- === LegendRare (NEVER top 3) ===
		"PicconeMacchina",
	},
}

-- =========================
-- Banner 2: Kingdom Rebellion
-- =========================
Banners[2] = {
	Name = "Kingdom Rebellion",
	SummonScene = "Kingdom",

	Rarities = {
		Rare = 100/100,
		SuperRare = 70/100,
		UberRare = 50/100,
		LegendRare = 10/100,
	},

	Content = {
		-- === Banner Display (Top 3) ===
		"CarrotiniBrainini", -- UberRare
		"BanditoAxolito",    -- Rare
		"PipiKiwi",          -- Special (Rare-tier)

		-- === Main Pool ===
		"ChimpBanana",
		"TimCheese",
		"GangsterFootera",
		"TiTiTiSahur",
		"TungTungSahur",
		"NoobPizza",

		-- === LegendRare (NEVER top 3) ===
		"PicconeMacchina",
	},
}

-- =========================
-- Banner 3: Ocean Tide
-- =========================

Banners[3] = {
	Name = "Ocean Tide",
	SummonScene = "OceanSide",

	Rarities = {
		Rare = 100/100,
		SuperRare = 70/100,
		UberRare = 50/100,
		LegendRare = 10/100,
	},

	Content = {
		-- === Banner Display (Top 3) ===
		"Gattatino",         -- UberRare
		"ExtinctTralalero",  -- SuperRare
		"OdinDinDinDun",     -- UberRare

		-- === Main Pool ===
		"ChimpBanana",
		"TimCheese",
		"GangsterFootera",
		"TiTiTiSahur",
		"TungTungSahur",
		"NoobPizza",
		"ToToSahur",

		-- === LegendRare ===
		"Tralalero",
	},
}

return Banners
