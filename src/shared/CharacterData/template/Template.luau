--!strict
local animations = script.Parent.Animations;
local Template = {
	
}

Template.generalAnimations = {
	idleId = animations.General.Idle.AnimationId,
	walkId = animations.General.Walk.AnimationId,
	runId = animations.General.Run.AnimationId,
	blockId = animations.General.Block.AnimationId,
}

Template.M1 = {
	one = {
		id = animations.M1s.M1.AnimationId,
		type = {},
		damage = 0;
	}
}

return Template
