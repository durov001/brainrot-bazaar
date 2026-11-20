-- World.luau — builds the floating market: water, docks, stalls, bases,
-- conveyor, lighthouse, lanterns, boats and palms, all from PartKit.

local Config = require(script.Parent.Parent.Shared.Config)
local PartKit = require(script.Parent.Parent.Shared.PartKit)

local World = {}

local WOOD = Color3.fromRGB(140, 95, 55)
local WOOD_DARK = Color3.fromRGB(105, 70, 40)
local TEAL = Color3.fromRGB(24, 150, 157)
local NEON_RED = Color3.fromRGB(255, 80, 50)
local NEON_CYAN = Color3.fromRGB(60, 220, 255)
local LEAF = Color3.fromRGB(50, 150, 70)
local TRUNK = Color3.fromRGB(110, 75, 40)
local ROOF_RED = Color3.fromRGB(180, 50, 45)

local function buildWater(folder)
	local water = PartKit.Box(folder, Config.WaterSize, Config.WaterPosition, TEAL, Enum.Material.Glass)
	water.Name = "Sea"
	water.Transparency = 0.25
end

local function buildDock(folder)
	PartKit.Box(folder, Config.DockSize, Config.DockPosition, WOOD, Enum.Material.WoodPlanks).Name = "MainDock"
	local bridges = {
		{ size = Vector3.new(10, 2, 40), pos = Vector3.new(-60, 0, -30) },
		{ size = Vector3.new(10, 2, 40), pos = Vector3.new(60, 0, -30) },
		{ size = Vector3.new(10, 2, 40), pos = Vector3.new(0, 0, 32) },
	}
	for i, bridge in ipairs(bridges) do
		local part = PartKit.Box(folder, bridge.size, bridge.pos, WOOD_DARK, Enum.Material.WoodPlanks)
		part.Name = "Bridge" .. i
	end
	for x = -85, 85, 17 do
		PartKit.Cylinder(folder, 6, 1.2, Vector3.new(x, -2, -12), WOOD_DARK, Enum.Material.Wood).Name = "Post"
		PartKit.Cylinder(folder, 6, 1.2, Vector3.new(x, -2, 12), WOOD_DARK, Enum.Material.Wood).Name = "Post"
	end
end

local function buildStall(folder, position, index)
	local stall = Instance.new("Folder")
	stall.Name = "Stall" .. index
	stall.Parent = folder
	local counter = PartKit.Box(stall, Vector3.new(8, 3, 4), position + Vector3.new(0, 1.5, 0), WOOD, Enum.Material.WoodPlanks)
	counter.Name = "Counter"
	PartKit.Cylinder(stall, 7, 0.6, position + Vector3.new(-3.5, 5, -1.5), WOOD_DARK, Enum.Material.Wood).Name = "PostL"
	PartKit.Cylinder(stall, 7, 0.6, position + Vector3.new(3.5, 5, -1.5), WOOD_DARK, Enum.Material.Wood).Name = "PostR"
	local roof = PartKit.Box(stall, Vector3.new(10, 0.6, 6), position + Vector3.new(0, 8, 0), ROOF_RED, Enum.Material.SmoothPlastic)
	roof.Name = "Roof"
	local anchor = PartKit.Part(stall, {
		Name = "OfferAnchor",
		Size = Vector3.new(1, 1, 1),
		Position = position + Vector3.new(0, 6, 0),
		Transparency = 1,
		CanCollide = false,
	})
	return anchor
end

local function buildBase(folder, center, index)
	local base = Instance.new("Folder")
	base.Name = "Base" .. index
	base.Parent = folder
	local floor = PartKit.Box(base, Vector3.new(38, 2, 32), center, WOOD, Enum.Material.WoodPlanks)
	floor.Name = "Floor"
	local roof = PartKit.Box(base, Vector3.new(40, 1, 34), center + Vector3.new(0, 14, 0), ROOF_RED, Enum.Material.SmoothPlastic)
	roof.Name = "Roof"
	for _, corner in ipairs({ Vector3.new(-18, 7, -15), Vector3.new(18, 7, -15), Vector3.new(-18, 7, 15), Vector3.new(18, 7, 15) }) do
		PartKit.Cylinder(base, 14, 0.8, center + corner, WOOD_DARK, Enum.Material.Wood).Name = "RoofPost"
	end
	local signPart = PartKit.Box(base, Vector3.new(10, 3, 0.6), center + Vector3.new(0, 11, -16), WOOD_DARK, Enum.Material.WoodPlanks)
	signPart.Name = "Sign"
	local signGui = Instance.new("SurfaceGui")
	signGui.Name = "SignGui"
	signGui.Face = Enum.NormalId.Front
	signGui.Parent = signPart
	local signText = Instance.new("TextLabel")
	signText.Name = "SignText"
	signText.Size = UDim2.new(1, 0, 1, 0)
	signText.BackgroundTransparency = 1
	signText.Font = Enum.Font.GothamBold
	signText.TextSize = 28
	signText.TextColor3 = Color3.fromRGB(255, 240, 200)
	signText.Text = "BASE " .. index
	signText.Parent = signGui
	local pedestals = {}
	local slot = 1
	for _, dz in ipairs({ -6, 6 }) do
		for _, dx in ipairs({ -12, -4, 4, 12 }) do
			local top = PartKit.Cylinder(base, 1, 4.5, center + Vector3.new(dx, 1.5, dz), Color3.fromRGB(200, 180, 140), Enum.Material.Marble)
			top.Name = "Pedestal" .. slot
			pedestals[slot] = center + Vector3.new(dx, 2, dz)
			slot += 1
		end
	end
	return {
		Folder = base,
		Center = center,
		Pedestals = pedestals,
		SignText = signText,
	}
end

local function buildConveyor(folder)
	local belt = PartKit.Box(folder, Vector3.new(130, 1, 8), Vector3.new(0, 0.5, 40), Color3.fromRGB(60, 60, 70), Enum.Material.Metal)
	belt.Name = "Conveyor"
	for x = -60, 60, 10 do
		local stripe = PartKit.Box(folder, Vector3.new(1.5, 0.2, 8), Vector3.new(x, 1.1, 40), NEON_CYAN, Enum.Material.Neon)
		stripe.Name = "Stripe"
	end
end

local function buildLighthouse(folder)
	local tower = PartKit.Cylinder(folder, 26, 8, Config.LighthousePosition + Vector3.new(0, 13, 0), Color3.fromRGB(240, 235, 220), Enum.Material.Concrete)
	tower.Name = "LighthouseTower"
	local beacon = PartKit.Ball(folder, 3, Config.LighthousePosition + Vector3.new(0, 28, 0), NEON_CYAN, Enum.Material.Neon)
	beacon.Name = "Beacon"
	local light = Instance.new("PointLight")
	light.Color = NEON_CYAN
	light.Range = 40
	light.Brightness = 2
	light.Parent = beacon
	local cap = PartKit.Cylinder(folder, 2, 10, Config.LighthousePosition + Vector3.new(0, 31, 0), ROOF_RED, Enum.Material.SmoothPlastic)
	cap.Name = "LighthouseRoof"
end

local function buildLanterns(folder)
	for i = 1, 9 do
		local x = -80 + (i - 1) * 20
		local z = (i % 2 == 0) and -13 or 13
		local pole = PartKit.Cylinder(folder, 8, 0.5, Vector3.new(x, 4, z), WOOD_DARK, Enum.Material.Wood)
		pole.Name = "LanternPole" .. i
		local lamp = PartKit.Ball(folder, 1.2, Vector3.new(x, 8.5, z), NEON_RED, Enum.Material.Neon)
		lamp.Name = "Lantern" .. i
		local light = Instance.new("PointLight")
		light.Color = NEON_RED
		light.Range = 18
		light.Brightness = 1.5
		light.Parent = lamp
	end
end

local function buildBoats(folder)
	local spots = { Vector3.new(-100, -2, 40), Vector3.new(100, -2, -40), Vector3.new(40, -2, -90) }
	for i, spot in ipairs(spots) do
		local boat = Instance.new("Folder")
		boat.Name = "Boat" .. i
		boat.Parent = folder
		local hull = PartKit.Box(boat, Vector3.new(12, 2, 5), spot, WOOD_DARK, Enum.Material.Wood)
		hull.Name = "Hull"
		PartKit.Cylinder(boat, 10, 0.5, spot + Vector3.new(0, 6, 0), WOOD, Enum.Material.Wood).Name = "Mast"
		local sail = PartKit.Box(boat, Vector3.new(0.4, 7, 6), spot + Vector3.new(0, 7, 0), Color3.fromRGB(250, 245, 230), Enum.Material.Fabric)
		sail.Name = "Sail"
	end
end

local function buildPalms(folder)
	local spots = {
		Vector3.new(-70, 0, -45),
		Vector3.new(70, 0, -45),
		Vector3.new(-70, 0, 45),
		Vector3.new(70, 0, 45),
		Vector3.new(-110, 0, 0),
		Vector3.new(110, 0, 0),
	}
	for i, spot in ipairs(spots) do
		local palm = Instance.new("Folder")
		palm.Name = "Palm" .. i
		palm.Parent = folder
		local trunk = PartKit.Cylinder(palm, 12, 1.2, spot + Vector3.new(0, 6, 0), TRUNK, Enum.Material.Wood)
		trunk.Name = "Trunk"
		for leaf = 1, 4 do
			local angle = (leaf - 1) * math.pi / 2
			local leafPart = PartKit.Box(palm, Vector3.new(7, 0.3, 1.6), spot + Vector3.new(math.cos(angle) * 3.5, 12, math.sin(angle) * 3.5), LEAF, Enum.Material.Grass)
			leafPart.Name = "Leaf" .. leaf
			leafPart.Orientation = Vector3.new(0, math.deg(angle), 25)
		end
	end
end

function World.Build()
	local folder = Instance.new("Folder")
	folder.Name = "BazaarWorld"
	folder.Parent = workspace
	buildWater(folder)
	buildDock(folder)
	local stallAnchors = {}
	for i, position in ipairs(Config.StallPositions) do
		stallAnchors[i] = buildStall(folder, position, i)
	end
	local bases = {}
	for i, position in ipairs(Config.BasePositions) do
		bases[i] = buildBase(folder, position, i)
	end
	buildConveyor(folder)
	buildLighthouse(folder)
	buildLanterns(folder)
	buildBoats(folder)
	buildPalms(folder)
	return {
		Folder = folder,
		Bases = bases,
		StallAnchors = stallAnchors,
		LighthousePosition = Config.LighthousePosition,
	}
end

return World
