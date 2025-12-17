extends Node2D

const HUB_SCENE := preload("res://Scenes/encampment.tscn")
const Player = Structures.Player

var main: Control = null

var players = []
var current_player_ind = null

static func create_instance() -> Node2D:
	var instance = HUB_SCENE.instantiate()
	instance.set_script(load("res://Scripts/encampment/encampment.gd"))
	return instance

func _ready():
	var start_game = get_node_or_null("StartGame")
	if start_game and start_game.has_signal("pressed"):
		start_game.connect("pressed", Callable(self, "_on_start_pressed"))
	var create_player_button = get_node_or_null("CreateCharacter")
	if create_player_button and create_player_button.has_signal("pressed"):
		create_player_button.connect("pressed", Callable(self, "create_player_button"))

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

func create_player_button():	
	var player = Player.new()
	# Add player creation UI

	# temp code
	create_player(player)

func create_player(player):
	print("Player created: ", player)
	players.append(player)
	current_player_ind = len(players) - 1
