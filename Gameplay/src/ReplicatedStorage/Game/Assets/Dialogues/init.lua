local Dialogues = {}


for _, NPC in pairs(script:GetChildren()) do
	for _, Dialogue in pairs(NPC:GetChildren()) do
		Dialogues[NPC.Name .. "_" .. Dialogue.Name] = require(Dialogue)
	end
end

return Dialogues