--!strict
local types = require(game.ReplicatedStorage.Functions.Types)
local Super = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Super)

local Awakened = {}
Awakened.__index = Awakened

Awakened.new = function(awakening : types.Awakening)
	return setmetatable(awakening, Awakened);
end

function Awakened:Awaken()
	return self
end

return Awakened
