--!strict

-- Modules
local types = require(game.ReplicatedStorage.Functions.Types)
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)
local animationFunction = require(game.ReplicatedStorage.Functions.AnimationFunction)
local playerCombatStateFunction = require(game.ReplicatedStorage.Functions.PlayerStateFunction)

-- Data Stores
local dataStoreService = game:GetService('DataStoreService')
local totalKillsDataStore = dataStoreService:GetDataStore('TotalKills')
local selectedCharacterDataStore = dataStoreService:GetDataStore('SelectedCharacter')

-- Remotes
local updateCharacterEvent = game.ReplicatedStorage.RemoteEvents.UpdateCharacter

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
		local selectedCharacter = player:FindFirstChild('SelectedCharacter') :: StringValue
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
	local selectedCharacter = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local totalKills = leaderStats:FindFirstChild('Total Kills') :: NumberValue
	local success, errorMessage = pcall(function()
		totalKillsDataStore:SetAsync(player.UserId, totalKills.Value)
		selectedCharacterDataStore:SetAsync(player.UserId, selectedCharacter)		
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

private.updatePlayerAnimations = function(player : Player)
	local character = player.Character :: Model
	local animateScript = character:WaitForChild('Animate')
	local walkAnimation = animateScript:FindFirstChild('walk'):FindFirstChild('WalkAnim') :: Animation
	local runAnimation = animateScript:FindFirstChild('run'):FindFirstChild('RunAnim') :: Animation
	local jumpAnimation = animateScript:FindFirstChild('jump'):FindFirstChild('JumpAnim') :: Animation
	local fallAnimation = animateScript:FindFirstChild('fall'):FindFirstChild('FallAnim') :: Animation
	local idleAnimation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation1') :: Animation
	local idle2Animation = animateScript:FindFirstChild('idle'):FindFirstChild('Animation2') :: Animation

	local selectedCharacterName = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
	local selectedCharacterAnimationFolder = getSelectedCharacterFunction.getSelectedCharacterAnimationFolder(player) :: Folder
	local selectedCharacterGeneralAnimationFolder = selectedCharacterAnimationFolder:FindFirstChild('General') :: Folder
	local selectedCharacterWalkAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Walk') :: Animation
	local selectedCharacterIdleAnimation = selectedCharacterGeneralAnimationFolder:FindFirstChild('Idle') :: Animation

	walkAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	runAnimation.AnimationId = selectedCharacterWalkAnimation.AnimationId
	jumpAnimation.AnimationId = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.Other.Jump.AnimationId
	fallAnimation.AnimationId = game.ReplicatedStorage.CharacterData.Animations.UniversalAnimations.Other.Fall.AnimationId
	idleAnimation.AnimationId = selectedCharacterIdleAnimation.AnimationId
	idle2Animation.AnimationId = selectedCharacterIdleAnimation.AnimationId
end

private.startPlayer = function(player : Player, characterName : types.characterName)
	player.CharacterAdded:Connect(function()
		private.retrieveDataStore(player)
		local character = player.Character or player.CharacterAdded:Wait() :: Model
		local humanoid = character:WaitForChild('Humanoid') :: Humanoid
		humanoid.Health = 100
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		private.updatePlayerAnimations(player)
	end)
end

public.onStart = function()
	updateCharacterEvent.OnServerEvent:Connect(function(player : Player, characterName : types.characterName)
		local selectedCharacter = getSelectedCharacterFunction.getSelectedCharacterName(player) :: string
		if selectedCharacter ~= characterName then
			player:LoadCharacter()
			selectedCharacter = characterName
			private.updatePlayerAnimations(player)
			updateCharacterEvent:FireClient(player, characterName)
		end
	end)

	game.Players.PlayerAdded:Connect(private.startPlayer)
	game.Players.PlayerRemoving:Connect(private.saveDataStore)
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
