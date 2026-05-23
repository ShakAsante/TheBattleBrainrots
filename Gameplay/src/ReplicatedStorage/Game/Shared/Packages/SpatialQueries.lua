local SpatialQueries = {}

--local function GetDistance(a: Vector3, b: Vector3)
--	return (a - b).Magnitude
--end

--local function IsInDirection(origin: Vector3, target: Vector3, direction: Vector3, maxAngleDegrees: number)
--	local toTarget = (target - origin).Unit
--	local dot = direction:Dot(toTarget)
--	local angle = math.deg(math.acos(dot))
--	return angle <= maxAngleDegrees
--end

--function SpatialQueries.GetPartsInRadius(position: Vector3, radius: number, ignoreList: {Instance}?): {BasePart}
--	ignoreList = ignoreList or {}

--	local region = Region3.new(position - Vector3.new(radius, radius, radius), position + Vector3.new(radius, radius, radius))
--	local parts = workspace:FindPartsInRegion3WithIgnoreList(region, ignoreList, math.huge)

--	local results = {}
--	for _, part in ipairs(parts) do
--		if part:IsA("BasePart") and GetDistance(part.Position, position) <= radius then
--			table.insert(results, part)
--		end
--	end

--	return results
--end

--function SpatialQueries.GetPlayersInRadius(position: Vector3, radius: number, ignoreCharacter: Model?): {Player}
--	local playersInRadius = {}

--	for _, player in ipairs(game.Players:GetPlayers()) do
--		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
--			if player.Character ~= ignoreCharacter then
--				local hrp = player.Character.HumanoidRootPart
--				if GetDistance(hrp.Position, position) <= radius then
--					table.insert(playersInRadius, player)
--				end
--			end
--		end
--	end

--	return playersInRadius
--end

--function SpatialQueries.GetNearestPlayer(position: Vector3, range: number?, ignoreCharacter: Model?): Player?
--	local closest = nil
--	local shortest = math.huge

--	for _, player in ipairs(game.Players:GetPlayers()) do
--		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
--			if player.Character ~= ignoreCharacter then
--				local dist = GetDistance(player.Character.HumanoidRootPart.Position, position)
--				if (not range or dist <= range) and dist < shortest then
--					shortest = dist
--					closest = player
--				end
--			end
--		end
--	end

--	return closest
--end

--function SpatialQueries.GetPlayersInDirection(position: Vector3, forward: Vector3, radius: number, fovAngle: number, ignoreCharacter: Model?): {Player}
--	local players = {}

--	for _, player in ipairs(game.Players:GetPlayers()) do
--		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
--			if player.Character ~= ignoreCharacter then
--				local hrp = player.Character.HumanoidRootPart
--				local distance = GetDistance(hrp.Position, position)
--				if distance <= radius and IsInDirection(position, hrp.Position, forward, fovAngle / 2) then
--					table.insert(players, player)
--				end
--			end
--		end
--	end

--	return players
--end

---- Get parts in directional FOV
--function SpatialQueries.GetPartsInDirection(position: Vector3, forward: Vector3, radius: number, fovAngle: number, ignoreList: {Instance}?): {BasePart}
--	local candidates = SpatialQueries.GetPartsInRadius(position, radius, ignoreList)
--	local results = {}

--	for _, part in ipairs(candidates) do
--		if IsInDirection(position, part.Position, forward, fovAngle / 2) then
--			table.insert(results, part)
--		end
--	end

--	return results
--end

function SpatialQueries:SimpleQuery(PartA, PartB, Range, ZCheck)
	--local ZCheck = Args.ZCheck
	--local Range = Args.Range
	local Hit = false
	--if PartA and PartB then else return false end
	local DistanceBetween =  (PartA.CFrame.p - PartB.CFrame.p).Magnitude

	if DistanceBetween <= (Range + 2) then
		if ZCheck then
			local Inversed = PartA.CFrame:Inverse() * PartB.CFrame
			if Inversed.Z <= 1.7 then
				Hit = true
			end
		else
			Hit = true
		end
	end

	return Hit
end

return SpatialQueries