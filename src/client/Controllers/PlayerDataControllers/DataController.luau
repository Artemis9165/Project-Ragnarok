--!strict

local animationController = require(game.StarterPlayer.StarterPlayerScripts.Controllers.PlayerDataControllers.AnimationController)
local types = require(game.ReplicatedStorage.Functions.Types)

local changeHumanoidStateEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.ChangeHumanoidStateEvent
local cloneCharacterSpecialsScriptEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.CloneCharacterSpecialsScriptEvent

local private = {}
local public = {}

private.getCharacterParts = function(player : Player)
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	return character, humanoid, humanoidRootPart
end

private.cloneCharacterSpecialsScript = function(player : Player, scriptName : types.characterName)
	local characterSpecialsScriptFolder = game.ReplicatedStorage.CharacterData.CharacterSpecialScripts :: Folder
	local characterSpecialsScript = characterSpecialsScriptFolder:FindFirstChild(scriptName) :: ModuleScript
	local characterSpecialsScriptClone = characterSpecialsScript:Clone() :: ModuleScript
	local playerScripts = player:WaitForChild('PlayerScripts')
	local controllers = playerScripts:WaitForChild('Controllers') :: Folder
	local combatControllers = controllers:WaitForChild('CombatControllers') :: Folder
	characterSpecialsScriptClone.Parent = combatControllers
end

public.changeHumanoidJumpState = function(player : Player, value : boolean)
	local player = game.Players.LocalPlayer
	local _, humanoid : Humanoid = private.getCharacterParts(player)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, value)
end

public.onStart = function()
	local player = game.Players.LocalPlayer
	animationController.createAnimationProfile(player)
	local initialized = false
	player.CharacterAdded:Connect(function() if initialized then animationController.reloadAnimations(player) else initialized = true end end)
	changeHumanoidStateEvent.OnClientEvent:Connect(function(value : boolean) public.changeHumanoidJumpState(player, value) end)
	cloneCharacterSpecialsScriptEvent.OnClientEvent:Connect(function(scriptName : types.characterName) private.cloneCharacterSpecialsScript(player, scriptName)  end)
end

return public