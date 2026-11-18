local Monsoon = {}

function Monsoon.isInShelter(character)
	if not character then return false end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local world = workspace:FindFirstChild("BazaarWorld")
	if not world then return false end
	local lighthouse = world:FindFirstChild("LighthouseShelter")
	if lighthouse and (root.Position - lighthouse:GetPivot().Position).Magnitude <= 20 then return true end
	for _, base in ipairs(world:FindFirstChild("PlayerBases"):GetChildren()) do
		local roof = base:FindFirstChild("Roof")
		if roof and math.abs(root.Position.X - roof.Position.X) < 9 and math.abs(root.Position.Z - roof.Position.Z) < 8 and root.Position.Y < roof.Position.Y then
			return true
		end
	end
	return false
end

function Monsoon.startWarning(remote, duration)
	local lighting = game:GetService("Lighting")
	local oldAmbient = lighting.Ambient
	lighting.Ambient = Color3.fromRGB(70, 85, 110)
	remote:FireAllClients("Monsoon", duration)
	for remaining = duration, 1, -1 do
		remote:FireAllClients("MonsoonTick", remaining)
		task.wait(1)
	end
	return oldAmbient
end

function Monsoon.sweepWave(root, players, remote, oldAmbient)
	local wave = Instance.new("Part")
	wave.Name = "MonsoonWave"
	wave.Size = Vector3.new(280, 18, 34)
	wave.Anchored = true
	wave.CanCollide = false
	wave.Material = Enum.Material.Neon
	wave.Color = Color3.fromRGB(40, 200, 215)
	wave.Transparency = 0.18
	wave.Position = Vector3.new(0, 5, -95)
	wave.Parent = root
	remote:FireAllClients("Wave")
	for z = -95, 110, 5 do
		wave.Position = Vector3.new(0, 5, z)
		for _, player in ipairs(players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid and rootPart and rootPart.Position.Z <= z and not Monsoon.isInShelter(character) then
				character:PivotTo(CFrame.new(0, 5, -5))
			end
		end
		task.wait(0.06)
	end
	wave:Destroy()
	game:GetService("Lighting").Ambient = oldAmbient or Color3.fromRGB(160, 145, 130)
	remote:FireAllClients("MonsoonEnd")
end

return Monsoon
