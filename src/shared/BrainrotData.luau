local BrainrotData = {}

BrainrotData.RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Divine" }
BrainrotData.RarityColors = {
	Common = Color3.fromRGB(190, 195, 203),
	Rare = Color3.fromRGB(70, 160, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 155, 55),
	Mythic = Color3.fromRGB(235, 65, 75),
	Divine = Color3.fromRGB(255, 220, 80),
}
BrainrotData.RarityWeights = { Common = 45, Rare = 25, Epic = 15, Legendary = 9, Mythic = 5, Divine = 1 }
BrainrotData.Mutations = { NORMAL = 1, GOLD = 2, DIAMOND = 3, PEDAS = 5 }

BrainrotData.List = {
	{ Name = "Bakso Bandit", Rarity = "Common", Price = 50, Rate = 1, Description = "A round meatball outlaw with a sack." },
	{ Name = "Kerupuk Knight", Rarity = "Common", Price = 120, Rate = 2, Description = "A crisp cracker knight with a shield." },
	{ Name = "Cireng Cyclops", Rarity = "Rare", Price = 350, Rate = 5, Description = "A chewy disc with one enormous eye." },
	{ Name = "Sate Sensei", Rarity = "Rare", Price = 800, Rate = 9, Description = "A skewer master with a headband and tiny katana." },
	{ Name = "Gado-Gado Goblin", Rarity = "Epic", Price = 2000, Rate = 18, Description = "A green goblin wearing a peanut bowl hat." },
	{ Name = "Es Cendol Cyber", Rarity = "Epic", Price = 4500, Rate = 32, Description = "A drink robot with glowing cendol tubes." },
	{ Name = "Soto Sphinx", Rarity = "Legendary", Price = 9000, Rate = 60, Description = "A soup-bowl sphinx with a golden crown." },
	{ Name = "Martabak Monster", Rarity = "Legendary", Price = 18000, Rate = 110, Description = "A folded pancake beast with chocolate drips." },
	{ Name = "Nasi Padang Paladin", Rarity = "Mythic", Price = 40000, Rate = 220, Description = "A rice-mound knight with a rendang sword." },
	{ Name = "Rendang Rex", Rarity = "Mythic", Price = 90000, Rate = 450, Description = "A saucy little tyrant with a tiny crown." },
	{ Name = "Es Teh Sultan", Rarity = "Divine", Price = 250000, Rate = 1200, Description = "A sultan seated on a giant iced-tea throne." },
	{ Name = "Klepon King", Rarity = "Divine", Price = 500000, Rate = 2000, Description = "A green coconut king with a crown and red cape." },
}

BrainrotData.ByName = {}
for _, item in ipairs(BrainrotData.List) do
	item.Color = BrainrotData.RarityColors[item.Rarity]
	BrainrotData.ByName[item.Name] = item
end

function BrainrotData.Get(name)
	return BrainrotData.ByName[name]
end

function BrainrotData.RebirthCost(rebirths)
	return 5000 * ((rebirths or 0) + 1) ^ 2
end

function BrainrotData.Income(item, mutation, multiplier)
	local factor = BrainrotData.Mutations[mutation or "NORMAL"] or 1
	return item.Rate * factor * (multiplier or 1)
end

return BrainrotData
