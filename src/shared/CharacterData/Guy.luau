--!strict
--[Components]
local Super = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Super)
local Awakened = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Abstracts.Awakened)
local SpecialSuper = require(game.ReplicatedStorage.CharacterData.Classes.Specials.Super)

--[Types]
local types = require(game.ReplicatedStorage.Functions.Types)

--[Animations]
local animations = game.ReplicatedStorage.CharacterData.Animations.CharacterAnimations.Guy
local universalAnimations = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations

local Guy = {}
Guy.__index = Guy

local generalAnimations : types.GeneralAnimations = {
	Idle = animations.General.Idle,
	Walk = animations.General.Walk,
	Sprint = animations.General.Sprint,
	Jump = universalAnimations.Other.Jump,
	Fall = universalAnimations.Other.Fall
}

local blockAnimations : types.BlockAnimations = {
	Startup = animations.M1.Block.Startup,
	Hold = animations.M1.Block.Hold
}

local dashAnimations : types.DashAnimations = {
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
	Name = 'The Dragon of Dojima',
	Animation = animations.Awakening,
	DestroysEnviroment = false
}

local RashRushdown : types.Special = {
	Name = 'Rash Rushdown',
	Animation = animations.Specials.Regular['1Special'],
	Cooldown = 12,
}

local DestroyerKick : types.Special = {
	Name = 'Destroyer Kick',
	Animation = animations.Specials.Regular['2Special'],
	Cooldown = 10,
}

local AsphaltCrunch : types.Special = {
	Name = 'Asphalt Crunch',
	Animation = animations.Specials.Regular[3],
	Cooldown = 10,
}

local BrawlersInstinct : types.Special = {
	Name = 'Brawler’s Instinct',
	Animation = animations.Specials.Regular[4],
	Cooldown = 10,
}

local WhiteTigerSpirit : types.Special = {
	Name = 'White Tiger Spirit',
	Animation = animations.Specials.Regular.RSpecial,
	Cooldown = 13,
}

local WayoftheYakuza : types.Special = {
	Name = 'Way of the Yakuza',
	Animation = animations.Specials.Awakened[1],
	Cooldown = 13,
}

local InvitationtoHell : types.Special = {
	Name = 'Invitation to Hell',
	Animation = animations.Specials.Awakened[2],
	Cooldown = 13,
}

local FriendshipBeatdown : types.Special = {
	Name = 'Friendship Beatdown',
	Animation = animations.Specials.Awakened[3],
	Cooldown = 13,
}

local YouAreAnEyesore : types.Special = {
	Name = 'You’re an eyesore',
	Animation = animations.Specials.Awakened[4],
	Cooldown = 13,
}

local regularSpecials = {
	RashRushdown,
	DestroyerKick,
	AsphaltCrunch,
	BrawlersInstinct,
	WhiteTigerSpirit
}

local awakenedSpecials = {
	Special1 = {
		SpecialSuper.new(WayoftheYakuza)
	},
	Special2 = {
		SpecialSuper.new(InvitationtoHell)
	},
	Special3 = {
		SpecialSuper.new(FriendshipBeatdown)
	},
	Special4 = {
		SpecialSuper.new(YouAreAnEyesore)
	},
}


Guy.new = function()
	return setmetatable({
		Super = Super.new('Guy', generalAnimations, dashAnimations, blockAnimations, m1Animations),
		Awakening = Awakened.new(awakening),
		Specials = {
			Regular = regularSpecials,
			Awakened = awakenedSpecials,
		}
	}, Guy)	
end

Guy.__toString = function()
	return Guy
end

return Guy