--!strict

local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

local changeHumanoidStateEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.ChangeHumanoidStateEvent

local private = {}
local public = {}

private.getCharacterParts = function(player : Player)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

public.changeHumanoidJumpState = function(player : Player, value : boolean)
	local player = game.Players.LocalPlayer
	local _, humanoid : Humanoid = private.getCharacterParts(player)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, value)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	animationController.createAnimationProfile(player)
	local initialized = false
	player.CharacterAdded:Connect(function() if initialized then animationController.reloadAnimations(player) else initialized = true end end)
	changeHumanoidStateEvent.OnClientEvent:Connect(function(value : boolean) public.changeHumanoidJumpState(player, value) end)
end

return public