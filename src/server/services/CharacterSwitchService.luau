--!strict

local types = require(game.ReplicatedStorage.Functions.Types)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

local updateCharacterEvent = game.ReplicatedStorage.RemoteEvents.UpdateCharacter

local private = {}
local public = {}

public.onStart = function()
	updateCharacterEvent.OnServerEvent:Connect(function(player : Player, characterName : types.characterName)
		local selectedCharacter = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
		if selectedCharacter ~= characterName then
			player:LoadCharacter()
			selectedCharacter = characterName
			updateCharacterEvent:FireClient(player, characterName)
		end
	end)
end

return public
