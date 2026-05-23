local Ads = {}
local AdService = game:GetService("AdService") :: AdService

function Ads.IsAvailable()
	local Sucess, Result = pcall(function()
		return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
	end)
	
	if Sucess and Result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable then
		return true
	end
	
	return false
end

function Ads.CanView()
	local INELIGIBLE_RESULTS = {
		Enum.AdAvailabilityResult.PlayerIneligible,
		Enum.AdAvailabilityResult.DeviceIneligible,
		Enum.AdAvailabilityResult.PublisherIneligible,
		Enum.AdAvailabilityResult.ExperienceIneligible,
	}
	
	local Sucess, Result = pcall(function()
		return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
	end)
	
	for _, inEligibleResult in ipairs(INELIGIBLE_RESULTS) do
		if Result.AdAvailabilityResult == inEligibleResult then
			return false
		end
	end
end

return Ads