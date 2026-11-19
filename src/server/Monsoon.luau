-- BRAINROT BAZAAR monsoon: the warning, the darkening sky and the sweeping wave.
local Monsoon = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

-- A character is sheltered under a base roof or close to the lighthouse.
function Monsoon.sheltered(character)
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return false
	end
	local world = workspace:FindFirstChild("BazaarWorld")
	if world == nil then
		return false
	end
	local lighthouse = world:FindFirstChild("LighthouseShelter")
	if lighthouse ~= nil then
		local pivot = lighthouse:GetPivot().Position
		local dx = root.Position.X - pivot.X
		local dz = root.Position.Z - pivot.Z
		if math.sqrt(dx * dx + dz * dz) <= Config.ShelterRange then
			return true
		end
	end
	local bases = world:FindFirstChild("PlayerBases")
	if bases == nil then
		return false
	end
	for _, base in ipairs(bases:GetChildren()) do
		local roof = base:FindFirstChild("Roof")
		if roof ~= nil then
			local under = math.abs(root.Position.X - roof.Position.X) < 18 and math.abs(root.Position.Z - roof.Position.Z) < 15
			if under and root.Position.Y < roof.Position.Y then
				return true
			end
		end
	end
	return false
end

-- Darken the sky and count the warning down to every client. Returns the old ambient.
function Monsoon.warn(remote, seconds)
	local lighting = game:GetService("Lighting")
	local before = lighting.Ambient
	lighting.Ambient = Color3.fromRGB(70, 85, 110)
	remote:FireAllClients("Monsoon", seconds)
	for left = seconds, 1, -1 do
		remote:FireAllClients("MonsoonTick", left)
		task.wait(1)
	end
	return before
end

-- Sweep a neon wave across the map; unsheltered players are sent back to spawn.
function Monsoon.wave(root, players, remote, before)
	local surge = Instance.new("Part")
	surge.Name = "MonsoonWave"
	surge.Size = Vector3.new(280, 18, 34)
	surge.Anchored = true
	surge.CanCollide = false
	surge.Material = Enum.Material.Neon
	surge.Color = Color3.fromRGB(40, 200, 215)
	surge.Transparency = 0.18
	surge.Position = Vector3.new(0, 5, -95)
	surge.Parent = root
	remote:FireAllClients("Wave")
	for z = -95, 110, 5 do
		surge.Position = Vector3.new(0, 5, z)
		for _, player in ipairs(players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid ~= nil and rootPart ~= nil and rootPart.Position.Z <= z and not Monsoon.sheltered(character) then
				character:PivotTo(CFrame.new(0, 5, -5))
			end
		end
		task.wait(0.06)
	end
	surge:Destroy()
	game:GetService("Lighting").Ambient = before or Color3.fromRGB(160, 145, 130)
	remote:FireAllClients("MonsoonEnd")
end

return Monsoon
