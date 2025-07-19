--!strict

local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

public.getCharactersFromParts = function(parts : {BasePart}) : {Model}
	local characters = {}
	for i, part in ipairs(parts) do
		local character = part.Parent :: Model
		local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
		if humanoid and not table.find(characters, character) then
			table.insert(characters, character)
		end
	end
	return characters
end

public.getTargetRaycast = function(character : Model, origin: Vector3, direction: Vector3, range: number): Instance | nil
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, direction.Unit * range, rayParams)
	local length = range
	if result then
		length = (result.Position - origin).Magnitude
	end

	--[DEBUG]
	--local rayPart = Instance.new("Part")
	--rayPart.Anchored = true
	--rayPart.CanCollide = false
	--rayPart.Transparency = 0.5
	--rayPart.Color = Color3.new(1, 0, 0)
	--rayPart.Material = Enum.Material.Neon
	--rayPart.Size = Vector3.new(0.1, 0.1, length)
	--rayPart.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -length / 2)
	--rayPart.Parent = workspace
	--game:GetService("Debris"):AddItem(rayPart, 0.2)

	if result then
		return result.Instance
	end
	return nil
end

public.getTargetRegion3 = function(character : Model, humanoidRootPart : BasePart, size : Vector3, forwardOffset : number) : {BasePart}
	local forwardVector : Vector3 = humanoidRootPart.CFrame.LookVector
	local center : Vector3 = humanoidRootPart.Position + forwardVector * forwardOffset
	local regionCFrame : CFrame = CFrame.new(center, center + forwardVector)
	local overlapParams : OverlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	--Add when in map
	--workspace.Maps.CentralPark.Arena.Arena
	overlapParams.FilterDescendantsInstances = {character}
	overlapParams.MaxParts = 50
	local parts : {BasePart} = workspace:GetPartBoundsInBox(regionCFrame, size, overlapParams)

	--[DEBUG]
	--local debugPart = Instance.new("Part")
	--debugPart.Size = size
	--debugPart.CFrame = regionCFrame
	--debugPart.Anchored = true
	--debugPart.CanCollide = false
	--debugPart.Transparency = 0.6
	--debugPart.Color = Color3.new(1, 0, 0)
	--debugPart.Material = Enum.Material.Neon
	--debugPart.Parent = workspace
	--game.Debris:AddItem(debugPart, 0.4)

	return parts
end

public.onStart = function()	end

return public