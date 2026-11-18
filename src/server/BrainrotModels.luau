local Models = {}

local function block(parent, name, size, position, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Color = color
	p.Anchored = false
	p.CanCollide = false
	p.Shape = shape or Enum.PartType.Block
	p.Parent = parent
	return p
end

local function face(parent, position, scale)
	local eye = block(parent, "EyeL", Vector3.new(scale, scale, scale), position + Vector3.new(-scale, scale, -scale), Color3.new(0, 0, 0), Enum.PartType.Ball)
	local eye2 = block(parent, "EyeR", Vector3.new(scale, scale, scale), position + Vector3.new(scale, scale, -scale), Color3.new(0, 0, 0), Enum.PartType.Ball)
	block(parent, "Mouth", Vector3.new(scale * 2.5, scale / 2, scale / 3), position + Vector3.new(0, -scale, -scale), Color3.fromRGB(80, 20, 25))
	return eye, eye2
end

local function rig(name, color, position)
	local model = Instance.new("Model")
	model.Name = name
	local body = block(model, "FoodBody", Vector3.new(4, 4, 4), position, color, Enum.PartType.Ball)
	face(model, position, 0.35)
	return model, body
end

function Models.buildBaksoBandit(position)
	local model, _body = rig("BaksoBandit", Color3.fromRGB(149, 86, 48), position)
	block(model, "BlackBanditMask", Vector3.new(3.5, 1.1, 0.4), position + Vector3.new(0, 0.7, -2), Color3.fromRGB(20, 20, 24))
	block(model, "Sack", Vector3.new(2, 2.5, 1.8), position + Vector3.new(2.5, -1, 0), Color3.fromRGB(170, 125, 62), Enum.PartType.Ball)
	return model
end

function Models.buildSateSensei(position)
	local model = Instance.new("Model")
	model.Name = "SateSensei"
	block(model, "SkewerBody", Vector3.new(1.7, 6, 1.7), position + Vector3.new(0, 1, 0), Color3.fromRGB(190, 120, 65), Enum.PartType.Cylinder)
	face(model, position + Vector3.new(0, 4, 0), 0.3)
	block(model, "Headband", Vector3.new(2.4, 0.35, 2.4), position + Vector3.new(0, 5.2, 0), Color3.fromRGB(185, 35, 45))
	block(model, "Katana", Vector3.new(0.25, 4, 0.25), position + Vector3.new(1.8, 2, 0), Color3.fromRGB(220, 225, 235), Enum.PartType.Cylinder)
	return model
end

function Models.buildKleponKing(position)
	local model, _body = rig("KleponKing", Color3.fromRGB(83, 190, 95), position)
	block(model, "Crown", Vector3.new(3.5, 1.2, 3.5), position + Vector3.new(0, 3, 0), Color3.fromRGB(255, 210, 55))
	block(model, "Cape", Vector3.new(3.8, 4, 0.5), position + Vector3.new(0, 0, 2.4), Color3.fromRGB(190, 38, 44))
	return model
end

function Models.buildCommon(name, position, color, scale)
	local model = Instance.new("Model")
	model.Name = name
	local size = scale or 4
	block(model, "FoodBody", Vector3.new(size, size, size), position, color, Enum.PartType.Ball)
	face(model, position, math.max(0.25, size / 11))
	block(model, "Feature", Vector3.new(size * 1.4, size / 2, size / 2), position + Vector3.new(0, size * 0.65, 0), color, Enum.PartType.Cylinder)
	return model
end

function Models.Build(name, position)
	if name == "Bakso Bandit" then return Models.buildBaksoBandit(position) end
	if name == "Sate Sensei" then return Models.buildSateSensei(position) end
	if name == "Klepon King" then return Models.buildKleponKing(position) end
	local colors = {
		["Kerupuk Knight"] = Color3.fromRGB(223, 175, 75), ["Cireng Cyclops"] = Color3.fromRGB(225, 190, 150),
		["Gado-Gado Goblin"] = Color3.fromRGB(65, 165, 75), ["Es Cendol Cyber"] = Color3.fromRGB(90, 210, 180),
		["Soto Sphinx"] = Color3.fromRGB(220, 150, 60), ["Martabak Monster"] = Color3.fromRGB(104, 59, 35),
		["Nasi Padang Paladin"] = Color3.fromRGB(245, 230, 180), ["Rendang Rex"] = Color3.fromRGB(155, 56, 38),
		["Es Teh Sultan"] = Color3.fromRGB(205, 145, 55),
	}
	return Models.buildCommon(name, position, colors[name] or Color3.new(1, 1, 1), 4)
end

return Models
