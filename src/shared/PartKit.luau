-- PartKit.luau — shared part-building helpers for the server modules.
-- World, BrainrotModels and Thief all build from these, so the same
-- construction lines live in exactly one place.

local PartKit = {}

function PartKit.Part(parent, props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = true
	for key, value in pairs(props) do
		part[key] = value
	end
	part.Parent = parent
	return part
end

function PartKit.Ball(parent, radius, position, color, material)
	return PartKit.Part(parent, {
		Name = "Ball",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(radius * 2, radius * 2, radius * 2),
		Position = position,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

function PartKit.Box(parent, size, position, color, material)
	return PartKit.Part(parent, {
		Name = "Box",
		Shape = Enum.PartType.Block,
		Size = size,
		Position = position,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

function PartKit.Cylinder(parent, length, diameter, position, color, material)
	return PartKit.Part(parent, {
		Name = "Cylinder",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(length, diameter, diameter),
		Position = position,
		Orientation = Vector3.new(0, 0, 90),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

function PartKit.Wedge(parent, size, position, color, material)
	return PartKit.Part(parent, {
		Name = "Wedge",
		Shape = Enum.PartType.Wedge,
		Size = size,
		Position = position,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

-- A floating name plate above a model. parent must be a BasePart.
function PartKit.Label(parent, text, textColor, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "FloatLabel"
	gui.Size = UDim2.new(0, 160, 0, 44)
	gui.StudsOffset = Vector3.new(0, size, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 15
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.2
	label.Text = text
	label.Parent = gui
	return gui
end

-- Two round eyes and a smile on the front (+Z face) of a ball body.
function PartKit.Face(body, radius, eyeColor)
	local front = body.Position + Vector3.new(0, radius * 0.25, radius * 0.85)
	local eyeSize = radius * 0.28
	PartKit.Ball(body.Parent, eyeSize, front + Vector3.new(-radius * 0.38, 0, 0), eyeColor or Color3.fromRGB(20, 20, 25))
	PartKit.Ball(body.Parent, eyeSize, front + Vector3.new(radius * 0.38, 0, 0), eyeColor or Color3.fromRGB(20, 20, 25))
	local mouth = PartKit.Box(
		body.Parent,
		Vector3.new(radius * 0.7, radius * 0.16, radius * 0.1),
		body.Position + Vector3.new(0, -radius * 0.3, radius * 0.9),
		Color3.fromRGB(30, 15, 15)
	)
	mouth.Name = "Mouth"
end

return PartKit
