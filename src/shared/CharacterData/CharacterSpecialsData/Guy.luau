--!strict

local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

private.special1General = {
	name = 'Rash Rushdown',
	keybind = '1',
	cooldown = 12
} :: types.special

private.special2General = {
	name = 'Destroyer Kick',
	keybind = '2',
	cooldown = 10
} :: types.special

private.special3General = {
	general = {
		name = 'Asphalt Crunch',
		keybind = '3',
		cooldown = 16
	},
	damage = 18
} :: types.damagingSpecial

private.special4General = {
	general = {
		name = 'Brawler’s Instinct',
		keybind = '4',
		cooldown = 20
	},
	damage = 14
} :: types.damagingSpecial

private.specialRGeneral = {
	name = 'White Tiger Spirit',
	keybind = 'R',
	cooldown = 20
} :: types.special

private.special1 = {
	general = private.special1General,
	damage = 2,
} :: types.damagingSpecial

private.special2 = {
	general = private.special2General,
	damage = 20,
	blockPercentage = 75
} :: types.damagingSpecial

private.special3 = {
	general = private.special3General,
	grabType = 'Hard Command Grab'
} :: types.grabSpecial

private.special4 = {
	general = private.special4General,
	counterType = 'm1'
} :: types.counterSpecial

private.specialR = {
	general = private.specialRGeneral,
	duration = 15,
	percentIncrease = 8.75
} :: types.universalDamagePromotion

private.awakenedSpecial1 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.awakenedSpecial2 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.awakenedSpecial3 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.awakenedSpecial4 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

public.specialDataR = {
	general = {
		awakenedSpecial1 = private.awakenedSpecial1,
		awakenedSpecial2 = private.awakenedSpecial2,
		awakenedSpecial3 = private.awakenedSpecial3,
		awakenedSpecial4 = private.awakenedSpecial4,
		special1 = private.special1,
		special2 = private.special2,
		special3 = private.special3,
		special4 = private.special4,
	},
	specialR = private.specialR
} :: types.specialDataR

return public.specialDataR
