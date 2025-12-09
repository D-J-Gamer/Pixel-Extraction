


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
