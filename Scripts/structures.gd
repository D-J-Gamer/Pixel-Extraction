class Player:
    var scenePath = ""
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