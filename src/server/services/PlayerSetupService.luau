--!strict

local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local types = require(game.ReplicatedStorage.Functions.Types)

local private = {}
local public = {}

private.updatePlayerAnimations = function(player : Player)
	local character = player.Character :: Model
	local animateScript = character:WaitForChild('Animate')
	local walkAnimation = animateScript:FindFirstChild('walk'):FindFirstChild('WalkAnim') :: Animation
	local runAnimation = animateScript:FindFirstChild('run'):FindFirstChild('RunAnim') :: Animation
	local jumpAnimation = animateScript:FindFirstChild('jump'):FindFirstChild('JumpAnim') :: Animation
	local fallAnimation = animateScript:FindFirstChild('fall'):FindFirstChild('FallAnim') :: Animation
	local idleAnimation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation1') :: Animation
	local idle2Animation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation2') :: Animation

	local selectedCharacterName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local selectedCharacterAnimationFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterGeneralAnimationFolder = selectedCharacterAnimationFolder:FindFirstChild('General') :: Folder
	local selectedCharacterWalkAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Walk') :: Animation
	local selectedCharacterIdleAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Idle') :: Animation

	walkAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	runAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	jumpAnimation.AnimationId = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.Other.Jump.AnimationId
	fallAnimation.AnimationId = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.Other.Fall.AnimationId
	idleAnimation.AnimationId = selectedCharacterIdleAnimation.AnimationId
	idle2Animation.AnimationId = selectedCharacterIdleAnimation.AnimationId
end

private.startPlayer = function(player : Player, characterName : types.characterName)
	player.CharacterAdded:Connect(function()
		local character = player.Character or player.CharacterAdded:Wait() :: Model
		local humanoid = character:WaitForChild('Humanoid') :: Humanoid
		humanoid.Health = 100
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		private.updatePlayerAnimations(player)
	end)
end

public.onStart = function()
	game.Players.PlayerAdded:Connect(private.startPlayer)
end

return public