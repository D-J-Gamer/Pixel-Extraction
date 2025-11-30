


extends Control

const MAIN_MENU := preload("res://Scripts/main_menu.gd")

func _ready() -> void:
	var menu_script = MAIN_MENU.new()
	menu_script._ready()
	add_child(menu_script)
	menu_script.main = self

	# Ensure processing is enabled so `_process` will be called every frame
	# set_process(true)

func start_game() -> void:
	print("Main: Starting game...")
