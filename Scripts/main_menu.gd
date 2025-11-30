extends Node2D

const MAIN_MENU_SCENE := preload("res://Scenes/Main_Menu.tscn")
# signal request_state(state: String)

var main: Control = null

func _ready() -> void:
	# Connect button signals if they exist as direct children
	var main_menu_scene = MAIN_MENU_SCENE.instantiate()
	add_child(main_menu_scene)
	var buttons = main_menu_scene.get_node_or_null("Menu_Buttons")
	for btn_name in ["StartGame", "LoadGame", "Settings", "Exit"]:
		var button = buttons.get_node_or_null(btn_name)
		if button and button.has_signal("pressed"):
			match btn_name:
				"StartGame": button.connect("pressed", Callable(self, "_on_start_pressed"))
				"LoadGame": button.connect("pressed", Callable(self, "_on_load_pressed"))
				"Settings": button.connect("pressed", Callable(self, "_on_settings_pressed"))
				"Exit": button.connect("pressed", Callable(self, "_on_exit_pressed"))

func _on_start_pressed() -> void:
	if main != null and main.has_method("start_game"):
		main.start_game()

func _on_load_pressed() -> void:
	# Does nothing yet
	print("Load_Game(): Load button pressed")

func _on_settings_pressed() -> void:
	# Does nothing yet
	print("Settings(): Settings button pressed")

func _on_exit_pressed() -> void:
	get_tree().quit()
