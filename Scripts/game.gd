extends Node2D

const GAME_SCENE = preload("res://game.tscn")
const PLAYER_SCRIPT = preload("res://Scripts/player.gd")

const MAP_SCALE = 2
const MAP_TILE_SIZE = 16
const VECTOR2_MAP_SCALE = Vector2(MAP_SCALE, MAP_SCALE)

var main: Control = null
var camera: Camera2D = null
var player_node: CharacterBody2D = null
var map_sprite: Sprite2D = null

static func create_instance():
	var instance = GAME_SCENE.instantiate()
	instance.set_script(load("res://Scripts/game.gd"))
	return instance

func _ready():
	pass

func make_map(map_path: String):
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
	set_map_collisions(map_path)

func set_player(player: Structures.Player):
	player_node = load(player.scenePath).instantiate() as CharacterBody2D
	# var player_node = PLAYER_SCRIPT.new()
	player_node.set_player(player)
	add_child(player_node)
	player_node.position = Vector2(180, 120)
	# center_camera_on(player_node)

func set_map_collisions(map_path: String):
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
