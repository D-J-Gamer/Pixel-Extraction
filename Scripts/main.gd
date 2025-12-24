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
# 6. Fighting (ability to kill enemies) 
# 7. Way to interact with enemies' inventory 
# 8. Actual player creation ui and way to customize character

const MAIN_MENU := preload("res://Scripts/main_menu.gd")
const CREATE_HUB_NAME := preload("res://Scripts/encampment_selection.gd")
const HUB := preload("res://Scripts/encampment/encampment.gd")
const GAME := preload("res://Scripts/game.gd")


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
	
	encampment = HUB.create_instance()
	add_child(encampment)
	encampment.main = self

	create_hub_name.queue_free()
	create_hub_name = null

	return false

func encampment_to_game() -> void:
	print("Encampment to game... ", "Difficulty: ",encampment.get_difficulty(), " Map path: ", encampment.get_map_path(), " Player: ", encampment.get_player())
	save_game()
	game = GAME.create_instance()
	add_child(game)
	game.make_map(encampment.get_map_path())
	game.set_player(encampment.get_player())
	game.place_enemies(encampment.get_difficulty())
	# Will add difficulty later
	game.main = self
	encampment.queue_free()
	encampment = null

func save_game() -> void:
	pass
