--!strict
local updateCharacterEvent = game.ReplicatedStorage.Events.UpdateCharacter;
local types = require(game.ReplicatedStorage.Functions.Types);

return function(player : Player, characterData)
	updateCharacterEvent:FireServer(characterData);
end
