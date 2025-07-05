--!strict
local userInputService = game:GetService('UserInputService')
local collectionService = game:GetService('CollectionService')

local playerStateFunction = require(game.ReplicatedStorage.Functions.PlayerStateFunction)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local dataController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.DataController)
local animationFunction = require(game.ReplicatedStorage.Functions.AnimationFunction)
local hurtController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.HurtController)
local movementController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.MovementController)

local npcFunction = game.ReplicatedStorage.RemoteFunctions.NPCFunction
local ragdollEvent = game.ReplicatedStorage.RemoteEvents.RagdollEvent
local knockbackEvent = game.ReplicatedStorage.RemoteEvents.KnockbackEvent
local hurtEvent = game.ReplicatedStorage.RemoteEvents.HurtEvent

local private = {}
local public = {}

private.m1Data = {
	damage = 30,
	slamDamage = 5,
	uppercutDamage = 4,
	timeBetweenCombos = 0.75,
	regularAreaOfEffect = Vector3.new(2, 2, 2),
	bigAreaOfEffect = Vector3.new(7.5, 7.5, 7.5),
	slamAreaOfEffect = Vector3.new(7, 30, 7),
	forwardDashAreaOfEffect = Vector3.new(5, 5, 5),
	comboResetTime = 1.5,
	m1StunDelay = 1.5
}

private.getCharacter = function(player : Player)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.getOtherCharacter = function(parts : {Part}) : Model
	local otherCharacter;
	for i, part in ipairs(parts) do
		local otherModel = part:FindFirstAncestorWhichIsA('Model') :: Model
		if otherModel:FindFirstChild('Humanoid') then
			otherCharacter = otherModel
			break
		end
	end
	return otherCharacter
end

private.detectHumanoid = function(parts : {Part}) : boolean
	for i, part in ipairs(parts) do
		local otherModel = part:FindFirstAncestorWhichIsA('Model') :: Model
		local otherModelHumanoid = otherModel:FindFirstChild('Humanoid') :: Humanoid
		if otherModelHumanoid then
			return true
		end
	end
	return false
end

private.getTargetRaycast = function(character : Model, origin: Vector3, direction: Vector3, range: number): Instance | nil
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, direction.Unit * range, rayParams)
	local length = range
	if result then
		length = (result.Position - origin).Magnitude
	end
	
	--[DEBUG]
	--local rayPart = Instance.new("Part")
	--rayPart.Anchored = true
	--rayPart.CanCollide = false
	--rayPart.Transparency = 0.5
	--rayPart.Color = Color3.new(1, 0, 0)
	--rayPart.Material = Enum.Material.Neon
	--rayPart.Size = Vector3.new(0.1, 0.1, length)
	--rayPart.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -length / 2)
	--rayPart.Parent = workspace
	--game:GetService("Debris"):AddItem(rayPart, 0.2)
	
	if result then
		return result.Instance
	end
	return nil
end

private.getTargetRegion3 = function(character : Model, humanoidRootPart : BasePart, size : Vector3, forwardOffset : number) : {Part}
	local forwardVector = humanoidRootPart.CFrame.LookVector
	local center = humanoidRootPart.Position + forwardVector * forwardOffset
	local regionCFrame = CFrame.new(center, center + forwardVector)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character, workspace.Maps.CentralPark.Arena.Arena}
	overlapParams.MaxParts = 50
	local parts = workspace:GetPartBoundsInBox(regionCFrame, size, overlapParams)
	
	--[DEBUG]
	--local debugPart = Instance.new("Part")
	--debugPart.Size = size
	--debugPart.CFrame = regionCFrame
	--debugPart.Anchored = true
	--debugPart.CanCollide = false
	--debugPart.Transparency = 0.6
	--debugPart.Color = Color3.new(1, 0, 0)
	--debugPart.Material = Enum.Material.Neon
	--debugPart.Parent = workspace
	--game.Debris:AddItem(debugPart, 0.4)
	
	return parts
end

private.destroyEnviroment = function(character : Model, impactPosition : Vector3, areaDestroyed : Vector3)
	local region = Region3.new(
		impactPosition - areaDestroyed,
		impactPosition + areaDestroyed
	)
	local environmentParts = workspace:FindPartsInRegion3(region, character, 50)
	for _, part in ipairs(environmentParts) do
		if collectionService:HasTag(part, 'Breakable') then
			local originalCFrame = part.CFrame
			local originalAnchored = part.Anchored
			local originalParent = part.Parent
			part.Anchored = false
			part:BreakJoints()
			part.Velocity = Vector3.new(math.random(-20, 20), math.random(20, 40), math.random(-20, 20))
			task.delay(3, function()
				if part and part:IsDescendantOf(workspace) then
					part.Anchored = originalAnchored
					part.CFrame = originalCFrame
					part.Velocity = Vector3.zero
					part.RotVelocity = Vector3.zero
				end
			end)
		end
	end
end

private.shouldBlockM1 = function(inputObject: InputObject, player: Player): boolean
	return inputObject.UserInputType ~= Enum.UserInputType.MouseButton1
		or playerStateFunction.getState(player, 'combat', 'hurting')
		or playerStateFunction.getState(player, 'combat', 'attacking')
		or playerStateFunction.getState(player, 'combat', 'blocking')
		or playerStateFunction.getState(player, 'combat', 'comboCooldown')
		or playerStateFunction.getState(player, 'combat', 'attackDebounce')
		or playerStateFunction.getState(player, 'misc', 'dashing')
		or playerStateFunction.getState(player, 'combat', 'comboCount') > 4
end

private.resetComboIfTimeout = function(player: Player)
	if tick() - playerStateFunction.getState(player, 'combat', 'lastComboTime') > private.m1Data.comboResetTime then
		playerStateFunction.setState(player, 'combat', 'comboCount', 1)
	end
end

private.disableSprint = function(player : Player, humanoid : Humanoid)
	if animationFunction.isAnimationPlaying(player, 'Sprint') then
		humanoid.WalkSpeed = 16
		animationFunction.stopAnimation(player, 'Sprint')
	end
end

private.getComboAnimationName = function(humanoid: Humanoid, player: Player): string
	local comboCount = playerStateFunction.getState(player, 'combat', 'comboCount')
	if humanoid:GetState() == Enum.HumanoidStateType.Freefall and comboCount == 4 then return "Slam" end
	if userInputService:IsKeyDown(Enum.KeyCode.Space) and comboCount == 4 then return "Uppercut" end
	return tostring(comboCount)
end

private.triggerHit = function(player : Player, otherCharacter : Model, damage : number, comboCount : number)
	hurtEvent:FireServer(otherCharacter, damage, comboCount)
end

private.handleAttackAnimation = function(player: Player, character: Model, humanoidRootPart: BasePart, animationName: string)
	animationFunction.playAnimation(player, animationName, false)
	
	local parts
	if animationName == 'Slam' then
		parts = private.getTargetRegion3(character, humanoidRootPart, private.m1Data.slamAreaOfEffect, 0)
	else
		parts = private.getTargetRegion3(character, humanoidRootPart, private.m1Data.regularAreaOfEffect, 3)
	end
	
	local otherCharacter = private.getOtherCharacter(parts)
	if otherCharacter and private.detectHumanoid(parts) then
		if animationName == "Slam" then
			--private.slam(otherCharacter)
		elseif animationName == "Uppercut" then
			--private.uppercut(otherCharacter)
		else
			private.triggerHit(player, otherCharacter, private.m1Data.damage, playerStateFunction.getState(player, 'combat', 'comboCount'))
		end
	end
end

private.handlePostAnimation = function(player: Player, humanoid: Humanoid, animationName: string)
	animationFunction.stopped(player, animationName, function()
		task.delay(1.15, function() humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
		playerStateFunction.setState(player, 'combat', 'attackDebounce', false)
	end)
end

private.incrementCombo = function(player: Player)
	local newCount = playerStateFunction.getState(player, 'combat', 'comboCount') + 1
	playerStateFunction.setState(player, 'combat', 'comboCount', newCount)
	if newCount > 4 then
		playerStateFunction.setState(player, 'combat', 'comboCooldown', true)
		task.delay(private.m1Data.comboResetTime, function()
			playerStateFunction.setState(player, 'combat', 'comboCount', 1)
			playerStateFunction.setState(player, 'combat', 'comboCooldown', false)
		end)
	end
end

private.m1 = function(inputObject: InputObject, player: Player, character: Model, humanoid: Humanoid, humanoidRootPart: BasePart)
	if private.shouldBlockM1(inputObject, player) then return end
	private.disableSprint(player, humanoid)
	private.resetComboIfTimeout(player)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	playerStateFunction.setState(player, 'combat', 'lastComboTime', tick())
	playerStateFunction.setState(player, 'combat', 'attackDebounce', true)
	local animationName = private.getComboAnimationName(humanoid, player)
	private.handleAttackAnimation(player, character, humanoidRootPart, animationName)
	private.handlePostAnimation(player, humanoid, animationName)
	private.incrementCombo(player)
end


private.initalizeAnimations = function(player : Player)
	local animationsFolder = game.ReplicatedStorage:FindFirstChild('CharacterData'):FindFirstChild('Animations') :: Folder
	local selectedCharacterAnimationsFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterM1AnimationsFolder = selectedCharacterAnimationsFolder:FindFirstChild('M1') :: Folder
	animationFunction.addAnimationsFromFolder(player, selectedCharacterM1AnimationsFolder)
end

private.setupCharacter = function(player : Player)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacter(player)
	userInputService.InputBegan:Connect(function(inputObject : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.m1(inputObject, player, character, humanoid, humanoidRootPart)
	end)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	private.setupCharacter(player)
	private.initalizeAnimations(player)
	player.CharacterAdded:Connect(function() private.setupCharacter(player) end)
end

return public
