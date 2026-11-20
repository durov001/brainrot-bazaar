-- GameServer.server.luau — the heart of BRAINROT BAZAAR. Owns player
-- state, the market, income, rebirth, locks, and the thief/monsoon loops.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(script.Parent.Parent.Shared.Config)
local BrainrotData = require(script.Parent.Parent.Shared.BrainrotData)
local PartKit = require(script.Parent.Parent.Shared.PartKit)
local World = require(script.Parent.World)
local BrainrotModels = require(script.Parent.BrainrotModels)
local Thief = require(script.Parent.Thief)
local Monsoon = require(script.Parent.Monsoon)

local world = World.Build()

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = Config.RemoteFolderName
remotesFolder.Parent = ReplicatedStorage

local Remotes = {}
for _, eventName in pairs(Config.Remotes) do
	local event = Instance.new("RemoteEvent")
	event.Name = eventName
	event.Parent = remotesFolder
	Remotes[eventName] = event
end

local rng = Random.new()
local states = {}
local nextBase = 1
local offers = { false, false, false, false }
local offerDisplays = { nil, nil, nil, nil }

local function characterPosition(player)
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	return root.Position
end

local function near(player, target, range)
	local pos = characterPosition(player)
	if not pos then
		return false
	end
	return (pos - target).Magnitude <= range
end

local function totalRate(state)
	local sum = 0
	for _, slot in ipairs(state.Pedestals) do
		if slot then
			local entry = BrainrotData.Find(slot.Name)
			if entry then
				sum += BrainrotData.IncomePerSecond(entry, slot.Mutation, state.Rebirths)
			end
		end
	end
	return sum
end

local function sendState(player)
	local state = states[player]
	if not state then
		return
	end
	local now = os.time()
	local payload = {
		Cash = state.Cash,
		Rate = totalRate(state),
		Rebirths = state.Rebirths,
		Multiplier = BrainrotData.RebirthMultiplier(state.Rebirths),
		Carrying = state.Carrying and state.Carrying.Name or "",
		Locked = now < state.LockUntil,
		LockLeft = math.max(0, state.LockUntil - now),
		Pedestals = {},
	}
	for index, slot in ipairs(state.Pedestals) do
		if slot then
			payload.Pedestals[index] = { Name = slot.Name, Mutation = slot.Mutation }
		else
			payload.Pedestals[index] = false
		end
	end
	Remotes[Config.Remotes.State]:FireClient(player, payload)
end

local function notice(player, text)
	Remotes[Config.Remotes.Notice]:FireClient(player, text)
end

local function clearOfferDisplay(index)
	if offerDisplays[index] then
		offerDisplays[index]:Destroy()
		offerDisplays[index] = nil
	end
end

local function refreshMarket()
	for index = 1, Config.MarketOfferCount do
		clearOfferDisplay(index)
		local entry = BrainrotData.RandomCharacter(rng)
		local mutation = BrainrotData.RandomMutation(rng)
		offers[index] = { Name = entry.Name, Mutation = mutation }
		local anchor = world.StallAnchors[index]
		local ball = PartKit.Ball(workspace, 1.6, anchor.Position, BrainrotData.RarityColors[entry.Rarity], Enum.Material.Neon)
		ball.Name = "Offer" .. index
		local label = entry.Name .. "\n$" .. entry.Price .. "  " .. entry.Rarity
		if mutation ~= "NORMAL" then
			label ..= "  " .. mutation
		end
		PartKit.Label(ball, label, BrainrotData.RarityColors[entry.Rarity], 4)
		offerDisplays[index] = ball
	end
end

local function onPlayerAdded(player)
	local baseIndex = nextBase
	nextBase = nextBase % Config.BaseCount + 1
	local base = world.Bases[baseIndex]
	base.SignText.Text = player.Name
	local pedestals = {}
	for _ = 1, Config.PedestalCount do
		table.insert(pedestals, false)
	end
	states[player] = {
		Cash = Config.StartCash,
		Pedestals = pedestals,
		Carrying = nil,
		Rebirths = 0,
		LockUntil = 0,
		LockCooldownUntil = 0,
		BaseIndex = baseIndex,
	}
	sendState(player)
end

local function onPlayerRemoving(player)
	local state = states[player]
	if state then
		for _, slot in ipairs(state.Pedestals) do
			if slot and slot.Model then
				slot.Model:Destroy()
			end
		end
		world.Bases[state.BaseIndex].SignText.Text = "BASE " .. state.BaseIndex
	end
	states[player] = nil
end

local function onBuy(player, offerIndex)
	local state = states[player]
	if not state or type(offerIndex) ~= "number" then
		return
	end
	local offer = offers[offerIndex]
	if not offer then
		notice(player, "That offer is gone.")
		return
	end
	if state.Carrying then
		notice(player, "Place what you carry first (F).")
		return
	end
	local entry = BrainrotData.Find(offer.Name)
	if not entry or state.Cash < entry.Price then
		notice(player, "Not enough cash.")
		return
	end
	local stallPos = Config.StallPositions[offerIndex]
	if not near(player, stallPos, Config.InteractRange) then
		notice(player, "Get closer to the stall.")
		return
	end
	state.Cash -= entry.Price
	state.Carrying = { Name = offer.Name, Mutation = offer.Mutation }
	offers[offerIndex] = false
	clearOfferDisplay(offerIndex)
	sendState(player)
	notice(player, "Picked up " .. offer.Name .. "!")
end

local function onPlace(player)
	local state = states[player]
	if not state or not state.Carrying then
		return
	end
	local base = world.Bases[state.BaseIndex]
	if not near(player, base.Center, 30) then
		notice(player, "Go to your base to place it.")
		return
	end
	local slotIndex = 0
	for index, slot in ipairs(state.Pedestals) do
		if not slot then
			slotIndex = index
			break
		end
	end
	if slotIndex == 0 then
		notice(player, "Your base is full.")
		return
	end
	local carried = state.Carrying
	local entry = BrainrotData.Find(carried.Name)
	local displayRate = math.floor(BrainrotData.IncomePerSecond(entry, carried.Mutation, state.Rebirths))
	local model = BrainrotModels.Build(carried.Name, base.Pedestals[slotIndex], displayRate)
	if model then
		model.Parent = base.Folder
	end
	state.Pedestals[slotIndex] = { Name = carried.Name, Mutation = carried.Mutation, Model = model }
	state.Carrying = nil
	sendState(player)
end

local function onSell(player, slotIndex)
	local state = states[player]
	if not state or type(slotIndex) ~= "number" then
		return
	end
	local slot = state.Pedestals[slotIndex]
	if not slot then
		return
	end
	local entry = BrainrotData.Find(slot.Name)
	if slot.Model then
		slot.Model:Destroy()
	end
	state.Pedestals[slotIndex] = false
	state.Cash += math.floor(entry.Price * Config.SellRefund)
	sendState(player)
	notice(player, "Sold " .. slot.Name .. ".")
end

local function onRebirth(player)
	local state = states[player]
	if not state then
		return
	end
	local cost = BrainrotData.RebirthCost(state.Rebirths)
	if state.Cash < cost then
		notice(player, "Rebirth costs $" .. cost .. ".")
		return
	end
	for index, slot in ipairs(state.Pedestals) do
		if slot and slot.Model then
			slot.Model:Destroy()
		end
		state.Pedestals[index] = false
	end
	state.Cash = Config.StartCash
	state.Rebirths += 1
	sendState(player)
	notice(player, "Rebirth! Income x" .. BrainrotData.RebirthMultiplier(state.Rebirths) .. ".")
end

local function onLock(player)
	local state = states[player]
	if not state then
		return
	end
	local now = os.time()
	if now < state.LockCooldownUntil then
		notice(player, "Lock recharging (" .. (state.LockCooldownUntil - now) .. "s).")
		return
	end
	state.LockUntil = now + Config.LockDuration
	state.LockCooldownUntil = now + Config.LockDuration + Config.LockCooldown
	sendState(player)
	notice(player, "Base locked for 60s.")
end

Remotes[Config.Remotes.Buy].OnServerEvent:Connect(onBuy)
Remotes[Config.Remotes.Place].OnServerEvent:Connect(onPlace)
Remotes[Config.Remotes.Sell].OnServerEvent:Connect(onSell)
Remotes[Config.Remotes.Rebirth].OnServerEvent:Connect(onRebirth)
Remotes[Config.Remotes.Lock].OnServerEvent:Connect(onLock)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

refreshMarket()

task.spawn(function()
	while true do
		task.wait(Config.IncomeTick)
		for player, state in pairs(states) do
			local gain = math.floor(totalRate(state))
			if gain > 0 then
				state.Cash += gain
				Remotes[Config.Remotes.Income]:FireClient(player, gain, state.Cash, totalRate(state))
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.MarketCycle)
		refreshMarket()
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.ThiefInterval)
		local candidates = {}
		for player, state in pairs(states) do
			if os.time() >= state.LockUntil then
				for _, slot in ipairs(state.Pedestals) do
					if slot then
						table.insert(candidates, player)
						break
					end
				end
			end
		end
		if #candidates > 0 then
			local victim = candidates[rng:NextInteger(1, #candidates)]
			local victimState = states[victim]
			local base = world.Bases[victimState.BaseIndex]
			Thief.Run({
				BaseCenter = base.Center,
				Pedestals = victimState.Pedestals,
				IsLocked = function()
					return os.time() < victimState.LockUntil
				end,
				OnStolen = function(index)
					local slot = victimState.Pedestals[index]
					if slot then
						if slot.Model then
							slot.Model:Destroy()
						end
						victimState.Pedestals[index] = false
						sendState(victim)
						notice(victim, "A thief stole your " .. slot.Name .. "!")
					end
				end,
			})
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(Config.MonsoonInterval)
		Monsoon.Run(
			Remotes[Config.Remotes.Notice],
			world.Bases,
			world.LighthousePosition,
			Players:GetPlayers(),
			Config.SpawnPosition
		)
	end
end)
