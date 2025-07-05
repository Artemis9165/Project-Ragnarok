--!strict

local private = {}
local public = {}

private.npcSavedAnimations = {} :: {[Model] : {[string] : Animation}}
private.npcLoadedAnimations = {} :: {[Model] : {[string] : AnimationTrack}}

public.createAnimationProfile = function(npc : Model)
	if not private.npcSavedAnimations[npc] then
		private.npcSavedAnimations[npc] = {}
		private.npcLoadedAnimations[npc] = {}
	end
end

public.clearSavedAnimations = function(npc : Model)
	private.npcSavedAnimations[npc] = nil
end

public.clearLoadedAnimations = function(npc : Model)
	private.npcLoadedAnimations[npc] = nil
end

public.clearAnimations = function(npc : Model)
	public.clearSavedAnimations(npc)
	public.clearLoadedAnimations(npc)
end

public.getAnimatorFromCharacter = function(npc : Model) : Animator
	local humanoid = npc:WaitForChild('Humanoid') :: Humanoid
	local animator = humanoid:WaitForChild("Animator") :: Animator
	return animator
end

public.reloadAnimations = function(npc : Model)
	local animator = public.getAnimatorFromCharacter(npc)
	public.clearLoadedAnimations(npc)
	for _, animation in private.npcSavedAnimations[npc] do
		private.npcLoadedAnimations[npc][animation.Name] = animator:LoadAnimation(animation)
	end
end

public.addAnimation = function(npc : Model, animation : Animation)
	local animator = public.getAnimatorFromCharacter(npc) :: Animator
	if not animation.AnimationId or animation.AnimationId == '' then return end
	private.npcSavedAnimations[npc][animation.Name] = animation
	private.npcLoadedAnimations[npc][animation.Name] = animator:LoadAnimation(animation)
end

public.addAnimationsFromFolder = function(npc : Model, folder : Folder)
	for _, instance in ipairs(folder:GetDescendants()) do
		if instance:IsA('Animation') then
			local animation : Animation = instance
			public.addAnimation(npc, animation)
		end
	end
end

public.playAnimation = function(npc : Model, animationName : string, looped : boolean, priority : Enum.AnimationPriority?)
	private.npcLoadedAnimations[npc][animationName].Looped = looped
	private.npcLoadedAnimations[npc][animationName].Priority = priority or Enum.AnimationPriority.Action
	private.npcLoadedAnimations[npc][animationName]:Play()
end

return public
