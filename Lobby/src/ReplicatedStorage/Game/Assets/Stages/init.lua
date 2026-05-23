local Stages = {}

Stages.Story = require("@self/Story")
Stages.Event = require("@self/Event")


local StageInfo = {}


StageInfo["Story"] = {
	Name = "Story",
	Desc = "Story Stages",
	LayoutOrder = 1,
}

StageInfo["Event"] = {
	Name = "Event",
	Special = true,
	Desc = "Event Stages",
	LayoutOrder = 2,
}

return {Stages, StageInfo}