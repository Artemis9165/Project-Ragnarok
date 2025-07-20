--!strict

local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

public.getSelectedCharacterName = function(player : Player) : string
	local selectedCharacter = player:WaitForChild('SelectedCharacter') :: StringValue
	return selectedCharacter.Value
end

public.getSelectedCharacterAnimationFolder = function(player : Player) : Folder
	local path = game.ReplicatedStorage.CharacterData.Animations.CharacterAnimations:FindFirstChild(public.getSelectedCharacterName(player)) :: Folder
	return path
end

public.getSelectedCharacterSpecialsDataFolder = function(player : Player) : ModuleScript
	local path = game.ReplicatedStorage.CharacterData.CharacterSpecialsData:FindFirstChild(public.getSelectedCharacterName(player)) :: ModuleScript
	return path
end

public.getSelectedCharacterSpecialsScriptFolder = function(player : Player) : ModuleScript
	local path = game.ReplicatedStorage.CharacterData.CharacterSpecialScripts:FindFirstChild(public.getSelectedCharacterName(player)) :: ModuleScript
	return path
end

return public