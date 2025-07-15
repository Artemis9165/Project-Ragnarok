--!strict

local cameraEvent = game.ReplicatedStorage.RemoteEvents.CameraEvent

local private = {}
local public = {}

public.onStart = function()
	local camera : Camera = workspace.CurrentCamera
	cameraEvent.OnClientEvent:Connect(function(player : Player) cameraEvent:FireServer(camera.CFrame.LookVector) end)
end

return public