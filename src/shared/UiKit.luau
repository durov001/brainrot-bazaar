-- UiKit.luau — shared GUI builders for the client script, so every panel,
-- label and button is assembled from the same few helpers.

local UiKit = {}

function UiKit.Corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = parent
	return corner
end

function UiKit.Stroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(255, 255, 255)
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0.6
	stroke.Parent = parent
	return stroke
end

function UiKit.Frame(parent, props)
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	for key, value in pairs(props) do
		frame[key] = value
	end
	frame.Parent = parent
	return frame
end

function UiKit.Label(parent, props)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.3
	for key, value in pairs(props) do
		label[key] = value
	end
	label.Parent = parent
	return label
end

function UiKit.Button(parent, props)
	local button = Instance.new("TextButton")
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.AutoButtonColor = true
	for key, value in pairs(props) do
		button[key] = value
	end
	button.Parent = parent
	return button
end

function UiKit.Pill(parent, position, size, bg, text, textSize)
	local button = UiKit.Button(parent, {
		Name = "Pill",
		Position = position,
		Size = size,
		BackgroundColor3 = bg,
		Text = text,
		TextSize = textSize or 15,
	})
	UiKit.Corner(button, 12)
	UiKit.Stroke(button)
	return button
end

return UiKit
