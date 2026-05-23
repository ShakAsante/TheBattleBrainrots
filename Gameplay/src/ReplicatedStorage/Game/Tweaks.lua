local Tweaks = {}

Tweaks.WalletCost = function(Level)
	local Cost = Tweaks.CalcMaxMoney(Level)
	return math.round((Cost * 0.75) / 25) * 25
end

Tweaks.CalcMaxMoney = function(Level)
	local Caps = {
		150,
		275,
		400,
		675,
		1500,
	}
	return Caps[Level]
end

Tweaks.BaseAbilityCooldown = 30
Tweaks.TeamSize = 8
Tweaks.StatBoostPerLevel = function(Level)
	local Boosts = {
		1,
		1.5,
		1.75,
		2.25,
		2.5,
		3,
		3.75,
		4.25,
		4.75,
		5,
	}
	
	return Boosts[Level] 
end


return table.freeze (Tweaks)