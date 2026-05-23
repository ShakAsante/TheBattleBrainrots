local Summon = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Remotes = Root.Remotes
local InventoryTools = require("./InventoryTools")
local Banners = require(Root.Banners)

local Tweaks = require(Root.Tweaks)
local Assets = Root:WaitForChild("Assets")
local UnitInfo = require(Assets.UnitInfo)

function Summon.GameStart()
	local Data = require("./Data")
	Quests = require("./Quests")
	
	Remotes.Summon.OnServerInvoke = function(Player, Banner, Type)
		Type = Type or "Single"
		
		local Success, Profile = Data.GetProfile(Player):await()
		
		if Success and Profile then
			local Actions = {
				["Single"] = function(Player, Banner, Type)
					local CurrentGems = Profile.Data.Gems
					
					if CurrentGems >= Tweaks.SummonCost then
						Quests.Progress(Player, "Summon")
						Profile.Data.Gems -= Tweaks.SummonCost
						
						local BannerData = Banners[Banner] :: Banners.Banner
						local UnitContent = BannerData.Content
						
						local Chances = BannerData.Rarities
						
						
						local Rarities = {
							Normal = {},
							Rare = {},
							Special = {},
							SuperRare = {},
							UberRare = {},
							LegendRare = {},
						}
						
						for _, Unit in UnitContent do
							local Rarity = UnitInfo[Unit].Rarity
							table.insert(Rarities[Rarity], Unit)
						end
						
						local ChosenRarity = "Rare"
						
						local Roll = math.random()
						--print("yea")
						--print("chances", Chances)
						
						for Rarity, Value in ipairs(Chances) do
							if Roll < Value then
								ChosenRarity = Rarity
								break
							end
						end

						--print(Rarities, "uu")
						
						local PossibleUnits = Rarities[ChosenRarity]
						
						if not PossibleUnits or #PossibleUnits == 0 then
							PossibleUnits = Rarities.Normal
						end
						
						local Chosen = PossibleUnits[math.random(#PossibleUnits)]
						
						if InventoryTools.HasBrainrot(Player, Chosen) then
							Remotes.Replicate:FireClient(Player, "Notification", "You have been refunded 50 Gems", true)
							Profile.Data.Gems += 50
						else
							InventoryTools.UnlockBrainrot(Player, Chosen)
							InventoryTools.UpdateToBrainrotsClient(Player)
						end

						
						return {
							true,
							{ Chosen } 
						}
					end
					
					return {
						false
					}
				end,
				["Multi"] = function(Player, Banner, Type)
					local CurrentGems = Profile.Data.Gems

					if CurrentGems >= Tweaks.SummonCost * 5 then
						Quests.Progress(Player, "MultiSummon")
						Quests.Progress(Player, "Summon")
						Profile.Data.Gems -= Tweaks.SummonCost * 5
						
						local ListOfChosen = {}
						
						local RefundAmount = 0
						
						for Summon=1, 5 do
							local BannerData = Banners[Banner]
							local UnitContent = BannerData.Content

							local Chances = BannerData.Rarities

							local Rarities = {
								Normal = {},
								Rare = {},
								Special = {},
								SuperRare = {},
								UberRare = {},
								LegendRare = {},
							}

							for _, Unit in UnitContent do
								local Rarity = UnitInfo[Unit].Rarity
								table.insert(Rarities[Rarity], Unit)
							end
							
							--print(Rarities, "uu")

							local ChosenRarity = "Normal"

							local Roll = math.random()

							for Rarity, Value in ipairs(Chances) do
								if Roll <= Value then
									ChosenRarity = Rarity
									break
								end
							end

							local PossibleUnits = Rarities[ChosenRarity]

							if not PossibleUnits or #PossibleUnits == 0 then
								PossibleUnits = Rarities.Normal
							end

							local Chosen = PossibleUnits[math.random(#PossibleUnits)]

							if InventoryTools.HasBrainrot(Player, Chosen) then
								RefundAmount += 1
							else
								InventoryTools.UnlockBrainrot(Player, Chosen)
							end
							
							table.insert(ListOfChosen, Chosen)
						end
						
						if RefundAmount > 0 then
							Remotes.Replicate:FireClient(Player, "Notification", "You have been refunded " .. RefundAmount * 50 .. " Gems", true)
						end
						
						InventoryTools.UpdateToBrainrotsClient(Player)

						return {
							true,
							ListOfChosen 
						}
					end

					return {
						false
					}
				end,
			} 
			
			return Actions[Type](Player, Banner, Type)
		end 
	end
end

return Summon