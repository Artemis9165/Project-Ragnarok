--!strict
local userInputService = game:GetService('UserInputService')
local players = game:GetService('Players')
local runService = game:GetService('RunService')

local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local playerStateFunction = require(game.ReplicatedStorage.Functions.PlayerStateFunction)
local animationFunction = require(game.ReplicatedStorage.Functions.AnimationFunction)

local private = {}
local public = {}

local sprintKey = Enum.KeyCode.W :: Enum.KeyCode
local maxDelay = 0.25 :: number
local sprintTick = 0 :: number

local dashKey = Enum.KeyCode.Q :: Enum.KeyCode
local dashCooldown = 1.5 :: number

local dashValues = {
	canDash = true,
	canForwardDash = true,
	canBackDash = true,
	canSideDash = true,
}

private.getCharacter = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
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

private.startSprint = function( player : Player, humanoid : Humanoid, inputObject: InputObject)
	if inputObject.KeyCode == sprintKey then
		if tick() - sprintTick <= maxDelay then
			humanoid.WalkSpeed = 24
			animationFunction.playAnimation(player, "Sprint", true)
			playerStateFunction.setState(player, 'misc', 'sprinting', true)
		else
			sprintTick = tick()
		end
	end
end

private.endSprint = function(player : Player, humanoid : Humanoid, inputObject: InputObject)
	if inputObject.KeyCode == sprintKey then
		humanoid.WalkSpeed = 16
		animationFunction.stopAnimation(player, "Sprint")
		playerStateFunction.setState(player, 'misc', 'sprinting', false)
	end
end

private.disableJump = function(humanoid : Humanoid, time : number)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	task.delay(time, function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end)
end

private.createLinearVelocity = function(humanoidRootPart : BasePart, camera : Camera, localDirection: Vector3, speed: number, time: number, moveable: boolean)
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.WorldPosition = humanoidRootPart.AssemblyCenterOfMass
	attachment.WorldCFrame = humanoidRootPart.CFrame
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.MaxForce = math.huge
	linearVelocity.Parent = attachment
	if moveable then
		local alive = true
		local connection = runService.Heartbeat:Connect(function()
			if not alive then return end
			local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
			local baseDirectionCFrame = CFrame.new(Vector3.zero, camLook)
			local worldDirection = baseDirectionCFrame:VectorToWorldSpace(localDirection).Unit
			linearVelocity.PlaneVelocity = Vector2.new(worldDirection.X, worldDirection.Z) * speed
		end)
		task.delay(time, function()
			alive = false
			if connection then connection:Disconnect() end
		end)
	else
		local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
		local baseDirectionCFrame = CFrame.new(Vector3.zero, camLook)
		local worldDirection = baseDirectionCFrame:VectorToWorldSpace(localDirection).Unit
		linearVelocity.PlaneVelocity = Vector2.new(worldDirection.X, worldDirection.Z) * speed
	end
	task.delay(time, function()
		linearVelocity:Destroy()
		attachment:Destroy()
	end)
end

private.triggerDash = function(player : Player, humanoid : Humanoid, humanoidRootPart : BasePart, camera : Camera, dashType : string)
	private.playerFaceAwayCamera(humanoidRootPart, camera)
	playerStateFunction.setState(player, 'misc', "dashing", true)
	dashValues.canDash = false
	local moveable = true
	if not private.detectShiftLock(player) then
		humanoid.AutoRotate = false
		moveable = false
	end
	animationFunction.playAnimation(player, dashType, false, Enum.AnimationPriority.Action2)
	local animationDuration = animationFunction.getAnimationDuration(player, dashType)
	private.disableJump(humanoid, animationDuration)
	if dashType == 'ForwardDash' then
		dashValues.canForwardDash = false
		private.createLinearVelocity(humanoidRootPart, camera, Vector3.new(0, 0, -1), 50, animationDuration - 0.8, moveable)
		task.delay(animationDuration + 2, function()
			dashValues.canForwardDash = true
		end)
	end
	if dashType == 'Back' then
		private.createLinearVelocity(humanoidRootPart, camera, Vector3.new(0, 0, 1), 50, animationDuration, moveable)
		dashValues.canBackDash = false
		task.delay(animationDuration + 3, function()
			dashValues.canBackDash = true
		end)
	end
	if dashType == 'Left' then
		private.createLinearVelocity(humanoidRootPart, camera, Vector3.new(-1, 0, 0), 50, animationDuration, moveable)
		dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			dashValues.canSideDash = true
		end)
	end
	if dashType == 'Right' then
		private.createLinearVelocity(humanoidRootPart, camera, Vector3.new(1, 0, 0), 50, animationDuration, moveable)
		dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			dashValues.canSideDash = true
		end)
	end
	
	animationFunction.stopped(player, dashType, function()
		playerStateFunction.setState(player, 'misc', 'dashing', false)
	end)
	
	task.delay(animationDuration, function()
		humanoid.AutoRotate = true
		dashValues.canDash = true
	end)
end

private.dash = function(player : Player, humanoid : Humanoid, humanoidRootPart : BasePart, camera : Camera, inputObject: InputObject)
	if inputObject.KeyCode == dashKey and dashValues.canDash then
		if userInputService:IsKeyDown(Enum.KeyCode.W) and dashValues.canForwardDash then
			private.triggerDash(player, humanoid, humanoidRootPart, camera, "ForwardDash")
		elseif userInputService:IsKeyDown(Enum.KeyCode.S) and dashValues.canBackDash then
			private.triggerDash(player, humanoid, humanoidRootPart, camera, "Back")
		elseif userInputService:IsKeyDown(Enum.KeyCode.A) and dashValues.canSideDash then
			private.triggerDash(player, humanoid, humanoidRootPart, camera, "Left")
		elseif userInputService:IsKeyDown(Enum.KeyCode.D) and dashValues.canSideDash then
			private.triggerDash(player, humanoid, humanoidRootPart, camera, "Right")
		elseif dashValues.canForwardDash and humanoid.MoveDirection.Magnitude == 0 then
			private.triggerDash(player, humanoid, humanoidRootPart, camera, "ForwardDash")
		end
	end
end

private.initalizeAnimations = function(player : Player)
	local animationsFolder = game.ReplicatedStorage:FindFirstChild('CharacterData'):FindFirstChild('Animations') :: Folder
	local universalAnimationsFolder = animationsFolder:FindFirstChild('UniversalAnimations') :: Folder
	local dashesAnimationFolder = universalAnimationsFolder:FindFirstChild('Dashes') :: Folder
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterGeneralAnimationsFolder = selectedCharacterAnimationsFolder:FindFirstChild('General') :: Folder
	local selectedCharacterSprintAnimation = selectedCharacterGeneralAnimationsFolder:FindFirstChild('Sprint') :: Animation
	local selectedCharacterForwardDashAnimation = selectedCharacterGeneralAnimationsFolder:FindFirstChild('ForwardDash') :: Animation
	animationFunction.addMultipleAnimations(player, selectedCharacterSprintAnimation, selectedCharacterForwardDashAnimation)
	animationFunction.addAnimationsFromFolder(player, dashesAnimationFolder)
end

private.setupCharacter = function(player : Player)
	local camera = workspace.CurrentCamera :: Camera
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacter(player)
	userInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		private.startSprint(player, humanoid, inputObject)
		private.dash(player, humanoid, humanoidRootPart, camera, inputObject)
	end)

	userInputService.InputEnded:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		private.endSprint(player, humanoid, inputObject)
	end)
end

public.onStart = function()
	local player = players.LocalPlayer :: Player
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public