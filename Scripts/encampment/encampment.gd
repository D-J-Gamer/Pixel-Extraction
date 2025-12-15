extends Node2D

const HUB_SCENE := preload("res://Scenes/encampment.tscn")

var main: Control = null

static func create_instance() -> Node2D:
	var instance = HUB_SCENE.instantiate()
	instance.set_script(load("res://Scripts/encampment/encampment.gd"))
	return instance

func _ready():
	var start_game = get_node_or_null("StartGame")
	if start_game and start_game.has_signal("pressed"):
		start_game.connect("pressed", Callable(self, "_on_start_pressed"))

func _on_start_pressed():
	if main == null:
		return
	
	main.encampment_to_game()

func get_difficulty() -> int: # 0 = easy, 1 = normal, 2 = hard, 3 = insane , 4 = legendary
	var menuButton = get_node_or_null("DifficultySelect")
	return menuButton.difficulty

func get_map_path() -> String:
	var menuButton = get_node_or_null("MapSelect")
	return menuButton.map_path
