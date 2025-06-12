--!strict

-- Modules
local updateCharacterModule = game.ReplicatedStorage.Functions.UpdateCharacter
local types = require(game.ReplicatedStorage.Functions.Types)
local getCharacterData = require(game.ReplicatedStorage.Functions.GetCharacterData)
local playerCombatStateService = require(game.ServerScriptService.Services.PlayerCombatStateService)

-- Data Stores
local dataStoreService = game:GetService('DataStoreService')
local totalKillsDataStore = dataStoreService:GetDataStore('TotalKills')
local selectedCharacterDataStore = dataStoreService:GetDataStore('SelectedCharacter')

-- Remotes
local updateCharacterEvent = game.ReplicatedStorage.Events.UpdateCharacter

local private = {}
local public = {}

private.createLeaderstats = function(player : Player)
	local leaderStats = Instance.new('Folder', player)
	leaderStats.Name = 'leaderstats'
	local kills = Instance.new('IntValue', leaderStats)
	kills.Name = 'Kills'
	kills.Value = 0
	local totalKills = Instance.new('IntValue', leaderStats)
	totalKills.Name = 'Total Kills'
	totalKills.Value = 0
	local selectedCharacter = Instance.new('StringValue', player)
	selectedCharacter.Name = 'SelectedCharacter'
	selectedCharacter.Value = 'Guy'
end

private.retrieveDataStore = function(player : Player)
	private.createLeaderstats(player)
	local success, currentValue = pcall(function()
		local storedTotalKills = totalKillsDataStore:GetAsync(player.UserId)
		local storedSelectedCharacter = selectedCharacterDataStore:GetAsync(player.UserId)
		local leaderStats = player:FindFirstChild('leaderstats') :: Folder
		local selectedCharacter = player:FindFirstChild("SelectedCharacter") :: StringValue
		local totalKills = leaderStats:FindFirstChild('Total Kills') :: NumberValue
		if storedTotalKills then
			totalKills.Value = storedTotalKills
		end

		if storedSelectedCharacter then
			selectedCharacter.Value = storedSelectedCharacter
		end
	end)
end

private.saveDataStore = function(player : Player)
	local leaderStats = player:FindFirstChild('leaderstats') :: Folder
	local selectedCharacter = player:FindFirstChild("SelectedCharacter") :: StringValue
	local totalKills = leaderStats:FindFirstChild('Total Kills') :: NumberValue
	local success, errorMessage = pcall(function()
		totalKillsDataStore:SetAsync(player.UserId, totalKills.Value)
		selectedCharacterDataStore:SetAsync(player.UserId, selectedCharacter.Value)		
	end)
end

private.checkData = function(player : Player) : boolean
	local storedTotalKills = totalKillsDataStore:GetAsync(player.UserId)
	local storedSelectedCharacter = selectedCharacterDataStore:GetAsync(player.UserId)
	if storedTotalKills and storedSelectedCharacter then
		return true
	end
	return false
end

private.updatePlayerStats = function(player : Player, characterData)
	local character = player.Character :: Model
	local humanoid = character:FindFirstChild('Humanoid') :: Humanoid
	humanoid.Health = characterData.Super.Stats.Health
	humanoid.WalkSpeed = characterData.Super.Stats.WalkSpeed
end

private.updatePlayerAnimations = function(player : Player, characterData)
	local character = player.Character :: Model
	local animateScript = character:WaitForChild('Animate')
	local walkAnimation = animateScript:FindFirstChild('walk'):FindFirstChild('WalkAnim') :: Animation
	local runAnimation = animateScript:FindFirstChild('run'):FindFirstChild('RunAnim') :: Animation
	local jumpAnimation = animateScript:FindFirstChild('jump'):FindFirstChild('JumpAnim') :: Animation
	local fallAnimation = animateScript:FindFirstChild('fall'):FindFirstChild('FallAnim') :: Animation
	local idleAnimation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation1') :: Animation
	local idle2Animation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation2') :: Animation
	walkAnimation.AnimationId = characterData.Super.Animations.General[1].Walk.AnimationId
	runAnimation.AnimationId = characterData.Super.Animations.General[1].Walk.AnimationId
	jumpAnimation.AnimationId = characterData.Super.Animations.General[1].Jump.AnimationId
	fallAnimation.AnimationId = characterData.Super.Animations.General[1].Fall.AnimationId
	idleAnimation.AnimationId = characterData.Super.Animations.General[1].Idle.AnimationId
	idle2Animation.AnimationId = characterData.Super.Animations.General[1].Idle.AnimationId
end

private.startPlayer = function(player : Player)
	player.CharacterAdded:Connect(function()
		private.retrieveDataStore(player)
		local characterData = getCharacterData(player) 
		local character = player.Character :: Model
		local humanoid = character:FindFirstChild('Humanoid') :: Humanoid
		humanoid.Health = characterData.Super.Stats.Health
		humanoid.WalkSpeed = characterData.Super.Stats.WalkSpeed
		humanoid.JumpHeight = characterData.Super.Stats.JumpHeight
		private.updatePlayerAnimations(player, characterData)
		updateCharacterEvent:FireClient(player, characterData)
		playerCombatStateService.getState(player)
	end)
end

public.onStart = function()
	local data;
	updateCharacterEvent.OnServerEvent:Connect(function(player : Player, characterData)
		data = characterData;
		local selectedCharacter = player:FindFirstChild("SelectedCharacter") :: StringValue
		if selectedCharacter.Value ~= characterData.Super.Stats.Name then
			player:LoadCharacter()
			selectedCharacter.Value = characterData.Super.Stats.Name
			private.updatePlayerStats(player, characterData)
			private.updatePlayerAnimations(player, characterData)
			updateCharacterEvent:FireClient(player, characterData)
		end
	end)
	
	game.Players.PlayerAdded:Connect(private.startPlayer)
	game.Players.PlayerRemoving:Connect(private.saveDataStore);
end

public.getData = function(player : Player)
	if private.checkData(player) then
		return totalKillsDataStore:GetAsync(player.UserId), selectedCharacterDataStore:GetAsync(player.UserId)
	end
	return false
end

public.updateTotalKills = function(player : Player)
	local leaderStats = player:FindFirstChild('leaderstats') :: Folder
	local totalKills = leaderStats:FindFirstChild('Total Kills') :: NumberValue
	if not private.checkData(player) then
		return
	end
	totalKills.Value += 1
end

return public
