--!strict

local tweenService = game:GetService('TweenService')
local updateCharacterEvent = game.ReplicatedStorage.RemoteEvents.UpdateCharacter

local private = {}
local public = {}

local player : Player = game.Players.LocalPlayer 
local playerGui : Instance = player:WaitForChild("PlayerGui")

private.updatePlayerGUI = function(characterName)
	local UI = playerGui:FindFirstChild('CombatUI')
	local MoveBar = UI:FindFirstChild("Main"):FindFirstChild("Moveset")
	local Move1 = MoveBar:FindFirstChild("Move1") :: TextLabel
	local Move2 = MoveBar:FindFirstChild("Move2") :: TextLabel
	local Move3 = MoveBar:FindFirstChild("Move3") :: TextLabel
	local Move4 = MoveBar:FindFirstChild("Move4") :: TextLabel
	local Awaken = MoveBar:FindFirstChild('Ultimate') :: ImageButton
	
	--Move1.Text = specials[1].Name
	--Move2.Text = specials[2].Name
	--Move3.Text = specials[3].Name
	--Move4.Text = specials[4].Name
	
	-- this is the one we're supposed to use when we actually have individualized images
	--Awaken = characterData.Awakening.Image
	
	-- we're doing THIS for now
	Awaken.Image = "rbxassetid://7612501101"

end

public.cooldown = function(specialNumber : number, duration : number)
	local UI = playerGui:FindFirstChild('CombatUI')
	local MoveBar = UI:FindFirstChild("Main"):FindFirstChild("Moveset")
	local Move = MoveBar:FindFirstChild("Move"..specialNumber)
	local cooldownFrame = Move:FindFirstChild('Frame') :: Frame
	
	cooldownFrame.Size = UDim2.new(0, 60, 0, 50)
	local goalSize = UDim2.new(0, 60, 0, 0)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = tweenService:Create(cooldownFrame, tweenInfo, {Size = goalSize})
	tween:Play()
	
	tween.Completed:Once(function()
		cooldownFrame.Size = UDim2.new()
	end)
end

public.onStart = function()
	updateCharacterEvent.OnClientEvent:Connect(function(characterName)
		private.updatePlayerGUI(characterName)
	end)
end

return public

