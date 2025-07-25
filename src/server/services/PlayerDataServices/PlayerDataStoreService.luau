--!strict
local getSelectedCharacterFunction = require(game.ReplicatedStorage.Functions.GetSelectedCharacterFunction)

local private = {}
local public = {}

local dataStoreService = game:GetService('DataStoreService')
local totalKillsDataStore = dataStoreService:GetDataStore('TotalKills')
local selectedCharacterDataStore = dataStoreService:GetDataStore('SelectedCharacter')

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

public.onStart = function()
	game.Players.PlayerAdded:Connect(function(player: Player) private.retrieveDataStore(player) end)
	game.Players.PlayerRemoving:Connect(function(player: Player) private.saveDataStore(player) end)
end


return public
