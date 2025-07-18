--!strict

local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)
local cameraEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.CameraEvent
local movementEventFolder = game.ReplicatedStorage.RemoteEvents.MovementEvents
local sprintEvent = movementEventFolder.SprintEvent
local dashEvent = movementEventFolder.DashEvent

local private = {}
local public = {}

private.walkSpeed = 16
private.sprintSpeed = 24
private.dashSpeed = 50

private.getPlayerParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	return character, humanoid, humanoidRootPart
end

private.setWalkSpeed = function(player : Player, speed : number)
	local _, humanoid : Humanoid = private.getPlayerParts(player)
	humanoid.WalkSpeed = speed
end

private.disableJump = function(player : Player, humanoid : Humanoid, humanoidRootPart : BasePart, duration : number)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	task.delay(duration, function()
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end)
end

private.sprint = function(player : Player, enable : boolean)
	if enable then
		playerStateService.setState(player, 'misc', 'sprinting', true)
		private.setWalkSpeed(player, private.sprintSpeed)
	else
		playerStateService.setState(player, 'misc', 'sprinting', false)
		private.setWalkSpeed(player, private.walkSpeed)
	end
end

private.applyVelocity = function(lookVector : Vector3, localDirection : Vector3, linearVelocity : LinearVelocity, speed : number)
	local camLook = Vector3.new(lookVector.X, 0, lookVector.Z)
	local baseDirectionCFrame = CFrame.new(Vector3.zero, camLook)
	local worldDirection = baseDirectionCFrame:VectorToWorldSpace(localDirection).Unit
	linearVelocity.PlaneVelocity = Vector2.new(worldDirection.X, worldDirection.Z) * speed
end

private.createLinearVelocity = function(player : Player, humanoidRootPart : BasePart, lookVector : Vector3, localDirection : Vector3, speed : number, time : number, moveable : boolean)
	local attachment : Attachment = Instance.new("Attachment")
	attachment.Name = "VelocityAttachment"
	attachment.CFrame = CFrame.identity
	attachment.Parent = humanoidRootPart

	local linearVelocity : LinearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.MaxForce = math.huge
	linearVelocity.Parent = attachment
	cameraEvent.OnServerEvent:Connect(function(player : Player, playerLookVector : Vector3) lookVector = playerLookVector end)
	if moveable then
		local alive = true
		local connection = game:GetService("RunService").Heartbeat:Connect(function()
			if not alive then return end
			cameraEvent:FireClient(player)
			private.applyVelocity(lookVector, localDirection, linearVelocity, speed)
		end)
		task.delay(time, function()
			alive = false
			if connection then connection:Disconnect() end
			linearVelocity:Destroy()
			attachment:Destroy()
		end)
	else
		private.applyVelocity(lookVector, localDirection, linearVelocity, speed)
		task.delay(time, function()
			linearVelocity:Destroy()
			attachment:Destroy()
		end)
	end
end

private.dash = function(player : Player, start : boolean, lookVector : Vector3?, localDirection : Vector3?, duration : number?, moveable : boolean?)
	local _, humanoid : Humanoid, humanoidRootPart : BasePart = private.getPlayerParts(player)
	if start and lookVector and localDirection and duration and moveable ~= nil and not playerStateService.getState(player, 'misc', "dashing") then
		private.disableJump(player, humanoid, humanoidRootPart, duration)
		playerStateService.setState(player, 'misc', 'dashing', true)
		private.createLinearVelocity(player, humanoidRootPart, lookVector, localDirection, private.dashSpeed, duration, moveable)
	else
		playerStateService.setState(player, 'misc', 'dashing', false)
	end
end

public.onStart = function()
	sprintEvent.OnServerEvent:Connect(private.sprint)
	dashEvent.OnServerEvent:Connect(private.dash)
end

return public