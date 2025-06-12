--!strict
local userInputService = game:GetService('UserInputService')
local collectionService = game:GetService('CollectionService')
local playerCombatStateFunction = game.ReplicatedStorage.Events.PlayerCombatStateFunction
local loadedAnimationsFunction = game.ReplicatedStorage.Events.LoadedAnimationsFunction
local getCharacterData = require(game.ReplicatedStorage.Functions.GetCharacterData)
local ragdollEvent = game.ReplicatedStorage.Events.RagdollEvent
local knockbackEvent = game.ReplicatedStorage.Events.KnockbackEvent
local npcFunction = game.ReplicatedStorage.Events.NPCFunction
local dataController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.DataController)

local private = {}
local public = {}

local m1Hurts = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.M1Hurts

local player = game.Players.LocalPlayer
local character: Model
local humanoid: Humanoid
local humanoidRootPart: BasePart
local animator: Animator
local loadedAnimations
local playerState = playerCombatStateFunction:InvokeServer('get')
local characterData

local m1 = {
	damage = 3,
	slamDamage = 5,
	uppercutDamage = 4,
	timeBetweenCombos = 0.75,
	regularAreaOfEffect = Vector3.new(2, 2, 2),
	bigAreaOfEffect = Vector3.new(7.5, 7.5, 7.5),
	slamAreaOfEffect = Vector3.new(7, 30, 7),
	forwardDashAreaOfEffect = Vector3.new(5, 5, 5),
	comboResetTime = 1.5,
	m1StunDelay = 1.5,
	rashRushdownCooldown = false,
	destroyerKickCooldown = false,
	asphaltCrunchCooldown = false,
	brawlersInstinctCooldown = false
}

private.getCharacter = function()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	animator = humanoid:WaitForChild("Animator") :: Animator
	characterData = getCharacterData(player)
end

private.createAnimationProfile = function()
	loadedAnimations = loadedAnimationsFunction:InvokeServer(player)
	for i, animation : Animation in pairs(characterData.Super.Animations.M1[1].Combo :: {Animation}) do
		loadedAnimations[animation.Name] = animator:LoadAnimation(animation)
	end
	for i, animation : Animation in pairs(characterData.Super.Animations.M1[1].ComboFinishers :: {Animation}) do
		loadedAnimations[animation.Name] = animator:LoadAnimation(animation)
	end
	for i, animation : Animation in pairs(characterData.Super.Animations.M1.Block :: {Animation}) do
		loadedAnimations[animation.Name] = animator:LoadAnimation(animation)
	end
	for i, animation : Animation in pairs(characterData.Super.Animations.M1.M1Hurt :: {Animation}) do
		loadedAnimations[animation.Name] = animator:LoadAnimation(animation)
	end
end

private.playAnimation = function(animationName: string, looped : boolean, priority : Enum.AnimationPriority?)
	loadedAnimations[animationName].Looped = looped
	loadedAnimations[animationName].Priority = priority or Enum.AnimationPriority.Action
	loadedAnimations[animationName]:Play()
end

private.getTargetRaycast = function(origin: Vector3, direction: Vector3, range: number): Instance | nil
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction.Unit * range, rayParams)

	--local rayPart = Instance.new("Part")
	--rayPart.Anchored = true
	--rayPart.CanCollide = false
	--rayPart.Transparency = 0.5
	--rayPart.Color = Color3.new(1, 0, 0)
	--rayPart.Material = Enum.Material.Neon

	local length = range
	if result then
		length = (result.Position - origin).Magnitude
	end

	--rayPart.Size = Vector3.new(0.1, 0.1, length)
	--rayPart.CFrame = CFrame.new(origin, origin + direction) * CFrame.new(0, 0, -length / 2)
	--rayPart.Parent = workspace

	--game:GetService("Debris"):AddItem(rayPart, 0.2)

	if result then
		return result.Instance
	end
	return nil
end

private.getTargetRegion3 = function(character : Model, size : Vector3, forwardOffset : number) : {Part}
	local hrp = character:FindFirstChild('HumanoidRootPart') :: BasePart
	local forwardVector = hrp.CFrame.LookVector
	local center = hrp.Position + forwardVector * forwardOffset
	local regionCFrame = CFrame.new(center, center + forwardVector)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {character, workspace.Maps.CentralPark.Arena.Arena}
	overlapParams.MaxParts = 50
	local parts = workspace:GetPartBoundsInBox(regionCFrame, size, overlapParams)
	
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

private.triggerHit = function(otherCharacter : Model, damage : number, comboCount : number, forwardDash : boolean?)
	local otherPlayer = game.Players:GetPlayerFromCharacter(otherCharacter) :: Player
	local otherHumanoid = otherCharacter:FindFirstChild('Humanoid') :: Humanoid
	local otherHumanoidRootPart = otherCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
	local otherAnimator = otherHumanoid:FindFirstChild('Animator') :: Animator
	local otherLoadedAnimations = loadedAnimationsFunction:InvokeServer(otherPlayer) :: {[string] : AnimationTrack}
	local otherCharacterStatus = playerCombatStateFunction:InvokeServer()
	if playerCombatStateFunction:InvokeServer('get', otherPlayer).isCountering then
		for i, v : AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
			v:Stop()
			local counterAnimation = loadedAnimationsFunction:InvokeServer(otherPlayer)
			counterAnimation:Play()
			otherHumanoid.PlatformStand = true
			counterAnimation:GetMarkerReachedSignal('Attack'):Connect(function()
				humanoid:TakeDamage(14)
				private.playAnimation('Hurt2', false)
			end)
			counterAnimation.Stopped:Once(function()
				otherCharacterStatus.isAttacking = false
				dataController.cooldown(3, 2)
				task.delay(2, function()
					m1.asphaltCrunchCooldown = false
				end)
				task.delay(m1.m1StunDelay, function()
					otherHumanoid.PlatformStand = false
				end)
			end)
		end
	end
	if forwardDash then
		local filePath = m1Hurts.Hurt1 :: Animation
		local hurtAnimationTrack = otherAnimator:LoadAnimation(filePath)
		hurtAnimationTrack.Looped = false
		hurtAnimationTrack:Play()
		hurtAnimationTrack:AdjustSpeed(0.8)
		otherHumanoid.PlatformStand = true
		otherHumanoid:TakeDamage(m1.damage)
		task.delay(hurtAnimationTrack.Length + m1.m1StunDelay, function()
			otherHumanoid.PlatformStand = false
		end)
		return
	end
	if otherPlayer and otherCharacterStatus.isBlocking then
		local isInfront = false
		local isNextTo = false
		if otherHumanoidRootPart then
			local angle = math.acos(otherHumanoidRootPart.CFrame.LookVector:Dot((humanoidRootPart.Position-otherHumanoidRootPart.Position).Unit))
			isInfront = angle < math.pi/2
			isNextTo = angle < math.pi/1.65
		end
		if isInfront or isNextTo then
			return
		end
		otherLoadedAnimations['Hold']:Stop()
		playerCombatStateFunction:InvokeServer(otherCharacter).isBlocking = false
	end
	if comboCount < 4 then
		local filePath = m1Hurts['Hurt'..comboCount] :: Animation
		local hurtAnimationTrack = otherAnimator:LoadAnimation(filePath)
		hurtAnimationTrack.Looped = false
		hurtAnimationTrack:Play()
		hurtAnimationTrack:AdjustSpeed(0.8)
		otherHumanoid.PlatformStand = true
		otherHumanoid:TakeDamage(m1.damage)
		task.delay(loadedAnimations[tostring(comboCount)].Length + m1.m1StunDelay, function()
			otherHumanoid.PlatformStand = false
		end)
	end
	if comboCount == 4 then 
		knockbackEvent:FireServer(otherCharacter, humanoidRootPart.CFrame.LookVector, 5)
		ragdollEvent:FireServer(otherCharacter, 2)
	end
end

private.destroyEnviroment = function(impactPosition : Vector3, areaDestroyed : Vector3)
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

private.createLinearVelocity = function(time: number)
	local speed = 50
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
	linearVelocity.PlaneVelocity = Vector2.zero
	linearVelocity.Parent = attachment
	local moveDir = humanoid.MoveDirection
	linearVelocity.PlaneVelocity = Vector2.new(moveDir.X, moveDir.Z) * speed

	task.delay(time, function()
		linearVelocity:Destroy()
		attachment:Destroy()
	end)
end

private.slam = function(otherCharacter : Model)
	local otherHumanoid = otherCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
	local otherHumanoidRootPart = otherCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
	ragdollEvent:FireServer(otherCharacter, 4)
	otherHumanoid:TakeDamage(m1.slamDamage)
	private.destroyEnviroment(otherHumanoidRootPart.Position, m1.slamAreaOfEffect)
end

private.uppercut = function(otherCharacter : Model)
	local otherHumanoid = otherCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
	ragdollEvent:FireServer(otherCharacter, 2)
	knockbackEvent:FireServer(otherCharacter, Vector3.yAxis, 30)
	otherHumanoid:TakeDamage(m1.slamDamage)
end

private.m1 = function(inputObject : InputObject, gameProcessedEvent)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if playerState.isAttacking then return end
	if playerState.comboCount > 4 then return end
	if tick() - playerState.lastComboTime > m1.comboResetTime then
		playerState.comboCount = 1
	end
	playerState.lastComboTime = tick()
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	playerState.isAttacking = true
	local animationName

	if humanoid:GetState() == Enum.HumanoidStateType.Freefall and playerState.comboCount == 4 then
		animationName = "Slam"
	elseif userInputService:IsKeyDown(Enum.KeyCode.Space) and playerState.comboCount == 4 then
		animationName = "Uppercut"
	else
		animationName = tostring(playerState.comboCount)
	end

	private.playAnimation(animationName, false)

	local parts
	if animationName == 'Slam' then
		parts = private.getTargetRegion3(character, m1.slamAreaOfEffect, 0)
	else
		parts = private.getTargetRegion3(character, m1.regularAreaOfEffect, 3)
	end

	local otherCharacter = private.getOtherCharacter(parts)
	if otherCharacter and private.detectHumanoid(parts) then
		if animationName == "Slam" then
			private.slam(otherCharacter)
		elseif animationName == "Uppercut" then
			private.uppercut(otherCharacter)
		else
			private.triggerHit(otherCharacter, m1.damage, playerState.comboCount)
		end
	end

	loadedAnimations[animationName].Stopped:Once(function()
		task.delay(1.15, function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end)
		if playerState.comboCount < 4 then
			playerState.comboCount += 1
			playerState.isAttacking = false
		else
			task.delay(m1.timeBetweenCombos, function()
				playerState.comboCount = 1
				playerState.isAttacking = false 
			end)
		end
	end)
end

private.block = function(inputObject : InputObject, gameProcessedEvent)
	if inputObject.KeyCode == Enum.KeyCode.F then
		for i, v in pairs(loadedAnimationsFunction:FireServer(player)) do
			if string.find(v.Name, "[^%a]Hurt[^%a]") then
				return
			end
		end
		private.playAnimation('Startup', false)
		loadedAnimationsFunction:FireServer(player)['Startup'].Stopped:Once(function()
			if userInputService:IsKeyDown(Enum.KeyCode.F) then
				private.playAnimation('Hold', true)
				playerCombatStateFunction:InvokeServer().isBlocking = true
			end
		end)
	end
end

private.unblock = function(inputObject : InputObject, gameProcessedEvent)
	if inputObject.KeyCode == Enum.KeyCode.F then
		loadedAnimationsFunction:FireServer(player)['Startup']:Stop()
		loadedAnimationsFunction:FireServer(player)['Hold']:Stop()
		playerCombatStateFunction:InvokeServer().isBlocking = false
	end
end

public.forwardDash = function(character : Model)
	local parts = private.getTargetRegion3(character, m1.forwardDashAreaOfEffect, 5)
	local otherCharacter = private.getOtherCharacter(parts)
	if otherCharacter and private.detectHumanoid(parts) then
		private.triggerHit(otherCharacter, m1.damage, playerState.comboCount, true)
	end
end

public.onStart = function()
	private.getCharacter()
	player.CharacterAdded:Connect(private.getCharacter)
	private.createAnimationProfile()
	userInputService.InputBegan:Connect(function(inputObject : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.m1(inputObject, gameProcessedEvent)
		private.block(inputObject, gameProcessedEvent)
	end)
	
	userInputService.InputEnded:Connect(function(inputObject : InputObject, gameProcessedEvent : boolean)
		if gameProcessedEvent then return end
		private.unblock(inputObject, gameProcessedEvent)
	end)
	
	ragdollEvent.OnClientEvent:Connect(function(type : string, humanoid : Humanoid)
		if type == 'ragdoll' then
			humanoid.AutoRotate = false
			humanoid.PlatformStand = true
		elseif type == 'unragdoll' then
			if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
			humanoid.PlatformStand = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

return public
