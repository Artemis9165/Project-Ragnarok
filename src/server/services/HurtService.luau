--!strict

local npcService = require(game.ServerScriptService.Services.NPCService)
local ragdollService = require(game.ServerScriptService.Services.RagdollService)
local knockbackService = require(game.ServerScriptService.Services.KnockbackService)
local npcAnimationFunction = require(game.ReplicatedStorage.Functions.NPCAnimationFunction)

local hurtEvent = game.ReplicatedStorage.RemoteEvents.HurtEvent

local private = {}
local public = {}

private.m1Hurt = function(fromPlayer : Player, targetCharacter : Model, isNPC : boolean, comboCount : number)
	if not isNPC then 
		local targetPlayer = game.Players:GetPlayerFromCharacter(targetCharacter) :: Player 
		hurtEvent:FireClient(targetPlayer, fromPlayer, comboCount)
	elseif comboCount ~= 4 then
		npcAnimationFunction.playAnimation(targetCharacter, tostring('Hurt'..comboCount), false)
	elseif comboCount == 4 then
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

public.onStart = function()
	hurtEvent.OnServerEvent:Connect(function(fromPlayer : Player, targetCharacter : Model, typeOfAttack : string, damage : number, comboCount : number?)
		local npcs = npcService.detectNPCs() :: {Model}
		local isNPC : boolean = false 
		for _, npc in ipairs(npcs) do if targetCharacter == npc then isNPC = true end end
		if typeOfAttack == 'm1' and comboCount then private.m1Hurt(fromPlayer, targetCharacter, isNPC, comboCount) end
		if typeOfAttack == 'slam' then private.slamHurt(targetCharacter) end
		if typeOfAttack == 'uppercut' then private.uppercutHurt(targetCharacter, isNPC) end
		local targetHumanoid = targetCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
		targetHumanoid:TakeDamage(damage)
	end)
end

return public