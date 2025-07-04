--!strict

local animationFunction = require(game.ReplicatedStorage.Functions.AnimationFunction)
local playerStateFunction = require(game.ReplicatedStorage.Functions.PlayerStateFunction)

local public = {}

public.onStart = function()
	local player = game.Players.LocalPlayer
	animationFunction.createAnimationProfile(player)
	playerStateFunction.createState(player)
	local initialized = false
	player.CharacterAdded:Connect(function() if initialized then animationFunction.reloadAnimations(player) else initialized = true end end)
end

return public
