-- BrainrotData.luau — the twelve original Indonesian street-food brainrots,
-- their rarities, prices, income rates, mutations and the economy formulas.

local Config = require(script.Parent.Config)

local BrainrotData = {}

BrainrotData.Characters = {
	{ Name = "Bakso Bandit", Rarity = "Common", Price = 50, Rate = 1, Body = Color3.fromRGB(150, 100, 60), Blurb = "A round meatball outlaw with a sack." },
	{ Name = "Kerupuk Knight", Rarity = "Common", Price = 120, Rate = 2, Body = Color3.fromRGB(230, 190, 90), Blurb = "A crisp cracker knight with a shield." },
	{ Name = "Cireng Cyclops", Rarity = "Rare", Price = 350, Rate = 5, Body = Color3.fromRGB(240, 225, 200), Blurb = "A chewy disc with one enormous eye." },
	{ Name = "Sate Sensei", Rarity = "Rare", Price = 800, Rate = 9, Body = Color3.fromRGB(120, 70, 30), Blurb = "A skewer master with headband and tiny katana." },
	{ Name = "Gado-Gado Goblin", Rarity = "Epic", Price = 2000, Rate = 18, Body = Color3.fromRGB(90, 160, 70), Blurb = "A green goblin wearing a peanut bowl hat." },
	{ Name = "Es Cendol Cyber", Rarity = "Epic", Price = 4500, Rate = 32, Body = Color3.fromRGB(120, 200, 180), Blurb = "A drink robot with glowing cendol tubes." },
	{ Name = "Soto Sphinx", Rarity = "Legendary", Price = 9000, Rate = 60, Body = Color3.fromRGB(240, 200, 60), Blurb = "A soup-bowl sphinx with a golden crown." },
	{ Name = "Martabak Monster", Rarity = "Legendary", Price = 18000, Rate = 110, Body = Color3.fromRGB(110, 70, 40), Blurb = "A folded pancake beast with chocolate drips." },
	{ Name = "Nasi Padang Paladin", Rarity = "Mythic", Price = 40000, Rate = 220, Body = Color3.fromRGB(250, 245, 235), Blurb = "A rice-mound knight with a rendang sword." },
	{ Name = "Rendang Rex", Rarity = "Mythic", Price = 90000, Rate = 450, Body = Color3.fromRGB(90, 50, 25), Blurb = "A saucy little tyrant with a tiny crown." },
	{ Name = "Es Teh Sultan", Rarity = "Divine", Price = 250000, Rate = 1200, Body = Color3.fromRGB(200, 130, 50), Blurb = "A sultan seated on a giant iced-tea throne." },
	{ Name = "Klepon King", Rarity = "Divine", Price = 500000, Rate = 2000, Body = Color3.fromRGB(60, 170, 90), Blurb = "A green coconut king with a crown and red cape." },
}

BrainrotData.RarityColors = {
	Common = Color3.fromRGB(190, 195, 203),
	Rare = Color3.fromRGB(70, 160, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 155, 55),
	Mythic = Color3.fromRGB(235, 65, 75),
	Divine = Color3.fromRGB(255, 220, 80),
}

BrainrotData.RarityWeights = {
	Common = 45,
	Rare = 25,
	Epic = 15,
	Legendary = 9,
	Mythic = 5,
	Divine = 1,
}

BrainrotData.Mutations = {
	NORMAL = 1,
	GOLD = 2,
	DIAMOND = 3,
	PEDAS = 5,
}

-- Chances for a market offer to carry a mutation.
BrainrotData.MutationRolls = {
	{ Name = "NORMAL", Weight = 80 },
	{ Name = "GOLD", Weight = 12 },
	{ Name = "DIAMOND", Weight = 6 },
	{ Name = "PEDAS", Weight = 2 },
}

local byName = {}
for _, entry in ipairs(BrainrotData.Characters) do
	byName[entry.Name] = entry
end

function BrainrotData.Find(name)
	return byName[name]
end

function BrainrotData.RebirthCost(rebirths)
	local step = rebirths + 1
	return Config.RebirthBaseCost * step * step
end

function BrainrotData.RebirthMultiplier(rebirths)
	return 1 + rebirths * Config.RebirthIncomeBonus
end

function BrainrotData.IncomePerSecond(entry, mutation, rebirths)
	local factor = BrainrotData.Mutations[mutation] or 1
	return entry.Rate * factor * BrainrotData.RebirthMultiplier(rebirths)
end

local function pickWeighted(rng, tableOfWeights, order)
	local total = 0
	for _, key in ipairs(order) do
		total += tableOfWeights[key]
	end
	local roll = rng:NextNumber(0, total)
	local running = 0
	for _, key in ipairs(order) do
		running += tableOfWeights[key]
		if roll <= running then
			return key
		end
	end
	return order[1]
end

function BrainrotData.RandomCharacter(rng)
	local rarity = pickWeighted(rng, BrainrotData.RarityWeights, Config.RarityOrder)
	local pool = {}
	for _, entry in ipairs(BrainrotData.Characters) do
		if entry.Rarity == rarity then
			table.insert(pool, entry)
		end
	end
	return pool[rng:NextInteger(1, #pool)]
end

function BrainrotData.RandomMutation(rng)
	local total = 0
	for _, roll in ipairs(BrainrotData.MutationRolls) do
		total += roll.Weight
	end
	local pick = rng:NextNumber(0, total)
	local running = 0
	for _, roll in ipairs(BrainrotData.MutationRolls) do
		running += roll.Weight
		if pick <= running then
			return roll.Name
		end
	end
	return "NORMAL"
end

return BrainrotData
