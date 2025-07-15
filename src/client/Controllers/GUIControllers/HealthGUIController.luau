--!strict
--Change the player's health color when they are low

local public = {}
local private = {}

private.healthBarChange = function(player : Player, humanoid : Humanoid)
	local playerGui = player:WaitForChild('PlayerGui')
	local combatUI = playerGui:WaitForChild('CombatUI')
	local base = combatUI:WaitForChild('Health') :: Frame --The maximum size of the bar
	local bar = base:WaitForChild('Bar') :: Frame --The percentage of health the player has remaining
	local measure = base:WaitForChild('Measure') :: TextLabel --The color part of the bar, shows the ratio of health the player has
	local health = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	bar.Size = UDim2.new(health/maxHealth, 0, 1, 0)
	measure.Text = math.round(health/maxHealth*100).."%"
end

public.onStart = function()
	local player : Player = game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait() :: Model
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.Changed:Connect(function(stateChanged)
		if stateChanged == 'Health' then
			private.healthBarChange(player, humanoid)
		end
	end)
end

return public