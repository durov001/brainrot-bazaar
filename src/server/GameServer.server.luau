-- BRAINROT BAZAAR server: the economy, the market, the thief and the monsoon.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = require(Shared:WaitForChild("BrainrotData"))
local Config = require(Shared:WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))
local Models = require(script.Parent:WaitForChild("BrainrotModels"))
local Thief = require(script.Parent:WaitForChild("Thief"))
local Monsoon = require(script.Parent:WaitForChild("Monsoon"))

-- One folder holding every RemoteEvent the client talks to.
local folder = ReplicatedStorage:FindFirstChild("BazaarRemotes") or Instance.new("Folder")
folder.Name = "BazaarRemotes"
folder.Parent = ReplicatedStorage

local Remotes = {}
for _, name in ipairs({ "BuyBrainrot", "PlaceBrainrot", "SellBrainrot", "Rebirth", "ToggleLock", "StateUpdate", "Notice", "Income" }) do
	local event = folder:FindFirstChild(name) or Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = folder
	Remotes[name] = event
end

local world = World.assemble()
local bases = world:WaitForChild("PlayerBases")
local marketFolder = Instance.new("Folder")
marketFolder.Name = "MarketOffers"
marketFolder.Parent = world

local states = {}
local baseOwner = {}
local offers = {}
local missions = { "Buy your first brainrot", "Fill 4 pedestals", "Earn $500", "Rebirth once" }

local function findBase(player)
	local index = baseOwner[player]
	if index == nil then
		return nil
	end
	return bases:FindFirstChild("Base_" .. index)
end

local function gap(player, position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return math.huge
	end
	return (root.Position - position).Magnitude
end

local function nearOwnBase(player)
	local base = findBase(player)
	local floorPart = base and base:FindFirstChild("BaseFloor")
	if floorPart == nil then
		return false
	end
	return gap(player, floorPart.Position) <= Config.Reach
end

-- Send one player the whole visible state: cash, rate, slots, carry, lock, offers.
local function pushState(player)
	local state = states[player]
	if state == nil then
		return
	end
	local slots = {}
	for slot = 1, Config.PedestalsPerBase do
		slots[slot] = state.slots[slot]
	end
	local offerNames = {}
	for i, item in ipairs(offers) do
		offerNames[i] = item.name
	end
	Remotes.StateUpdate:FireClient(player, {
		cash = state.cash,
		rate = state.rate,
		boost = state.boost,
		rebirths = state.rebirths,
		slots = slots,
		carried = state.carried,
		locked = os.clock() < state.lockedUntil,
		lockReady = os.clock() >= state.lockReadyAt,
		offers = offerNames,
		mission = missions[(math.floor(os.clock() / 45) % #missions) + 1],
		baseIndex = baseOwner[player],
	})
end

-- Recompute a state's dollars per second from its filled pedestals.
local function refreshRate(state)
	local total = 0
	for _, entry in pairs(state.slots) do
		local item = entry and Data.find(entry.name)
		if item ~= nil then
			total += Data.earnPerSecond(item, entry.mutation, state.boost)
		end
	end
	state.rate = math.floor(total * 100) / 100
end

local function spawnPlaced(player, slot, entry)
	local base = findBase(player)
	local pedestal = base and base:FindFirstChild("Pedestal_" .. slot)
	if pedestal == nil then
		return
	end
	local old = base:FindFirstChild("Placed_" .. slot)
	if old ~= nil then
		old:Destroy()
	end
	local model = Models.make(entry.name, pedestal.Position + Vector3.new(0, 4, 0))
	model.Name = "Placed_" .. slot
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("BrainrotName", entry.name)
	model:SetAttribute("Mutation", entry.mutation)
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Anchored = true
		end
	end
	model.Parent = base
end

local function removePlaced(player, slot)
	local base = findBase(player)
	local old = base and base:FindFirstChild("Placed_" .. slot)
	if old ~= nil then
		old:Destroy()
	end
end

-- Pick four fresh market offers and show them as colored balls over the stalls.
local function rotateOffers()
	for i = 1, 4 do
		local name = Data.Order[math.random(1, #Data.Order)]
		offers[i] = Data.find(name)
		local display = marketFolder:FindFirstChild("Offer_" .. i)
		if display ~= nil then
			display:Destroy()
		end
		local stallX = (i - 2.5) * 42
		local stand = Instance.new("Part")
		stand.Name = "Offer_" .. i
		stand.Size = Vector3.new(4, 4, 4)
		stand.Position = Vector3.new(stallX, 7, 32)
		stand.Anchored = true
		stand.CanCollide = false
		stand.Color = offers[i].color
		stand.Shape = Enum.PartType.Ball
		stand.Parent = marketFolder
		local board = Instance.new("BillboardGui")
		board.Size = UDim2.fromOffset(220, 70)
		board.StudsOffset = Vector3.new(0, 3, 0)
		board.AlwaysOnTop = true
		board.Parent = stand
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(42, 32, 28)
		label.BackgroundTransparency = 0.12
		label.Text = offers[i].name .. "\n$" .. offers[i].price .. " | " .. offers[i].rarity
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = board
	end
	for player in pairs(states) do
		pushState(player)
	end
end

local function claimBase(player)
	for index = 1, Config.BaseTotal do
		local taken = false
		for _, value in pairs(baseOwner) do
			if value == index then
				taken = true
			end
		end
		if not taken then
			baseOwner[player] = index
			break
		end
	end
	local base = findBase(player)
	if base ~= nil then
		base:SetAttribute("OwnerUserId", player.UserId)
		local sign = base:FindFirstChild("Sign")
		if sign ~= nil then
			sign:SetAttribute("OwnerName", player.DisplayName)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	claimBase(player)
	states[player] = {
		cash = Config.StartingCash,
		slots = {},
		rebirths = 0,
		boost = 1,
		lockedUntil = 0,
		lockReadyAt = 0,
		carried = nil,
		rate = 0,
		bought = 0,
	}
	task.defer(pushState, player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		pushState(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local base = findBase(player)
	if base ~= nil then
		base:SetAttribute("OwnerUserId", nil)
		for _, child in ipairs(base:GetChildren()) do
			if child.Name:match("^Placed_") then
				child:Destroy()
			end
		end
	end
	states[player] = nil
	baseOwner[player] = nil
end)

Remotes.BuyBrainrot.OnServerEvent:Connect(function(player, offerIndex)
	local state = states[player]
	local index = typeof(offerIndex) == "number" and math.floor(offerIndex) or nil
	local item = index ~= nil and offers[index] or nil
	local stand = index ~= nil and marketFolder:FindFirstChild("Offer_" .. index) or nil
	if state == nil or item == nil or stand == nil then
		return
	end
	if gap(player, stand.Position) > Config.Reach then
		Remotes.Notice:FireClient(player, "Walk closer to the market stall.")
		return
	end
	if state.carried ~= nil then
		Remotes.Notice:FireClient(player, "Place your carried brainrot first.")
		return
	end
	if state.cash < item.price then
		Remotes.Notice:FireClient(player, "Not enough cash.")
		return
	end
	state.cash -= item.price
	state.carried = { name = item.name, mutation = "NORMAL" }
	state.bought += 1
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root ~= nil then
		local carried = Models.make(item.name, root.Position + Vector3.new(0, 5, 0))
		carried.Name = "CarriedBrainrot"
		carried:SetAttribute("OwnerUserId", player.UserId)
		for _, object in ipairs(carried:GetDescendants()) do
			if object:IsA("BasePart") then
				object.Anchored = true
			end
		end
		carried.Parent = character
		state.carryModel = carried
	end
	Remotes.Notice:FireClient(player, "Bought " .. item.name .. ". Bring it to your base and press F.")
	pushState(player)
end)

Remotes.PlaceBrainrot.OnServerEvent:Connect(function(player, slot)
	local state = states[player]
	if state == nil or state.carried == nil then
		Remotes.Notice:FireClient(player, "Buy a brainrot first.")
		return
	end
	if typeof(slot) ~= "number" then
		return
	end
	slot = math.floor(slot)
	if slot < 1 or slot > Config.PedestalsPerBase then
		return
	end
	if not nearOwnBase(player) then
		Remotes.Notice:FireClient(player, "Go to your own base to place it.")
		return
	end
	if state.slots[slot] ~= nil then
		Remotes.Notice:FireClient(player, "That pedestal is occupied.")
		return
	end
	state.slots[slot] = state.carried
	if state.carryModel ~= nil then
		state.carryModel:Destroy()
		state.carryModel = nil
	end
	spawnPlaced(player, slot, state.carried)
	state.carried = nil
	refreshRate(state)
	pushState(player)
	Remotes.Notice:FireClient(player, "Placed! Income is now $" .. state.rate .. "/s.")
end)

Remotes.SellBrainrot.OnServerEvent:Connect(function(player, slot)
	local state = states[player]
	if state == nil or typeof(slot) ~= "number" or not nearOwnBase(player) then
		return
	end
	slot = math.floor(slot)
	local entry = state.slots[slot]
	local item = entry and Data.find(entry.name)
	if item == nil then
		return
	end
	local refund = math.floor(item.price * Config.SellReturn)
	state.cash += refund
	state.slots[slot] = nil
	removePlaced(player, slot)
	refreshRate(state)
	pushState(player)
	Remotes.Notice:FireClient(player, "Sold for $" .. refund .. ".")
end)

Remotes.Rebirth.OnServerEvent:Connect(function(player)
	local state = states[player]
	if state == nil then
		return
	end
	local cost = Data.rebirthPrice(state.rebirths)
	if state.cash < cost then
		Remotes.Notice:FireClient(player, "Rebirth costs $" .. cost .. ".")
		return
	end
	state.cash = Config.StartingCash
	state.rebirths += 1
	state.boost = 1 + state.rebirths * 0.25
	state.slots = {}
	state.carried = nil
	if state.carryModel ~= nil then
		state.carryModel:Destroy()
		state.carryModel = nil
	end
	local base = findBase(player)
	if base ~= nil then
		for _, child in ipairs(base:GetChildren()) do
			if child.Name:match("^Placed_") then
				child:Destroy()
			end
		end
	end
	refreshRate(state)
	pushState(player)
	Remotes.Notice:FireClient(player, "Rebirth complete! Income multiplier x" .. string.format("%.2f", state.boost) .. ".")
end)

Remotes.ToggleLock.OnServerEvent:Connect(function(player)
	local state = states[player]
	if state == nil then
		return
	end
	local now = os.clock()
	if now < state.lockReadyAt then
		Remotes.Notice:FireClient(player, "Lock recharging.")
		return
	end
	state.lockedUntil = now + Config.BaseLockTime
	state.lockReadyAt = state.lockedUntil + Config.BaseLockRecharge
	pushState(player)
	Remotes.Notice:FireClient(player, "Base locked for 60 seconds.")
end)

-- Income: every second, each player's rate lands in their cash.
task.spawn(function()
	while true do
		task.wait(Config.IncomePeriod)
		for player, state in pairs(states) do
			refreshRate(state)
			local amount = math.floor(state.rate)
			if amount > 0 then
				state.cash += amount
				Remotes.Income:FireClient(player, amount)
			end
			pushState(player)
		end
	end
end)

-- Market: fresh offers on a fixed cycle.
task.spawn(function()
	rotateOffers()
	while true do
		task.wait(Config.OfferPeriod)
		rotateOffers()
	end
end)

-- Thief: every cycle, one raid on a random unlocked base.
task.spawn(function()
	while true do
		task.wait(Config.ThiefPeriod)
		local thief = Thief.create(world, Vector3.new(90, 3, 0))
		local open = {}
		for player, state in pairs(states) do
			if os.clock() >= state.lockedUntil then
				table.insert(open, player)
			end
		end
		if #open > 0 then
			local target = open[math.random(1, #open)]
			local targetBase = findBase(target)
			if targetBase ~= nil then
				local at = targetBase:GetPivot().Position
				Thief.walk(thief, { Vector3.new(50, 0, 0), Vector3.new(at.X, 0, at.Z) }, 1.5)
				local state = states[target]
				local slot, item = Thief.rob(state)
				if item ~= nil then
					removePlaced(target, slot)
					refreshRate(state)
					Remotes.Notice:FireClient(target, "THIEF! Stole " .. item.name .. "!")
					pushState(target)
				end
			end
		end
		Thief.escape(thief, Vector3.new(110, 0, -45))
	end
end)

-- Monsoon: a warning, then the wave, on a fixed cycle.
task.spawn(function()
	while true do
		task.wait(Config.MonsoonPeriod - Config.MonsoonWarningTime)
		local oldAmbient = Monsoon.warn(Remotes.Notice, Config.MonsoonWarningTime)
		Monsoon.wave(world, Players, Remotes.Notice, oldAmbient)
	end
end)
