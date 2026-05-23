return function (Who, TagInfo, Statuses)
	Statuses = Statuses or {}
	if Who then
		local Target = Who.Model
		local PostureDamage = TagInfo.PostureDamage or 0 
		local HealthDamage = TagInfo.Damage or 0
		local BaseDamage = TagInfo.BaseDamage or 0

		local TargetHealth = Target:FindFirstChild("Health")
		local TargetPosture = Target:FindFirstChild("Posture")
		local IsBase = Target:FindFirstChild("BaseHealth")

		if IsBase then
			IsBase.Value -= BaseDamage or PostureDamage or 0
		else
			if TargetPosture then
				TargetPosture.Value -= PostureDamage or 0

				if TargetPosture.Value == 0 then
					TargetHealth.Value -= 1
					TargetPosture.Value = TargetPosture.MaxValue
				end
			end

			if TargetHealth then
				TargetHealth.Value -= HealthDamage or 0
			end
		end
		
		task.spawn(function()
			local HasStates = Who.Statuses
			
			if HasStates then
				if Statuses.Freeze and Who.Freeze then
					Who.Freeze()
				elseif Statuses.Slow and Who.Slow then
					Who.Slow()
				elseif Statuses.Knockback and Who.Knockback then
					Who.Knockback()
				end
			end
		end)
		
	end
end