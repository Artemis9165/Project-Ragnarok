--!strict
return function(player : Player)
	local selectedCharacter = player:WaitForChild("SelectedCharacter") :: StringValue
	local character = require(game.ReplicatedStorage.CharacterData.Classes.Characters:FindFirstChild(selectedCharacter.Value)) :: ModuleScript
	return character.new()
end

