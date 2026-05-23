local ServerStorage = game:GetService("ServerStorage")

return function(IsDeep)
	local IsServer = game:GetService("RunService"):IsServer()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Root = ReplicatedStorage:WaitForChild("Game")

	local Client = Root:WaitForChild("Client")
	local Server = Root:FindFirstChild("Server")

	local ClientScripts = (Client) and (IsDeep and Client:GetDescendants() or Client:GetChildren()) or {}
	local ServerScripts = (Server) and (IsDeep and Server:GetDescendants() or Server:GetChildren()) or {}

	if Server then
		Server.Parent = ServerStorage
	end

	for _, Script in pairs(IsServer and ServerScripts or ClientScripts) do
		if Script:IsA("ModuleScript") then
			task.spawn(function()
				local Required = require(Script)

				local function run()
					if Required.GameStart then
						Required.GameStart()
					end
				end

				local success, err = xpcall(run, debug.traceback)

				if not success then
					error(err)
				end
			end)
		else
			continue
		end
	end
end