-- Monsoon.luau — the storm cycle. A 30-second warning darkens the sky,
-- then a neon wave sweeps the map and carries unsheltered players back
-- to spawn. Shelter is a base roof or the lighthouse.

local Config = require(script.Parent.Parent.Shared.Config)

local Monsoon = {}

local DARK_AMBIENT = Color3.fromRGB(38, 38, 51)

function Monsoon.IsSheltered(character, bases, lighthousePosition)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return true
	end
	local pos = root.Position
	for _, base in ipairs(bases) do
		local dx = math.abs(pos.X - base.Center.X)
		local dz = math.abs(pos.Z - base.Center.Z)
		if dx < 18 and dz < 15 then
			return true
		end
	end
	local lx = pos.X - lighthousePosition.X
	local lz = pos.Z - lighthousePosition.Z
	if math.sqrt(lx * lx + lz * lz) <= Config.ShelterRange then
		return true
	end
	return false
end

local function sweepWave(wave, fromZ, toZ, seconds)
	local steps = math.max(1, math.floor(seconds / 0.05))
	for step = 1, steps do
		local alpha = step / steps
		local z = fromZ + (toZ - fromZ) * alpha
		wave.CFrame = CFrame.new(0, 10, z)
		task.wait(0.05)
	end
end

-- noticeEvent: RemoteEvent fired to all clients with a text message.
-- players: array of Player objects currently in the game.
function Monsoon.Run(noticeEvent, bases, lighthousePosition, players, spawnPosition)
	task.spawn(function()
		local lighting = game:GetService("Lighting")
		local savedAmbient = lighting.Ambient
		lighting.Ambient = DARK_AMBIENT
		noticeEvent:FireAllClients("MONSOON INCOMING - TAKE SHELTER! (30s)")
		task.wait(Config.MonsoonWarning)
		local wave = Instance.new("Part")
		wave.Name = "MonsoonWave"
		wave.Shape = Enum.PartType.Block
		wave.Size = Vector3.new(300, 22, 12)
		wave.Position = Vector3.new(0, 10, -95)
		wave.Color = Color3.fromRGB(60, 200, 255)
		wave.Material = Enum.Material.Neon
		wave.Transparency = 0.35
		wave.Anchored = true
		wave.CanCollide = false
		wave.Parent = workspace
		sweepWave(wave, -95, 0, 4)
		for _, player in ipairs(players) do
			local character = player.Character
			if character and not Monsoon.IsSheltered(character, bases, lighthousePosition) then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					root.CFrame = CFrame.new(spawnPosition)
					noticeEvent:FireClient(player, "Swept away by the monsoon!")
				end
			end
		end
		sweepWave(wave, 0, 110, 4)
		wave:Destroy()
		lighting.Ambient = savedAmbient
		noticeEvent:FireAllClients("The monsoon has passed.")
	end)
end

return Monsoon
