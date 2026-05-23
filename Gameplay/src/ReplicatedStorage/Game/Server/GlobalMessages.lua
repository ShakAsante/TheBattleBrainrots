local GlobalMessages = {}
local Messaging = game:GetService("MessagingService")
local Remotes = game:GetService("ReplicatedStorage").Game.Remotes

function GlobalMessages.GameStart()
	Messaging:SubscribeAsync("GlobalMessage", function( Data )
		Remotes.Replicate:FireAllClients("Notification", Data.Data)
	end)	
end

return GlobalMessages