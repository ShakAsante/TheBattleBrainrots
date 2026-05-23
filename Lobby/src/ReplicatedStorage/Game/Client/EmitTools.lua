local Emit = {}


function Emit.Do(Object)
	local function EmitParticles(ParticleOrSound)
		local EmitCount = ParticleOrSound:GetAttribute("EmitCount") or 0
		local Delay = ParticleOrSound:GetAttribute("EmitDelay") or 0
		
		if ParticleOrSound:IsA("ParticleEmitter") then
			task.delay(Delay, function()
				ParticleOrSound:Emit(EmitCount or 0)
			end)
		elseif ParticleOrSound:IsA("Sound") then
			task.delay(Delay, function()
				ParticleOrSound:Play()
			end)
		end
	end
	
	for _, Descend in pairs(Object:GetDescendants()) do
		EmitParticles(Descend)
	end
end

return Emit