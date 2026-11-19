-- BRAINROT BAZAAR world: the floating market, its docks, bases and landmarks.
local World = {}

local WOOD = Color3.fromRGB(116, 65, 38)
local TRIM = Color3.fromRGB(210, 117, 45)
local WATER = Color3.fromRGB(24, 150, 157)
local LEAF = Color3.fromRGB(52, 125, 76)

-- Make one instance, set its properties from a table, then parent it.
local function make(className, parent, props)
	local inst = Instance.new(className)
	for key, value in pairs(props) do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

-- One anchored wooden-style slab, smooth top and bottom.
local function slab(parent, name, size, at, color, material, seeThrough)
	return make("Part", parent, {
		Name = name,
		Size = size,
		Position = at,
		Anchored = true,
		Color = color,
		Material = material or Enum.Material.Wood,
		Transparency = seeThrough or 0,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	})
end

local function water(root)
	slab(root, "TealWater", Vector3.new(280, 2, 220), Vector3.new(0, -4, 0), WATER, Enum.Material.Glass, 0.12)
end

local function docks(root)
	local folder = make("Folder", root, { Name = "FloatingDocks" })
	slab(folder, "MainDock", Vector3.new(180, 2, 22), Vector3.new(0, 0, 0), WOOD)
	slab(folder, "NorthBridge", Vector3.new(18, 2, 95), Vector3.new(0, 0, 55), WOOD)
	slab(folder, "EastBridge", Vector3.new(64, 2, 12), Vector3.new(85, 0, 40), WOOD)
	slab(folder, "WestBridge", Vector3.new(64, 2, 12), Vector3.new(-85, 0, 40), WOOD)
	for x = -80, 80, 20 do
		slab(folder, "DockPost_" .. x, Vector3.new(2, 12, 2), Vector3.new(x, -4, 0), TRIM)
	end
	make("SpawnLocation", root, {
		Name = "DockSpawn",
		Position = Vector3.new(0, 4, -5),
		Size = Vector3.new(12, 1, 8),
		Anchored = true,
		Neutral = true,
		Color = TRIM,
	})
end

local function stalls(root)
	local folder = make("Folder", root, { Name = "MarketStalls" })
	for i = 1, 4 do
		local x = (i - 2.5) * 42
		local stall = make("Model", folder, { Name = "MarketStall_" .. i })
		slab(stall, "Counter", Vector3.new(28, 3, 10), Vector3.new(x, 3, 32), WOOD)
		slab(stall, "Roof", Vector3.new(30, 1, 14), Vector3.new(x, 15, 32), TRIM)
		slab(stall, "PostL", Vector3.new(1, 14, 1), Vector3.new(x - 13, 9, 27), WOOD)
		slab(stall, "PostR", Vector3.new(1, 14, 1), Vector3.new(x + 13, 9, 27), WOOD)
	end
end

local function bases(root)
	local folder = make("Folder", root, { Name = "PlayerBases" })
	for i = 1, 8 do
		local x = ((i - 1) % 4 - 1.5) * 42
		local z = 78 + math.floor((i - 1) / 4) * 38
		local base = make("Model", folder, { Name = "Base_" .. i })
		base:SetAttribute("BaseIndex", i)
		slab(base, "BaseFloor", Vector3.new(38, 1, 32), Vector3.new(x, 1, z), WOOD)
		for slot = 1, 8 do
			local px = x + ((slot - 1) % 4 - 1.5) * 8
			local pz = z + (math.floor((slot - 1) / 4) - 0.5) * 11
			slab(base, "Pedestal_" .. slot, Vector3.new(4, 2, 4), Vector3.new(px, 3, pz), TRIM)
		end
		slab(base, "Roof", Vector3.new(39, 1, 33), Vector3.new(x, 15, z), TRIM)
		slab(base, "Sign", Vector3.new(12, 3, 1), Vector3.new(x, 10, z - 15), Color3.fromRGB(241, 213, 130))
	end
end

local function belt(root)
	slab(root, "BrainrotConveyor", Vector3.new(130, 1, 7), Vector3.new(0, 5, 51), Color3.fromRGB(52, 52, 60), Enum.Material.Metal)
	for x = -60, 60, 12 do
		slab(root, "ConveyorStripe_" .. x, Vector3.new(2, 0.2, 7), Vector3.new(x, 5.6, 51), TRIM, Enum.Material.Neon)
	end
end

local function beacon(root)
	local tower = make("Model", root, { Name = "LighthouseShelter" })
	slab(tower, "Tower", Vector3.new(12, 30, 12), Vector3.new(112, 13, 76), Color3.fromRGB(238, 238, 221), Enum.Material.Concrete)
	slab(tower, "Beacon", Vector3.new(15, 4, 15), Vector3.new(112, 30, 76), Color3.fromRGB(255, 198, 64), Enum.Material.Neon)
	slab(tower, "LighthouseRoof", Vector3.new(16, 2, 16), Vector3.new(112, 33, 76), TRIM)
	tower:SetAttribute("Shelter", true)
end

local function lights(root)
	local folder = make("Folder", root, { Name = "Lanterns" })
	for i = -4, 4 do
		local lamp = slab(folder, "Lantern_" .. i, Vector3.new(2, 3, 2), Vector3.new(i * 20, 10, 18), Color3.fromRGB(255, 90, 30), Enum.Material.Neon)
		make("PointLight", lamp, {
			Color = Color3.fromRGB(255, 120, 50),
			Range = 24,
			Brightness = 1.5,
		})
	end
end

local function boats(root)
	local folder = make("Folder", root, { Name = "Boats" })
	for i = 1, 3 do
		local x = -95 + i * 45
		slab(folder, "BoatHull_" .. i, Vector3.new(22, 3, 7), Vector3.new(x, -1, -32), WOOD)
		slab(folder, "BoatMast_" .. i, Vector3.new(1, 14, 1), Vector3.new(x, 6, -32), TRIM)
		slab(folder, "BoatSail_" .. i, Vector3.new(1, 8, 8), Vector3.new(x + 3, 8, -32), Color3.fromRGB(235, 220, 180))
	end
end

local function palms(root)
	local folder = make("Folder", root, { Name = "PalmTrees" })
	for i = 1, 6 do
		local x = -115 + (i % 3) * 115
		local z = 20 + math.floor(i / 3) * 70
		slab(folder, "PalmTrunk_" .. i, Vector3.new(2, 18, 2), Vector3.new(x, 8, z), Color3.fromRGB(107, 72, 36))
		for leaf = 1, 4 do
			local angle = leaf * math.pi / 2
			slab(folder, "PalmLeaf_" .. i .. "_" .. leaf, Vector3.new(1, 1, 12), Vector3.new(x + math.cos(angle) * 4, 18, z + math.sin(angle) * 4), LEAF)
		end
	end
end

-- Build the whole market fresh under Workspace, replacing any earlier one.
function World.assemble()
	local old = workspace:FindFirstChild("BazaarWorld")
	if old then
		old:Destroy()
	end
	local root = make("Folder", workspace, { Name = "BazaarWorld" })
	water(root)
	docks(root)
	stalls(root)
	bases(root)
	belt(root)
	beacon(root)
	lights(root)
	boats(root)
	palms(root)
	return root
end

return World
