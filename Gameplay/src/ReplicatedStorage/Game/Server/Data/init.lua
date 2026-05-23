local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local Data = Fusion.scoped(Fusion)
local Players = game:GetService("Players")
local ProfileStore = require(Root.Shared.Packages.ProfileStore)
local Promise = require(Root.Shared.Packages.Promise)

local RunService = game:GetService("RunService")

local Template = require("@self/Template")
local MainStore = RunService:IsStudio() and ProfileStore.New("Main", Template).Mock or  ProfileStore.New("Main", Template) 

local Remotes = Root.Remotes

function Data.GameStart()
	Data.Profiles = {}
	
	Players.PlayerAdded:Connect(function(Player)
		local Profile =  MainStore:StartSessionAsync("Player_"..Player.UserId, {
			Cancel = function()
				return not Player:IsDescendantOf(Players)
			end,
		})
		
		Profile:Reconcile()
		Profile:AddUserId(Player.UserId)

		Profile.OnSessionEnd:Connect(function()
			Data.Profiles[Player] = nil
		end)
		
		Data.Profiles[Player] = Profile
		print(Profile.Data)
	end)
	
	Players.PlayerRemoving:Connect(function(Player)
		Data.Profiles[Player] = nil
	end)
end


function Data.GetProfile(Player)
	return Promise.new(function(Resolve, Reject)
		local Sucessful, Exists = pcall(function()
			return Data.Profiles[Player] 
		end)

		if Sucessful and Exists then
			Resolve(Exists)
		else
			local Timeout = 10

			while Timeout > 0 do
				if Data.Profiles[Player] ~= nil then
					break
				end
				
				Timeout -= wait()
			end

			if Data.Profiles[Player] then
				Resolve(Data.Profiles[Player])
			else
				Reject(`Profile does not exist: {Player.Name}`)
			end
		end
	end)
end


return Data