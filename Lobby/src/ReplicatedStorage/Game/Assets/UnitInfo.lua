local UnitInfo = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Anims = Assets.Anims.Rots

--UnitInfo["LaPalini"] = {
--	Animations = {
--		Speed = {
--			Walk = 1,
--			Attack = 1,
--			Knockback = 1,
--			Idle = 1,
--		},

--		Base = {
--			--Walk = Anims.LaPalini.Base.Walk,
--			--Attack = Anims.LaPalini.Base.Attack,
--			--Knockback = Anims.LaPalini.Base.Knockback,
--			--Idle = Anims.LaPalini.Base.Idle	
--		}
--	},

--	Rarity = "Special",
--	Cost = 1,
--	Cooldown = 10,

--	Base = {
--		Health = 3,
--		Posture = 85,
--		Damage = 3,
--		AttackSpeed = 4,	
--		Range = 10,
--		Speed = 5,
--		DisplayName = "Agarrini la Palini",	
--	},	
--}

UnitInfo["PicconeMacchina"] = { -- dragon cat
	Animations = {
		Speed = {
			Walk = .6,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.PicconeMacchina.Base.Walk,
			Attack = Anims.PicconeMacchina.Base.Attack,
			Knockback = Anims.PicconeMacchina.Base.Knockback,
			Idle = Anims.PicconeMacchina.Base.Idle	
		}
	},

	Rarity = "LegendRare",
	Cost = 1000,
	Cooldown = 15,

	Base = {
		Health = 2,
		Posture = 400,
		Damage = 140,
		AttackSpeed = 4.3,	
		Range = 13,
		Speed = 6,

		AttackType = "LOS",
		AttackVisual = "Laser",	
		DisplayName = "PicconeMacchina",	
	}
}

UnitInfo["ChefCabra"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.ChefCabra.Base.Walk,
			Attack = Anims.ChefCabra.Base.Attack,
			Knockback = Anims.ChefCabra.Base.Knockback,
			Idle = Anims.ChefCabra.Base.Idle
		}
	},

	Rarity = "Special",
	Cost = 1,
	Cooldown = 10,

	Base = {
		Health = 5,
		Posture = 100,
		Damage = 17,
		AttackSpeed = 4,
		Range = 6,
		Speed = 9,

		DisplayName = "Chef Cabra",
		DamageDelay = .9
	}
}


UnitInfo["PipiKiwi"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.PipiKiwi.Base.Walk,
			Attack = Anims.PipiKiwi.Base.Attack,
			AttackHold = Anims.PipiKiwi.Base.AttackHold,
			Knockback = Anims.PipiKiwi.Base.Knockback,
			Idle = Anims.PipiKiwi.Base.Idle
		}
	},

	Rarity = "SuperRare",
	Cost = 650,
	Cooldown = 15,

	Affinities = {
		["Strong"] = 1.5,
		--["Weak"] = .7,
	},

	Base = {
		Health = 5,
		Posture = 230,
		Damage = 35,
		AttackSpeed = 3,
		Range = 8,
		Speed = 9,

		DisplayName = "Pipi Kiwi",
		AttackVisual = "BarrageFast"
	}
}

UnitInfo["BanditoAxolito"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.BanditoAxolito.Base.Walk,
			Attack = Anims.BanditoAxolito.Base.Attack,
			Knockback = Anims.BanditoAxolito.Base.Knockback,
			Idle = Anims.BanditoAxolito.Base.Idle
		}
	},

	Rarity = "Rare",
	Cost = 325,
	Cooldown = 10,

	Affinities = {
		["HyperArmor"] = 1.5,
		["Strong"] = .5,
	},


	Base = {
		Health = 5,
		Posture = 90,
		Damage = 35,
		AttackSpeed = 1.5,
		Range = 11,
		Speed = 9,

		DisplayName = "Bandito Axolito",
		DamageDelay = .9
	}
}

UnitInfo["TimCheese"] =  { -- cow cat
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.TimCheese.Base.Walk,
			Attack = Anims.TimCheese.Base.Attack,
			Knockback = Anims.TimCheese.Base.Knockback,
			Idle = Anims.TimCheese.Base.Idle
		}
	},
	Rarity = "Rare",

	Cost = 350,
	Cooldown = 8,

	Affinities = {
		["Frozen"] = 1.35,
		["Slow"] = 1.25,
	},


	Base = {
		Health = 5,
		Posture = 220,
		Damage = 20,
		AttackSpeed = .53,
		Range = 10,
		Speed = 20,

		DisplayName = "Tim Cheese",
	}
}

UnitInfo["GangsterFootera"] =  { -- axe cat
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.GangsterFootera.Base.Walk,
			Attack = Anims.GangsterFootera.Base.Attack,
			Knockback = Anims.GangsterFootera.Base.Knockback,
			Idle = Anims.GangsterFootera.Base.Idle
		}
	},

	Rarity = "Normal",
	Cost = 200,
	Cooldown = 6, 

	Base = {
		Health = 3,
		Posture = 200,
		Damage = 20,
		AttackSpeed = .9,
		Range = 11,
		Speed = 13,
		DisplayName = "Gangster Footera",	
	}
}

UnitInfo["SpioniroGolubiro"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.SpioniroGolubiro.Base.Walk,
			Attack = Anims.SpioniroGolubiro.Base.Attack,
			Knockback = Anims.SpioniroGolubiro.Base.Knockback,
			Idle = Anims.SpioniroGolubiro.Base.Idle
		}
	},

	Rarity = "Special",
	Cost = 500,

	Base = {
		Health = 3,
		Posture = 130,
		Damage = 25,
		AttackSpeed = 5.23,
		Range = 10,
		Speed = 10,
		DisplayName = "Spioniro Golubiro",

		--AttackType = "LOS",
		AttackVisual = "FlashFreeze",
	}
}

UnitInfo["TungTungSahur"] =  { -- basic cat
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.TungTungSahur.Base.Walk,
			Attack = Anims.TungTungSahur.Base.Attack,
			Knockback = Anims.TungTungSahur.Base.Knockback,
			Idle = Anims.TungTungSahur.Base.Idle
		},

		Evolved = {
			Walk = Anims.TungTungSahur.Evolved.Walk,
			Attack = Anims.TungTungSahur.Evolved.Attack,
			Knockback = Anims.TungTungSahur.Evolved.Knockback,
			Idle = Anims.TungTungSahur.Evolved.Idle
		}
	},

	Cooldown = 5,
	Rarity = "Normal",
	Cost = 75,

	Base = {
		Health = 3,
		Posture = 80,
		Damage = 12,
		AttackSpeed = 1.23,
		Range = 10,
		Speed = 9,
		DisplayName = "Tung Tung Sahur",
		AttackType = "LOS",
	},

	Evolved = {
		Health = 3,
		Posture = 175,
		Damage = 35,
		AttackSpeed = 2.50,
		Range = 12,
		Speed = 6,

		DisplayName = "Te Te Sahur",
		DamageDelay = 1.7,
		AttackVisual = "BFlash",
		--AttackType = "Single",
		--HitVisual = "BFlash"
	}
}


UnitInfo["KingTung"] =  { -- basic cat
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.KingTung.Base.Walk,
			Attack = Anims.KingTung.Base.Attack,
			Knockback = Anims.KingTung.Base.Knockback,
			Idle = Anims.KingTung.Base.Idle
		},
	},

	Cooldown = 30,
	Rarity = "Special",
	Cost = 400,

	Base = {
		Health = 3,
		Posture = 200,
		Damage = 40,
		AttackSpeed = .6,
		Range = 10,
		Speed = 15,
		DamageDelay = .7,
		DisplayName = "King Sahur",
		AttackVisual = "Slam",
		--AttackType = "LOS",
	},
}

UnitInfo["CappuccinoAssasino"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.CappuccinoAssasino.Base.Walk,
			Attack = Anims.CappuccinoAssasino.Base.Attack,
			Knockback = Anims.CappuccinoAssasino.Base.Knockback,
			Idle = Anims.CappuccinoAssasino.Base.Idle
		}
	},

	Cooldown = 7,
	Rarity = "Rare",
	Cost = 400,

	Base = {
		Health = 2,
		Posture = 150,
		Damage = 20,
		AttackSpeed = .5,
		Range = 8,
		Speed = 6,
		DisplayName = "Cappuccino Assasino",

		AttackVisual = "TripleHit",
	}
}

UnitInfo["OdinDinDinDun"] = {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.OdinDinDinDun.Base.Walk,
			Attack = Anims.OdinDinDinDun.Base.Attack,
			Knockback = Anims.OdinDinDinDun.Base.Knockback,
			Idle = Anims.OdinDinDinDun.Base.Idle
		}
	},

	Rarity = "UberRare",
	Cost = 900,
	Cooldown = 25,

	Base = {
		Health = 3,
		Posture = 125,
		Damage = 0,
		AttackSpeed = 10,
		Range = 8,
		Speed = 4.5,
		DisplayName = "Odin Din Din Dun",

		AttackVisual = "UdinCharge",
	}
}

UnitInfo["Fragola"] = {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.Fragola.Base.Walk,
			Attack = Anims.Fragola.Base.Attack,
			Knockback = Anims.Fragola.Base.Knockback,
			Idle = Anims.Fragola.Base.Idle
		}
	},

	Rarity = "SuperRare",
	Cost = 1350,
	Cooldown = 25,

	Base = {
		Health = 3,
		Posture = 125,
		Damage = 0,
		AttackSpeed = 10,
		Range = 8,
		Speed = 4.5,
		DisplayName = "Fragola La La La",

		AttackVisual = "UdinCharge",
	}
}

UnitInfo["ChimpBanana"] =  {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.ChimpBanana.Base.Walk,
			Attack = Anims.ChimpBanana.Base.Attack,
			Knockback = Anims.ChimpBanana.Base.Knockback,
			Idle = Anims.ChimpBanana.Base.Idle
		}
	},

	Rarity = "Normal",
	Cost = 210,
	Cooldown = 15,

	Base = {
		Health = 3,
		Posture = 140,
		Damage = 17,
		AttackSpeed = 1,
		Range = 9,
		Speed = 4.5,	
		DisplayName = "Chimpanini Bananini",
		DamageDelay = .6,

		--AttackVisual = "UdinCharge",
	}
}

UnitInfo["ExtinctTralalero"] =  {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.ExtinctTralalero.Base.Walk,
			Attack = Anims.ExtinctTralalero.Base.Attack,
			Knockback = Anims.ExtinctTralalero.Base.Knockback,
			Idle = Anims.ExtinctTralalero.Base.Idle
		}
	},

	Rarity = "SuperRare",
	Cost = 500,
	Cooldown = 15,

	Base = {
		Health = 1,
		Posture = 100,
		Damage = 60,
		AttackSpeed = 7,
		Range = 8,
		Speed = 16,
		DisplayName = "Extinct Tralalero Tralalero",

		AttackVisual = "Kamikaze",
	}
}

UnitInfo["ToToSahur"] =  {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.ToToSahur.Base.Walk,
			Attack = Anims.ToToSahur.Base.Attack,
			Knockback = Anims.ToToSahur.Base.Knockback,
			Idle = Anims.ToToSahur.Base.Idle
		}
	},

	Rarity = "Rare",
	Cost = 300,
	Cooldown = 15,

	Base = {
		Health = 2,
		Posture = 175,
		Damage = 27,
		AttackSpeed = 3,
		Range = 13,
		Speed = 8,
		DisplayName = "To To To Sahur",
	}
}

UnitInfo["CarrotiniBrainini"] =  {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.CarrotiniBrainini.Base.Walk,
			Attack = Anims.CarrotiniBrainini.Base.Attack,
			Knockback = Anims.CarrotiniBrainini.Base.Knockback,
			Idle = Anims.CarrotiniBrainini.Base.Idle
		}
	},

	Rarity = "UberRare",
	Cost = 1200,
	Cooldown = 25,

	Base = {
		Health = 3,
		Posture = 470,
		Damage = 70,
		AttackSpeed = 1,
		Range = 8,
		Speed = 4.5,
		DisplayName = "Carrotini Brainini",
	}
}

UnitInfo["Gattatino"] =  {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.Gattatino.Base.Walk,
			Attack = Anims.Gattatino.Base.Attack,
			Knockback = Anims.Gattatino.Base.Knockback,
			Idle = Anims.Gattatino.Base.Idle
		}
	},

	Rarity = "UberRare",
	Cost = 900,
	Cooldown = 20,

	Base = {
		Health = 4,
		Posture = 200,
		Damage = 220,
		AttackSpeed = 15,
		Range = 8,
		Speed = 4.5,
		DisplayName = "Gattatino Neonino",
		DamageDelay = 1.7,
		AttackVisual = "Gattatino",
	}
}

UnitInfo["NoobPizza"] = {
	Animations = {
		Speed = {
			Walk = .5,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.NoobPizza.Base.Walk,
			Attack = Anims.NoobPizza.Base.Attack,
			Knockback = Anims.NoobPizza.Base.Knockback,
			Idle = Anims.NoobPizza.Base.Idle
		}
	},

	Rarity = "Normal",
	Cost = 180,
	Cooldown = 15,

	Base = {
		Health = 3,
		Posture = 120,
		Damage = 18,
		AttackSpeed = 10,
		Range = 8,
		Speed = 4.5,
		DisplayName = "Noobini Pizzanini",
	}
}

UnitInfo["TiTiTiSahur"] =  { -- wall cat
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},

		Base = {
			Walk = Anims.TiTiTiSahur.Base.Walk,
			Attack = Anims.TiTiTiSahur.Base.Attack,
			Knockback = Anims.TiTiTiSahur.Base.Knockback,
			Idle = Anims.TiTiTiSahur.Base.Idle
		}
	},

	Rarity = "Normal",
	Cost = 125,
	Cooldown = 7,

	Base = {
		Health = 3,
		Posture = 180,
		Damage = 5,
		AttackSpeed = 2.23,
		Range = 8,
		Speed = 8,
		AttackType = "Single",
		DisplayName = "Ti Ti Sahur",	
	}
}

UnitInfo["Tralalero"] = {
	Animations = {
		Speed = {
			Walk = 1,
			Attack = 1,
			Knockback = 1,
			Idle = 1,
		},
		
		Base = {
			Idle = Anims.Tralalero.Base.Idle,
			Walk = Anims.Tralalero.Base.Walk,
			Attack = Anims.Tralalero.Base.Attack,
			Knockback = Anims.Tralalero.Base.Knockback,
		},

		Evolved = {
			Idle = Anims.Tralalero.Evolved.Idle,
			Walk = Anims.Tralalero.Evolved.Walk,
			Attack = Anims.Tralalero.Evolved.Attack,
			Knockback = Anims.Tralalero.Evolved.Knockback,
		}
	},

	Rarity = "LegendRare",
	Cost = 1500,
	Cooldown = 60,

	Base = {
		Health = 3,
		Posture = 400,
		Damage = 100,
		AttackSpeed = 2.23,
		Range = 80,	
		Speed = 6,
		DisplayName = "Tralalero",	
		AttackVisual = "TralaleroSplash",
	},

	Evolved = {
		Health = 5,
		Posture = 600,
		Damage = 240,
		AttackSpeed = 10.23,
		Range = 40,
		Speed = 3,
		AttackVisual = "TralaledonRoar",
		DisplayName = "Tralaledon",	
	},

	--Ascended = {
	--	Health = 3,
	--	Posture = 400,
	--	Damage = 2,
	--	AttackSpeed = 2.23,
	--	Range = 8,
	--	Speed = 8,
	--	DisplayName = "Tralaledon",	
	--}
}


return table.freeze(UnitInfo)