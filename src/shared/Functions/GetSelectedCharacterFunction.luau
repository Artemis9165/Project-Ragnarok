--!strict

local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

public.getSelectedCharacterName = function(player : Player)
	local selectedCharacter = player:WaitForChild('SelectedCharacter') :: StringValue
	local value = selectedCharacter.Value :: types.characterName
	return value
end

public.getSelectedCharacterAnimationFolder = function(player : Player) : Folder
	local path = game.ReplicatedStorage.CharacterData.Animations.CharacterAnimations:FindFirstChild(public.getSelectedCharacterName(player)) :: Folder
	return path
end

public.getSelectedCharacterSpecialsDataFolder = function(player : Player) : ModuleScript
	local path = game.ReplicatedStorage.CharacterData.CharacterSpecials.CharacterSpecialsData:FindFirstChild(public.getSelectedCharacterName(player)) :: ModuleScript
	return path
end

public.getSelectedCharacterSpecialsScriptFolder = function(player : Player) : ModuleScript
	local path = game.ReplicatedStorage.CharacterData.CharacterSpecials.CharacterSpecialScripts:FindFirstChild(public.getSelectedCharacterName(player)) :: ModuleScript
	return path
end

return public