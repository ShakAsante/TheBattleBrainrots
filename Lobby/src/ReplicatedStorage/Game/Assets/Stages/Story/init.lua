local Stages = {}

for _, Stage in  pairs(script:GetChildren()) do
	Stages[tonumber(Stage.Name)] = require(Stage)
end

return table.freeze (Stages)