--!strict

-- [Roblox Services]

-- [Services]
local npcService = require(game.ServerScriptService.Services.NPCServices.NPCService)
local npcAnimationService = require(game.ServerScriptService.Services.NPCServices.NPCAnimationService)
local ragdollService = require(game.ServerScriptService.Services.CombatServices.RagdollService)
local knockbackService = require(game.ServerScriptService.Services.CombatServices.KnockbackService)
local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)
local blockService = require(game.ServerScriptService.Services.CombatServices.BlockService)

-- [Controllers]

-- [Functions]
local types = require(game.ReplicatedStorage.Functions.Types)

-- [Remote Events]
local hurtEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.HurtEvent

-- [Remote Functions]

local private = {}
local public = {}

private.hurtTimeout = 1.5

private.getCharacterParts = function(player : Player) : (Model, Humanoid, BasePart)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.getCharacterPartsFromCharacter = function(character : Model) : (Humanoid, BasePart)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return humanoid, humanoidRootPart
end

private.m1Hurt = function(fromPlayer : Player, targetCharacter : Model, isNPC : boolean, comboCount : number)
	if not isNPC then 
		local targetPlayer = game.Players:GetPlayerFromCharacter(targetCharacter) :: Player
		playerStateService.setState(targetPlayer, 'combat', 'hurting', true)
		hurtEvent:FireClient(targetPlayer, fromPlayer, comboCount)
		task.delay(private.hurtTimeout, function() playerStateService.setState(targetPlayer, 'combat', 'hurting', false) end)
	elseif comboCount ~= 4 then npcAnimationService.playAnimation(targetCharacter, tostring('Hurt'..comboCount), false) end
	if comboCount == 4 then
		local fromPlayerCharacter = fromPlayer.Character or fromPlayer.CharacterAdded:Wait() :: Model
		local fromPlayerHumanoidRootPart = fromPlayerCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
		knockbackService.knockback(targetCharacter, isNPC, fromPlayerHumanoidRootPart.CFrame.LookVector, 5)
		ragdollService.ragdollCharacter(targetCharacter, 2)
	end
end

private.slamHurt = function(targetCharacter : Model)
	local targetHumanoid = targetCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
	local targetHumanoidRootPart = targetCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
	ragdollService.ragdollCharacter(targetCharacter, 4)
end

private.uppercutHurt = function(targetCharacter : Model, isNPC : boolean)
	ragdollService.ragdollCharacter(targetCharacter, 2)
	knockbackService.knockback(targetCharacter, isNPC, Vector3.yAxis, 30)
end

public.hurt = function(fromPlayer : Player, targetCharacter : Model, typeOfAttack : types.m1AttackType, comboCount : number, damage : number)
	local npcs = npcService.detectNPCs() :: {Model}
	local isNPC : boolean = false 
	for _, npc in ipairs(npcs) do if targetCharacter == npc then isNPC = true end end
	if typeOfAttack == 'm1' and comboCount and not blockService.detectBlock(fromPlayer, isNPC, targetCharacter) then private.m1Hurt(fromPlayer, targetCharacter, isNPC, comboCount) end
	if typeOfAttack == 'slam' then private.slamHurt(targetCharacter) end
	if typeOfAttack == 'uppercut' and not blockService.detectBlock(fromPlayer, isNPC, targetCharacter) then private.uppercutHurt(targetCharacter, isNPC) end
	local targetHumanoid = targetCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
	targetHumanoid:TakeDamage(damage)
end

public.onStart = function() end

return public