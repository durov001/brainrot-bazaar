-- BrainrotModels.luau — builds the twelve food characters from parts.
-- Every character is a ball body with a big face; the three heroes get
-- their own silhouettes, the rest a coloured topper.

local BrainrotData = require(script.Parent.Parent.Shared.BrainrotData)
local PartKit = require(script.Parent.Parent.Shared.PartKit)

local BrainrotModels = {}

local RADIUS = {
	Common = 1.5,
	Rare = 1.8,
	Epic = 2.1,
	Legendary = 2.4,
	Mythic = 2.7,
	Divine = 3.0,
}

local TOPPER_COLORS = {
	["Kerupuk Knight"] = Color3.fromRGB(200, 170, 60),
	["Cireng Cyclops"] = Color3.fromRGB(255, 255, 255),
	["Gado-Gado Goblin"] = Color3.fromRGB(120, 80, 30),
	["Es Cendol Cyber"] = Color3.fromRGB(60, 255, 200),
	["Soto Sphinx"] = Color3.fromRGB(255, 215, 0),
	["Martabak Monster"] = Color3.fromRGB(60, 35, 20),
	["Nasi Padang Paladin"] = Color3.fromRGB(200, 40, 40),
	["Rendang Rex"] = Color3.fromRGB(255, 215, 0),
	["Es Teh Sultan"] = Color3.fromRGB(255, 240, 180),
}

local function addTopper(model, body, radius, color)
	local topper = PartKit.Ball(model, radius * 0.45, body.Position + Vector3.new(0, radius * 1.25, 0), color)
	topper.Name = "Topper"
end

local function buildGeneric(model, entry, radius, position)
	local body = PartKit.Ball(model, radius, position, entry.Body)
	body.Name = "Body"
	PartKit.Face(body, radius)
	local topperColor = TOPPER_COLORS[entry.Name]
	if topperColor then
		addTopper(model, body, radius, topperColor)
	end
	return body
end

local function buildBakso(model, entry, radius, position)
	local body = PartKit.Ball(model, radius, position, entry.Body)
	body.Name = "Body"
	PartKit.Face(body, radius)
	local mask = PartKit.Box(model, Vector3.new(radius * 1.5, radius * 0.5, radius * 0.2), position + Vector3.new(0, radius * 0.25, radius * 0.85), Color3.fromRGB(15, 15, 20))
	mask.Name = "Mask"
	local sack = PartKit.Ball(model, radius * 0.6, position + Vector3.new(radius * 1.3, -radius * 0.4, 0), Color3.fromRGB(170, 140, 90))
	sack.Name = "Sack"
	return body
end

local function buildSate(model, entry, radius, position)
	local stick = PartKit.Cylinder(model, radius * 4, radius * 0.7, position + Vector3.new(0, radius, 0), Color3.fromRGB(210, 170, 110), Enum.Material.Wood)
	stick.Name = "Skewer"
	local body = PartKit.Ball(model, radius, position + Vector3.new(0, radius * 0.8, 0), entry.Body)
	body.Name = "Body"
	PartKit.Face(body, radius)
	local band = PartKit.Box(model, Vector3.new(radius * 1.9, radius * 0.35, radius * 0.2), position + Vector3.new(0, radius * 1.6, radius * 0.8), Color3.fromRGB(220, 40, 40))
	band.Name = "Headband"
	local blade = PartKit.Box(model, Vector3.new(0.2, radius * 2, radius * 0.4), position + Vector3.new(radius * 1.4, radius * 0.5, 0), Color3.fromRGB(220, 225, 235), Enum.Material.Metal)
	blade.Name = "Katana"
	return body
end

local function buildKlepon(model, entry, radius, position)
	local body = PartKit.Ball(model, radius, position, entry.Body)
	body.Name = "Body"
	PartKit.Face(body, radius)
	local crown = PartKit.Cylinder(model, radius * 0.7, radius * 1.1, position + Vector3.new(0, radius * 1.35, 0), Color3.fromRGB(255, 215, 0), Enum.Material.Metal)
	crown.Name = "Crown"
	local cape = PartKit.Box(model, Vector3.new(radius * 1.6, radius * 1.8, radius * 0.15), position + Vector3.new(0, -radius * 0.2, -radius * 1.05), Color3.fromRGB(190, 25, 25), Enum.Material.Fabric)
	cape.Name = "Cape"
	return body
end

local HEROES = {
	["Bakso Bandit"] = buildBakso,
	["Sate Sensei"] = buildSate,
	["Klepon King"] = buildKlepon,
}

function BrainrotModels.Build(name, position, displayRate)
	local entry = BrainrotData.Find(name)
	if not entry then
		return nil
	end
	local radius = RADIUS[entry.Rarity] or 1.5
	local model = Instance.new("Model")
	model.Name = entry.Name
	local builder = HEROES[entry.Name] or buildGeneric
	local center = position + Vector3.new(0, radius, 0)
	local body = builder(model, entry, radius, center)
	model.PrimaryPart = body
	local rarityColor = BrainrotData.RarityColors[entry.Rarity]
	local labelText = entry.Name .. "\n" .. entry.Rarity .. "  $" .. displayRate .. "/s"
	PartKit.Label(body, labelText, rarityColor, radius + 3)
	return model
end

return BrainrotModels
