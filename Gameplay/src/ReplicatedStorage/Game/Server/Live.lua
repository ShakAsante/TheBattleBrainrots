local Live = {}

local Bases = workspace.Map.Bases
local EnemyBase = Bases:WaitForChild("2")
local PlayerBase = Bases:WaitForChild("1")

Live.Units = {
	{ Model = PlayerBase }
}

Live.EnemyUnits = {
	{ Model = EnemyBase } 
}

function Live.ClearAll()
	for i = #Live.Units, 1, -1 do
		local Unit = Live.Units[i]

		--if Unit.UUID then
		 if Unit.Cleaner then
		 	Unit.Cleaner:Destroy()
		 --end

			table.remove(Live.Units, i)
		end
	end

	for i = #Live.EnemyUnits, 1, -1 do
		local Unit = Live.EnemyUnits[i]

		--if Unit.UUID then
		if Unit.Cleaner then
			Unit.Cleaner:Destroy()
			--end

			table.remove(Live.EnemyUnits, i)
		end
	end
	
	--for _, Unit in ipairs(Live.EnemyUnits) do
		--if Unit.Cleaner then
			--Unit.Model:Destroy()
			--table.remove(Live.EnemyUnits, _)
			--Unit.Cleaner:Destroy()
		--else
			--continue
		--end
	--end
end

return Live