--!strict

-- [Roblox Services]

-- [Services]
local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)

-- [Controllers]

-- [Functions]

-- [Remote Events]
local blockEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.BlockEvent

-- [Remote Functions]
local blockCheckerFunction = game.ReplicatedStorage.RemoteFunctions.BlockChecker

local private = {}
local public = {}

private.blockThreshold = 0.5

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

private.blockChecker = function(player : Player)
	return playerStateService.getState(player, 'combat', 'hurting')
		or playerStateService.getState(player, 'combat', 'attacking')
		or playerStateService.getState(player, 'misc', 'dashing')
end

private.block = function(player : Player, enable : boolean) playerStateService.setState(player, 'combat', 'blocking', enable) end

public.detectBlock = function(fromPlayer : Player, isNPC : boolean, targetCharacter : Model) : boolean
	if not isNPC then
		local targetPlayer = game.Players:GetPlayerFromCharacter(targetCharacter)
		if not playerStateService.getState(targetPlayer, 'combat', 'blocking') then return false end
	else return false end
	local _, _, fromHumanoidRootPart : BasePart = private.getCharacterParts(fromPlayer)
	local _, targetHumanoidRootPart : BasePart = private.getCharacterPartsFromCharacter(targetCharacter)
	local dir = (fromHumanoidRootPart.Position - 
		targetHumanoidRootPart.Position).Unit
	local dot = dir:Dot(targetHumanoidRootPart.CFrame.LookVector)
	return dot >= private.blockThreshold
end

public.onStart = function()
	blockCheckerFunction.OnServerInvoke = private.blockChecker
	blockEvent.OnServerEvent:Connect(private.block)
end

return public