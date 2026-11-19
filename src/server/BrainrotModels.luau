-- BRAINROT BAZAAR models: all twelve characters built from parts, with big faces.
local Models = {}

-- Body colors for the nine characters without a hero builder.
local BODY_COLORS = {
	["Kerupuk Knight"] = Color3.fromRGB(223, 175, 75),
	["Cireng Cyclops"] = Color3.fromRGB(225, 190, 150),
	["Gado-Gado Goblin"] = Color3.fromRGB(65, 165, 75),
	["Es Cendol Cyber"] = Color3.fromRGB(90, 210, 180),
	["Soto Sphinx"] = Color3.fromRGB(220, 150, 60),
	["Martabak Monster"] = Color3.fromRGB(104, 59, 35),
	["Nasi Padang Paladin"] = Color3.fromRGB(245, 230, 180),
	["Rendang Rex"] = Color3.fromRGB(155, 56, 38),
	["Es Teh Sultan"] = Color3.fromRGB(205, 145, 55),
}

-- One loose part of a character: no collision, so models never snag the player.
local function chunk(model, name, size, at, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = at
	p.Color = color
	p.Anchored = false
	p.CanCollide = false
	p.Shape = shape or Enum.PartType.Block
	p.Parent = model
	return p
end

-- Two ball eyes and a wide mouth on the front of a body.
local function addFace(model, at, s)
	chunk(model, "EyeL", Vector3.new(s, s, s), at + Vector3.new(-s, s, -s), Color3.new(0, 0, 0), Enum.PartType.Ball)
	chunk(model, "EyeR", Vector3.new(s, s, s), at + Vector3.new(s, s, -s), Color3.new(0, 0, 0), Enum.PartType.Ball)
	chunk(model, "Mouth", Vector3.new(s * 2.5, s / 2, s / 3), at + Vector3.new(0, -s, -s), Color3.fromRGB(80, 20, 25))
end

-- A round food body with a face: the base every round character starts from.
local function roundBody(name, color, at)
	local model = Instance.new("Model")
	model.Name = name
	chunk(model, "FoodBody", Vector3.new(4, 4, 4), at, color, Enum.PartType.Ball)
	addFace(model, at, 0.35)
	return model
end

local function baksoBandit(at)
	local model = roundBody("BaksoBandit", Color3.fromRGB(149, 86, 48), at)
	chunk(model, "BlackBanditMask", Vector3.new(3.6, 1, 0.5), at + Vector3.new(0, 0.7, -2), Color3.fromRGB(20, 20, 24))
	chunk(model, "Sack", Vector3.new(2.2, 2.4, 1.6), at + Vector3.new(2.5, -1, 0), Color3.fromRGB(170, 125, 62), Enum.PartType.Ball)
	return model
end

local function sateSensei(at)
	local model = Instance.new("Model")
	model.Name = "SateSensei"
	chunk(model, "SkewerBody", Vector3.new(1.7, 6, 1.7), at + Vector3.new(0, 1, 0), Color3.fromRGB(190, 120, 65), Enum.PartType.Cylinder)
	addFace(model, at + Vector3.new(0, 4, 0), 0.3)
	chunk(model, "Headband", Vector3.new(2.4, 0.35, 2.4), at + Vector3.new(0, 5.2, 0), Color3.fromRGB(185, 35, 45))
	chunk(model, "Katana", Vector3.new(0.25, 4, 0.25), at + Vector3.new(1.8, 2, 0), Color3.fromRGB(220, 225, 235), Enum.PartType.Cylinder)
	return model
end

local function kleponKing(at)
	local model = roundBody("KleponKing", Color3.fromRGB(83, 190, 95), at)
	chunk(model, "Crown", Vector3.new(3.5, 1.2, 3.5), at + Vector3.new(0, 3, 0), Color3.fromRGB(255, 210, 55))
	chunk(model, "Cape", Vector3.new(3.8, 4, 0.5), at + Vector3.new(0, 0, 2.4), Color3.fromRGB(190, 38, 44))
	return model
end

-- Every other character: a round body, a face, and a little topper ball.
local function plain(name, at, color)
	local model = roundBody(name, color, at)
	chunk(model, "Topper", Vector3.new(1.8, 1.8, 1.8), at + Vector3.new(0, 2.9, 0), color, Enum.PartType.Ball)
	return model
end

-- Build one character model by its display name, at a world position.
function Models.make(name, at)
	if name == "Bakso Bandit" then
		return baksoBandit(at)
	end
	if name == "Sate Sensei" then
		return sateSensei(at)
	end
	if name == "Klepon King" then
		return kleponKing(at)
	end
	return plain(name, at, BODY_COLORS[name] or Color3.new(1, 1, 1))
end

return Models
