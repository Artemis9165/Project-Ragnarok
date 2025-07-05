--!strict

local npcService = require(game.ServerScriptService.Services.NPCService)
local npcAnimationFunction = require(game.ReplicatedStorage.Functions.NPCAnimationFunction)

local private = {}
local public = {}

local hurtEvent = game.ReplicatedStorage.RemoteEvents.HurtEvent

public.onStart = function()
	hurtEvent.OnServerEvent:Connect(function(fromPlayer : Player, targetCharacter : Model, damage : number, comboCount : number)
		local npcs = npcService.detectNPCs() :: {Model}
		local isNPC : boolean = false 
		local targetPlayer : Player
		for _, npc in ipairs(npcs) do if targetCharacter == npc then isNPC = true end end
		if not isNPC then 
			targetPlayer = game.Players:GetPlayerFromCharacter(targetCharacter) :: Player 
			hurtEvent:FireClient(targetPlayer, comboCount)
		elseif comboCount ~= 4 then
			npcAnimationFunction.playAnimation(targetCharacter, tostring('Hurt'..comboCount), false)
		end
		local targetHumanoid = targetCharacter:FindFirstChildOfClass('Humanoid') :: Humanoid
		targetHumanoid:TakeDamage(damage)
	end)
end

return public