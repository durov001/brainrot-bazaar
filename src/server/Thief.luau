-- Thief.luau — the shadow that patrols unlocked bases. A dark floating
-- orb with a red THIEF label: it glides to a base, takes the highest
-- occupied pedestal item, and drifts away.

local PartKit = require(script.Parent.Parent.Shared.PartKit)

local Thief = {}

local SPEED = 9

local function glide(model, from, to)
	local distance = (to - from).Magnitude
	local steps = math.max(1, math.floor(distance / (SPEED * 0.05)))
	for step = 1, steps do
		local alpha = step / steps
		local nextPos = from:Lerp(to, alpha)
		model:PivotTo(CFrame.new(nextPos))
		task.wait(0.05)
	end
end

local function buildThief(position)
	local model = Instance.new("Model")
	model.Name = "Thief"
	local body = PartKit.Ball(model, 2, position, Color3.fromRGB(25, 25, 35), Enum.Material.Neon)
	body.Name = "Shadow"
	body.Transparency = 0.25
	PartKit.Ball(model, 0.4, position + Vector3.new(-0.7, 0.5, 1.8), Color3.fromRGB(255, 40, 40), Enum.Material.Neon).Name = "EyeL"
	PartKit.Ball(model, 0.4, position + Vector3.new(0.7, 0.5, 1.8), Color3.fromRGB(255, 40, 40), Enum.Material.Neon).Name = "EyeR"
	PartKit.Label(body, "THIEF", Color3.fromRGB(255, 60, 60), 5)
	model.PrimaryPart = body
	model.Parent = workspace
	return model
end

-- target: { BaseCenter, Pedestals, IsLocked, OnStolen(index) }
-- Pedestals is an array of 8 entries, each a table or false.
function Thief.Run(target)
	task.spawn(function()
		local entry = Vector3.new(-130, 6, target.BaseCenter.Z + 30)
		local exitPoint = Vector3.new(130, 6, target.BaseCenter.Z - 30)
		local thief = buildThief(entry)
		local hover = target.BaseCenter + Vector3.new(0, 6, 0)
		glide(thief, entry, hover)
		if target.IsLocked() then
			glide(thief, hover, exitPoint)
			thief:Destroy()
			return
		end
		local victim = 0
		for index = 1, #target.Pedestals do
			if target.Pedestals[index] then
				victim = index
			end
		end
		if victim > 0 then
			target.OnStolen(victim)
			task.wait(1)
		end
		glide(thief, hover, exitPoint)
		thief:Destroy()
	end)
end

return Thief
