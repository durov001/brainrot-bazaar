local Thief = {}

function Thief.spawnThief(parent, position)
	local thief = Instance.new("Model")
	thief.Name = "BazaarThief"
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 5, 2)
	body.Position = position
	body.Color = Color3.fromRGB(45, 45, 52)
	body.Parent = thief
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(3, 3, 3)
	head.Position = position + Vector3.new(0, 4, 0)
	head.Color = Color3.fromRGB(65, 55, 55)
	head.Parent = thief
	local gui = Instance.new("BillboardGui")
	gui.Name = "ThiefAlert"
	gui.Size = UDim2.fromOffset(150, 45)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "THIEF!"
	label.TextColor3 = Color3.fromRGB(255, 30, 25)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	thief.PrimaryPart = body
	thief.Parent = parent
	return thief
end

function Thief.patrolThief(thief, points, pauseSeconds)
	if not thief or not thief.Parent or #points == 0 then return end
	for _, point in ipairs(points) do
		if not thief.Parent then return end
		thief:PivotTo(CFrame.new(point + Vector3.new(0, 3, 0)))
		task.wait(pauseSeconds or 1.5)
	end
end

function Thief.stealFromBase(state)
	if not state or os.clock() < (state.lockedUntil or 0) then return nil end
	for index = #state.pedestals, 1, -1 do
		if state.pedestals[index] then
			local stolen = state.pedestals[index]
			state.pedestals[index] = nil
			return index, stolen
		end
	end
	return nil
end

function Thief.fleeThief(thief, exitPoint)
	if thief and thief.Parent then
		thief:PivotTo(CFrame.new(exitPoint + Vector3.new(0, 3, 0)))
		task.wait(0.5)
		thief:Destroy()
	end
end

return Thief
