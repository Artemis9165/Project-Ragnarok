--!strict

local types = require(game.ReplicatedStorage.Functions.Types)
local playerGetStateFunction = game.ReplicatedStorage.RemoteFunctions.PlayerGetStateFunction

local private = {}
local public = {}

private.states = {} :: {[Player] : types.PlayerState}

public.createState = function(player : Player)
	private.states[player] = {
		combat = {
			blocking = false,
			comboCount = 1,
			jumping = false,
			attacking = false,
			hurting = false,
			comboCooldown = false,
			attackDebounce = false,
			lastComboTime = 0
		},
		misc = {
			sprinting = false,
			dashing = false,
			isSpaceDown = false
		}
	}
end

public.clearState = function(player : Player) private.states[player] = nil end

public.getState = function(player: Player, stateType : types.stateType?, state : types.stateName?)
	if stateType and state then return private.states[player][stateType][state] end
	if stateType then return private.states[player][stateType] end
	return private.states[player]
end

public.setState = function(player: Player, stateType : types.stateType, state: types.stateName, value: boolean | number)
	private.states[player][stateType][state] = value
end

public.onStart = function()
	playerGetStateFunction.OnServerInvoke = function(player : Player, stateType : types.stateType?, state : types.stateName?) return public.getState(player, stateType, state) end
end

return public
