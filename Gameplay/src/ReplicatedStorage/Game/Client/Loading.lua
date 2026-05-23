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

function Loading.GameStart()
	--local InterfaceTools = require(Root.Client.InterfaceTools)
	--local LoadingScreen = InterfaceTools.GetInterface("Loading")
	--local Progress = Loading:Value(0)
	
	--Loading:Hydrate(LoadingScreen.CanvasGroup.Back.Icon.Desc) {
		--Text = Loading:Computed(function(Use)
			--return "(Assets Loaded: " .. Use(Progress) .. " / " .. #ActualAssets .. ")"
		--end)
	--}

	ContentProvider:PreloadAsync(ActualAssets, function(AssetId, Status)
		--Progress:set(Fusion.peek(Progress) + 1)
	end)
end

return Loading