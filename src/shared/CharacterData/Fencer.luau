--!strict
--[Components]
local Super = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Super)
local Awakened = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Awakened)
local SpecialSuper = require(game.ReplicatedStorage.CharacterData.Classes.Specials.Super)

--[Types]
local types = require(game.ReplicatedStorage.Functions.Types)

--[Animations]
local animations = game.ReplicatedStorage.CharacterData.Animations.CharacterAnimations.Fencer
local universalAnimations = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations

local Fencer = {}
Fencer.__index = Fencer

local generalAnimations : types.GeneralAnimations = {
	Idle = animations.General.Idle,
	Walk = animations.General.Walk,
	Sprint = animations.General.Sprint,
	Block = animations.General.Block,
	Jump = universalAnimations.Other.Jump
}

local DashAnimations : types.DashAnimations = {
	Forward = animations.General.ForwardDash,
	Back = universalAnimations.Dashes.Back,
	Left = universalAnimations.Dashes.Left,
	Right = universalAnimations.Dashes.Right
}

local combo : types.combo = {
	One = animations.M1[1],
	Two = animations.M1[2],
	Three = animations.M1[3],
	Four = animations.M1[4],
}

local comboFinishers : types.comboFinishers = {
	Slam = animations.M1.Slam,
	Uppercut = animations.M1.Uppercut
}

local m1Animations : types.M1Animations = {
	Combo = combo,
	ComboFinishers = comboFinishers
}

local awakening : types.Awakening = {
	Name = 'test',
	Animation = animations.Awakening,
	DestroysEnviroment = false
}

local Special1 : types.Special = {
	Name = 'Special1',
	Animation = animations.Specials.Regular[1],
	Cooldown = 0,
}

local Special2 : types.Special = {
	Name = 'Special2',
	Animation = animations.Specials.Regular[2],
	Cooldown = 0,
}

local Special3 : types.Special = {
	Name = 'Special3',
	Animation = animations.Specials.Regular[3],
	Cooldown = 0,
}

local Special4 : types.Special = {
	Name = 'Special4',
	Animation = animations.Specials.Regular[4],
	Cooldown = 0,
}

local AwakenedSpecial1 : types.Special = {
	Name = 'Special1',
	Animation = animations.Specials.Awakened[1],
	Cooldown = 0,
}

local AwakenedSpecial2 : types.Special = {
	Name = 'Special2',
	Animation = animations.Specials.Awakened[2],
	Cooldown = 0,
}

local AwakenedSpecial3 : types.Special = {
	Name = 'Special3',
	Animation = animations.Specials.Awakened[3],
	Cooldown = 0,
}

local AwakenedSpecial4 : types.Special = {
	Name = 'Special4',
	Animation = animations.Specials.Awakened[4],
	Cooldown = 0,
}

local regularSpecials = {
	Special1 = {
		SpecialSuper.new(Special1)
	},
	Special2 = {
		SpecialSuper.new(Special2)
	},
	Special3 = {
		SpecialSuper.new(Special3)
	},
	Special4 = {
		SpecialSuper.new(Special4)
	},
}

local awakenedSpecials = {
	Special1 = {
		SpecialSuper.new(AwakenedSpecial1)
	},
	Special2 = {
		SpecialSuper.new(AwakenedSpecial2)
	},
	Special3 = {
		SpecialSuper.new(AwakenedSpecial3)
	},
	Special4 = {
		SpecialSuper.new(AwakenedSpecial4)
	},
}


Fencer.new = function()
	return setmetatable({
		Super = Super.new('Fencer', generalAnimations, m1Animations, DashAnimations),
		Awakening = Awakened.new(awakening),
		Specials = {
			Regular = regularSpecials,
			Awakened = awakenedSpecials,
		}
	}, Fencer)	
end

Fencer.__toString = function()
	return Fencer
end

return Fencer