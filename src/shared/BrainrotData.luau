-- BRAINROT BAZAAR cast: the twelve food brainrots, their rarities and their math.
local BrainrotData = {}

BrainrotData.RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine" }

BrainrotData.RarityColor = {
	Common = Color3.fromRGB(190, 195, 203),
	Rare = Color3.fromRGB(70, 160, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 155, 55),
	Mythic = Color3.fromRGB(235, 65, 75),
	Divine = Color3.fromRGB(255, 220, 80),
}

BrainrotData.RarityWeight = {
	Common = 45,
	Rare = 25,
	Epic = 15,
	Legendary = 9,
	Mythic = 5,
	Divine = 1,
}

BrainrotData.MutationFactor = {
	NORMAL = 1,
	GOLD = 2,
	DIAMOND = 3,
	PEDAS = 5,
}

BrainrotData.Order = {
	"Bakso Bandit",
	"Kerupuk Knight",
	"Cireng Cyclops",
	"Sate Sensei",
	"Gado-Gado Goblin",
	"Es Cendol Cyber",
	"Soto Sphinx",
	"Martabak Monster",
	"Nasi Padang Paladin",
	"Rendang Rex",
	"Es Teh Sultan",
	"Klepon King",
}

BrainrotData.Entries = {
	["Bakso Bandit"] = { rarity = "Common", price = 50, rate = 1, blurb = "A round meatball outlaw carrying a sack." },
	["Kerupuk Knight"] = { rarity = "Common", price = 120, rate = 2, blurb = "A crunchy cracker knight with a shield." },
	["Cireng Cyclops"] = { rarity = "Rare", price = 350, rate = 5, blurb = "A chewy disc with one giant eye." },
	["Sate Sensei"] = { rarity = "Rare", price = 800, rate = 9, blurb = "A skewer master with a headband and a tiny katana." },
	["Gado-Gado Goblin"] = { rarity = "Epic", price = 2000, rate = 18, blurb = "A green goblin wearing a peanut-bowl hat." },
	["Es Cendol Cyber"] = { rarity = "Epic", price = 4500, rate = 32, blurb = "A drink robot with glowing cendol tubes." },
	["Soto Sphinx"] = { rarity = "Legendary", price = 9000, rate = 60, blurb = "A soup-bowl sphinx wearing a golden crown." },
	["Martabak Monster"] = { rarity = "Legendary", price = 18000, rate = 110, blurb = "A folded pancake beast with chocolate drips." },
	["Nasi Padang Paladin"] = { rarity = "Mythic", price = 40000, rate = 220, blurb = "A rice-mound knight with a rendang sword." },
	["Rendang Rex"] = { rarity = "Mythic", price = 90000, rate = 450, blurb = "A saucy little tyrant with a tiny crown." },
	["Es Teh Sultan"] = { rarity = "Divine", price = 250000, rate = 1200, blurb = "A sultan seated on a giant iced-tea throne." },
	["Klepon King"] = { rarity = "Divine", price = 500000, rate = 2000, blurb = "A green coconut king with a crown and a red cape." },
}

-- Full record for a name, or nil when the name is not in the cast.
function BrainrotData.find(name)
	local entry = BrainrotData.Entries[name]
	if entry == nil then
		return nil
	end
	return {
		name = name,
		rarity = entry.rarity,
		price = entry.price,
		rate = entry.rate,
		blurb = entry.blurb,
		color = BrainrotData.RarityColor[entry.rarity],
	}
end

-- Rebirth n costs 5000 * (n + 1)^2, where n is the rebirths already done.
function BrainrotData.rebirthPrice(rebirths)
	local step = (rebirths or 0) + 1
	return 5000 * step * step
end

-- Dollars per second: base rate times the mutation factor times the rebirth boost.
function BrainrotData.earnPerSecond(entry, mutation, boost)
	local factor = BrainrotData.MutationFactor[mutation or "NORMAL"] or 1
	return entry.rate * factor * (boost or 1)
end

return BrainrotData
