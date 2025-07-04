--!strict
local ragdollData = require(game.ReplicatedStorage.Functions.Offsets)
local npcService = require(game.ServerScriptService.Services.NPCService)
local ragdollEvent = game.ReplicatedStorage.RemoteEvents.RagdollEvent

local private = {}
local public = {}

private.ragdollTimers = {}

private.buildCollisionParts = function(character : Model)
	for _, v in pairs(character:GetChildren()) do
		if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then
			local part = v:Clone()
			part.Name = 'Collide'
			part.Parent = v
			part.Transparency = 1
			part.Size = Vector3.one
			part.CanCollide = true
			part.Massless = true
			part.Anchored = false
			part:ClearAllChildren()
			local weld = Instance.new('Weld')
			weld.Part0 = v
			weld.Part1 = part
			weld.Parent = part
		end
	end
end


private.enableCollisionPoints = function(character : Model, enabled : boolean)
	for i, v in pairs(character:GetChildren()) do
		if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then
			v.CanCollide = enabled
		end
	end
end

private.setupHumanoid = function(humanoid : Humanoid)
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
end

private.enableMotor6D = function(character : Model, enabled : boolean)
	for i, v in pairs(character:GetDescendants()) do
		if v.Name == 'Handle' or v.Name == 'RootJoint' or v.Name == 'Neck' then continue end
		if v:IsA('Motor6D') then v.Enabled = enabled end
		if v:IsA('BasePart') then v.CollisionGroup = if enabled then 'Character' else 'Ragdoll' end
	end
end

private.buildJoints = function(character : Model)
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
	for i, v in pairs(character:GetDescendants()) do
		if not v:IsA('BasePart') or v:FindFirstAncestorOfClass('Accessory') or v.Name == 'Handle' or v.Name == 'Torso' or v.Name == 'HumanoidRootPart' or v.Name == 'Collide' then continue end
		local attachment0 : Attachment, attachment1 : Attachment = Instance.new('Attachment'), Instance.new('Attachment')
		local joint : Constraint = Instance.new('BallSocketConstraint')
		attachment0.Name = 'RagdollAttachment'
		attachment0.Parent = v
		attachment0.CFrame = ragdollData[v.Name].CFrame[2]
		attachment1.Name = 'RagdollAttachment'
		attachment1.Parent = humanoidRootPart
		attachment1.CFrame = ragdollData[v.Name].CFrame[1]
		joint.Name = 'RagdollConstraint'
		joint.Parent = v
		joint.Attachment0 = attachment0
		joint.Attachment1 = attachment1	
		v.Massless = true
	end
end

private.destroyJoints = function(character : Model)
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	humanoidRootPart.Massless = false
	for i, v in pairs(character:GetDescendants()) do
		if v.Name == 'RagdollAttachment' or v.Name == 'RagdollConstraint' then v:Destroy() end
		if not v:IsA('BasePart') or v:FindFirstAncestorOfClass('Accessory') or v.Name == 'Torso' or v.Name == 'HumanoidRootPart' then continue end
	end
end

public.unragdollCharacter = function(character : Model)
	local player : Player = game.Players:GetPlayerFromCharacter(character)
	local humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	
	if player then
		ragdollEvent:FireClient('unragdoll')
	else
		humanoidRootPart:SetNetworkOwner(nil)
		if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
		humanoid.PlatformStand = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
	private.destroyJoints(character)
	private.enableMotor6D(character, true)
	private.enableCollisionPoints(character, false)
end

public.ragdollCharacter = function(character : Model, duration : number?)
	local player : Player = game.Players:GetPlayerFromCharacter(character)
	local humanoid : Humanoid = character:FindFirstChildOfClass('Humanoid') :: Humanoid
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	if not humanoidRootPart then return end
	private.enableMotor6D(character, false)
	private.buildJoints(character)
	private.enableCollisionPoints(character, true)
	if player then
		ragdollEvent:FireClient('ragdoll')
	else
		humanoidRootPart:SetNetworkOwner(nil)
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
	end
	if not duration then return end
	if private.ragdollTimers[character] then coroutine.close(private.ragdollTimers[character]) end
	private.ragdollTimers[character] = coroutine.create(function()
		task.wait(duration)
		public.unragdollCharacter(character)
	end)
	coroutine.resume(private.ragdollTimers[character])
end

public.onStart = function()
	for i, v in pairs(npcService.detectNPCs()) do
		local humanoid = v:WaitForChild('Humanoid') :: Humanoid
		private.setupHumanoid(humanoid)
		private.buildCollisionParts(v)
	end
	
	game.Players.PlayerAdded:Connect(function(player : Player)
		player.CharacterAdded:Connect(function(character : Model)
			local humanoid = character:WaitForChild('Humanoid') :: Humanoid
			private.setupHumanoid(humanoid)
			private.buildCollisionParts(character)
		end)
	end)
	
	ragdollEvent.OnServerEvent:Connect(function(player : Player, character : Model, duration : number?)
		public.ragdollCharacter(character, duration)
	end)
end

return public