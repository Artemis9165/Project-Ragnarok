--!strict

-- [Roblox Services]

-- [Services]

-- [Controllers]
local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

-- [Functions]

-- [Remote Events]
local hurtEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.HurtEvent
local specialHurtEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.SpecialHurtEvent

-- [Remote Functions]

local private = {}
local public = {}

private.m1Hurt = function(comboCount : number)
	local player = game.Players.LocalPlayer
	if comboCount ~= 4 then animationController.playAnimation(player, 'Hurt'..comboCount, false) end
end

private.regularSpecialHurt = function(count : number?)
	local player = game.Players.LocalPlayer
	if count then
		print(count)
		animationController.playAnimation(player, tostring('Hurt'..count), false)
	else
		animationController.playAnimation(player, tostring('Hurt1'), false)
	end
end

public.onStart = function() 
	hurtEvent.OnClientEvent:Connect(private.m1Hurt)
	specialHurtEvent.OnClientEvent:Connect(function(count : number?)
		private.regularSpecialHurt(count)
	end)
end

return public