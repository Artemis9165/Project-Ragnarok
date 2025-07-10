--!strict

local collectionService = game:GetService('CollectionService')

local destroyEnviromentEvent = game.ReplicatedStorage.RemoteEvents.DestroyEnviromentEvent

local private = {}
local public = {}

private.destroyEnviroment = function(player : Player, character : Model, impactPosition : Vector3, areaDestroyed : Vector3)
	local region = Region3.new(
		impactPosition - areaDestroyed,
		impactPosition + areaDestroyed
	)
	local environmentParts = workspace:FindPartsInRegion3(region, character, 50)
	for _, part in ipairs(environmentParts) do
		if collectionService:HasTag(part, 'Breakable') then
			local originalCFrame = part.CFrame
			local originalAnchored = part.Anchored
			local originalParent = part.Parent
			part.Anchored = false
			part:BreakJoints()
			part.Velocity = Vector3.new(math.random(-20, 20), math.random(20, 40), math.random(-20, 20))
			task.delay(3, function()
				if part and part:IsDescendantOf(workspace) then
					part.Anchored = originalAnchored
					part.CFrame = originalCFrame
					part.Velocity = Vector3.zero
					part.RotVelocity = Vector3.zero
				end
			end)
		end
	end
end

public.onStart = function()
	destroyEnviromentEvent.OnServerEvent:Connect(private.destroyEnviroment)
end

return public