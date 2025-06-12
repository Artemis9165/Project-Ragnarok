--!strict
local updateCharacterEvent = game.ReplicatedStorage.Events.UpdateCharacter
local tweenService = game:GetService('TweenService')

local player : Player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character: Model

local private = {}
local public = {}

private.updatePlayerGUI = function(characterData)
	local hotbarFrame = playerGui:FindFirstChild('Hotbar'):GetChildren()[1]:GetChildren()
	local awakenBar;
	--awakenBar = playerGui:FindFirstChild('Awaken'):FindFirstChild('Bar')
	local specials = characterData.Specials.Regular
	local textLabel1 = hotbarFrame[1] :: TextLabel
	local textLabel2 = hotbarFrame[2] :: TextLabel
	local textLabel3 = hotbarFrame[3] :: TextLabel
	local textLabel4 = hotbarFrame[4] :: TextLabel
	--local awakenShadow = awakenBar:FindFirstChild('AwakenShadow') :: TextLabel
	--local awakenText = awakenShadow:GetChildren()[1] :: TextLabel
	--textLabel1.Text = specials.Special1[1].Name
	--textLabel2.Text = specials.Special2[1].Name
	--textLabel3.Text = specials.Special3[1].Name
	--textLabel4.Text = specials.Special4[1].Name
	--Hard CODE
	textLabel1.Text = specials[1].Name
	textLabel2.Text = specials[2].Name
	textLabel3.Text = specials[3].Name
	textLabel4.Text = specials[4].Name
	--awakenShadow.Text = characterData.Awakening.Name
	--awakenText.Text = characterData.Awakening.Name
end

public.cooldown = function(specialNumber : number, duration : number)
	local hotbarFrame = playerGui:FindFirstChild('Hotbar'):GetChildren()[1]:GetChildren()
	local label = hotbarFrame[specialNumber]
	local cooldownFrame = label:FindFirstChild('Special'..specialNumber..'CoolDown') :: Frame
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
	player.CharacterAdded:Connect(function()
		character = player.Character or player.CharacterAdded:Wait()
	end)
	updateCharacterEvent.OnClientEvent:Connect(function(characterData)
		private.updatePlayerGUI(characterData)
	end)
end

return public
