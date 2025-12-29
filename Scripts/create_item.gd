extends Node

const Stats = Structures.Stats
const Type = Structures.Type
const Weapons = Structures.Weapons
const Consumables = Structures.Consumables
# const Item = Structures.Item
enum Rarity {COMMON, UNCOMMON, RARE, EPIC, LEGENDARY}

var rarity_worth_ranges: Dictionary = {
	Rarity.COMMON: [0, 100], # 100 / 3 = 33 avg
	Rarity.UNCOMMON: [50, 150], # 150 / 4 = 37.5 avg
	Rarity.RARE: [100, 200], # 200 / 5 = 40 avg
	Rarity.EPIC: [150, 250], # 250 / 6 = 41.66 avg
	Rarity.LEGENDARY: [200, 300] # 300 / 7 = 42.85 avg`
} # This number will change depending on map and difficulty

# [constant worth, multiplier worth]
var cost_per_modifier: Dictionary = {
	Stats.Constitution: {"constant": 5, "percentile": 5, "constant_add": 1},
	Stats.Strength: {"constant": 5, "percentile": 5, "constant_add": 1},
	Stats.Dexterity: {"constant": 5, "percentile": 5, "constant_add": 1},
	Stats.Intelligence: {"constant": 5, "percentile": 5, "constant_add": 1},
	Stats.Wisdom: {"constant": 5, "percentile": 5, "constant_add": 1},
	# Stats.Charisma: {"constant": 5, "percentile": 100, "constant_add": 1},
	Stats.Health: {"constant": 1, "percentile": 5, "constant_add": 1},
	Stats.Mana: {"constant": 1, "percentile": 5, "constant_add": 1},
	Stats.Mana_Regen: {"constant": 10, "percentile": 5, "constant_add": 0.5},
	Stats.Stamina: {"constant": 1, "percentile": 5, "constant_add": 1},
	Stats.Defense: {"constant": 10, "percentile": 5, "constant_add": 1},
	Stats.Damage: {"constant": 10, "percentile": 5, "constant_add": 1},
	Stats.Weight_Capacity: {"constant": 1, "percentile": 5, "constant_add": 1},
	Stats.Base_Speed: {"constant": 20, "percentile": 5, "constant_add": 0.1},
	# Stats.Weight_Ignore: {"constant": 1, "percentile": 5},
	Stats.Speed: {"constant": 20, "percentile": 5, "constant_add": 0.01},
	Stats.Poison_Resist: {"constant": 5, "percentile": 5, "constant_add": 0.01},
	Stats.Magic_Resist: {"constant": 5, "percentile": 5, "constant_add": 0.01},
	Stats.Fire_Resist: {"constant": 5, "percentile": 5, "constant_add": 0.01},
	Stats.Cold_Resist: {"constant": 5, "percentile": 5, "constant_add": 0.01},
	Stats.Lightning_Resist: {"constant": 5, "percentile": 5, "constant_add": 0.01}
	# Stats.Current_Weight: {"constant": -1, "percentile": 5}
}

var weapon_to_damage_stat: Dictionary = {
	Weapons.SWORD: Stats.Strength,
	Weapons.AXE: Stats.Strength,
	# Weapons.BOW: Stats.Dexterity,
	Weapons.DAGGER: Stats.Dexterity,
	Weapons.STAFF: Stats.Strength
}
var weapon_cost_modifier: Dictionary = {
	Weapons.SWORD: {"constant": 10, "per_stat": 5},
	Weapons.AXE: {"constant": 10, "per_stat": 5},
	# Weapons.BOW: {"constant": 15, "per_stat": 5},
	Weapons.DAGGER: {"constant": 20, "per_stat": 5},
	Weapons.STAFF: {"constant": 15, "per_stat": 5}
}

func calculate_worth(lower_worth: int, upper_worth: int) -> int:
	return randi() % (upper_worth - lower_worth + 1) + lower_worth

func set_worth_ranges(worth_ranges: Dictionary) -> void:
	rarity_worth_ranges = worth_ranges

func create_item(lower_worth, upper_worth, item_type: Structures.Type = Structures.Type.DEFAULT) -> Structures.Item:
	var budget = calculate_worth(lower_worth, upper_worth)
	var new_item = Structures.Item.new()
	var value = 0
	if item_type != Structures.Type.DEFAULT:
		new_item.type = item_type
	else:
		var item_types = Structures.items.keys()
		var random_index = randi() % (item_types.size() - 1) + 1
		new_item.type = item_types[random_index]
		if new_item.type == Type.CONSUMABLE:
			new_item.consumable_type = randi() % Consumables.size()
			pass #Will Get to
		# print("Randomly selected item type: ", new_item.type)
	
	if new_item.type == Type.WEAPON:
		var weapon_types = Weapons.keys()
		var random_weapon_index = randi() % weapon_types.size()
		new_item.weapon_type = weapon_types[random_weapon_index]
	
	var rarity_candidates = []
	for rarity in Rarity.values():
		var worth_range = rarity_worth_ranges[rarity]
		if worth_range[0] <= budget <= worth_range[1]:
			rarity_candidates.append(rarity)
	var selected_rarity = Rarity.COMMON
	if rarity_candidates.size() > 0:
		var random_rarity_index = randi() % rarity_candidates.size()
		selected_rarity = rarity_candidates[random_rarity_index]
	new_item.rarity = selected_rarity
	var modifier_count
	match selected_rarity:
		Rarity.COMMON:
			modifier_count = 3
		Rarity.UNCOMMON:
			modifier_count = 4
		Rarity.RARE:
			modifier_count = 5
		Rarity.EPIC:
			modifier_count = 6
		Rarity.LEGENDARY:
			modifier_count = 7

	var base_damage_stat = Stats.Strength
	var modifiers_added = []
	var stat_keys = cost_per_modifier.keys().duplicate()

	if new_item.type == Type.WEAPON:
		match new_item.weapon_type:
			Weapons.SWORD, Weapons.AXE, Weapons.STAFF:
				base_damage_stat = Stats.Strength
			# Weapons.BOW, 
			Weapons.DAGGER:
				base_damage_stat = Stats.Dexterity
		var weapon_costs = weapon_cost_modifier[new_item.weapon_type]
		var weapon_constant_cost = weapon_costs["constant"]
		var weapon_per_stat_cost = weapon_costs["per_stat"]
		if budget >= weapon_constant_cost:
			var max_constant_increases = (budget - modifier_count * 5) / weapon_constant_cost
			var constant_increases = randi() % (max_constant_increases + 1)
			if constant_increases > 0:
				new_item.replacement_damage[2] = constant_increases
				budget -= constant_increases * weapon_constant_cost
				value += constant_increases * weapon_constant_cost
		if budget >= weapon_per_stat_cost:
			var max_per_stat_increases = (budget - (modifier_count - 1) * 5) / weapon_per_stat_cost
			var per_stat_increases = randi() % (max_per_stat_increases + 1)
			if per_stat_increases > 0:
				new_item.replacement_damage[0] = per_stat_increases * 0.1
				new_item.replacement_damage[1] = per_stat_increases * 0.15
				budget -= per_stat_increases * weapon_per_stat_cost
				value += per_stat_increases * weapon_per_stat_cost
		new_item.replacement_damage[3] = base_damage_stat
		new_item.modifiers[Stats.Replacement_Damage] = new_item.replacement_damage
		modifiers_added.append(Stats.Replacement_Damage)
		stat_keys.remove(Stats.Damage)

	if new_item.type in [Type.SHIELD, Type.HEADGEAR, Type.CHESTPLATE, Type.BOOTS, Type.GLOVES]:
		# Ensure Defense is added for armor pieces
		if Stats.Defense not in modifiers_added:
			var defense_costs = cost_per_modifier[Stats.Defense]
			var defense_constant_cost = defense_costs["constant"]
			if budget >= defense_constant_cost:
				var max_defense_increases = (budget - (modifier_count - 1) * 5) / defense_constant_cost
				var defense_increases = randi() % (max_defense_increases + 1)
				if defense_increases > 0:
					new_item.modifiers[Stats.Defense] = [defense_increases * defense_costs["constant_add"], 0]
					budget -= defense_increases * defense_constant_cost
					value += defense_increases * defense_constant_cost
					modifiers_added.append(Stats.Defense)
					stat_keys.remove(Stats.Defense)

	stat_keys.remove(Stats.Replacement_Damage)
	stat_keys.remove(Stats.Charisma)
	stat_keys.remove(Stats.Current_Weight)
	stat_keys.remove(Stats.Weight_Ignore)
	while budget > 0 and new_item.type != Type.CONSUMABLE:
		var random_stat_index = randi() % stat_keys.size()
		var selected_stat = stat_keys[random_stat_index]
		if selected_stat in modifiers_added:
			continue
		var costs = cost_per_modifier[selected_stat]
		var cost_types = ["constant", "percentile"]
		var selected_cost_type = cost_types[randi() % cost_types.size()]
		var cost = costs[selected_cost_type]
		if budget >= cost:
			if selected_cost_type == "constant":
				var max_increases = (budget - (modifier_count - len(modifiers_added) - 1) * 5) / cost
				var increases = randi() % (max_increases + 1)
				if modifier_count - len(modifiers_added) == 1: # Last modifier, use all remaining budget
					increases = max_increases
					budget = 0
				if increases > 0:
					budget -= increases * cost
					new_item.modifiers[selected_stat] = [increases * costs["constant_add"], 0]
					modifiers_added.append(selected_stat)
			else: # percentile
				var max_increases = (budget - (modifier_count - len(modifiers_added) - 1) * 5) / cost
				var increases = randi() % (max_increases + 1) / 100.0
				if modifier_count - len(modifiers_added) == 1: # Last modifier, use all remaining budget
					increases = max_increases
					budget = 0
				if increases > 0:
					new_item.modifiers[selected_stat] = [0, increases]
					budget -= increases * 100 * cost
					modifiers_added.append(selected_stat)
		if len(modifiers_added) >= modifier_count:
			break
	
	match selected_rarity:
		Rarity.COMMON:
			value = int(value * 0.25)
		Rarity.UNCOMMON:
			value = int(value * 0.35)
		Rarity.RARE:
			value = int(value * 0.5)
		Rarity.EPIC:
			value = int(value * 0.75)
		Rarity.LEGENDARY:
			value = int(value * 1.0)
	new_item.value = value

	match new_item.type:
		Type.WEAPON:
			match new_item.weapon_type:
				Weapons.SWORD:
					new_item.size = [[0, -1], [0, 0], [0, 1]]
					new_item.weight = 5.0
					match selected_rarity:
						Rarity.COMMON: new_item.imagePath = "res://Images/Items/Weapons/Common/Sword.png"
						Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Weapons/Uncommon/Sword.png"
						Rarity.RARE: new_item.imagePath = "res://Images/Items/Weapons/Rare/Sword.png"
						Rarity.EPIC: new_item.imagePath = "res://Images/Items/Weapons/Epic/Sword.png"
						Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Weapons/Legendary/Sword.png"
				Weapons.DAGGER:
					new_item.size = [[0, 0], [0, 1]]
					new_item.weight = 2.0
					match selected_rarity:
						Rarity.COMMON: new_item.imagePath = "res://Images/Items/Weapons/Common/Dagger.png"
						Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Weapons/Uncommon/Dagger.png"
						Rarity.RARE: new_item.imagePath = "res://Images/Items/Weapons/Rare/Dagger.png"
						Rarity.EPIC: new_item.imagePath = "res://Images/Items/Weapons/Epic/Dagger.png"
						Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Weapons/Legendary/Dagger.png"
				Weapons.AXE:
					new_item.size = [[-1, -1], [0, -1], [1, -1], [0, 0], [0, 1]]
					new_item.weight = 7.0
					match selected_rarity:
						Rarity.COMMON: new_item.imagePath = "res://Images/Items/Weapons/Common/Axe.png"
						Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Weapons/Uncommon/Axe.png"
						Rarity.RARE: new_item.imagePath = "res://Images/Items/Weapons/Rare/Axe.png"
						Rarity.EPIC: new_item.imagePath = "res://Images/Items/Weapons/Epic/Axe.png"
						Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Weapons/Legendary/Axe.png"
				# Weapons.BOW:
				# 	new_item.size = [[2, 4]]
				Weapons.STAFF:
					new_item.size = [[0, -1], [0, 0], [0, 1]]
					new_item.weight = 6.0
					match selected_rarity:
						Rarity.COMMON: new_item.imagePath = "res://Images/Items/Weapons/Common/Staff.png"
						Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Weapons/Uncommon/Staff.png"
						Rarity.RARE: new_item.imagePath = "res://Images/Items/Weapons/Rare/Staff.png"
						Rarity.EPIC: new_item.imagePath = "res://Images/Items/Weapons/Epic/Staff.png"
						Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Weapons/Legendary/Staff.png"
		Type.SHIELD:
			new_item.size = [[0, 0], [1, 0], [0, 1], [1, 1]]
			new_item.weight = 4.0
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/Shields/Common/Shield.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Shields/Uncommon/Shield.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/Shields/Rare/Shield.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/Shields/Epic/Shield.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Shields/Legendary/Shield.png"
		Type.CHESTPLATE:
			new_item.size = [[0, -1], [1, -1], [0, 0], [1, 0], [0, 1], [1, 1]]
			new_item.weight = 8.0
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/ChestPlate/Common/ChestPlate.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/ChestPlate/Uncommon/ChestPlate.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/ChestPlate/Rare/ChestPlate.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/ChestPlate/Epic/ChestPlate.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/ChestPlate/Legendary/ChestPlate.png"
		Type.HEADGEAR:
			new_item.size = [[0, 0], [1, 0], [0, 1], [1, 1]]
			new_item.weight = 3.0
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/HeadGear/Common/HeadGear.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/HeadGear/Uncommon/HeadGear.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/HeadGear/Rare/HeadGear.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/HeadGear/Epic/HeadGear.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/HeadGear/Legendary/HeadGear.png"
		Type.BOOTS:
			new_item.size = [[0, 0], [1, 0], [0, 1], [1, 1]]
			new_item.weight = 3.0
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/Boots/Common/Boots.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Boots/Uncommon/Boots.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/Boots/Rare/Boots.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/Boots/Epic/Boots.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Boots/Legendary/Boots.png"
		Type.GLOVES:
			new_item.size = [[0, 0], [1, 0], [0, 1], [1, 1]]
			new_item.weight = 2.0
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/Gloves/Common/Gloves.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Gloves/Uncommon/Gloves.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/Gloves/Rare/Gloves.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/Gloves/Epic/Gloves.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Gloves/Legendary/Gloves.png"
		Type.CONSUMABLE:
			new_item.size = [[0, 0]]
			new_item.weight = 0.5
			match new_item.consumable_type:
				Consumables.HEALTH_POTION:
					new_item.imagePath = "res://Images/Items/Consumables/Health/HealingPotion.png"
				Consumables.MANA_POTION:
					new_item.imagePath = "res://Images/Items/Consumables/Mana/Mana_Potion.png"
		Type.RING:
			new_item.size = [[0, 0]]
			new_item.weight = 0.2
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/Rings/Common/Ring.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Rings/Uncommon/Ring.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/Rings/Rare/Ring.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/Rings/Epic/Ring.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Rings/Legendary/Ring.png"
		Type.AMULET:
			new_item.size = [[0, 0]]
			new_item.weight = 0.3
			match selected_rarity:
				Rarity.COMMON: new_item.imagePath = "res://Images/Items/Amulets/Common/Amulet.png"
				Rarity.UNCOMMON: new_item.imagePath = "res://Images/Items/Amulets/Uncommon/Amulet.png"
				Rarity.RARE: new_item.imagePath = "res://Images/Items/Amulets/Rare/Amulet.png"
				Rarity.EPIC: new_item.imagePath = "res://Images/Items/Amulets/Epic/Amulet.png"
				Rarity.LEGENDARY: new_item.imagePath = "res://Images/Items/Amulets/Legendary/Amulet.png"
	new_item.modifiers[Stats.Current_Weight] = new_item.weight
	return new_item
