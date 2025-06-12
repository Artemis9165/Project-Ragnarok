--!strict
local types = require(game.ReplicatedStorage.Functions.Types)
local animations = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations

local Super = {}
Super.__index = Super

Super.new = function(name : types.characterName, 
	generalAnimations : types.GeneralAnimations,
	DashAnimations : types.DashAnimations,
	BlockAnimations : types.BlockAnimations,
	m1Animations : types.M1Animations)
	return setmetatable({
		Stats = {
			Name = name,
			Health = 100,
			WalkSpeed = 16,
			SprintSpeed = 24,
			JumpHeight = 7.2,
			M1Damage = 3,	
		},
		Animations = {
			General = { 
				generalAnimations,
				Dashes = DashAnimations,
			},
			M1 = {
				m1Animations,
				M1Hurt = {
					Hurt1 = animations.M1Hurts.Hurt1,
					Hurt2 = animations.M1Hurts.Hurt2,
					Hurt3 = animations.M1Hurts.Hurt3,
					Knockback = animations.M1Hurts.Knockback
				},
				Block = BlockAnimations
			},
		},
	}, Super)
end

Super.__toString = function()
	return Super;
end

return Super