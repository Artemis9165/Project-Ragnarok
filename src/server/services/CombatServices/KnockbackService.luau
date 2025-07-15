--!strict
local knockbackEvent = game.ReplicatedStorage.RemoteEvents.CombatEvents.KnockbackEvent
local private = {}
local public = {}

public.knockback = function(character : Model, isNPC : boolean, direction : Vector3, amplifier : number)
	local humanoidRootPart = character:FindFirstChild('HumanoidRootPart') :: BasePart
	if not isNPC then
		humanoidRootPart:SetNetworkOwner(nil) 
		task.delay(0.1, function()
			local player = game.Players:GetPlayerFromCharacter(character)
			humanoidRootPart:SetNetworkOwner(player)
		end)
	end
	local velocity = math.sqrt(196.2 * amplifier) * (direction + Vector3.new(0, .5, 0)).Unit * 2
	humanoidRootPart.AssemblyLinearVelocity = velocity
	humanoidRootPart.AssemblyAngularVelocity = Vector3.new(100, 0, 0)
end

public.onStart = function()
	knockbackEvent.OnServerEvent:Connect(function(player : Player, character : Model, isNPC : boolean, direction : Vector3, amplifier : number)
		public.knockback(character, isNPC, direction, amplifier)
	end)
end

return public