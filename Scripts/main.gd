extends Control

const MAIN_MENU := preload("res://Scripts/main_menu.gd")
const HUB := preload("res://Scripts/encampment_selection.gd")

var menu_script: Node = null

func _ready() -> void:
	menu_script = MAIN_MENU.create_instance()
	add_child(menu_script)
	menu_script.main = self

	# Ensure processing is enabled so `_process` will be called every frame
	# set_process(true)

func main_menu_to_hub() -> void:
	print("Main: Starting game...")
	var hub = HUB.create_instance()
	add_child(hub)
	hub.main = self
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
	return false
