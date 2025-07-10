--!strict

local npcAnimationFunction = require(game.ReplicatedStorage.Functions.NPCAnimationFunction)
local npcTemplate = game.ServerStorage:WaitForChild('DummyTemplate') -- Original rig
local npcFunction = game.ReplicatedStorage.RemoteFunctions.NPCFunction

local private = {}
local public = {}

local npcFolder = workspace.Rigs.Dummies

private.npcSavedAnimations = {} :: {[Model] : {[string] : Animation}}
private.npcLoadedAnimations = {} :: {[Model] : {[string] : AnimationTrack}}

private.initializeAnimations = function(npc : Model)
	npcAnimationFunction.createAnimationProfile(npc)
	npcAnimationFunction.addAnimationsFromFolder(npc, game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.M1Hurts)
end

private.spawnNPC = function(position: CFrame?)
	local npcClone = npcTemplate:Clone()
	npcClone.Name = 'Dummy1'
	npcClone.Parent = workspace.Rigs.Dummies
	npcClone:PivotTo(position or CFrame.new(0, 5, 0))

	private.initializeAnimations(npcClone)

	local humanoid = npcClone:FindFirstChildOfClass('Humanoid') :: Humanoid
	humanoid.Died:Connect(function()
		task.delay(3, function()
			npcAnimationFunction.clearAnimations(npcClone)
			npcClone:Destroy()
			private.spawnNPC(position)
		end)
	end)
end

public.detectNPCs = function() : {Model}
	return npcFolder:GetChildren()
end

public.onStart = function()
	task.delay(0.25, private.spawnNPC)
	npcFunction.OnServerInvoke = function(player)
		return public.detectNPCs()
	end
end

return public