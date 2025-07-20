--!strict

-- [Roblox Services]
local userInputService = game:GetService('UserInputService')

-- [Controllers]
local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)

-- [Functions]
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

-- [Remote Events]
local specialsEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.SpecialsEvent

-- [Remote Functions]
local specialCheckerFunction = game.ReplicatedStorage.RemoteFunctions.SpecialChecker

local private = {}
local public = {}

private.getCharacterParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.disableSprint = function(player : Player, humanoid : Humanoid, walkspeed : number)
	humanoid.WalkSpeed = walkspeed
	animationController.stopAnimation(player, 'Sprint')
end

private.initalizeAnimations = function(player : Player)
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterAwakeningOrUltimateFolder = selectedCharacterAnimationsFolder:FindFirstChild('Awakening') :: Folder or selectedCharacterAnimationsFolder:FindFirstChild('Ultimate') :: Folder
	local selectedCharacterSpecialsAnimationFolder = selectedCharacterAnimationsFolder:FindFirstChild('Specials') :: Folder
	animationController.addAnimationsFromMultipleFolders(player, selectedCharacterSpecialsAnimationFolder, selectedCharacterAwakeningOrUltimateFolder)
end

private.special1 = function(player : Player, humanoid : Humanoid, input : InputObject)
	if input.KeyCode ~= Enum.KeyCode.One or specialCheckerFunction:InvokeServer(Enum.KeyCode.One) then return end
	specialsEvent:FireServer(Enum.KeyCode.One)
	private.disableSprint(player, humanoid, 16)
	animationController.playAnimation(player, 'Special1', false)
end

private.setupCharacter = function(player : Player)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacterParts(player)
	userInputService.InputBegan:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.special1(player, humanoid, input)
	end)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public