extends Node

class Player:
	var scenePath = ""
	var name = ""
	var stats = {
		"Level": 0,
		"Exp": 0,
		"Constitution": 0,
		"Strength": 0,
		"Dexterity": 0,
		"Intelligence": 0,
		"Wisdom": 0,
		# "Charisma": 0
		#Health = Constitution * 10 + Constitution * 5 * level
		#Mana = Intelligence * 10 + Intelligence * 5 * level
		#Mana_Regen = Intelligence * 0.1 + Intelligence * 0.05 * level
		#Stamina = 40 + Constitution * Level
		#Defense(How well you can take a hit) = Armor: int(constant + Dexterity * modifier)
		#Defence without armor = int(Dexterity * 0.5 * level + Constitution * 0.2 * level) (Whatever is higher is the left stat)
		#Damage = Weapon: constant + Stat * modifier (Depends on weapon type)
		#Damage without weapon = Strength * 0.5 + Strength * 0.1 * level
		#Weight_Capacity = Strength * 15
		#Soft_Capacity = Strength * 7.5
		#Base_Speed = 1 + Dexterity * 0.1 + Dexterity * 0.05 * level
		#Weight_ignore = Strength * 1.5
		#If weight - Weight_ignore <= Soft_Capacity:
			#Speed = Base_Speed * (0.75 + 0.25 * (1 - (weight / Soft_Capacity)))
		#If weight  - Weight_ignore > Soft_Capacity:
			#Speed = Base_Speed * (0.75 * (weight - Soft_Capacity) / Weight_Capacity)
		#Poison_Resist = Constitution / (Constitution + 50)
		#Magic_Resist = Wisdom / (Wisdom + 50)
		#Fire_Resist = Constitution / (Constitution + 50)
		#Cold_Resist = Constitution / (Constitution + 50)
		#Lightning_Resist = Constitution / (Constitution + 50)
	}
	var inventory = []
	var equippedItems = {}

const default_beginner_warrior_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 14,
	"Strength": 14,
	"Dexterity": 10,
	"Intelligence": 8,
	"Wisdom": 8,
}

const default_beginner_mage_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 8,
	"Strength": 8,
	"Dexterity": 10,
	"Intelligence": 16,
	"Wisdom": 12,
}

const default_beginner_rogue_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 11,
	"Strength": 11,
	"Dexterity": 18,
	"Intelligence": 8,
	"Wisdom": 8,
}

const default_beginner_cleric_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 12,
	"Strength": 8,
	"Dexterity": 8,
	"Intelligence": 10,
	"Wisdom": 16,
}

enum BEGINNER_CLASS {
	WARRIOR,
	MAGE,
	ROGUE,
	CLERIC
}

const BEGINNER_CLASSES = [
	default_beginner_warrior_stats,
	default_beginner_mage_stats,
	default_beginner_rogue_stats,
	default_beginner_cleric_stats
]

#This structure will probably not be used, but is here for future reference
class Enemy:
	var scenePath = ""
	var stats = {
		"Exp": 0,
		"Health": 0,
		"Mana": 0,
		"Mana_Regen": 0.0,
		"Defence": 0,
		"Damage": 0,
		"Speed": 0.0,
		"Poison_Resist": 0.0,
		"Magic_Resist": 0.0,
		"Fire_Resist": 0.0,
		"Cold_Resist": 0.0,
		"Lightning_Resist": 0.0
	}
	var flags = [] # To be iterated and matched for a function so enemies can have special behaviors
	var drops = [] # List of items that can be dropped on death

enum Type {DEFAULT, WEAPON, SHIELD, CONSUMABLE, HEADGEAR, CHESTPLATE, BOOTS, RING, AMULET, GLOVES, TRINKET}
enum Stats {
	Constitution,
	Strength,
	Dexterity,
	Intelligence,
	Wisdom,
	Charisma,
	Health,
	Current_Health,
	Mana,
	Current_Mana,
	Mana_Regen,
	Stamina,
	Defense,
	Damage,
	Weight_Capacity,
	Base_Speed,
	Weight_Ignore,
	Speed,
	Poison_Resist,
	Magic_Resist,
	Fire_Resist,
	Cold_Resist,
	Lightning_Resist,
	Current_Weight,
	Replacement_Damage
}

class Item:
	var imagePath : String
	var name : String
	var type :Type
	var rarity : int
	var modifiers = {} # Dictionary of Stats enum to modifier value
	# []
	var weight : float
	var size = [[0, 0]] # placement slots
	var value = 0 # Monetary value
	var description = ""
	var replacement_damage = [0.0, 0.0, 0, Stats.Strength] # lower multipler, upper multiplier, base damage, stat used for damage calculation
	var weapon_type: Weapons
	var consumable_type: Consumables
	var rating: int = 0

var items = {
	Type.DEFAULT: Item.new(),
	Type.WEAPON: Item.new(),
	Type.SHIELD: Item.new(),
	Type.CONSUMABLE: Item.new(),
	Type.HEADGEAR: Item.new(),
	Type.CHESTPLATE: Item.new(),
	Type.BOOTS: Item.new(),
	Type.RING: Item.new(),
	Type.AMULET: Item.new(),
	Type.GLOVES: Item.new()
}

enum Weapons {SWORD, AXE, DAGGER, STAFF} #, BOW} Bow currently not implemented
enum Consumables {HEALTH_POTION, MANA_POTION}
# var weapons = {
# 	Weapons.SWORD: Item.new(),
# 	Weapons.AXE: Item.new(),
# 	Weapons.BOW: Item.new(),
# 	Weapons.DAGGER: Item.new(),
# 	Weapons.STAFF: Item.new()
# }

func _ready() -> void:
	for item_keys in items.keys():
		items[item_keys].type = item_keys
