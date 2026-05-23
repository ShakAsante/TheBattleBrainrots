local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage.Game
local Assets = Root:WaitForChild("Assets")
local Remotes = Root:WaitForChild("Remotes")

local Fusion = require(Root.Shared.Packages.Fusion)
local Battle = Fusion.scoped(Fusion)
local Remotes = Root.Remotes

Battle.Team = {}
Battle.Running = Battle:Value(false)

local Products  = require(Assets.Products)

local UnitInfo = require(Assets.UnitInfo)
local RunService = game:GetService("RunService")

local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui

local TweenService = game:GetService("TweenService")

Battle.SpawningDisabled = Battle:Value(false)
Battle.AbilityDisabled = Battle:Value(false)
Battle.Data = {}

function Battle.HandleAbility()
	local AbilityButton = MainInterface.Actions.Ability

	do
		local Cooldown = Battle:Value(true)
		local CooldownProgress = Battle:Value(0) 
		
		local function RegisterCooldown()
			local CooldownTime = tick() + (30)
			while CooldownTime - tick() > 0 do
				CooldownProgress:set(30 - (CooldownTime-tick()))
				task.wait()
			end
		end
		
		task.spawn(function()
			RegisterCooldown()

			Cooldown:set(false)
			CooldownProgress:set(0)
		end)

		Battle:Hydrate(AbilityButton) {
			[Fusion.OnEvent("Activated")] = function()
				if Fusion.peek(Cooldown) or Fusion.peek(Battle.Running) == false or Fusion.peek(Battle.AbilityDisabled) then
					return
				end

				local Sucessful = Remotes.UseAbility:InvokeServer()

				if not Sucessful then return end

				Cooldown:set(true)

				RegisterCooldown()

				Cooldown:set(false)
				CooldownProgress:set(0)
			end,
		}

		Battle:Hydrate(AbilityButton.Cooldown) {
			Visible = Cooldown
		}

		Battle:Hydrate(AbilityButton.Cooldown.Bar.Progress) {
			Size = Battle:Spring(Battle:Computed(function(Use)
				return UDim2.fromScale(Use(CooldownProgress)/30,1)
			end), 15, .9)
		}
	end

end

function Battle.GameStart()
	Effects = require("./Effects")
	InterfaceTools = require("./InterfaceTools")
	MainInterface = InterfaceTools.GetInterface("Main")
	Ads = require("./Ads")
	Purchase = require("./Purchase")
	Interface = require("./Interface")

	Remotes.PlaceUnit.OnClientEvent:Connect(function(UnitName)
		Battle.Data[UnitName].Cooldown()
	end)
	
	Battle.HandleAbility()
	
	local Listeners = {
		["Starting"] = function(Team)
			local TeamFrame = MainInterface.Team
			for UnitIndex, Unit in pairs(Team) do
				if Unit.Name == "" then continue end
				--print(Unit.Name)
				
				local Form = Unit.Form or "Base"
				local Info = UnitInfo[Unit.Name]
				
				local UnitTemplate = TeamFrame.Template:Clone()
				UnitTemplate.Parent = TeamFrame
				UnitTemplate.Visible = true

				--local UnitRarity = Info.Rarity or "Normal"

				--InterfaceTools.CreateGradient(UnitRarity) {
				--	Parent = UnitTemplate.Stroke:WaitForChild("2"),
				--	Rotation = 45,
				--}
		
				
				local Model = Assets.Rots:WaitForChild(Unit.Name):WaitForChild(Form).Default:Clone()
				Model.Parent = UnitTemplate.View.WorldModel
				--wait()
				local Body = Model:WaitForChild("Body")
				
				local Original = CFrame.new(-2,-2,-5) * CFrame.Angles(0, math.rad(-50), 0)
				Body:PivotTo(Original)

				--local Cost = `${FormInfo.Cost or 0}`
				--UnitTemplate.Price.Text = Cost

				local Cooldown = Battle:Value(false)
				local CooldownProgress = Battle:Value(0) 
				local UnitCooldown = UnitInfo[Unit.Name].Cooldown or 5

				Battle.Data[UnitIndex] = {
					Cooldown = function()
						Cooldown:set(true)

						local CooldownTime = tick() + UnitCooldown

						while CooldownTime - tick() > 0 do
							CooldownProgress:set(UnitCooldown - (CooldownTime-tick()))
							task.wait()
						end

						Cooldown:set(false)
						CooldownProgress:set(0)
					end,
				}
				
				Battle:Hydrate(UnitTemplate) {
					[Fusion.OnEvent("Activated")] = function()
						if Fusion.peek(Cooldown) or Fusion.peek(Battle.SpawningDisabled) then
							return
						end

						Remotes.PlaceUnit:FireServer(UnitIndex)

						--if not Placed then 
							--return 
						--end

						--Cooldown:set(true)
						
						--local CooldownTime = tick() + UnitCooldown

						--while CooldownTime - tick() > 0 do
							--CooldownProgress:set(UnitCooldown - (CooldownTime-tick()))
							--task.wait()
						--end

						--Cooldown:set(false)
						--CooldownProgress:set(0)
					end,
				}
				
				Battle:Hydrate(UnitTemplate.Price) {
					Text = `$` .. Info.Cost
				}

				Battle:Hydrate(UnitTemplate.Cooldown) {
					Visible = Cooldown
				}

				Battle:Hydrate(UnitTemplate.Cooldown.Back.Progress) {
					Size = Battle:Spring(Battle:Computed(function(Use)
						return UDim2.fromScale(Use(CooldownProgress)/UnitCooldown, 1)
					end), 15, .9)
				}

				Battle.Team[UnitIndex] = { Cooldown = Cooldown }
			end

			Battle.RequestStart()
		end,
		
		["Disable"] = function(Type, State)
			if Type == "Ability" then
				Battle.AbilityDisabled:set(State)
			elseif Type == "Spawning" then
				Battle.SpawningDisabled:set(State)
			end
		end,
		
		["Running"] = function()
			Battle.Running:set(true)
		end,
		
		["End"] = function(Config)
			local Failed  = Config.Failed
			local Rewards = Config.Rewards
			local EndScreen = script.EndScreen:Clone()

			Battle.Running:set(false)
			
			MainInterface.Enabled = false
			
			local Body = EndScreen.Body
			Body.Size = UDim2.fromScale(1, 0)
			
			Battle:Hydrate(Body.TextLabel) {
				Text = Battle:Computed(function()
					return Failed and "YOU LOST!" or "YOU WON!"
				end)
			}
			
			EndScreen.Parent = PlayerGui
			
			local Easing = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local Actions = Body.Inner.Actions
			local Currencies = Body.Inner.Currencies
			local Items = Body.Inner.Items

			local ReviveButton = Actions.Inner.Revive
			ReviveButton.Visible = false --Failed
			
			local Lobby = Actions.Inner.Lobby
			
			Battle:Hydrate(Lobby) {
				[Fusion.OnEvent("Activated")] = function()
					Remotes.Game:InvokeServer("RequestLobby")
				end,
			}
			
			local NextStage = Actions.Inner.NextStage
			local IsNextStage = Config.IsNextStage 
			
			Battle:Hydrate(NextStage) {
				[Fusion.OnEvent("Activated")] = function()
					Remotes.Game:InvokeServer("RequestNextStage")
					MainInterface.Enabled = true
					EndScreen:Destroy()
				end,
				
				Visible = not Failed and IsNextStage
			}
			
			Battle:Hydrate(ReviveButton) {
				[Fusion.OnEvent("Activated")] = function()
					if Ads.CanView() then
						Remotes.Game:InvokeServer("RequestRevive")
					else
						Purchase.PromptProduct(Products.DevProducts.Revive)
					end
				end,	
			}	
			
			local ShowCurrenciesFrame = (not Failed and Rewards) and (Rewards.Money or Rewards.Gems or Rewards.XP)
			Currencies.Visible = ShowCurrenciesFrame

			local MoneyExists = Rewards and Rewards.Money
			local GemsExists = Rewards and Rewards.Gems
			local XPExists = Rewards and Rewards.XP
			
			local MoneyText = Currencies.Inner.Money
			local GemText = Currencies.Inner.Gems
			local XPText = Currencies.Inner.XP

			Battle:Hydrate(MoneyText) { 
				Visible = MoneyExists ~= 0 and MoneyExists ~= nil
			}
			
			Battle:Hydrate(GemText) { 
				Visible = GemsExists ~= 0  and GemsExists ~= nil
			}
			
			Battle:Hydrate(XPText) { 
				Visible = XPExists ~= 0 and XPExists ~= nil
			}

			Battle:Hydrate(MoneyText.TextLabel) {
				Text = MoneyExists
			}

			Battle:Hydrate(GemText.TextLabel) {
				Text = GemsExists
			}
			
			Battle:Hydrate(XPText.TextLabel) {
				Text = XPExists
			}
			
			--Currencies.Inner.Money.TextLabel.Text = `+{MoneyExists or 0} Money`
			
			
			--Currencies.Inner.Gems.TextLabel.Text = `+{GemsExists or 0}`
			--Currencies.Inner.XP.TextLabel.Text = `{XPExists or 0}`
			
			local ShowItemsFrame = (not Failed and Rewards) and Rewards.Items
			Items.Visible = ShowItemsFrame	

			local Tween = TweenService:Create(Body, Easing, {Size = UDim2.fromScale(1, .15)})
			Tween:Play()
			Tween.Completed:Wait()
			Body.Inner.Visible = true
		end,
		
		["ResetWallet"] = function()
			Interface.WalletLevel:set(0)
		end,
	}
	
	Remotes.Game.OnClientInvoke = function(EventName, ...)
		if Listeners[EventName] then
			Listeners[EventName](...)
		end
	end
end

function Battle.RequestStart()
	game.SoundService.Snd007:Play()
	Effects:DoEffect("IntroDefault")
	Battle.HandleClient()
end

function Battle.HandleClient()
	local Bases = workspace.Map.Bases
	
	local function HandleBase(Base)
		local HealthInstance = Base:WaitForChild("BaseHealth", 5) :: IntConstrainedValue
		local HealthValue = Battle:Value(HealthInstance.Value)
		
		local HealthDisplay = Base.HealthBar
		local Bar = HealthDisplay.Body.Inner.Progress
		
		Battle:Hydrate(Bar) {
			Size = Battle:Spring(Battle:Computed(function(Use)
				return UDim2.fromScale(Use(HealthValue)/HealthInstance.MaxValue, 1)
			end), 15, .9)
		}
		
		local Label = HealthDisplay.Body.Label
		
		Battle:Hydrate(Label) {
			Text = Battle:Computed(function(Use)
				return `{Use(HealthValue)}/{HealthInstance.MaxValue}`
			end)
		}
		
		Battle:Hydrate(HealthInstance) {
			[Fusion.OnEvent("Changed")] = function()
				HealthValue:set(HealthInstance.Value)
			end,
		}
	end
	
	for _, Base in pairs(Bases:GetChildren()) do
		HandleBase(Base)
	end
end

return Battle