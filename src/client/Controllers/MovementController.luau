--!strict
local userInputService = game:GetService('UserInputService')
local players = game:GetService('Players')
local runService = game:GetService('RunService')
local loadedAnimationsFunction = game.ReplicatedStorage.Events.LoadedAnimationsFunction
local getCharacterData = require(game.ReplicatedStorage.Functions.GetCharacterData)
local combatController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.CombatController)

local private = {}
local public = {}

local camera = workspace.CurrentCamera :: Camera
local player = players.LocalPlayer :: Player

local character: Model
local humanoid: Humanoid
local humanoidRootPart: BasePart
local animator: Animator
local characterData
local loadedAnimations = loadedAnimationsFunction:InvokeServer()

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

private.getCharacter = function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	animator = humanoid:WaitForChild("Animator") :: Animator
	characterData = getCharacterData(player)
end

private.createAnimationProfile = function()
	loadedAnimations['Sprint'] = animator:LoadAnimation(characterData.Super.Animations.General[1].Sprint)
	for _, animation: Animation in pairs(characterData.Super.Animations.General.Dashes :: {Animation}) do
		loadedAnimations[animation.Name] = animator:LoadAnimation(animation)
	end
end

private.getAnimationDuration = function(animationName: string)
	return loadedAnimations[animationName].length
end

private.playAnimation = function(animationName: string, looped: boolean, priority: Enum.AnimationPriority?)
	loadedAnimations[animationName].Looped = looped
	loadedAnimations[animationName].Priority = priority or Enum.AnimationPriority.Action
	loadedAnimations[animationName]:Play()
end

private.stopAnimation = function(animationName: string)
	local anim = loadedAnimations[animationName]
	if anim then anim:Stop() end
end

private.playerFaceAwayCamera = function()
	local camera = workspace.CurrentCamera
	if humanoidRootPart then
		local camLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
		local oppositeDirection = camLook
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + oppositeDirection)
	end
end

private.detectShiftLock = function()
	return player.DevEnableMouseLock and userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

private.startSprint = function(inputObject: InputObject, gameProcessedEvent: boolean)
	if inputObject.KeyCode == sprintKey then
		if tick() - sprintTick <= maxDelay then
			humanoid.WalkSpeed = 24
			private.playAnimation("Sprint", true)
		else
			sprintTick = tick()
		end
	end
end

private.endSprint = function(inputObject: InputObject, gameProcessedEvent: boolean)
	if inputObject.KeyCode == sprintKey then
		humanoid.WalkSpeed = 16
		private.stopAnimation("Sprint")
	end
end

private.disableJump = function(time)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	task.delay(time, function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end)
end

private.createLinearVelocity = function(localDirection: Vector3, speed: number, time: number, moveable: boolean)
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

private.triggerDash = function(type: string)
	private.playerFaceAwayCamera()
	dashValues.canDash = false
	local moveable = true
	if not private.detectShiftLock() then
		humanoid.AutoRotate = false
		moveable = false
	end
	private.playAnimation(type, false, Enum.AnimationPriority.Action2)
	local animationDuration = private.getAnimationDuration(type)
	private.disableJump(animationDuration)
	if type == 'ForwardDash' then
		dashValues.canForwardDash = false
		private.createLinearVelocity(Vector3.new(0, 0, -1), 50, animationDuration - 0.8, moveable)
		task.delay(animationDuration + 2, function()
			dashValues.canForwardDash = true
		end)
	end
	if type == 'Back' then
		private.createLinearVelocity(Vector3.new(0, 0, 1), 50,animationDuration, moveable)
		dashValues.canBackDash = false
		task.delay(animationDuration + 3, function()
			dashValues.canBackDash = true
		end)
	end
	if type == 'Left' then
		private.createLinearVelocity(Vector3.new(-1, 0, 0), 50, animationDuration, moveable)
		dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			dashValues.canSideDash = true
		end)
	end
	if type == 'Right' then
		private.createLinearVelocity(Vector3.new(1, 0, 0), 50, animationDuration, moveable)
		dashValues.canSideDash = false
		task.delay(animationDuration + 1, function()
			dashValues.canSideDash = true
		end)
	end
	task.delay(animationDuration, function()
		humanoid.AutoRotate = true
		dashValues.canDash = true
	end)
end

private.dash = function(inputObject: InputObject, gameProcessedEvent: boolean)
	if inputObject.KeyCode == dashKey and dashValues.canDash then
		if userInputService:IsKeyDown(Enum.KeyCode.W) and dashValues.canForwardDash then
			private.triggerDash("ForwardDash")
		elseif userInputService:IsKeyDown(Enum.KeyCode.S) and dashValues.canBackDash then
			private.triggerDash("Back")
		elseif userInputService:IsKeyDown(Enum.KeyCode.A) and dashValues.canSideDash then
			private.triggerDash("Left")
		elseif userInputService:IsKeyDown(Enum.KeyCode.D) and dashValues.canSideDash then
			private.triggerDash("Right")
		elseif dashValues.canForwardDash and humanoid.MoveDirection.Magnitude == 0 then
			private.triggerDash("ForwardDash")
		end
	end
end

public.onStart = function()
	private.getCharacter()
	player.CharacterAdded:Connect(function() private.getCharacter() end)
	private.createAnimationProfile()
	userInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		private.startSprint(inputObject, gameProcessedEvent)
		private.dash(inputObject, gameProcessedEvent)
	end)

	userInputService.InputEnded:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		private.endSprint(inputObject, gameProcessedEvent)
	end)
end

return public