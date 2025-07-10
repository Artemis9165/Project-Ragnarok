--!strict

local animationFunction = require(game.ReplicatedStorage.Functions.AnimationFunction)
local hurtEvent = game.ReplicatedStorage.RemoteEvents.HurtEvent
local knockbackEvent = game.ReplicatedStorage.RemoteEvents.KnockbackEvent
local ragdollEvent = game.ReplicatedStorage.RemoteEvents.RagdollEvent

local private = {}
local public = {}

private.getHumanoidRootPart = function(player : Player) : BasePart
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	return humanoidRootPart
end

public.hurt = function(fromPlayer : Player, comboCount : number)
	local player = game.Players.LocalPlayer
	if comboCount ~= 4 then
		animationFunction.playAnimation(player, 'Hurt'..comboCount, false)
	else
		local character = player.Character or player.CharacterAdded:Wait() :: Model
		local fromPlayerHumanoidRootPart : BasePart = private.getHumanoidRootPart(fromPlayer)
		knockbackEvent:FireServer(character, false, fromPlayerHumanoidRootPart.CFrame.LookVector, 5)
		ragdollEvent:FireServer(character, 2)
	end
end

public.onStart = function()
	hurtEvent.OnClientEvent:Connect(public.hurt)
end

return public