-- Game.client.luau — every screen the player sees: title, HUD, base
-- panel, missions, prompts, monsoon banner, notices and pause.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local BrainrotData = require(ReplicatedStorage.Shared.BrainrotData)
local UiKit = require(ReplicatedStorage.Shared.UiKit)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild(Config.RemoteFolderName)

local function remote(name)
	return remotes:WaitForChild(name)
end

local BuyEvent = remote(Config.Remotes.Buy)
local PlaceEvent = remote(Config.Remotes.Place)
local SellEvent = remote(Config.Remotes.Sell)
local RebirthEvent = remote(Config.Remotes.Rebirth)
local LockEvent = remote(Config.Remotes.Lock)
local StateEvent = remote(Config.Remotes.State)
local NoticeEvent = remote(Config.Remotes.Notice)
local IncomeEvent = remote(Config.Remotes.Income)

local state = nil
local muted = false
local paused = false
local popupCount = 0

local NAVY = Color3.fromRGB(22, 28, 45)
local GOLD = Color3.fromRGB(255, 200, 80)
local GREEN = Color3.fromRGB(80, 255, 120)

local gui = Instance.new("ScreenGui")
gui.Name = "BazaarGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Top bar: cash, rate, multiplier, rebirths.
local topBar = UiKit.Frame(gui, {
	Name = "TopBar",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 12),
	Size = UDim2.new(0, 620, 0, 46),
	BackgroundColor3 = NAVY,
	BackgroundTransparency = 0.15,
})
UiKit.Corner(topBar, 12)
UiKit.Stroke(topBar)
local cashLabel = UiKit.Label(topBar, {
	Name = "Cash",
	Position = UDim2.new(0, 14, 0, 0),
	Size = UDim2.new(0, 170, 1, 0),
	Text = "$250",
	TextSize = 22,
	TextColor3 = GOLD,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local rateLabel = UiKit.Label(topBar, {
	Name = "Rate",
	Position = UDim2.new(0, 190, 0, 0),
	Size = UDim2.new(0, 150, 1, 0),
	Text = "$0/s",
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local multLabel = UiKit.Label(topBar, {
	Name = "Multiplier",
	Position = UDim2.new(0, 350, 0, 0),
	Size = UDim2.new(0, 130, 1, 0),
	Text = "x1.0",
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local rebirthLabel = UiKit.Label(topBar, {
	Name = "Rebirths",
	Position = UDim2.new(0, 490, 0, 0),
	Size = UDim2.new(0, 116, 1, 0),
	Text = "Rebirth 0",
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
})

-- Mission panel, left side.
local missionPanel = UiKit.Frame(gui, {
	Name = "MissionPanel",
	Position = UDim2.new(0, 14, 0, 90),
	Size = UDim2.new(0, 250, 0, 150),
	BackgroundColor3 = NAVY,
	BackgroundTransparency = 0.2,
})
UiKit.Corner(missionPanel, 12)
UiKit.Stroke(missionPanel)
UiKit.Label(missionPanel, {
	Name = "Header",
	Position = UDim2.new(0, 12, 0, 8),
	Size = UDim2.new(1, -24, 0, 24),
	Text = "MISSIONS",
	TextSize = 17,
	TextColor3 = GOLD,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local missionLines = {
	"1. Buy your first brainrot (E)",
	"2. Fill all 8 pedestals",
	"3. Rebirth for +25% income",
}
for i, line in ipairs(missionLines) do
	UiKit.Label(missionPanel, {
		Name = "Mission" .. i,
		Position = UDim2.new(0, 12, 0, 36 + (i - 1) * 32),
		Size = UDim2.new(1, -24, 0, 28),
		Text = line,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

-- My Base panel, right side, with one row per pedestal.
local basePanel = UiKit.Frame(gui, {
	Name = "BasePanel",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 90),
	Size = UDim2.new(0, 280, 0, 330),
	BackgroundColor3 = NAVY,
	BackgroundTransparency = 0.2,
})
UiKit.Corner(basePanel, 12)
UiKit.Stroke(basePanel)
UiKit.Label(basePanel, {
	Name = "Header",
	Position = UDim2.new(0, 12, 0, 8),
	Size = UDim2.new(1, -24, 0, 24),
	Text = "MY BASE",
	TextSize = 17,
	TextColor3 = GOLD,
	TextXAlignment = Enum.TextXAlignment.Left,
})
local slotRows = {}
for slot = 1, Config.PedestalCount do
	local row = UiKit.Frame(basePanel, {
		Name = "Slot" .. slot,
		Position = UDim2.new(0, 10, 0, 38 + (slot - 1) * 34),
		Size = UDim2.new(1, -20, 0, 30),
		BackgroundColor3 = Color3.fromRGB(35, 42, 62),
		BackgroundTransparency = 0.1,
	})
	UiKit.Corner(row, 8)
	local nameLabel = UiKit.Label(row, {
		Name = "SlotName",
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -70, 1, 0),
		Text = "Empty pedestal",
		TextSize = 13,
		TextColor3 = Color3.fromRGB(180, 185, 200),
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local sellButton = UiKit.Button(row, {
		Name = "SellButton",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0, 56, 0, 22),
		BackgroundColor3 = Color3.fromRGB(170, 60, 60),
		Text = "SELL",
		TextSize = 12,
		Visible = false,
	})
	UiKit.Corner(sellButton, 6)
	sellButton.MouseButton1Click:Connect(function()
		SellEvent:FireServer(slot)
	end)
	slotRows[slot] = { Name = nameLabel, Sell = sellButton }
end

-- Action buttons under the base panel.
local lockButton = UiKit.Pill(gui, UDim2.new(1, -294, 0, 434), UDim2.new(0, 132, 0, 40), Color3.fromRGB(60, 110, 200), "LOCK BASE", 14)
lockButton.Name = "LockButton"
local rebirthButton = UiKit.Pill(gui, UDim2.new(1, -152, 0, 434), UDim2.new(0, 138, 0, 40), Color3.fromRGB(160, 60, 180), "REBIRTH", 14)
rebirthButton.Name = "RebirthButton"
lockButton.MouseButton1Click:Connect(function()
	LockEvent:FireServer()
end)
rebirthButton.MouseButton1Click:Connect(function()
	RebirthEvent:FireServer()
end)

-- Prompts bar along the bottom.
local promptsBar = UiKit.Frame(gui, {
	Name = "PromptsBar",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.new(0, 640, 0, 34),
	BackgroundColor3 = NAVY,
	BackgroundTransparency = 0.25,
})
UiKit.Corner(promptsBar, 10)
UiKit.Label(promptsBar, {
	Name = "Prompts",
	Size = UDim2.new(1, 0, 1, 0),
	Text = "E Buy   |   F Place   |   L Lock   |   R Rebirth   |   P Pause   |   M Mute",
	TextSize = 15,
})

-- Monsoon banner, hidden until the warning.
local monsoonBanner = UiKit.Frame(gui, {
	Name = "MonsoonBanner",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 66),
	Size = UDim2.new(0, 460, 0, 40),
	BackgroundColor3 = Color3.fromRGB(30, 90, 140),
	BackgroundTransparency = 0.1,
	Visible = false,
})
UiKit.Corner(monsoonBanner, 10)
UiKit.Stroke(monsoonBanner, Color3.fromRGB(120, 220, 255))
local monsoonText = UiKit.Label(monsoonBanner, {
	Name = "MonsoonText",
	Size = UDim2.new(1, 0, 1, 0),
	Text = "MONSOON INCOMING",
	TextSize = 18,
	TextColor3 = Color3.fromRGB(180, 235, 255),
})

-- Notice popup.
local noticeLabel = UiKit.Label(gui, {
	Name = "Notice",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 116),
	Size = UDim2.new(0, 520, 0, 34),
	Text = "",
	TextSize = 17,
	Visible = false,
})

-- Pause panel.
local pausePanel = UiKit.Frame(gui, {
	Name = "PausePanel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 360, 0, 180),
	BackgroundColor3 = NAVY,
	BackgroundTransparency = 0.05,
	Visible = false,
})
UiKit.Corner(pausePanel, 14)
UiKit.Stroke(pausePanel, GOLD)
UiKit.Label(pausePanel, {
	Name = "PauseTitle",
	Position = UDim2.new(0, 0, 0, 30),
	Size = UDim2.new(1, 0, 0, 44),
	Text = "PAUSED",
	TextSize = 32,
	TextColor3 = GOLD,
})
UiKit.Label(pausePanel, {
	Name = "PauseHint",
	Position = UDim2.new(0, 0, 0, 92),
	Size = UDim2.new(1, 0, 0, 30),
	Text = "Press P to resume",
	TextSize = 16,
	TextColor3 = Color3.fromRGB(200, 205, 220),
})

-- Title screen on top of everything.
local titleScreen = UiKit.Frame(gui, {
	Name = "TitleScreen",
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(12, 16, 30),
	BackgroundTransparency = 0.05,
})
UiKit.Label(titleScreen, {
	Name = "Title",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 130),
	Size = UDim2.new(0, 700, 0, 70),
	Text = "BRAINROT BAZAAR",
	TextSize = 54,
	TextColor3 = GOLD,
})
UiKit.Label(titleScreen, {
	Name = "Subtitle",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 205),
	Size = UDim2.new(0, 700, 0, 32),
	Text = "A floating market of Indonesian street-food brainrots",
	TextSize = 19,
	TextColor3 = Color3.fromRGB(210, 215, 230),
})
UiKit.Label(titleScreen, {
	Name = "Controls",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 270),
	Size = UDim2.new(0, 700, 0, 90),
	Text = "Buy brainrots at the stalls, carry them home, place them on your pedestals.\nEarn cash every second. Rebirth to multiply it. Beware the monsoon and the thief.",
	TextSize = 16,
	TextColor3 = Color3.fromRGB(180, 185, 200),
})
local playButton = UiKit.Pill(titleScreen, UDim2.new(0.5, -110, 0, 400), UDim2.new(0, 220, 0, 54), Color3.fromRGB(40, 160, 80), "CLICK TO PLAY", 20)
playButton.Name = "PlayButton"
playButton.MouseButton1Click:Connect(function()
	titleScreen.Visible = false
end)

local function showNotice(text)
	noticeLabel.Text = text
	noticeLabel.Visible = true
	noticeLabel.TextTransparency = 0
	task.delay(2.5, function()
		TweenService:Create(noticeLabel, TweenInfo.new(0.8), { TextTransparency = 1 }):Play()
		task.delay(0.8, function()
			noticeLabel.Visible = false
		end)
	end)
end

local function spawnIncomePopup(amount)
	popupCount += 1
	local slot = (popupCount - 1) % 5
	local popup = UiKit.Label(gui, {
		Name = "IncomePopup",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, -120 + slot * 50, 0, 160),
		Size = UDim2.new(0, 120, 0, 30),
		Text = "+$" .. amount,
		TextSize = 20,
		TextColor3 = GREEN,
	})
	local tween = TweenService:Create(popup, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -120 + slot * 50, 0, 110),
		TextTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		popup:Destroy()
	end)
end

local function refreshBasePanel()
	if not state then
		return
	end
	for slot = 1, Config.PedestalCount do
		local row = slotRows[slot]
		local entry = state.Pedestals[slot]
		if entry then
			local data = BrainrotData.Find(entry.Name)
			local rate = data and math.floor(BrainrotData.IncomePerSecond(data, entry.Mutation, state.Rebirths)) or 0
			row.Name.Text = entry.Name .. "  $" .. rate .. "/s"
			row.Name.TextColor3 = BrainrotData.RarityColors[data.Rarity]
			row.Sell.Visible = true
		else
			row.Name.Text = "Empty pedestal"
			row.Name.TextColor3 = Color3.fromRGB(180, 185, 200)
			row.Sell.Visible = false
		end
	end
end

local function refreshTopBar()
	if not state then
		return
	end
	cashLabel.Text = "$" .. state.Cash
	rateLabel.Text = "$" .. state.Rate .. "/s"
	multLabel.Text = "x" .. string.format("%.2f", state.Multiplier)
	rebirthLabel.Text = "Rebirth " .. state.Rebirths
	if state.Locked then
		lockButton.Text = "LOCKED " .. state.LockLeft .. "s"
		lockButton.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
	else
		lockButton.Text = "LOCK BASE"
		lockButton.BackgroundColor3 = Color3.fromRGB(60, 110, 200)
	end
end

StateEvent.OnClientEvent:Connect(function(payload)
	state = payload
	refreshTopBar()
	refreshBasePanel()
end)

IncomeEvent.OnClientEvent:Connect(function(gain, cash, rate)
	if state then
		state.Cash = cash
		state.Rate = rate
		refreshTopBar()
	end
	spawnIncomePopup(gain)
end)

local monsoonCounting = false
NoticeEvent.OnClientEvent:Connect(function(text)
	showNotice(text)
	if string.find(text, "MONSOON INCOMING", 1, true) and not monsoonCounting then
		monsoonCounting = true
		monsoonBanner.Visible = true
		task.spawn(function()
			for left = Config.MonsoonWarning, 1, -1 do
				monsoonText.Text = "MONSOON IN " .. left .. "s - TAKE SHELTER!"
				task.wait(1)
			end
			monsoonText.Text = "MONSOON WAVE!"
		end)
	elseif text == "The monsoon has passed." then
		monsoonBanner.Visible = false
		monsoonCounting = false
	end
end)

local function nearestStallIndex()
	local character = player.Character
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local best = nil
	local bestDistance = Config.InteractRange
	for index, stallPos in ipairs(Config.StallPositions) do
		local distance = (root.Position - stallPos).Magnitude
		if distance <= bestDistance then
			best = index
			bestDistance = distance
		end
	end
	return best
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local key = input.KeyCode
	if key == Enum.KeyCode.P then
		paused = not paused
		pausePanel.Visible = paused
		return
	end
	if paused then
		return
	end
	if key == Enum.KeyCode.M then
		muted = not muted
		showNotice(muted and "Sound muted." or "Sound on.")
	elseif key == Enum.KeyCode.E then
		local stall = nearestStallIndex()
		if stall then
			BuyEvent:FireServer(stall)
		else
			showNotice("Get closer to a market stall.")
		end
	elseif key == Enum.KeyCode.F then
		PlaceEvent:FireServer()
	elseif key == Enum.KeyCode.L then
		LockEvent:FireServer()
	elseif key == Enum.KeyCode.R then
		RebirthEvent:FireServer()
	end
end)
