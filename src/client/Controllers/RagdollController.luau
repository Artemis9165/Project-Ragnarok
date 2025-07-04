local ragdollEvent = game.ReplicatedStorage.RemoteEvents.RagdollEvent

local public = {}

public.onStart = function()
	ragdollEvent.OnClientEvent:Connect(function(type : string, humanoid : Humanoid)
		if type == 'ragdoll' then
			humanoid.AutoRotate = false
			humanoid.PlatformStand = true
		elseif type == 'unragdoll' then
			if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
			humanoid.PlatformStand = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

return public