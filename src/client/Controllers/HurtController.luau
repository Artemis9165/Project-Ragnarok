--!strict
local private = {}
local public = {}

--public.hurt = function(otherCharacter : Model)
--	local hurtAnimationTrack = otherAnimator:LoadAnimation(filePath)
--	hurtAnimationTrack.Looped = false
--	hurtAnimationTrack:Play()
--	hurtAnimationTrack:AdjustSpeed(0.8)
--	otherHumanoid.PlatformStand = true
--	otherHumanoid:TakeDamage(m1.damage)
--	task.delay(hurtAnimationTrack.Length + m1.m1StunDelay, function()
--		otherHumanoid.PlatformStand = false
--	end)
--end

public.onStart = function()
	
end

return public