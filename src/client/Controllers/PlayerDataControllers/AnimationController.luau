--!strict

local private = {}
local public = {}

private.playerSavedAnimations = {} :: {[Player] : {[string] : Animation }}
private.playerLoadedAnimations = {} :: {[Player] : {[string] : AnimationTrack}}

private.markerConnections = {} :: {[string] : RBXScriptConnection}

private.getAnimatorFromPlayer = function(player : Player) : Animator
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild('Humanoid') :: Humanoid
	local animator = humanoid:WaitForChild("Animator") :: Animator
	return animator
end

private.clearSavedAnimations = function(player : Player)
	private.playerSavedAnimations[player] = {}
end

private.clearLoadedAnimations = function(player : Player)
	private.playerLoadedAnimations[player] = {}
end

private.clearAnimations = function(player : Player)
	private.clearSavedAnimations(player)
	private.clearLoadedAnimations(player)
end

public.createAnimationProfile = function(player : Player)
	if not private.playerSavedAnimations[player] then
		private.playerSavedAnimations[player] = {}
		private.playerLoadedAnimations[player] = {}
	end
end

public.removeAnimations = function(player : Player)
	private.playerSavedAnimations[player] = nil
	private.playerLoadedAnimations[player] = nil
end

public.addAnimation = function(player : Player, animation : Animation)
	while not private.playerSavedAnimations[player] or not private.playerLoadedAnimations[player] do task.wait() end
	local animator = private.getAnimatorFromPlayer(player) :: Animator
	if not animation.AnimationId or animation.AnimationId == '' then return end
	private.playerSavedAnimations[player][animation.Name] = animation
	private.playerLoadedAnimations[player][animation.Name] = animator:LoadAnimation(animation)
end

public.addMultipleAnimations = function(player : Player, ... : Animation)
	local animations = {...} :: {Animation}
	for _, animation in ipairs(animations) do
		public.addAnimation(player, animation)
	end
end

public.addAnimationsFromFolder = function(player : Player, folder : Folder)
	for _, instance in ipairs(folder:GetDescendants()) do
		if instance:IsA('Animation') then
			local animation : Animation = instance
			public.addAnimation(player, animation)
		end
	end
end

public.addAnimationsFromMultipleFolders = function(player : Player, ... : Folder)
	local folders = {...} :: {Folder}
	for _, folder in ipairs(folders) do
		public.addAnimationsFromFolder(player, folder)
	end
end

public.playAnimation = function(player : Player, animationName : string, looped : boolean, priority : Enum.AnimationPriority?)
	private.playerLoadedAnimations[player][animationName].Looped = looped
	private.playerLoadedAnimations[player][animationName].Priority = priority or Enum.AnimationPriority.Action
	private.playerLoadedAnimations[player][animationName]:Play()
end

public.isAnimationPlaying = function(player : Player, animationName : string)
	return private.playerLoadedAnimations[player][animationName].IsPlaying
end

public.reloadAnimations = function(player : Player)
	local animator = private.getAnimatorFromPlayer(player)
	private.clearLoadedAnimations(player)
	for _, animation in private.playerSavedAnimations[player] do
		private.playerLoadedAnimations[player][animation.Name] = animator:LoadAnimation(animation)
	end
end

public.getAnimationDuration = function(player : Player, animationName: string)
	return private.playerLoadedAnimations[player][animationName].Length
end

public.stopAnimation = function(player : Player, animationName : string)
	local anim = private.playerLoadedAnimations[player][animationName]
	if anim then anim:Stop() end
end

public.markerReached = function(player: Player, animationName: string, markerName: string, callback: () -> ())
	local key = player.UserId .. animationName .. markerName

	if private.markerConnections[key] then private.markerConnections[key]:Disconnect() end

	private.markerConnections[key] = private.playerLoadedAnimations[player][animationName]:GetMarkerReachedSignal(markerName):Connect(callback)
end


public.stopped = function(player : Player, animationName : string, functionParameter : () -> ())
	private.playerLoadedAnimations[player][animationName].Stopped:Connect(functionParameter)
end

public.ended = function(player : Player, animationName : string, functionParameter : () -> ())
	private.playerLoadedAnimations[player][animationName].Ended:Connect(functionParameter)
end

public.onStart = function()
	
end

return public