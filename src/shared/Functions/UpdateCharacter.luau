--!strict

local updateCharacterEvent = game.ReplicatedStorage.Events.UpdateCharacter;
local types = require(game.ReplicatedStorage.Functions.Types);

return function(player : Player, characterName : types.characterName)
	print(characterName)
	updateCharacterEvent:FireServer(characterName);
end
