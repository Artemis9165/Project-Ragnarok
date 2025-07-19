--!strict

local userInputService = game:GetService('UserInputService')

local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

local sprintEvent = game.ReplicatedStorage.RemoteEvents.MovementEvents.SprintEvent
local dashEvent = game.ReplicatedStorage.RemoteEvents.MovementEvents.DashEvent

local getPlayerStateRemoteFunction = game.ReplicatedStorage.RemoteFunctions.PlayerGetStateFunction

local private = {}
local public = {}

private.dashValues = {
	canDash = true,
	canForwardDash = true,
	canBackDash = true,
	canSideDash = true,
}

private.sprintKey = Enum.KeyCode.W :: Enum.KeyCode
private.maxDelay = 0.25 :: number
private.sprintTick = 0 :: number

private.dashKey = Enum.KeyCode.Q :: Enum.KeyCode
private.dashCooldown = 1.5 :: number

private.getPlayerParts = function(player : Player) : (Model, Humanoid, BasePart, Camera)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	local camera = workspace.CurrentCamera
	return character, humanoid, humanoidRootPart, camera
end

private.initalizeAnimations = function(player : Player)
	local animationsFolder = game.ReplicatedStorage:FindFirstChild('CharacterData'):FindFirstChild('Animations') :: Folder
	local universalAnimationsFolder = animationsFolder:FindFirstChild('UniversalAnimations') :: Folder
	local dashesAnimationFolder = universalAnimationsFolder:FindFirstChild('Dashes') :: Folder
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterGeneralAnimationsFolder = selectedCharacterAnimationsFolder:FindFirstChild('General') :: Folder
	local selectedCharacterSprintAnimation = selectedCharacterGeneralAnimationsFolder:FindFirstChild('Sprint') :: Animation
	local selectedCharacterForwardDashAnimation = selectedCharacterGeneralAnimationsFolder:FindFirstChild('ForwardDash') :: Animation
	animationController.addMultipleAnimations(player, selectedCharacterSprintAnimation, selectedCharacterForwardDashAnimation)
	animationController.addAnimationsFromFolder(player, dashesAnimationFolder)
end

private.startSprint = function(player : Player, input : InputObject)
	if input.KeyCode ~= private.sprintKey or getPlayerStateRemoteFunction:InvokeServer('combat', 'blocking') then return end
	if tick() - private.sprintTick <= private.maxDelay then
		animationController.playAnimation(player, 'Sprint', true)
		sprintEvent:FireServer(true)
	else
		private.sprintTick = tick()
	end
end

private.endSprint = function(player : Player, input : InputObject)
	if input.KeyCode ~= private.sprintKey then return end
	animationController.stopAnimation(player, 'Sprint')
	sprintEvent:FireServer(false)
end

private.playerFaceAwayCamera = function(humanoidRootPart : BasePart, camera : Camera)
	if humanoidRootPart then
		local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
		local oppositeDirection = camLook
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + oppositeDirection)
	end
end

private.detectShiftLock = function(player : Player) : boolean
	return player.DevEnableMouseLock and userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

private.getDashDirection = function(player : Player, character : Model): Vector3
	if not character then return Vector3.zero end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not humanoidRootPart then return Vector3.zero end

	local moveVector = Vector3.zero

	if private.detectShiftLock(player) then
		local camCFrame = workspace.CurrentCamera.CFrame
		moveVector = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
	else
		moveVector = humanoidRootPart.CFrame:VectorToWorldSpace(Vector3.new(userInputService:IsKeyDown(Enum.KeyCode.D) and 1 or userInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
			0, 
			userInputService:IsKeyDown(Enum.KeyCode.S) and 1 or userInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0)).Unit
	end
	return moveVector.Magnitude > 0 and moveVector.Unit or Vector3.zero
end


private.triggerDash = function(player : Player, character : Model, humanoid : Humanoid, humanoidRootPart : BasePart, camera : Camera, dashType : string)
	local camLook = workspace.CurrentCamera.CFrame.LookVector
	local flatDir = Vector3.new(camLook.X, 0, camLook.Z).Unit
	private.playerFaceAwayCamera(humanoidRootPart, camera)
	private.dashValues.canDash = false
	local moveable = true
	if not private.detectShiftLock(player) then
		humanoid.AutoRotate = false
		moveable = false
	end
	animationController.playAnimation(player, dashType, false, Enum.AnimationPriority.Action2)
	local dashDirection = private.getDashDirection(player, character)
	local animationDuration = animationController.getAnimationDuration(player, dashType)
	if dashType == 'ForwardDash' then
		private.dashValues.canForwardDash = false
		dashEvent:FireServer(true, workspace.CurrentCamera.CFrame.LookVector, Vector3.new(0, 0, -1), animationDuration - 0.8, moveable, 'Forward')
		task.delay(animationDuration + 2, function()
			private.dashValues.canForwardDash = true
		end)
	end
	if dashType == 'Back' then
		dashEvent:FireServer(true, workspace.CurrentCamera.CFrame.LookVector, Vector3.new(0, 0, 1), animationDuration, moveable)
		private.dashValues.canBackDash = false
		task.delay(animationDuration + 3, function()
			private.dashValues.canBackDash = true
		end)
	end
	if dashType == 'Left' then
		dashEvent:FireServer(true, workspace.CurrentCamera.CFrame.LookVector, Vector3.new(-1, 0, 0), animationDuration, moveable)
		private.dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			private.dashValues.canSideDash = true
		end)
	end
	if dashType == 'Right' then
		dashEvent:FireServer(true, workspace.CurrentCamera.CFrame.LookVector, Vector3.new(1, 0, 0), animationDuration, moveable)
		private.dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			private.dashValues.canSideDash = true
		end)
	end

	animationController.stopped(player, dashType, function()
		dashEvent:FireServer(false)
		humanoid.AutoRotate = true
		private.dashValues.canDash = true
	end)
end


private.dash = function(player : Player, character : Model, humanoid : Humanoid, humanoidRootPart : BasePart, camera : Camera, input: InputObject)
	if input.KeyCode ~= private.dashKey or not private.dashValues.canDash then return end
	if userInputService:IsKeyDown(Enum.KeyCode.W) and private.dashValues.canForwardDash then
		private.triggerDash(player, character, humanoid, humanoidRootPart, camera, "ForwardDash")
	elseif userInputService:IsKeyDown(Enum.KeyCode.S) and private.dashValues.canBackDash then
		private.triggerDash(player, character, humanoid, humanoidRootPart, camera, "Back")
	elseif userInputService:IsKeyDown(Enum.KeyCode.A) and private.dashValues.canSideDash then
		private.triggerDash(player, character, humanoid, humanoidRootPart, camera, "Left")
	elseif userInputService:IsKeyDown(Enum.KeyCode.D) and private.dashValues.canSideDash then
		private.triggerDash(player, character, humanoid, humanoidRootPart, camera, "Right")
	elseif private.dashValues.canForwardDash and humanoid.MoveDirection.Magnitude == 0 then
		private.triggerDash(player, character, humanoid, humanoidRootPart, camera, "ForwardDash")
	end
end

private.setupCharacter = function(player : Player)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart, camera : Camera = private.getPlayerParts(player)
	userInputService.InputBegan:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.startSprint(player, input)
		private.dash(player, character, humanoid, humanoidRootPart, camera, input)
	end)
	userInputService.InputEnded:Connect(function(input : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.endSprint(player, input)
	end)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public
