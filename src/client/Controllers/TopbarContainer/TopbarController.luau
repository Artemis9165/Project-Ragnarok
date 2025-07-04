--!strict
local icon = require(game.ReplicatedStorage.Functions.Icon)
local updateCharacterEvent = game.ReplicatedStorage.RemoteEvents.UpdateCharacter
local types = require(game.ReplicatedStorage.Functions.Types)

local public = {}

public.onStart = function()
	local player = game.Players.LocalPlayer
	icon.new()
		:setLabel('Characters')
		:setDropdown({
			icon.new()
			:setLabel('Guy')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'Guy');
			end),
			icon.new()
			:setLabel('Outlaw')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'Outlaw');
			end),
			icon.new()
			:setLabel('Fencer')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'Fencer');
			end),
			icon.new()
			:setLabel('Special')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'Special');
			end),
			icon.new()
			:setLabel('Holy Grail')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'HolyGrail');
			end),
			icon.new()
			:setLabel('Hunter')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'Hunter');
			end),
			icon.new()
			:setLabel('Escape Artist')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'EscapeArtist');
			end),
			icon.new()
			:setLabel('Pestering Snow')
			:oneClick()
			:bindEvent('selected', function()
				updateCharacterEvent:FireServer(player, 'PesteringSnow');
			end),
		})
end

return public