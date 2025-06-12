--!strict
local types = require(game.ReplicatedStorage.Functions.Types)
local Super = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Super)

local Weapon = {}
Weapon.__index = Weapon

Weapon.new = function()
	return setmetatable({}, Weapon);
end

return Weapon
