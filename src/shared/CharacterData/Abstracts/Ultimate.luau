--!strict
local types = require(game.ReplicatedStorage.Functions.Types)
local Super = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Super)

local Ultimate = {}
Ultimate.__index = Ultimate

Ultimate.new = function(ultimate : types.Ultimate)
	return setmetatable(ultimate, Ultimate);
end

function Ultimate:Ultimate()
	return self
end

return Ultimate
