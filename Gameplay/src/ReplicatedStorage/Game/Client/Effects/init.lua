local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Effects = {}
Effects.__effects = {}

local Remotes = Root.Remotes

function Effects.GameStart()
	for _, Module in pairs(script:GetChildren()) do
		local Exec = require(Module);
		for MethodName, Method in pairs(Exec) do
			Effects.__effects[MethodName] = Method
		end 
	end
	
	print(Effects.__effects)
	
	Remotes.Replicate.OnClientEvent:Connect(function(EffectName, ...)
		Effects:DoEffect(EffectName, ...)
	end)
	
end

function Effects:DoEffect(EffectName, ...)
	local Effect = Effects.__effects[EffectName]
	if Effect then
		coroutine.wrap(Effect)(...)
	end
end

return Effects