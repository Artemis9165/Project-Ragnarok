--!strict

local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.AnimationController)

local public = {}

public.onStart = function()
	local player = game.Players.LocalPlayer
	animationController.createAnimationProfile(player)
	local initialized = false
	player.CharacterAdded:Connect(function() if initialized then animationController.reloadAnimations(player) else initialized = true end end)
end

return public