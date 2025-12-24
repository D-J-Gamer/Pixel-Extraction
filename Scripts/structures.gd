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
		"Charisma": 0
		#Health = Constitution * 10 + Constitution * 5 * level
		#Mana = Intelligence * 10 + Intelligence * 5 * level
		#Mana_Regen = Intelligence * 0.1 + Intelligence * 0.05 * level
		#Stamina = 40 + Constitution * Level
		#Defense(How well you can take a hit) = Armor: int(constant + Dexterity * modifier)
		#Defence without armor = int(Dexterity * 0.5 * level + Constitution * 0.2 * level) (Whatever is higher is the left stat)
		#Damage = Weapon: constant + Stat * modifier (Depends on weapon type)
		#Damage without weapon = Strength * 1.5 + Strength * 0.5 * level
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
	"Wisdom": 6,
	"Charisma": 6
}

const default_beginner_mage_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 8,
	"Strength": 6,
	"Dexterity": 10,
	"Intelligence": 16,
	"Wisdom": 12,
	"Charisma": 6
}

const default_beginner_rogue_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 10,
	"Strength": 10,
	"Dexterity": 16,
	"Intelligence": 8,
	"Wisdom": 8,
	"Charisma": 6
}

const default_beginner_cleric_stats = {
	"Level": 1,
	"Exp": 0,
	"Constitution": 12,
	"Strength": 8,
	"Dexterity": 6,
	"Intelligence": 10,
	"Wisdom": 16,
	"Charisma": 6
}

enum BEGINNER_CLASS {
	WARRIOR,
	MAGE,
	ROGUE,
	CLERIC
}

const BEGINNER_CLASSES = {
	"Warrior": default_beginner_warrior_stats,
	"Mage": default_beginner_mage_stats,
	"Rogue": default_beginner_rogue_stats,
	"Cleric": default_beginner_cleric_stats
}

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
