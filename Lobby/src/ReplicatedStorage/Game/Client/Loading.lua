local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = ReplicatedStorage:WaitForChild("Game")
local Fusion = require(Root.Shared.Packages.Fusion)
local Loading = Fusion.scoped(Fusion)
Loading.IsLoaded = Loading:Value(false)

local ContentProvider = game:GetService("ContentProvider")
local Assets = Root.Assets:GetDescendants()
local ActualAssets = {}
for _, Asset in pairs(Assets) do
	if Asset:IsA("Decal") or Asset:IsA("Sound") or Asset:IsA("Texture") or Asset:IsA("Animation") then
		table.insert(ActualAssets, Asset)
	end
end

local Promise = require(Root.Shared.Packages.Promise)

local TweenService = game:GetService("TweenService")
local TableUtils = require(Root.Shared.Packages.TableUtil)

function Loading.HandleLoadingScreen()
	--local LoadingInterface = InterfaceTools.GetInterface("Loading")
	Loading.Await():await()

	wait(1.75)
	
	--local DoneSound = LoadingInterface.Done
	--DoneSound:Play()
	
	--local Tween = TweenService:Create(LoadingInterface.Body, TweenInfo.new(1, Enum.EasingStyle.Quad), {
	--	GroupTransparency = 1
	--})
	
	--Tween:Play()
	--Tween.Completed:Wait()
	
	
	--LoadingInterface:Destroy()
end

function Loading.GameStart()
	local InterfaceTools = require(Root.Client.InterfaceTools)
	local LoadingScreen = InterfaceTools.GetInterface("Loading")
	local Progress = Loading:Value(0)
	
	Loading:Hydrate(LoadingScreen.CanvasGroup.Back.Icon.Desc) {
		Text = Loading:Computed(function(Use)
			return "(Assets Loaded: " .. Use(Progress) .. " / " .. #ActualAssets .. ")"
		end)
	}

	ContentProvider:PreloadAsync(ActualAssets, function(AssetId, Status)
		--if Status == Enum.AssetFetchStatus.Success then
		--else
			--print("Failed to load asset with ID:", AssetId)
			
		--end
		Progress:set(Fusion.peek(Progress) + 1)
	end)
end

function Loading.Await()
	return Promise.new(function(Resolve, Reject)
		local FinishedLoading = false
		
		while FinishedLoading == false do
			wait()
			if Fusion.peek(Loading.IsLoaded) then
				FinishedLoading = true
				Resolve()
			end
		end
	end)
end

function Loading.Skip()
	Loading.IsLoaded:set(true)
end

function Loading.Load()
	--ContentProvider:PreloadAsync(Assets)
	--Loading.IsLoaded:set(true)
end

return Loading