-- Config.luau — every tunable number for BRAINROT BAZAAR in one place.
-- Server and client both read from here; nothing else hard-codes a value.

local Config = {}

-- Economy
Config.StartCash = 250
Config.PedestalCount = 8
Config.SellRefund = 0.5
Config.RebirthBaseCost = 5000
Config.RebirthIncomeBonus = 0.25

-- Timing (seconds)
Config.IncomeTick = 1
Config.MarketCycle = 20
Config.ThiefInterval = 90
Config.MonsoonInterval = 240
Config.MonsoonWarning = 30
Config.LockDuration = 60
Config.LockCooldown = 30

-- Interaction
Config.InteractRange = 18
Config.ShelterRange = 16
Config.MarketOfferCount = 4

-- World layout
Config.BaseCount = 8
Config.WaterSize = Vector3.new(280, 1, 220)
Config.WaterPosition = Vector3.new(0, -4, 0)
Config.DockSize = Vector3.new(180, 2, 22)
Config.DockPosition = Vector3.new(0, 0, 0)
Config.LighthousePosition = Vector3.new(112, 0, 76)
Config.SpawnPosition = Vector3.new(0, 2, -5)

-- The eight player bases, arranged in two rows around the dock.
Config.BasePositions = {
	Vector3.new(-90, 0, -60),
	Vector3.new(-30, 0, -70),
	Vector3.new(30, 0, -70),
	Vector3.new(90, 0, -60),
	Vector3.new(-90, 0, 60),
	Vector3.new(-30, 0, 70),
	Vector3.new(30, 0, 70),
	Vector3.new(90, 0, 60),
}

-- The four market stalls sit on the main dock.
Config.StallPositions = {
	Vector3.new(-60, 1, 0),
	Vector3.new(-20, 1, 0),
	Vector3.new(20, 1, 0),
	Vector3.new(60, 1, 0),
}

-- RemoteEvent names, shared by server and client so they can never drift.
Config.Remotes = {
	Buy = "BuyBrainrot",
	Place = "PlaceBrainrot",
	Sell = "SellBrainrot",
	Rebirth = "Rebirth",
	Lock = "ToggleLock",
	State = "StateUpdate",
	Notice = "Notice",
	Income = "Income",
}
Config.RemoteFolderName = "BazaarRemotes"

-- Rarity order, weakest first.
Config.RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine" }

return Config
