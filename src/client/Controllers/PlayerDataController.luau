--!strict

local updateCharacterEvent = game.ReplicatedStorage.Events.UpdateCharacter;
local private = {};
local public = {};

local player : Player = script.Parent.Parent.Parent;

public.onStart = function()
	updateCharacterEvent.OnClientEvent:Connect(function(character)
		-- Replace the GUI with the new characters GUI (and weapon if the character has one);
	end)
	
end

return public;