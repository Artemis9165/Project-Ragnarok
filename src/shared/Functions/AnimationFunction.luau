--!strict

local private = {}
local public = {}

private.savedAnimations = {} :: {[Player] : {[string] : Animation }}
private.loadedAnimations = {} :: {[Player] : {[string] : AnimationTrack}}

private.getAnimator = function(player : Player) : Animator
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild('Humanoid') :: Humanoid
	local animator = humanoid:WaitForChild("Animator") :: Animator
	return animator
end

private.clearSavedAnimations = function(player : Player)
	private.savedAnimations[player] = {}
end

private.clearLoadedAnimations = function(player : Player)
	private.loadedAnimations[player] = {}
end

private.clearAnimations = function(player : Player)
	private.clearSavedAnimations(player)
	private.clearLoadedAnimations(player)
end

public.createAnimationProfile = function(player : Player)
	if not private.savedAnimations[player] then
		private.savedAnimations[player] = {}
		private.loadedAnimations[player] = {}
	end
end

public.addAnimation = function(player : Player, animation : Animation)
	local animator = private.getAnimator(player) :: Animator
	if not animation.AnimationId or animation.AnimationId == '' then return end
	private.savedAnimations[player][animation.Name] = animation
	private.loadedAnimations[player][animation.Name] = animator:LoadAnimation(animation)
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
	private.loadedAnimations[player][animationName].Looped = looped
	private.loadedAnimations[player][animationName].Priority = priority or Enum.AnimationPriority.Action
	private.loadedAnimations[player][animationName]:Play()
end

public.isAnimationPlaying = function(player : Player, animationName : string)
	return private.loadedAnimations[player][animationName].IsPlaying
end

public.reloadAnimations = function(player : Player)
	local animator = private.getAnimator(player)
	private.clearLoadedAnimations(player)
	for _, animation in private.savedAnimations[player] do
		private.loadedAnimations[player][animation.Name] = animator:LoadAnimation(animation)
	end
end

public.getAnimationDuration = function(player : Player, animationName: string)
	return private.loadedAnimations[player][animationName].Length
end

public.stopAnimation = function(player : Player, animationName : string)
	local anim = private.loadedAnimations[player][animationName]
	if anim then anim:Stop() end
end

public.stopped = function(player : Player, animationName : string, functionParameter : () -> ())
	private.loadedAnimations[player][animationName].Stopped:Connect(functionParameter)
end

public.ended = function(player : Player, animationName : string, functionParameter : () -> ())
	private.loadedAnimations[player][animationName].Ended:Connect(functionParameter)
end

return public