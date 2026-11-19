-- BRAINROT BAZAAR client: title screen, HUD, prompts, labels and popups.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local Data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local view = { cash = 250, rate = 0, boost = 1, rebirths = 0, slots = {}, offers = {} }
local playing = false
local paused = false
local muted = false

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBazaarHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

-- A rounded panel.
local function mkFrame(parent, name, size, pos, color, round)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = pos
	frame.BackgroundColor3 = color or Color3.fromRGB(34, 38, 43)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, round or 10)
	corner.Parent = frame
	return frame
end

-- A left-aligned label (or centered when align is passed).
local function mkText(parent, name, str, size, pos, color, px, align)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Size = size
	item.Position = pos
	item.BackgroundTransparency = 1
	item.Text = str
	item.TextColor3 = color or Color3.new(1, 1, 1)
	item.TextSize = px or 18
	item.Font = Enum.Font.GothamSemibold
	item.TextXAlignment = align or Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

-- A warm orange button that runs a callback when pressed.
local function mkButton(parent, name, str, size, pos, onClick)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Size = size
	item.Position = pos
	item.BackgroundColor3 = Color3.fromRGB(168, 80, 40)
	item.TextColor3 = Color3.new(1, 1, 1)
	item.Text = str
	item.TextSize = 16
	item.Font = Enum.Font.GothamBold
	item.AutoButtonColor = true
	item.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = item
	item.Activated:Connect(onClick)
	return item
end

-- Top status bar: cash, income rate, rebirth multiplier, rebirth count.
local topBar = mkFrame(gui, "TopStatus", UDim2.new(0.58, 0, 0, 56), UDim2.new(0.21, 0, 0, 12), Color3.fromRGB(33, 42, 44))
topBar.BackgroundTransparency = 0.05
local cashText = mkText(topBar, "Cash", "CASH  $250", UDim2.new(0.3, 0, 1, 0), UDim2.new(0.025, 0, 0, 0), Color3.fromRGB(255, 231, 145), 21)
local rateText = mkText(topBar, "Rate", "$0/s", UDim2.new(0.2, 0, 1, 0), UDim2.new(0.34, 0, 0, 0), Color3.fromRGB(122, 255, 147), 19)
local boostText = mkText(topBar, "Multiplier", "x1.00", UDim2.new(0.16, 0, 1, 0), UDim2.new(0.58, 0, 0, 0), Color3.fromRGB(155, 218, 255), 19)
local rebirthText = mkText(topBar, "Rebirths", "REBIRTHS 0", UDim2.new(0.23, 0, 1, 0), UDim2.new(0.76, 0, 0, 0), Color3.fromRGB(255, 205, 125), 16)

-- Mission strip under the status bar.
local missionBar = mkFrame(gui, "MissionPanel", UDim2.new(0.42, 0, 0, 34), UDim2.new(0.29, 0, 0, 76), Color3.fromRGB(61, 52, 37))
local missionText = mkText(missionBar, "Mission", "MISSION  Buy your first brainrot", UDim2.new(1, -18, 1, 0), UDim2.new(0, 10, 0, 0), Color3.fromRGB(255, 224, 145), 16)

-- MY BASE: the eight pedestal slots, each with a SELL button.
local basePanel = mkFrame(gui, "MyBase", UDim2.new(0, 240, 0, 330), UDim2.new(0, 14, 0.25, 0), Color3.fromRGB(39, 48, 47))
mkText(basePanel, "BaseTitle", "MY BASE", UDim2.new(1, -18, 0, 36), UDim2.new(0, 12, 0, 7), Color3.fromRGB(255, 224, 150), 22)
local slotTexts = {}
for slot = 1, 8 do
	local y = 48 + (slot - 1) * 31
	slotTexts[slot] = mkText(basePanel, "Slot" .. slot, slot .. ". Empty", UDim2.new(0.68, 0, 0, 29), UDim2.new(0, 12, 0, y), Color3.fromRGB(232, 237, 231), 14)
	local sell = mkButton(basePanel, "Sell" .. slot, "SELL", UDim2.new(0.23, 0, 0, 25), UDim2.new(0.74, 0, 0, y + 2), function()
		remotes.SellBrainrot:FireServer(slot)
	end)
	sell.TextSize = 12
end
local carryText = mkText(basePanel, "SlotInfo", "8 pedestals available", UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 1, -34), Color3.fromRGB(172, 224, 186), 13)

-- Lock and rebirth buttons on the right.
local actionPanel = mkFrame(gui, "Actions", UDim2.new(0, 186, 0, 112), UDim2.new(1, -200, 0, 118), Color3.fromRGB(44, 42, 39))
local lockButton = mkButton(actionPanel, "LockButton", "LOCK BASE [L]", UDim2.new(1, -14, 0, 40), UDim2.new(0, 7, 0, 7), function()
	remotes.ToggleLock:FireServer()
end)
mkButton(actionPanel, "RebirthButton", "REBIRTH [R]", UDim2.new(1, -14, 0, 40), UDim2.new(0, 7, 0, 58), function()
	remotes.Rebirth:FireServer()
end)

-- Bottom prompt bar with every key.
local promptBar = mkFrame(gui, "Prompts", UDim2.new(0.56, 0, 0, 42), UDim2.new(0.22, 0, 1, -56), Color3.fromRGB(32, 38, 43))
local _promptText = mkText(promptBar, "PromptText", "E  BUY OFFER     F  PLACE     L  LOCK     R  REBIRTH     P  PAUSE     M  MUTE", UDim2.new(1, -16, 1, 0), UDim2.new(0, 9, 0, 0), Color3.fromRGB(245, 239, 215), 14, Enum.TextXAlignment.Center)

-- Monsoon banner, hidden until a warning arrives.
local banner = mkFrame(gui, "MonsoonBanner", UDim2.new(0, 400, 0, 48), UDim2.new(0.5, -200, 0, 120), Color3.fromRGB(30, 69, 91))
banner.Visible = false
local bannerText = mkText(banner, "Countdown", "MONSOON WARNING", UDim2.new(1, -16, 1, 0), UDim2.new(0, 8, 0, 0), Color3.fromRGB(190, 239, 255), 20, Enum.TextXAlignment.Center)

-- One-line notice popup, hidden until a message arrives.
local noticePanel = mkFrame(gui, "Notice", UDim2.new(0, 460, 0, 42), UDim2.new(0.5, -230, 0.82, 0), Color3.fromRGB(41, 45, 46))
noticePanel.Visible = false
local noticeText = mkText(noticePanel, "NoticeText", "", UDim2.new(1, -18, 1, 0), UDim2.new(0, 9, 0, 0), Color3.new(1, 1, 1), 16, Enum.TextXAlignment.Center)

-- Title screen, drawn last so it covers everything until play starts.
local titleScreen = mkFrame(gui, "TitleScreen", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(21, 38, 43), 0)
titleScreen.BackgroundTransparency = 0.08
local titleName = mkText(titleScreen, "Title", "BRAINROT BAZAAR", UDim2.new(0.8, 0, 0, 100), UDim2.new(0.1, 0, 0.22, 0), Color3.fromRGB(255, 219, 131), 48, Enum.TextXAlignment.Center)
titleName.Font = Enum.Font.GothamBlack
mkText(titleScreen, "Subtitle", "Floating market collector", UDim2.new(0.8, 0, 0, 42), UDim2.new(0.1, 0, 0.37, 0), Color3.fromRGB(210, 241, 235), 24, Enum.TextXAlignment.Center)
local helpText = mkText(titleScreen, "TitleControls", "WASD move   E buy   F place   L lock   R rebirth\nP pause   M mute", UDim2.new(0.8, 0, 0, 80), UDim2.new(0.1, 0, 0.48, 0), Color3.fromRGB(237, 232, 216), 20, Enum.TextXAlignment.Center)
helpText.TextYAlignment = Enum.TextYAlignment.Center
local startButton = mkButton(titleScreen, "StartButton", "CLICK TO PLAY", UDim2.new(0, 250, 0, 58), UDim2.new(0.5, -125, 0.68, 0), function()
	playing = true
	titleScreen.Visible = false
end)
startButton.TextSize = 22

-- Pause panel, hidden until P is pressed.
local pausePanel = mkFrame(gui, "PausePanel", UDim2.new(0, 300, 0, 150), UDim2.new(0.5, -150, 0.5, -75), Color3.fromRGB(31, 40, 45))
pausePanel.Visible = false
local _pauseTitle = mkText(pausePanel, "Paused", "PAUSED", UDim2.new(1, 0, 0, 70), UDim2.new(0, 0, 0, 12), Color3.fromRGB(255, 222, 151), 30, Enum.TextXAlignment.Center)
mkButton(pausePanel, "Resume", "RESUME [P]", UDim2.new(0.7, 0, 0, 42), UDim2.new(0.15, 0, 0.62, 0), function()
	paused = false
	pausePanel.Visible = false
end)

local function showNotice(message)
	noticeText.Text = tostring(message)
	noticePanel.Visible = true
	task.delay(3, function()
		if noticePanel.Parent ~= nil then
			noticePanel.Visible = false
		end
	end)
end

-- Rewrite every HUD label from the latest server state.
local function refresh()
	cashText.Text = "CASH  $" .. math.floor(view.cash or 0)
	rateText.Text = "$" .. string.format("%.0f", view.rate or 0) .. "/s"
	boostText.Text = "x" .. string.format("%.2f", view.boost or 1)
	rebirthText.Text = "REBIRTHS " .. tostring(view.rebirths or 0)
	missionText.Text = "MISSION  " .. tostring(view.mission or "Buy your first brainrot")
	for slot = 1, 8 do
		local entry = view.slots and view.slots[slot]
		if entry ~= nil then
			slotTexts[slot].Text = slot .. ". " .. entry.name .. " [" .. entry.mutation .. "]"
		else
			slotTexts[slot].Text = slot .. ". Empty"
		end
	end
	if view.locked then
		lockButton.Text = "LOCKED [L]"
	elseif view.lockReady == false then
		lockButton.Text = "LOCK RECHARGING"
	else
		lockButton.Text = "LOCK BASE [L]"
	end
	if view.carried ~= nil then
		carryText.Text = "Carrying: " .. view.carried.name .. " | choose empty slot"
	else
		carryText.Text = "8 pedestals available"
	end
end

-- The nearest market offer stand and its distance, or nil when none is close.
local function nearestStand()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local folder = workspace:FindFirstChild("BazaarWorld")
	local market = folder and folder:FindFirstChild("MarketOffers")
	if root == nil or market == nil then
		return nil
	end
	local best, bestDistance
	for index = 1, 4 do
		local stand = market:FindFirstChild("Offer_" .. index)
		if stand ~= nil then
			local distance = (root.Position - stand.Position).Magnitude
			if distance < (bestDistance or math.huge) then
				best, bestDistance = index, distance
			end
		end
	end
	return best, bestDistance
end

local function buy()
	if not playing then
		return
	end
	local index, distance = nearestStand()
	if index ~= nil and distance <= 18 then
		remotes.BuyBrainrot:FireServer(index)
	else
		showNotice("Walk up to a market offer to buy it.")
	end
end

local function place()
	if not playing then
		return
	end
	for slot = 1, 8 do
		if view.slots == nil or view.slots[slot] == nil then
			remotes.PlaceBrainrot:FireServer(slot)
			return
		end
	end
	showNotice("All eight pedestals are full. Sell one to make space.")
end

local function togglePause()
	if not playing then
		return
	end
	paused = not paused
	pausePanel.Visible = paused
end

local actions = {
	Buy = function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			buy()
		end
		return Enum.ContextActionResult.Sink
	end,
	Place = function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			place()
		end
		return Enum.ContextActionResult.Sink
	end,
	Lock = function(_, inputState)
		if inputState == Enum.UserInputState.Begin and playing then
			remotes.ToggleLock:FireServer()
		end
		return Enum.ContextActionResult.Sink
	end,
	Rebirth = function(_, inputState)
		if inputState == Enum.UserInputState.Begin and playing then
			remotes.Rebirth:FireServer()
		end
		return Enum.ContextActionResult.Sink
	end,
	Pause = function(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			togglePause()
		end
		return Enum.ContextActionResult.Sink
	end,
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
		titleScreen.Visible = false
	end
end)

remotes.StateUpdate.OnClientEvent:Connect(function(update)
	view = update
	refresh()
end)

remotes.Notice.OnClientEvent:Connect(function(message, value)
	if message == "Monsoon" or message == "MonsoonTick" then
		banner.Visible = true
		bannerText.Text = "MONSOON IN " .. tostring(value) .. "s - GET TO SHELTER!"
	elseif message == "Wave" then
		banner.Visible = true
		bannerText.Text = "MONSOON WAVE! Shelter under your roof or lighthouse!"
	elseif message == "MonsoonEnd" then
		banner.Visible = false
	else
		showNotice(message)
	end
end)

-- A floating name / rarity / rate label over one placed brainrot model.
local function addBrainrotLabel(model)
	if model:FindFirstChild("FloatingLabel") ~= nil then
		return
	end
	local anchor = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if anchor == nil then
		return
	end
	local name = model:GetAttribute("BrainrotName") or model.Name
	local item = Data.find(name)
	if item == nil then
		return
	end
	local board = Instance.new("BillboardGui")
	board.Name = "FloatingLabel"
	board.Size = UDim2.fromOffset(230, 92)
	board.StudsOffset = Vector3.new(0, 4, 0)
	board.AlwaysOnTop = true
	board.Parent = anchor
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, 0, 0, 34)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.55
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Parent = board
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Position = UDim2.new(0, 0, 0, 35)
	rarityLabel.Size = UDim2.new(1, 0, 0, 25)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = item.rarity
	rarityLabel.TextColor3 = Data.RarityColor[item.rarity]
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = board
	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "Rate"
	rateLabel.Position = UDim2.new(0, 0, 0, 61)
	rateLabel.Size = UDim2.new(1, 0, 0, 24)
	rateLabel.BackgroundTransparency = 1
	local mutation = model:GetAttribute("Mutation") or "NORMAL"
	local factor = Data.MutationFactor[mutation] or 1
	rateLabel.Text = "$" .. item.rate * factor .. "/s"
	rateLabel.TextColor3 = Color3.fromRGB(100, 255, 125)
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.GothamBold
	rateLabel.Parent = board
end

local function scanLabels()
	local folder = workspace:FindFirstChild("BazaarWorld")
	local bases = folder and folder:FindFirstChild("PlayerBases")
	if bases == nil then
		return
	end
	for _, base in ipairs(bases:GetChildren()) do
		for _, object in ipairs(base:GetChildren()) do
			if object:IsA("Model") and object.Name:match("^Placed_") then
				addBrainrotLabel(object)
			end
		end
	end
end

-- A green "+$N" popup that floats up over the player and fades away.
remotes.Income.OnClientEvent:Connect(function(amount)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return
	end
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
	task.delay(1.3, function()
		popup:Destroy()
	end)
end)

task.spawn(function()
	while gui.Parent ~= nil do
		scanLabels()
		task.wait(1)
	end
end)

refresh()
