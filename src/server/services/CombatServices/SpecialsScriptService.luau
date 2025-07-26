--!strict

-- [Roblox Services]

-- [Services]
local detectionService = require(game.ServerScriptService.Services.CombatServices.DetectionService)
local hurtService = require(game.ServerScriptService.Services.CombatServices.HurtService)

-- [Controllers]

-- [Functions]
local types = require(game.ReplicatedStorage.Functions.Types)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

-- [Remote Events]

-- [Remote Functions]

local private = {}
local public = {}

private.standardHitbox = Vector3.new(2, 2, 2) :: Vector3

private.getCharacterParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.getSelectedCharacterSpecialData = function(player : Player) : SharedTable
	local characterName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local selectedCharacterSpecialData = require(game.ReplicatedStorage.CharacterData.CharacterSpecials.CharacterSpecialsData[characterName]) :: SharedTable
	return selectedCharacterSpecialData
end

private.createHitbox = function(player : Player) : {Model}
	local character : Model, _, humanoidRootPart : BasePart = private.getCharacterParts(player)
	local parts = detectionService.getTargetRegion3(character, humanoidRootPart, private.standardHitbox, 4)
	local characters = detectionService.getCharactersFromParts(parts)
	return characters
end

private.damagingSpecial = function(player : Player, damage : number, count : number?)
	local characters = private.createHitbox(player)
	for _, character in ipairs(characters) do
		if count then
			hurtService.regularSpecialHurt(player, character, damage, count)
		else
			hurtService.regularSpecialHurt(player, character, damage)
		end
	end
end

private.multiHitSpecial = function(player : Player, specialName : types.specialName, count : number)
	local damage = private.getSelectedCharacterSpecialData(player).getSpecialData(specialName).damage :: {number}
	private.damagingSpecial(player, damage[count], count)
end

public.triggerSpecial = function(player : Player, characterName : string, specialName : types.specialName, count : number?)
	local selectedCharacterSpecialData = private.getSelectedCharacterSpecialData(player)
	local specialType = types.determineSpecialType(selectedCharacterSpecialData.getSpecialData(specialName))
	if specialType == 'multiHit' and count then private.multiHitSpecial(player, specialName, count) end
end

public.onStart = function()
	
end

return public