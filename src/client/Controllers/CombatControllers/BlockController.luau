--!strict

-- [Roblox Services]
local userInputService = game:GetService('UserInputService')

-- [Services]

-- [Controllers]
local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

-- [Functions]
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

-- [Remote Events]
local blockEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.BlockEvent

-- [Remote Functions]
local blockCheckerFunction = game.ReplicatedStorage.RemoteFunctions.BlockChecker
local getPlayerStateRemoteFunction = game.ReplicatedStorage.RemoteFunctions.PlayerGetStateFunction

local private = {}
local public = {}

private.getCharacterParts = function(player : Player)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.initalizeAnimations = function(player : Player)
	local animationsFolder = game.ReplicatedStorage:FindFirstChild('CharacterData'):FindFirstChild('Animations') :: Folder
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterBlockAnimationsFolder = selectedCharacterAnimationsFolder:FindFirstChild('Block') :: Folder
	animationController.addAnimationsFromFolder(player, selectedCharacterBlockAnimationsFolder)
end

private.shouldNotBlock = function(player : Player, input : InputObject) return input.KeyCode ~= Enum.KeyCode.F or blockCheckerFunction:InvokeServer() end

private.disableSprint = function(player : Player, humanoid : Humanoid, walkspeed : number)
	humanoid.WalkSpeed = walkspeed
	animationController.stopAnimation(player, 'Sprint')
end

private.enableBlock = function(player : Player, humanoid : Humanoid, input : InputObject)
	if private.shouldNotBlock(player, input) then return end
	animationController.playAnimation(player, 'Startup', false)
	animationController.stopped(player, 'Startup', function() if userInputService:IsKeyDown(Enum.KeyCode.F) then animationController.playAnimation(player, 'Hold', true) end end)
	private.disableSprint(player, humanoid, 3)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	blockEvent:FireServer(true)
end

private.disableBlock = function(player : Player, humanoid : Humanoid, input : InputObject)
	if input.KeyCode ~= Enum.KeyCode.F then return end
	animationController.stopAnimation(player, 'Startup')
	animationController.stopAnimation(player, 'Hold')
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	blockEvent:FireServer(false)
	humanoid.WalkSpeed = 16
end

private.setupCharacter = function(player : Player)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacterParts(player)
	userInputService.InputBegan:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.enableBlock(player, humanoid, input)
	end)
	userInputService.InputEnded:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.disableBlock(player, humanoid, input)
	end)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacterParts(player)
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public