local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = require(Shared:WaitForChild("BrainrotData"))
local Config = require(Shared:WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Models = require(script.Parent:WaitForChild("BrainrotModels"))
local Thief = require(script.Parent:WaitForChild("Thief"))
local Monsoon = require(script.Parent:WaitForChild("Monsoon"))

local remotes = ReplicatedStorage:FindFirstChild("BazaarRemotes") or Instance.new("Folder")
remotes.Name = "BazaarRemotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
	local event = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
	return event
end

local BuyBrainrot = remote("BuyBrainrot")
local PlaceBrainrot = remote("PlaceBrainrot")
local SellBrainrot = remote("SellBrainrot")
local Rebirth = remote("Rebirth")
local ToggleLock = remote("ToggleLock")
local StateUpdate = remote("StateUpdate")
local Notice = remote("Notice")
local Income = remote("Income")

local world = World.Build()
local bases = world:WaitForChild("PlayerBases")
local states = {}
local assignedBase = {}
local offers = {}
local missions = { "Buy 3 brainrots", "Earn $1,000", "Rebirth once", "Own a Legendary" }
local marketFolder = Instance.new("Folder")
marketFolder.Name = "MarketOffers"
marketFolder.Parent = world

local function baseFor(player)
	local index = assignedBase[player]
	return index and bases:FindFirstChild("Base_" .. index)
end

local function distanceFrom(player, position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root and (root.Position - position).Magnitude or math.huge
end

local function playerNearBase(player)
	local base = baseFor(player)
	local floor = base and base:FindFirstChild("BaseFloor")
	return floor and distanceFrom(player, floor.Position) <= Config.InteractionDistance
end

local function snapshot(player)
	local state = states[player]
	if not state then return end
	local pedestals = {}
	for slot = 1, Config.PedestalCount do
		pedestals[slot] = state.pedestals[slot]
	end
	local offerData = {}
	for i, item in ipairs(offers) do offerData[i] = item.Name end
	StateUpdate:FireClient(player, {
		cash = state.cash, rate = state.rate, multiplier = state.multiplier,
		rebirths = state.rebirths, pedestals = pedestals, carry = state.carry,
		locked = os.clock() < state.lockedUntil, lockReady = os.clock() >= state.lockCooldownUntil,
		offers = offerData, mission = missions[(math.floor(os.clock() / 45) % #missions) + 1],
		baseIndex = assignedBase[player],
	})
end

local function updateIncome(player)
	local state = states[player]
	if not state then return end
	state.rate = 0
	for _, entry in pairs(state.pedestals) do
		local item = entry and Data.Get(entry.name)
		if item then state.rate += Data.Income(item, entry.mutation, state.multiplier) end
	end
	state.rate = math.floor(state.rate * 100) / 100
end

local function makePlaced(player, slot, entry)
	local base = baseFor(player)
	local pedestal = base and base:FindFirstChild("Pedestal_" .. slot)
	if not pedestal then return end
	local old = base:FindFirstChild("Placed_" .. slot)
	if old then old:Destroy() end
	local model = Models.Build(entry.name, pedestal.Position + Vector3.new(0, 4, 0))
	model.Name = "Placed_" .. slot
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("BrainrotName", entry.name)
	model:SetAttribute("Mutation", entry.mutation)
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") then object.Anchored = true end
	end
	model.Parent = base
end

local function clearPlaced(player, slot)
	local base = baseFor(player)
	local old = base and base:FindFirstChild("Placed_" .. slot)
	if old then old:Destroy() end
end

local function cycleOffers()
	for i = 1, 4 do
		local index = math.random(1, #Data.List)
		offers[i] = Data.List[index]
		local display = marketFolder:FindFirstChild("Offer_" .. i)
		if display then display:Destroy() end
		local stallX = (i - 2.5) * 42
		local stand = Instance.new("Part")
		stand.Name = "Offer_" .. i
		stand.Size = Vector3.new(4, 4, 4)
		stand.Position = Vector3.new(stallX, 7, 32)
		stand.Anchored = true
		stand.CanCollide = false
		stand.Color = offers[i].Color
		stand.Shape = Enum.PartType.Ball
		stand.Parent = marketFolder
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(220, 70)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.Parent = stand
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(42, 32, 28)
		label.BackgroundTransparency = 0.12
		label.Text = offers[i].Name .. "\n$" .. offers[i].Price .. " | " .. offers[i].Rarity
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = gui
	end
	for player in pairs(states) do snapshot(player) end
end

local function assignBase(player)
	for index = 1, Config.BaseCount do
		local occupied = false
		for _, value in pairs(assignedBase) do if value == index then occupied = true end end
		if not occupied then assignedBase[player] = index break end
	end
	local base = baseFor(player)
	if base then
		base:SetAttribute("OwnerUserId", player.UserId)
		local sign = base:FindFirstChild("Sign")
		if sign then sign:SetAttribute("OwnerName", player.DisplayName) end
	end
end

Players.PlayerAdded:Connect(function(player)
	assignBase(player)
	states[player] = {
		cash = Config.StartCash, pedestals = {}, rebirths = 0, multiplier = 1,
		lockedUntil = 0, lockCooldownUntil = 0, carry = nil, rate = 0, buys = 0,
	}
	task.defer(snapshot, player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		snapshot(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local base = baseFor(player)
	if base then
		base:SetAttribute("OwnerUserId", nil)
		for _, child in ipairs(base:GetChildren()) do
			if child.Name:match("^Placed_") then child:Destroy() end
		end
	end
	states[player] = nil
	assignedBase[player] = nil
end)

BuyBrainrot.OnServerEvent:Connect(function(player, offerIndex)
	local state = states[player]
	local item = typeof(offerIndex) == "number" and offers[math.floor(offerIndex)]
	local stand = typeof(offerIndex) == "number" and marketFolder:FindFirstChild("Offer_" .. math.floor(offerIndex))
	if not state or not item or not stand then return end
	if distanceFrom(player, stand.Position) > Config.InteractionDistance then Notice:FireClient(player, "Walk closer to the market stall.") return end
	if state.carry then Notice:FireClient(player, "Place your carried brainrot first.") return end
	if state.cash < item.Price then Notice:FireClient(player, "Not enough cash.") return end
	state.cash -= item.Price
	state.carry = { name = item.Name, mutation = "NORMAL" }
	state.buys += 1
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local carried = Models.Build(item.Name, root.Position + Vector3.new(0, 5, 0))
		carried.Name = "CarriedBrainrot"
		carried:SetAttribute("OwnerUserId", player.UserId)
		for _, object in ipairs(carried:GetDescendants()) do if object:IsA("BasePart") then object.Anchored = true end end
		carried.Parent = character
		state.carryModel = carried
	end
	Notice:FireClient(player, "Bought " .. item.Name .. ". Bring it to your base and press F.")
	snapshot(player)
end)

PlaceBrainrot.OnServerEvent:Connect(function(player, slot)
	local state = states[player]
	if not state or not state.carry then Notice:FireClient(player, "Buy a brainrot first.") return end
	if typeof(slot) ~= "number" then return end
	slot = math.floor(slot)
	if slot < 1 or slot > Config.PedestalCount then return end
	if not playerNearBase(player) then Notice:FireClient(player, "Go to your own base to place it.") return end
	if state.pedestals[slot] then Notice:FireClient(player, "That pedestal is occupied.") return end
	state.pedestals[slot] = state.carry
	if state.carryModel then state.carryModel:Destroy() state.carryModel = nil end
	makePlaced(player, slot, state.carry)
	state.carry = nil
	updateIncome(player)
	snapshot(player)
	Notice:FireClient(player, "Placed! Income is now $" .. state.rate .. "/s.")
end)

SellBrainrot.OnServerEvent:Connect(function(player, slot)
	local state = states[player]
	if not state or not playerNearBase(player) or typeof(slot) ~= "number" then return end
	slot = math.floor(slot)
	local entry = state.pedestals[slot]
	local item = entry and Data.Get(entry.name)
	if not item then return end
	state.cash += math.floor(item.Price * Config.SellFraction)
	state.pedestals[slot] = nil
	clearPlaced(player, slot)
	updateIncome(player)
	snapshot(player)
	Notice:FireClient(player, "Sold for $" .. math.floor(item.Price * Config.SellFraction) .. ".")
end)

Rebirth.OnServerEvent:Connect(function(player)
	local state = states[player]
	if not state then return end
	local cost = Data.RebirthCost(state.rebirths)
	if state.cash < cost then Notice:FireClient(player, "Rebirth costs $" .. cost .. ".") return end
	state.cash = Config.StartCash
	state.rebirths += 1
	state.multiplier = 1 + state.rebirths * 0.25
	state.pedestals = {}
	state.carry = nil
	if state.carryModel then state.carryModel:Destroy() state.carryModel = nil end
	local base = baseFor(player)
	if base then for _, child in ipairs(base:GetChildren()) do if child.Name:match("^Placed_") then child:Destroy() end end end
	updateIncome(player)
	snapshot(player)
	Notice:FireClient(player, "Rebirth complete! Income multiplier x" .. string.format("%.2f", state.multiplier) .. ".")
end)

ToggleLock.OnServerEvent:Connect(function(player)
	local state = states[player]
	if not state then return end
	local now = os.clock()
	if now < state.lockCooldownUntil then Notice:FireClient(player, "Lock recharging.") return end
	state.lockedUntil = now + Config.LockDuration
	state.lockCooldownUntil = state.lockedUntil + Config.LockCooldown
	snapshot(player)
	Notice:FireClient(player, "Base locked for 60 seconds.")
end)

task.spawn(function()
	while true do
		task.wait(Config.IncomeTick)
		for player, state in pairs(states) do
			updateIncome(player)
			local amount = math.floor(state.rate)
			if amount > 0 then
				state.cash += amount
				Income:FireClient(player, amount)
			end
			snapshot(player)
		end
	end
end)

task.spawn(function()
	cycleOffers()
	while true do task.wait(Config.MarketCycle) cycleOffers() end
end)

task.spawn(function()
	while true do
		task.wait(Config.ThiefInterval)
		local thief = Thief.spawnThief(world, Vector3.new(90, 3, 0))
		local eligible = {}
		for player, state in pairs(states) do
			if os.clock() >= state.lockedUntil then table.insert(eligible, player) end
		end
		if #eligible > 0 then
			local target = eligible[math.random(1, #eligible)]
			local targetBase = baseFor(target)
			if targetBase then
				local position = targetBase:GetPivot().Position
				Thief.patrolThief(thief, { Vector3.new(50, 0, 0), Vector3.new(position.X, 0, position.Z) }, 1.5)
				local state = states[target]
				local slot, item = Thief.stealFromBase(state)
				if item then
					clearPlaced(target, slot)
					updateIncome(target)
					Notice:FireClient(target, "THIEF! Stole " .. item.name .. "!")
					snapshot(target)
				end
			end
		end
		Thief.fleeThief(thief, Vector3.new(110, 0, -45))
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.MonsoonInterval - Config.MonsoonWarning)
		local oldAmbient = Monsoon.startWarning(Notice, Config.MonsoonWarning)
		Monsoon.sweepWave(world, Players, Notice, oldAmbient)
	end
end)
