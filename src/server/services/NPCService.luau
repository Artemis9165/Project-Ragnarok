--!strict
local npcFunction = game.ReplicatedStorage.Events.NPCFunction
local private = {}
local public = {}

public.detectNPCs = function()
	return workspace.Rigs.Dummies:GetChildren()
end

public.onStart = function()
	npcFunction.OnServerInvoke = function(player)
		return public.detectNPCs()
	end
end

return public