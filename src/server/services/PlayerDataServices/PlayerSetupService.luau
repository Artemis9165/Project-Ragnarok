--!strict

local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local types = require(game.ReplicatedStorage.Functions.Types)

local cloneCharacterSpecialsScriptEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.CloneCharacterSpecialsScriptEvent

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

	local universalAnimationFolder = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations :: Folder
	local otherUniversalAnimationsFolder = universalAnimationFolder:FindFirstChild('Other') :: Folder
	local universalJumpAnimation = otherUniversalAnimationsFolder:FindFirstChild('Jump') :: Animation
	local universalFallAnimation = otherUniversalAnimationsFolder:FindFirstChild('Fall') :: Animation
	
	local selectedCharacterName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local selectedCharacterAnimationFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterGeneralAnimationFolder = selectedCharacterAnimationFolder:FindFirstChild('General') :: Folder
	local selectedCharacterWalkAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Walk') :: Animation
	local selectedCharacterIdleAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Idle') :: Animation

	walkAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	runAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	jumpAnimation.AnimationId = universalJumpAnimation.AnimationId
	fallAnimation.AnimationId = universalFallAnimation.AnimationId
	idleAnimation.AnimationId = selectedCharacterIdleAnimation.AnimationId
	idle2Animation.AnimationId = selectedCharacterIdleAnimation.AnimationId
end

private.cloneSelectedCharacterSpecialsScript = function(player : Player)
	local scriptName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: types.characterName
	cloneCharacterSpecialsScriptEvent:FireClient(player, scriptName)
end

private.setupCharacter = function(player : Player)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild('Humanoid') :: Humanoid
	humanoid.Health = 100
	humanoid.WalkSpeed = 16
	humanoid.JumpHeight = 7.2
	private.updatePlayerAnimations(player)
end

private.startPlayer = function(player : Player)
	playerStateService.createState(player)
	private.cloneSelectedCharacterSpecialsScript(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

private.removePlayer = function(player : Player) playerStateService.clearState(player) end

public.onStart = function()
	game.Players.PlayerAdded:Connect(private.startPlayer)
	game.Players.PlayerRemoving:Connect(private.removePlayer)
end

return public