--!strict
local icon = require(game.ReplicatedStorage.TopbarPlus.Icon);
local updateCharacterModule = require(game.ReplicatedStorage.Functions.UpdateCharacter);
local types = require(game.ReplicatedStorage.Functions.Types);
local player = game.Players.LocalPlayer;

local Guy = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Guy);
local Outlaw = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Outlaw);
local Fencer = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Fencer);
local Special = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Special);
local HolyGrail = require(game.ReplicatedStorage.CharacterData.Classes.Characters.HolyGrail);
local Hunter = require(game.ReplicatedStorage.CharacterData.Classes.Characters.Hunter);
local EscapeArtist = require(game.ReplicatedStorage.CharacterData.Classes.Characters.EscapeArtist);
local PesteringSnow = require(game.ReplicatedStorage.CharacterData.Classes.Characters.PesteringSnow);

local public = {};

public.onStart = function()
	icon.new()
	:setLabel('Characters')
	:setDropdown({
		icon.new()
		:setLabel('Guy')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, Guy.new());
		end),
		icon.new()
		:setLabel('Outlaw')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, Outlaw.new());
		end),
		icon.new()
		:setLabel('Fencer')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, Fencer.new());
		end),
		icon.new()
		:setLabel('Special')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, Special.new());
		end),
		icon.new()
		:setLabel('Holy Grail')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, HolyGrail.new());
		end),
		icon.new()
		:setLabel('Hunter')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, Hunter.new());
		end),
		icon.new()
		:setLabel('Escape Artist')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, EscapeArtist.new());
		end),
		icon.new()
		:setLabel('Pestering Snow')
		:oneClick()
		:bindEvent('selected', function()
			updateCharacterModule(player, PesteringSnow.new());
		end),
		})
	end
return public