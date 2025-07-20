--!strict

local userInputService = game:GetService('UserInputService')

local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

local m1Event = game.ReplicatedStorage.RemoteEvents.CombatEvents.M1Event
local playerSetStateEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.PlayerSetStateEvent

local getPlayerStateRemoteFunction = game.ReplicatedStorage.RemoteFunctions.PlayerGetStateFunction
local m1CheckerFunction = game.ReplicatedStorage.RemoteFunctions.M1Checker

local private = {}
local public = {}

private.getCharacterParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.initalizeAnimations = function(player : Player)
	local animationsFolder = game.ReplicatedStorage:FindFirstChild('CharacterData'):FindFirstChild('Animations') :: Folder
	local universalAnimationsFolder = animationsFolder:FindFirstChild('UniversalAnimations') :: Folder
	local m1HurtsFolder = universalAnimationsFolder:FindFirstChild('M1Hurts') :: Folder
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterM1AnimationsFolder = selectedCharacterAnimationsFolder:FindFirstChild('M1') :: Folder
	animationController.addAnimationsFromMultipleFolders(player, selectedCharacterM1AnimationsFolder, m1HurtsFolder)
end

private.shouldNotM1 = function(player : Player, input : InputObject) : boolean return input.UserInputType ~= Enum.UserInputType.MouseButton1 or m1CheckerFunction:InvokeServer() end

private.disableSprint = function(player : Player, humanoid : Humanoid, walkspeed : number)
	humanoid.WalkSpeed = walkspeed
	animationController.stopAnimation(player, 'Sprint')
end

private.getComboAnimationName = function(player : Player, humanoid : Humanoid) : string
	local comboCount = getPlayerStateRemoteFunction:InvokeServer('combat', 'comboCount')
	if humanoid:GetState() == Enum.HumanoidStateType.Freefall and comboCount == 4 then return "Slam" end
	if userInputService:IsKeyDown(Enum.KeyCode.Space) and comboCount == 4 then return "Uppercut" end
	return tostring(comboCount)
end

private.handlePostAnimation = function(player : Player, humanoid : Humanoid) 
	animationController.stopped(player, '3', function() task.delay(0.25, function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end) end) 
end

private.m1 = function(player : Player, humanoid : Humanoid, input : InputObject)
	if private.shouldNotM1(player, input) then return end
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	local animationName = private.getComboAnimationName(player, humanoid)
	animationController.playAnimation(player, animationName, false)
	private.disableSprint(player, humanoid, 16)
	m1Event:FireServer(animationController.getAnimationDuration(player, animationName))
	private.handlePostAnimation(player, humanoid)
end

private.enableSpaceState = function(player : Player, input : InputObject, value : boolean) if input.KeyCode == Enum.KeyCode.Space then playerSetStateEvent:FireServer('misc', 'isSpaceDown', value) end end

private.setupCharacter = function(player : Player)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacterParts(player)
	userInputService.InputBegan:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.m1(player, humanoid, input)
		private.enableSpaceState(player, input, true)
	end)
	userInputService.InputEnded:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.enableSpaceState(player, input, false)
	end)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public
