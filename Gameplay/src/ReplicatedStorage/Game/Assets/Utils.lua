local Utils = {}


function Utils.Abbreviate(Number)
	local function abbreviateNumber(num)
		if typeof(num) ~= "number" or num == math.huge or num == -math.huge then
			return "NaN"
		end

			if math.abs(num) < 1000 then
			return tostring(num)
		end

		local suffixes = { "K", "M", "B", "T" }

		local magnitude = math.floor(math.log(math.abs(num), 10) / 3)
		magnitude = math.min(magnitude, #suffixes) 

		local scaled = math.floor(num / (1000 ^ magnitude) + 0.5)

		return tostring(scaled) .. suffixes[magnitude]
	end
	
	return abbreviateNumber(Number)
end

function Utils.GetWeek()
	return math.floor(os.time() / 86400 / 7)
end

function Utils.FormatTime(Seconds) 
	local hours = math.floor(Seconds / 3600)
	local minutes = math.floor((Seconds % 3600) / 60)
	local seconds = Seconds % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

return table.freeze(Utils)