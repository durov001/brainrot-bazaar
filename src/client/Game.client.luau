local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local Data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))
local state = { cash = 250, rate = 0, multiplier = 1, rebirths = 0, pedestals = {}, offers = {} }
local playing = false
local paused = false
local muted = false

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBazaarHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local function panel(parent, name, size, position, color)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color or Color3.fromRGB(34, 38, 43)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	return frame
end

local function label(parent, name, text, size, position, color, fontSize)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Size = size
	item.Position = position
	item.BackgroundTransparency = 1
	item.Text = text
	item.TextColor3 = color or Color3.new(1, 1, 1)
	item.TextSize = fontSize or 18
	item.Font = Enum.Font.GothamSemibold
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function button(parent, name, text, size, position, callback)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Size = size
	item.Position = position
	item.BackgroundColor3 = Color3.fromRGB(168, 80, 40)
	item.TextColor3 = Color3.new(1, 1, 1)
	item.Text = text
	item.TextSize = 16
	item.Font = Enum.Font.GothamBold
	item.AutoButtonColor = true
	item.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = item
	item.Activated:Connect(callback)
	return item
end

local top = panel(gui, "TopStatus", UDim2.new(0.58, 0, 0, 58), UDim2.new(0.22, 0, 0, 12), Color3.fromRGB(33, 42, 44))
top.BackgroundTransparency = 0.05
local cashLabel = label(top, "Cash", "CASH  $250", UDim2.new(0.3, 0, 1, 0), UDim2.new(0.025, 0, 0, 0), Color3.fromRGB(255, 231, 145), 21)
local rateLabel = label(top, "Rate", "$0/s", UDim2.new(0.2, 0, 1, 0), UDim2.new(0.34, 0, 0, 0), Color3.fromRGB(122, 255, 147), 19)
local multiplierLabel = label(top, "Multiplier", "x1.00", UDim2.new(0.16, 0, 1, 0), UDim2.new(0.58, 0, 0, 0), Color3.fromRGB(155, 218, 255), 19)
local rebirthLabel = label(top, "Rebirths", "REBIRTHS 0", UDim2.new(0.23, 0, 1, 0), UDim2.new(0.76, 0, 0, 0), Color3.fromRGB(255, 205, 125), 16)

local missionPanel = panel(gui, "MissionPanel", UDim2.new(0.42, 0, 0, 34), UDim2.new(0.3, 0, 0, 78), Color3.fromRGB(61, 52, 37))
local missionLabel = label(missionPanel, "Mission", "MISSION  Buy 3 brainrots", UDim2.new(1, -18, 1, 0), UDim2.new(0, 10, 0, 0), Color3.fromRGB(255, 224, 145), 16)

local basePanel = panel(gui, "MyBase", UDim2.new(0, 235, 0, 328), UDim2.new(0, 14, 0.25, 0), Color3.fromRGB(39, 48, 47))
label(basePanel, "BaseTitle", "MY BASE", UDim2.new(1, -18, 0, 36), UDim2.new(0, 12, 0, 7), Color3.fromRGB(255, 224, 150), 22)
local baseSlots = {}
for slot = 1, 8 do
	local y = 48 + (slot - 1) * 31
	local slotLabel = label(basePanel, "Slot" .. slot, slot .. ". Empty", UDim2.new(0.68, 0, 0, 29), UDim2.new(0, 12, 0, y), Color3.fromRGB(232, 237, 231), 14)
	local sellButton = button(basePanel, "Sell" .. slot, "SELL", UDim2.new(0.23, 0, 0, 25), UDim2.new(0.74, 0, 0, y + 2), function()
		remotes.SellBrainrot:FireServer(slot)
	end)
	sellButton.TextSize = 12
	baseSlots[slot] = slotLabel
end
local unlockLabel = label(basePanel, "SlotInfo", "8 pedestals available", UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 1, -34), Color3.fromRGB(172, 224, 186), 13)

local controls = panel(gui, "Actions", UDim2.new(0, 182, 0, 108), UDim2.new(1, -196, 0, 118), Color3.fromRGB(44, 42, 39))
local lockButton = button(controls, "LockButton", "LOCK BASE [L]", UDim2.new(1, -14, 0, 40), UDim2.new(0, 7, 0, 7), function()
	remotes.ToggleLock:FireServer()
end)
local _rebirthButton = button(controls, "RebirthButton", "REBIRTH [R]", UDim2.new(1, -14, 0, 40), UDim2.new(0, 7, 0, 56), function()
	remotes.Rebirth:FireServer()
end)

local promptPanel = panel(gui, "Prompts", UDim2.new(0.56, 0, 0, 42), UDim2.new(0.22, 0, 1, -56), Color3.fromRGB(32, 38, 43))
local promptLabel = label(promptPanel, "PromptText", "E  BUY OFFER     F  PLACE     L  LOCK     R  REBIRTH     P  PAUSE     M  MUTE", UDim2.new(1, -16, 1, 0), UDim2.new(0, 9, 0, 0), Color3.fromRGB(245, 239, 215), 14)
promptLabel.TextXAlignment = Enum.TextXAlignment.Center

local banner = panel(gui, "MonsoonBanner", UDim2.new(0, 390, 0, 48), UDim2.new(0.5, -195, 0, 122), Color3.fromRGB(30, 69, 91))
banner.Visible = false
local bannerLabel = label(banner, "Countdown", "MONSOON WARNING", UDim2.new(1, -16, 1, 0), UDim2.new(0, 8, 0, 0), Color3.fromRGB(190, 239, 255), 20)
bannerLabel.TextXAlignment = Enum.TextXAlignment.Center

local notice = panel(gui, "Notice", UDim2.new(0, 450, 0, 42), UDim2.new(0.5, -225, 0.82, 0), Color3.fromRGB(41, 45, 46))
notice.Visible = false
local noticeText = label(notice, "NoticeText", "", UDim2.new(1, -18, 1, 0), UDim2.new(0, 9, 0, 0), Color3.new(1, 1, 1), 16)
noticeText.TextXAlignment = Enum.TextXAlignment.Center

local title = panel(gui, "TitleScreen", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(21, 38, 43))
title.BackgroundTransparency = 0.08
local titleName = label(title, "Title", "BRAINROT BAZAAR", UDim2.new(0.8, 0, 0, 100), UDim2.new(0.1, 0, 0.22, 0), Color3.fromRGB(255, 219, 131), 48)
titleName.TextXAlignment = Enum.TextXAlignment.Center
titleName.Font = Enum.Font.GothamBlack
local subtitle = label(title, "Subtitle", "Floating market collector", UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0.37, 0), Color3.fromRGB(210, 241, 235), 24)
subtitle.TextXAlignment = Enum.TextXAlignment.Center
local titleControls = label(title, "TitleControls", "WASD move   E buy   F place   L lock   R rebirth\nP pause   M mute", UDim2.new(0.8, 0, 0, 80), UDim2.new(0.1, 0, 0.48, 0), Color3.fromRGB(237, 232, 216), 20)
titleControls.TextXAlignment = Enum.TextXAlignment.Center
titleControls.TextYAlignment = Enum.TextYAlignment.Center
local startButton = button(title, "StartButton", "CLICK TO PLAY", UDim2.new(0, 250, 0, 58), UDim2.new(0.5, -125, 0.68, 0), function()
	playing = true
	title.Visible = false
end)
startButton.TextSize = 22

local pausePanel = panel(gui, "PausePanel", UDim2.new(0, 300, 0, 150), UDim2.new(0.5, -150, 0.5, -75), Color3.fromRGB(31, 40, 45))
pausePanel.Visible = false
local pauseLabel = label(pausePanel, "Paused", "PAUSED", UDim2.new(1, 0, 0, 70), UDim2.new(0, 0, 0, 12), Color3.fromRGB(255, 222, 151), 30)
pauseLabel.TextXAlignment = Enum.TextXAlignment.Center
button(pausePanel, "Resume", "RESUME [P]", UDim2.new(0.7, 0, 0, 42), UDim2.new(0.15, 0, 0.62, 0), function()
	paused = false
	pausePanel.Visible = false
end)

local function showNotice(message)
	noticeText.Text = tostring(message)
	notice.Visible = true
	task.delay(3, function() if notice.Parent then notice.Visible = false end end)
end

local function refresh()
	cashLabel.Text = "CASH  $" .. math.floor(state.cash or 0)
	rateLabel.Text = "$" .. string.format("%.0f", state.rate or 0) .. "/s"
	multiplierLabel.Text = "x" .. string.format("%.2f", state.multiplier or 1)
	rebirthLabel.Text = "REBIRTHS " .. tostring(state.rebirths or 0)
	missionLabel.Text = "MISSION  " .. tostring(state.mission or "Buy 3 brainrots")
	for slot = 1, 8 do
		local entry = state.pedestals and state.pedestals[slot]
		baseSlots[slot].Text = entry and (slot .. ". " .. entry.name .. " [" .. entry.mutation .. "]") or (slot .. ". Empty")
	end
	if state.locked then lockButton.Text = "LOCKED [L]" elseif state.lockReady == false then lockButton.Text = "LOCK RECHARGING" else lockButton.Text = "LOCK BASE [L]" end
	unlockLabel.Text = state.carry and ("Carrying: " .. state.carry.name .. " | choose empty slot") or "8 pedestals available"
end

local function nearestOffer()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local folder = workspace:FindFirstChild("BazaarWorld")
	local market = folder and folder:FindFirstChild("MarketOffers")
	if not root or not market then return nil end
	local best, bestDistance
	for index = 1, 4 do
		local stand = market:FindFirstChild("Offer_" .. index)
		if stand then
			local distance = (root.Position - stand.Position).Magnitude
			if distance < (bestDistance or math.huge) then best, bestDistance = index, distance end
		end
	end
	return best, bestDistance
end

local function buy()
	if not playing then return end
	local index, distance = nearestOffer()
	if index and distance <= 18 then remotes.BuyBrainrot:FireServer(index) else showNotice("Walk up to a market offer to buy it.") end
end

local function place()
	if not playing then return end
	for slot = 1, 8 do
		if not state.pedestals or not state.pedestals[slot] then
			remotes.PlaceBrainrot:FireServer(slot)
			return
		end
	end
	showNotice("All eight pedestals are full. Sell one to make space.")
end

local function togglePause()
	if not playing then return end
	paused = not paused
	pausePanel.Visible = paused
end

local actions = {
	Buy = function(_, inputState) if inputState == Enum.UserInputState.Begin then buy() end return Enum.ContextActionResult.Sink end,
	Place = function(_, inputState) if inputState == Enum.UserInputState.Begin then place() end return Enum.ContextActionResult.Sink end,
	Lock = function(_, inputState) if inputState == Enum.UserInputState.Begin and playing then remotes.ToggleLock:FireServer() end return Enum.ContextActionResult.Sink end,
	Rebirth = function(_, inputState) if inputState == Enum.UserInputState.Begin and playing then remotes.Rebirth:FireServer() end return Enum.ContextActionResult.Sink end,
	Pause = function(_, inputState) if inputState == Enum.UserInputState.Begin then togglePause() end return Enum.ContextActionResult.Sink end,
	Mute = function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			muted = not muted
			showNotice(muted and "Audio muted." or "Audio on.")
		end
		return Enum.ContextActionResult.Sink
	end,
}
ContextActionService:BindAction("BazaarBuy", actions.Buy, false, Enum.KeyCode.E)
ContextActionService:BindAction("BazaarPlace", actions.Place, false, Enum.KeyCode.F)
ContextActionService:BindAction("BazaarLock", actions.Lock, false, Enum.KeyCode.L)
ContextActionService:BindAction("BazaarRebirth", actions.Rebirth, false, Enum.KeyCode.R)
ContextActionService:BindAction("BazaarPause", actions.Pause, false, Enum.KeyCode.P)
ContextActionService:BindAction("BazaarMute", actions.Mute, false, Enum.KeyCode.M)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Return and not playing then
		playing = true
		title.Visible = false
	end
end)

remotes.StateUpdate.OnClientEvent:Connect(function(update)
	state = update
	refresh()
end)
remotes.Notice.OnClientEvent:Connect(function(message, value)
	if message == "Monsoon" then
		banner.Visible = true
		bannerLabel.Text = "MONSOON IN " .. tostring(value) .. "s — GET TO SHELTER!"
	elseif message == "MonsoonTick" then
		banner.Visible = true
		bannerLabel.Text = "MONSOON IN " .. tostring(value) .. "s — GET TO SHELTER!"
	elseif message == "Wave" then
		banner.Visible = true
		bannerLabel.Text = "MONSOON WAVE! Shelter under your roof or lighthouse!"
	elseif message == "MonsoonEnd" then
		banner.Visible = false
	else
		showNotice(message)
	end
end)

local function addBrainrotLabel(model)
	if model:FindFirstChild("FloatingLabel") then return end
	local anchor = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not anchor then return end
	local name = model:GetAttribute("BrainrotName") or model.Name
	local item = Data.Get(name)
	if not item then return end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "FloatingLabel"
	billboard.Size = UDim2.fromOffset(230, 92)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = anchor
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Name"
	titleLabel.Size = UDim2.new(1, 0, 0, 34)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = item.Name
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextStrokeTransparency = 0.55
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Parent = billboard
	local rarity = Instance.new("TextLabel")
	rarity.Name = "Rarity"
	rarity.Position = UDim2.new(0, 0, 0, 35)
	rarity.Size = UDim2.new(1, 0, 0, 25)
	rarity.BackgroundTransparency = 1
	rarity.Text = item.Rarity
	rarity.TextColor3 = Data.RarityColors[item.Rarity]
	rarity.TextScaled = true
	rarity.Font = Enum.Font.GothamBold
	rarity.Parent = billboard
	local rate = Instance.new("TextLabel")
	rate.Name = "Rate"
	rate.Position = UDim2.new(0, 0, 0, 61)
	rate.Size = UDim2.new(1, 0, 0, 24)
	rate.BackgroundTransparency = 1
	local mutation = model:GetAttribute("Mutation") or "NORMAL"
	local multiplier = Data.Mutations[mutation] or 1
	rate.Text = "$" .. item.Rate * multiplier .. "/s"
	rate.TextColor3 = Color3.fromRGB(100, 255, 125)
	rate.TextScaled = true
	rate.Font = Enum.Font.GothamBold
	rate.Parent = billboard
end

local function scanLabels()
	local folder = workspace:FindFirstChild("BazaarWorld")
	local bases = folder and folder:FindFirstChild("PlayerBases")
	if not bases then return end
	for _, base in ipairs(bases:GetChildren()) do
		for _, object in ipairs(base:GetChildren()) do
			if object:IsA("Model") and object.Name:match("^Placed_") then addBrainrotLabel(object) end
		end
	end
end

remotes.Income.OnClientEvent:Connect(function(amount)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local popup = Instance.new("BillboardGui")
	popup.Name = "IncomePopup"
	popup.Size = UDim2.fromOffset(130, 48)
	popup.StudsOffset = Vector3.new(math.random(-4, 4), 4, math.random(-3, 3))
	popup.AlwaysOnTop = true
	popup.Parent = root
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = "+$" .. tostring(amount)
	text.TextColor3 = Color3.fromRGB(100, 255, 125)
	text.TextStrokeTransparency = 0.5
	text.TextScaled = true
	text.Font = Enum.Font.GothamBlack
	text.Parent = popup
	TweenService:Create(popup, TweenInfo.new(1.2), { StudsOffset = popup.StudsOffset + Vector3.new(0, 3, 0) }):Play()
	task.delay(1.3, function() popup:Destroy() end)
end)

task.spawn(function()
	while gui.Parent do
		scanLabels()
		task.wait(1)
	end
end)

refresh()
