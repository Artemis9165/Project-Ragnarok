local playerCombatStateFunction = game.ReplicatedStorage.Events.PlayerCombatStateFunction
local states = {}

local public = {}

public.getState = function(player)
	if not states[player] then
		states[player] = {
			isBlocking = false,
			comboCount = 1,
			isJumping = false,
			isAttacking = false,
			lastComboTime = 0,
			isCountering = false,
		}
	end
	return states[player]
end

public.removeState = function(player)
	states[player] = nil
end

public.onStart = function()
	playerCombatStateFunction.OnServerInvoke = function(player : Player, type : string, otherPlayer : Player?)
		if type == 'get' then
			if otherPlayer then
				return public.getState(otherPlayer)
			end
			return public.getState(player)
		end
		if type == 'remove' then
			public.removeState(player)
		end
	end
end

return public
