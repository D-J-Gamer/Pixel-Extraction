extends Control

# To do list:
# 1. Character Create skeleton (excluding the ui that will be included and stats, just adding to a Players list with player image)
# 1 done 
# 2. game.gd skeleton as well as transition to game (basically to the point I can move a character around) 
# 2 done
# 3. Stats 
# done
# 4. Enemies which have stats
# done
# 5. Inventory system as well as a temporary create item in inventory (so I can move it around) 
# I believe I'm done, the first interaction with enemy inventory puts all the items visually into one slot, after you exit and grab it and interact again, it's fixed. Don't know the cause.
# 6. Fighting (ability to kill enemies) 
# done
# 7. Way to interact with enemies' inventory 
# done
# 8. Actual player creation ui and way to customize character
#done
#new todo list
# 1. Save and load system for encampment and game (including player stats, inventory, equipped items, etc)
# 2. Modify item creation system to fix stat distribution:
	# Each stat modifier gets random num between 0 and 1, sum them up, then divide each stat's num by total sum to get percentage
	# Then multiply by power rating to get stat increase
	# This instead of budget 1 item, then the next, then the next, which can lead to uneven stat distribution
# 3. Add a way to extract, and enter with the same character
# 4. Gain experience and level up system
# 5. Basic combat mechanics for enemies to fight back
# done
# Ideas for later:
	# Change a lot of map information from map_details to be turned into a scene that is instanced into game.gd
	# Multiplayer support
	# unlock new maps through drops.

const MAIN_MENU := preload("res://Scripts/main_menu.gd")
const CREATE_HUB_NAME := preload("res://Scripts/encampment_selection.gd")
# const HUB := preload("res://Scripts/encampment/encampment.gd")
const GAME := preload("res://Scripts/game.gd")
const HUB := preload("res://Scenes/encampment.tscn")

var menu_script: Node = null
var create_hub_name: Node = null
var encampment: Node = null
var game: Node = null

func _ready() -> void:
	menu_script = MAIN_MENU.create_instance()
	add_child(menu_script)
	menu_script.main = self

func main_menu_to_hub() -> void:
	print("Main: Starting game...")
	create_hub_name = CREATE_HUB_NAME.create_instance()
	add_child(create_hub_name)
	create_hub_name.main = self
	menu_script.queue_free()
	menu_script = null	# Optionally, you can set `menu_script` to null to indicate it's no longer active

func encampment_selection_to_encampment(encampment_name: String) -> bool:
	print("Starting encampment: " + encampment_name)
	# Create JSON save file named encampment_name.json as Saves\Example.json
	var save_path = "res://Saves/" + encampment_name + ".json"
	if FileAccess.file_exists(save_path):
		return true
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var save_data = {
			"Characters" : {},
			"Collection": []
		}
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
	
	encampment = HUB.instantiate()
	add_child(encampment)
	encampment.main = self

	create_hub_name.queue_free()
	create_hub_name = null

	return false

func encampment_to_game() -> void:
	print("Encampment to game... ", "Difficulty: ",encampment.get_difficulty(), " Map path: ", encampment.get_map_path(), " Player: ", encampment.get_player())
	save_game()
	MapDetails.set_map_path(encampment.get_map_path())
	MapDetails.set_difficulty(encampment.get_difficulty())
	game = GAME.create_instance()
	add_child(game)
	game.make_map(encampment.get_map_path())
	game.set_player(encampment.get_player())
	game.place_enemies(encampment.get_difficulty())
	# print("Map path", MapDetails.map_path)
	# Will add difficulty later
	game.main = self
	encampment.queue_free()
	encampment = null

func save_game() -> void:
	pass
