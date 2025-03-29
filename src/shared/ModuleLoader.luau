local isServer = game:GetService('RunService'):isServer()
local rootDirectory = if isServer then game.ServerScriptService else game.Players.LocalPlayer:WaitForChild("PlayerScripts")
local moduleDirectory = if isServer then rootDirectory.Services else rootDirectory:WaitForChild("Controllers")

local RequireModule = function(module: ModuleScript)
	if not module:IsA("ModuleScript") then
		return
	end
	
	local import = require(module)
	local onStart = import.onStart
	if onStart then task.spawn(onStart) end
end

return function()
	for _, descendant: ModuleScript in moduleDirectory:GetDescendants() do
		RequireModule(descendant)
	end

	if not isServer then
		moduleDirectory.DescendantAdded:Connect(function(descendant: ModuleScript)
			RequireModule(descendant)
		end)
	end
end