--!strict
local loadedAnimationsFunction = game.ReplicatedStorage.Events.LoadedAnimationsFunction
local private = {}
local public = {}
local loadedAnimations = {}

public.getLoadedAnimations = function(player)
	if not loadedAnimations[player] then
		loadedAnimations[player] = {}
	end
	return loadedAnimations[player]
end

public.removeState = function(player)
	loadedAnimations[player] = nil
end

public.onStart = function(player)
	loadedAnimationsFunction.OnServerInvoke = function(player : Player, otherPlayer : Player?) : {AnimationTrack}
		if otherPlayer then return public.getLoadedAnimations(otherPlayer) end 
		return public.getLoadedAnimations(player) 
	end
end

return public