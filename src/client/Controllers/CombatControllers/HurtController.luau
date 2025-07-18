--!strict

-- [Roblox Services]

-- [Services]

-- [Controllers]
local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

-- [Functions]

-- [Remote Events]
local hurtEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.HurtEvent

-- [Remote Functions]

local private = {}
local public = {}

public.hurt = function(fromPlayer : Player, comboCount : number)
	local player = game.Players.LocalPlayer
	if comboCount ~= 4 then animationController.playAnimation(player, 'Hurt'..comboCount, false) end
end

public.onStart = function() hurtEvent.OnClientEvent:Connect(public.hurt) end

return public