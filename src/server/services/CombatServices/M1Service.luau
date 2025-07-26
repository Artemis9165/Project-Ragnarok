--!strict

-- [Services]
local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)
local detectionService = require(game.ServerScriptService.Services.CombatServices.DetectionService)
local enviromentDestructionService = require(game.ServerScriptService.Services.CombatServices.EnviromentDestructionService)
local hurtService = require(game.ServerScriptService.Services.CombatServices.HurtService)
-- [Functions]

-- [Remote Events]
local m1Event = game.ReplicatedStorage.RemoteEvents.CombatEvents.M1Event
local changeHumanoidStateEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.ChangeHumanoidStateEvent

-- [Remote Functions]
local m1CheckerFunction = game.ReplicatedStorage.RemoteFunctions.M1Checker

local private = {}
local public = {}

private.m1Data = {
	damage = 3,
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

private.getCharacterParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.m1Checker = function(player : Player) : boolean
	return playerStateService.getState(player, 'combat', 'hurting')
		or playerStateService.getState(player, 'combat', 'attacking')
		or playerStateService.getState(player, 'combat', 'blocking')
		or playerStateService.getState(player, 'combat', 'comboCooldown')
		or playerStateService.getState(player, 'combat', 'attackDebounce')
		or playerStateService.getState(player, 'misc', 'dashing')
		or playerStateService.getState(player, 'combat', 'comboCount') > 4
end

private.createHitbox = function(player : Player, character : Model, humanoid : Humanoid, humanoidRootPart : BasePart) : {Model}
	local parts : {BasePart}
	if humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall) then
		parts = detectionService.getTargetRegion3(character, humanoidRootPart, private.m1Data.slamAreaOfEffect, 0)
	else
		parts = detectionService.getTargetRegion3(character, humanoidRootPart, private.m1Data.regularAreaOfEffect, 3)
	end
	local characters = detectionService.getCharactersFromParts(parts)
	return characters
end

private.triggerHit = function(player : Player, humanoid : Humanoid, characters : {Model}, isForwardDash : boolean?)
	for _, targetCharacter in ipairs(characters) do
		if isForwardDash then
			hurtService.m1Hurt(player, targetCharacter, 'm1', 1, private.m1Data.damage)
			return
		end
		if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			hurtService.m1Hurt(player, targetCharacter, 'slam', playerStateService.getState(player, 'combat', 'comboCount'), private.m1Data.slamDamage)
			local targetHumanoidRootPart = targetCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
			enviromentDestructionService.destroyEnviroment(targetCharacter, targetHumanoidRootPart.Position, private.m1Data.slamAreaOfEffect)
		elseif playerStateService.getState(player, 'misc', 'isSpaceDown') then
			hurtService.m1Hurt(player, targetCharacter, 'uppercut', playerStateService.getState(player, 'combat', 'comboCount'), private.m1Data.damage)
		else
			hurtService.m1Hurt(player, targetCharacter, 'm1', playerStateService.getState(player, 'combat', 'comboCount'), private.m1Data.damage)
		end
	end
end

private.disableSprint = function(player : Player) playerStateService.setState(player, 'misc', 'sprinting', false) end

private.resetCombo = function(player : Player)
	playerStateService.setState(player, 'combat', 'comboCount', 1)
	playerStateService.setState(player, 'combat', 'comboCooldown', false)
end

private.resetComboIfTimeout = function(player : Player)
	if tick() - playerStateService.getState(player, 'combat', 'lastComboTime') > private.m1Data.comboResetTime then
		private.resetCombo(player)
		changeHumanoidStateEvent:FireClient(player, true)
	end
end

private.incrementCombo = function(player : Player)
	local newCount = playerStateService.getState(player, 'combat', 'comboCount') + 1
	playerStateService.setState(player, 'combat', 'comboCount', newCount)
	if newCount > 4 then
		playerStateService.setState(player, 'combat', 'comboCooldown', true)
		task.delay(private.m1Data.comboResetTime, function()
			private.resetCombo(player)
		end)
	end
end

private.handlePostAnimation = function(player : Player, animationDuration : number) 
	task.delay(animationDuration, function() 
		playerStateService.setState(player, 'combat', 'attackDebounce', false) 
		playerStateService.setState(player, 'combat', 'attacking', false)
	end)
end

public.m1 = function(player: Player, animationDuration: number, isForwardDash : boolean?)
	local character : Model, humanoid : Humanoid, humanoidRootPart : BasePart = private.getCharacterParts(player)
	local characters : {Model} = private.createHitbox(player, character, humanoid, humanoidRootPart)
	if isForwardDash then
		private.triggerHit(player, humanoid, characters, isForwardDash)
		return
	end
	private.triggerHit(player, humanoid, characters)
	private.disableSprint(player)
	playerStateService.setState(player, 'combat', 'lastComboTime', tick())
	playerStateService.setState(player, 'combat', 'attackDebounce', true)
	playerStateService.setState(player, 'combat', 'attacking', true)
	private.incrementCombo(player)
	private.handlePostAnimation(player, animationDuration)
	task.delay(private.m1Data.comboResetTime, function() private.resetComboIfTimeout(player) end)
end


public.onStart = function()
	m1Event.OnServerEvent:Connect(public.m1)
	m1CheckerFunction.OnServerInvoke = private.m1Checker
end

return public