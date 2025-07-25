--!strict

local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

private.special1 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.special2 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.special3 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

private.special4 = {
	name = '',
	keybind = '',
	cooldown = 0
} :: types.special

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


public.getSpecialData = function(specialName : types.specialName) : types.specialType return private[specialName] end

return public
