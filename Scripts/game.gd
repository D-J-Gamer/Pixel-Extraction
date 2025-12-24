extends Node2D

const GAME_SCENE = preload("res://game.tscn")
const PLAYER_SCRIPT = preload("res://Scripts/player.gd")

const MAP_SCALE = 2
const MAP_TILE_SIZE = 16
const VECTOR2_MAP_SCALE = Vector2(MAP_SCALE, MAP_SCALE)
const UNKNOWN_CHARACTER_POS_SCALE = 2

var main: Control = null
var camera: Camera2D = null
var player_node: CharacterBody2D = null
var map_sprite: Sprite2D = null
var map_path: String = ""

var game_difficulty: String = ""

var enemies: Array = []

static func create_instance():
	var instance = GAME_SCENE.instantiate()
	instance.set_script(load("res://Scripts/game.gd"))
	return instance

func _ready():
	pass

func make_map(_path: String):
	map_path = _path
	var map_image = Image.new()
	map_image.load(map_path)
	var map_texture = ImageTexture.create_from_image(map_image)
	# map_texture.create_from_image(map_image)
	map_sprite = Sprite2D.new()
	map_sprite.texture = map_texture
	map_sprite.centered = false
	map_sprite.position = Vector2.ZERO
	map_sprite.scale = VECTOR2_MAP_SCALE
	add_child(map_sprite)
	set_map_collisions()

func set_player(player: Structures.Player):
	player_node = load(player.scenePath).instantiate() as CharacterBody2D
	# var player_node = PLAYER_SCRIPT.new()
	add_child(player_node)
	player_node.set_player(player)
	var spawn_positions = MapDetails.MAP_DATA[map_path]["Spawnpoints"]
	var spawn_position = spawn_positions[randi() % len(spawn_positions)]
	player_node.position = Vector2(spawn_position["x"], spawn_position["y"]) * MAP_SCALE * MAP_TILE_SIZE * UNKNOWN_CHARACTER_POS_SCALE
	# player_node.position = Vector2(180, 120)
	# center_camera_on(player_node)

func set_map_collisions():
	for wall in MapDetails.MAP_DATA[map_path]["collisions"]["locations"]:
		var wall_node = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		var rect_data = MapDetails.MAP_DATA[map_path]["collisions"]["rectangles"][wall["Rec"]]
		shape.size = Vector2(1, 1) * MAP_SCALE * MAP_TILE_SIZE * Vector2(rect_data["width"], rect_data["height"])
		collision.shape = shape
		wall_node.position = Vector2(wall["x"], wall["y"]) * MAP_SCALE * MAP_TILE_SIZE
		wall_node.position += shape.size / 2
		wall_node.add_child(collision)
		map_sprite.add_child(wall_node)

func place_enemies(difficulty: int):
	match difficulty:
		0:
			game_difficulty = "Easy"
		1:
			game_difficulty = "Normal"
		2:
			game_difficulty = "Hard"
		3:
			game_difficulty = "Insane"
		4:
			game_difficulty = "Legendary"
	var enemy_data = MapDetails.MAP_DATA[map_path]["enemies"]
	var difficulty_data = MapDetails.MAP_DATA[map_path]["difficulty"][game_difficulty]
	var enemy_scenes: Array = enemy_data["EnemyScenes"]
	var enemy_variety: int = len(enemy_scenes)
	var max_enemies: int = difficulty_data["Max_Enemies_Per_Area"]
	var min_enemies: int = difficulty_data["Min_Enemies_Per_Area"]
	var enemy_nodes: Node2D = Node2D.new()
	add_child(enemy_nodes)
	for area in enemy_data["EnemyPositions"]:
		var area_copy = area.duplicate()
		var num_enemies = randi() % (max_enemies - min_enemies + 1) + min_enemies
		if num_enemies > len(area_copy):
			num_enemies = len(area_copy)
		var positions_available = area_copy.size()
		for i in range(num_enemies):
			var enemy_type = randi() % enemy_variety
			var scenePath = enemy_scenes[enemy_type]
			# print("Spawning enemy: ", scenePath)
			var enemy_node = load(scenePath).instantiate() as CharacterBody2D
			var pos_index = randi() % positions_available
			var pos_data = area_copy[pos_index]
			enemy_node.position = Vector2(pos_data["x"], pos_data["y"]) * MAP_SCALE * MAP_TILE_SIZE * UNKNOWN_CHARACTER_POS_SCALE
			# temp
			# enemy_node.position = Vector2(22, 8) * MAP_SCALE * MAP_TILE_SIZE * UNKNOWN_ENEMY_POS_SCALE
			enemy_nodes.add_child(enemy_node)
			enemy_node.set_enemy(difficulty_data["Enemy_Stats"][enemy_type])
			area_copy.remove_at(pos_index)
			positions_available -= 1
			enemies.append(enemy_node)
