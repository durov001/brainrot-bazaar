-- BRAINROT BAZAAR thief: the dark prowler who raids unlocked bases.
local Thief = {}

-- Spawn the thief model: a dark body and head with a red THIEF label.
function Thief.create(parent, at)
	local model = Instance.new("Model")
	model.Name = "BazaarThief"
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 5, 2)
	body.Position = at
	body.Color = Color3.fromRGB(45, 45, 52)
	body.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(3, 3, 3)
	head.Position = at + Vector3.new(0, 4, 0)
	head.Color = Color3.fromRGB(65, 55, 55)
	head.Parent = model
	local tag = Instance.new("BillboardGui")
	tag.Name = "ThiefAlert"
	tag.Size = UDim2.fromOffset(150, 45)
	tag.StudsOffset = Vector3.new(0, 4, 0)
	tag.AlwaysOnTop = true
	tag.Parent = head
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = "THIEF!"
	text.TextColor3 = Color3.fromRGB(255, 30, 25)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBlack
	text.Parent = tag
	model.PrimaryPart = body
	model.Parent = parent
	return model
end

-- Walk the thief through waypoints, pausing at each one.
function Thief.walk(thief, waypoints, dwell)
	if thief == nil or thief.Parent == nil or #waypoints == 0 then
		return
	end
	for _, point in ipairs(waypoints) do
		if thief.Parent == nil then
			return
		end
		thief:PivotTo(CFrame.new(point + Vector3.new(0, 3, 0)))
		task.wait(dwell or 1.5)
	end
end

-- Steal the highest-index filled slot of a base state. A locked base refuses.
-- Returns the slot and the stolen entry, or nil when nothing can be taken.
function Thief.rob(state)
	if state == nil then
		return nil
	end
	if os.clock() < (state.lockedUntil or 0) then
		return nil
	end
	for slot = #state.slots, 1, -1 do
		local entry = state.slots[slot]
		if entry ~= nil then
			state.slots[slot] = nil
			return slot, entry
		end
	end
	return nil
end

-- Teleport the thief to the exit and remove it.
function Thief.escape(thief, exitAt)
	if thief ~= nil and thief.Parent ~= nil then
		thief:PivotTo(CFrame.new(exitAt + Vector3.new(0, 3, 0)))
		task.wait(0.5)
		thief:Destroy()
	end
end

return Thief
