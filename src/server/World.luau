local World = {}

local function part(parent, name, size, position, color, material, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.Wood
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local wood = Color3.fromRGB(116, 65, 38)
local trim = Color3.fromRGB(210, 117, 45)
local water = Color3.fromRGB(24, 150, 157)
local grass = Color3.fromRGB(52, 125, 76)

function World.buildWater(root)
	return part(root, "TealWater", Vector3.new(280, 2, 220), Vector3.new(0, -4, 0), water, Enum.Material.Glass, 0.12)
end

function World.buildDocks(root)
	local dock = Instance.new("Folder")
	dock.Name = "FloatingDocks"
	dock.Parent = root
	part(dock, "MainDock", Vector3.new(180, 2, 22), Vector3.new(0, 0, 0), wood)
	part(dock, "NorthBridge", Vector3.new(18, 2, 95), Vector3.new(0, 0, 55), wood)
	part(dock, "EastBridge", Vector3.new(64, 2, 12), Vector3.new(85, 0, 40), wood)
	part(dock, "WestBridge", Vector3.new(64, 2, 12), Vector3.new(-85, 0, 40), wood)
	for x = -80, 80, 20 do
		part(dock, "DockPost_" .. x, Vector3.new(2, 12, 2), Vector3.new(x, -4, 0), trim)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "DockSpawn"
	spawn.Position = Vector3.new(0, 4, -5)
	spawn.Size = Vector3.new(12, 1, 8)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = trim
	spawn.Parent = root
	return dock
end

function World.buildStalls(root)
	local stalls = Instance.new("Folder")
	stalls.Name = "MarketStalls"
	stalls.Parent = root
	for i = 1, 4 do
		local x = (i - 2.5) * 42
		local stall = Instance.new("Model")
		stall.Name = "MarketStall_" .. i
		stall.Parent = stalls
		part(stall, "Counter", Vector3.new(28, 3, 10), Vector3.new(x, 3, 32), wood)
		part(stall, "Roof", Vector3.new(30, 1, 14), Vector3.new(x, 15, 32), trim)
		part(stall, "PostL", Vector3.new(1, 14, 1), Vector3.new(x - 13, 9, 27), wood)
		part(stall, "PostR", Vector3.new(1, 14, 1), Vector3.new(x + 13, 9, 27), wood)
	end
	return stalls
end

function World.buildPedestals(root)
	local bases = Instance.new("Folder")
	bases.Name = "PlayerBases"
	bases.Parent = root
	for i = 1, 8 do
		local x = ((i - 1) % 4 - 1.5) * 42
		local z = 78 + math.floor((i - 1) / 4) * 38
		local base = Instance.new("Model")
		base.Name = "Base_" .. i
		base:SetAttribute("BaseIndex", i)
		base.Parent = bases
		part(base, "BaseFloor", Vector3.new(38, 1, 32), Vector3.new(x, 1, z), wood)
		for slot = 1, 8 do
			local px = x + ((slot - 1) % 4 - 1.5) * 8
			local pz = z + (math.floor((slot - 1) / 4) - 0.5) * 11
			part(base, "Pedestal_" .. slot, Vector3.new(4, 2, 4), Vector3.new(px, 3, pz), trim)
		end
		part(base, "Roof", Vector3.new(39, 1, 33), Vector3.new(x, 15, z), trim)
		part(base, "Sign", Vector3.new(12, 3, 1), Vector3.new(x, 10, z - 15), Color3.fromRGB(241, 213, 130))
	end
	return bases
end

function World.buildConveyor(root)
	local belt = part(root, "BrainrotConveyor", Vector3.new(130, 1, 7), Vector3.new(0, 5, 51), Color3.fromRGB(52, 52, 60), Enum.Material.Metal)
	for x = -60, 60, 12 do
		part(root, "ConveyorStripe_" .. x, Vector3.new(2, 0.2, 7), Vector3.new(x, 5.6, 51), trim, Enum.Material.Neon)
	end
	return belt
end

function World.buildLighthouse(root)
	local tower = Instance.new("Model")
	tower.Name = "LighthouseShelter"
	tower.Parent = root
	part(tower, "Tower", Vector3.new(12, 30, 12), Vector3.new(112, 13, 76), Color3.fromRGB(238, 238, 221), Enum.Material.Concrete)
	part(tower, "Beacon", Vector3.new(15, 4, 15), Vector3.new(112, 30, 76), Color3.fromRGB(255, 198, 64), Enum.Material.Neon)
	part(tower, "LighthouseRoof", Vector3.new(16, 2, 16), Vector3.new(112, 33, 76), trim)
	tower:SetAttribute("Shelter", true)
	return tower
end

function World.buildLanterns(root)
	local lanterns = Instance.new("Folder")
	lanterns.Name = "Lanterns"
	lanterns.Parent = root
	for i = -4, 4 do
		local light = part(lanterns, "Lantern_" .. i, Vector3.new(2, 3, 2), Vector3.new(i * 20, 10, 18), Color3.fromRGB(255, 90, 30), Enum.Material.Neon)
		local point = Instance.new("PointLight")
		point.Color = Color3.fromRGB(255, 120, 50)
		point.Range = 24
		point.Brightness = 1.5
		point.Parent = light
	end
	return lanterns
end

function World.buildBoats(root)
	local boats = Instance.new("Folder")
	boats.Name = "Boats"
	boats.Parent = root
	for i = 1, 3 do
		local x = -95 + i * 45
		part(boats, "BoatHull_" .. i, Vector3.new(22, 3, 7), Vector3.new(x, -1, -32), wood)
		part(boats, "BoatMast_" .. i, Vector3.new(1, 14, 1), Vector3.new(x, 6, -32), trim)
		part(boats, "BoatSail_" .. i, Vector3.new(1, 8, 8), Vector3.new(x + 3, 8, -32), Color3.fromRGB(235, 220, 180))
	end
	return boats
end

function World.buildPalms(root)
	local palms = Instance.new("Folder")
	palms.Name = "PalmTrees"
	palms.Parent = root
	for i = 1, 6 do
		local x = -115 + (i % 3) * 115
		local z = 20 + math.floor(i / 3) * 70
		part(palms, "PalmTrunk_" .. i, Vector3.new(2, 18, 2), Vector3.new(x, 8, z), Color3.fromRGB(107, 72, 36))
		for leaf = 1, 4 do
			local angle = leaf * math.pi / 2
			part(palms, "PalmLeaf_" .. i .. "_" .. leaf, Vector3.new(1, 1, 12), Vector3.new(x + math.cos(angle) * 4, 18, z + math.sin(angle) * 4), grass)
		end
	end
	return palms
end

function World.Build()
	local old = workspace:FindFirstChild("BazaarWorld")
	if old then old:Destroy() end
	local root = Instance.new("Folder")
	root.Name = "BazaarWorld"
	root.Parent = workspace
	World.buildWater(root)
	World.buildDocks(root)
	World.buildStalls(root)
	World.buildPedestals(root)
	World.buildConveyor(root)
	World.buildLighthouse(root)
	World.buildLanterns(root)
	World.buildBoats(root)
	World.buildPalms(root)
	return root
end

return World
