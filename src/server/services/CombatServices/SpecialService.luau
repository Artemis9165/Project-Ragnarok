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

private.special = function(player : Player, specialKeybind : Enum.KeyCode)
	local selectedCharacterSpecialDataScript : ModuleScript = getSelectedCharacterFunction.getSelectedCharacterSpecialsDataFolder(player)
	local selectedCharacterSpecialData = require(selectedCharacterSpecialDataScript) :: types.specialDataR
	if specialKeybind == Enum.KeyCode.One then
		print(selectedCharacterSpecialData.general.special1)
	end
end

public.onStart = function()
	specialsEvent.OnServerEvent:Connect(private.special)
	specialCheckerFunction.OnServerInvoke = private.specialChecker
end

return public