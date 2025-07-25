--!strict

-- [Roblox Services]

-- [Services]
local playerStateService = require(game.ServerScriptService.Services.PlayerDataServices.PlayerStateService)
local hurtService = require(game.ServerScriptService.Services.CombatServices.HurtService)

-- [Controllers]

-- [Functions]
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local types = require(game.ReplicatedStorage.Functions.Types)

-- [Remote Events]
local specialsEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.SpecialsEvent
local cooldownEvent = game.ReplicatedStorage.RemoteEvents.DataEvents.CooldownEvent

-- [Remote Functions]
local specialCheckerFunction = game.ReplicatedStorage.RemoteFunctions.SpecialChecker

local private = {}
local public = {}

private.specialChecker = function(player : Player, specialKeybind : Enum.KeyCode) : boolean
	local part1 = playerStateService.getState(player, 'combat', 'hurting')
		or playerStateService.getState(player, 'combat', 'attacking')
		or playerStateService.getState(player, 'combat', 'blocking')
		or playerStateService.getState(player, 'misc', 'dashing')
	if specialKeybind == Enum.KeyCode.One then return part1 or playerStateService.getState(player, 'specialsCooldown', 'special1') end
	return false
end

private.getSelectedCharacterSpecialData = function(player : Player) : SharedTable
	local characterName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local selectedCharacterSpecialData = require(game.ReplicatedStorage.CharacterData.CharacterSpecials.CharacterSpecialsData[characterName]) :: SharedTable
	return selectedCharacterSpecialData
end

private.enableCooldown = function(player : Player, special : types.stateName)
	local selectedCharacterSpecialData = private.getSelectedCharacterSpecialData(player)
	playerStateService.setState(player, 'specialsCooldown', special, true)
	task.delay(selectedCharacterSpecialData.getSpecialData(special).general.cooldown, function() playerStateService.setState(player, 'specialsCooldown', special, false) end)
end

private.special = function(player : Player, specialKeybind : Enum.KeyCode, count : number?)
	local selectedCharacterSpecialData = private.getSelectedCharacterSpecialData(player)
	if specialKeybind == Enum.KeyCode.One then 
		print(selectedCharacterSpecialData.getSpecialData('special1').general.cooldown)
	end
end

public.onStart = function()
	specialsEvent.OnServerEvent:Connect(private.special)
	cooldownEvent.OnServerEvent:Connect(private.enableCooldown)
	specialCheckerFunction.OnServerInvoke = private.specialChecker
end

return public