extends Node2D

const GAME_SCENE = preload("res://game.tscn")
const PLAYER_SCRIPT = preload("res://Scripts/player.gd")

const MAP_SCALE = 2
const VECTOR2_MAP_SCALE = Vector2(MAP_SCALE, MAP_SCALE)

var main: Control = null
var camera: Camera2D = null
var player_node: CharacterBody2D = null

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
	var map_sprite = Sprite2D.new()
	map_sprite.texture = map_texture
	map_sprite.centered = false
	map_sprite.position = Vector2.ZERO
	map_sprite.scale = VECTOR2_MAP_SCALE
	add_child(map_sprite)

func set_player(player: Structures.Player):
	player_node = load(player.scenePath).instantiate() as CharacterBody2D
	# var player_node = PLAYER_SCRIPT.new()
	player_node.set_player(player)
	add_child(player_node)
	player_node.position = Vector2(180, 120)
	# center_camera_on(player_node)

func center_camera_on(target: Node2D) -> void:
	if target == null:
		push_warning("center_camera_on(): target is null")
		return
	if camera == null:
		camera = Camera2D.new()
		# camera.current = true
	if camera.get_parent() != target:
		if camera.get_parent() != null:
			camera.get_parent().remove_child(camera)
		target.add_child(camera)
	camera.position = Vector2.ZERO
