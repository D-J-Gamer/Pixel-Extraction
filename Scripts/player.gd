extends Node2D

var texturePath: String = ""
var sprite: Node2D = null
var sprite_texture: Sprite2D = null
var delta_time: float = 0.0
const SECONDS_COUNT: int = 60
var speed: float = 2.5
	
func set_player(player: Structures.Player):
	texturePath = player.texturePath
	# temp code
	var packed_scene := load(texturePath) as PackedScene
	if packed_scene == null:
		push_error("set_player(): Expected a .tscn PackedScene at path: " + texturePath)
		return
	sprite = packed_scene.instantiate()
	add_child(sprite)
	sprite_texture = sprite.get_node("Sprite2D")
	set_process(true)


func _process(delta: float):
	if sprite != null:
		delta_time += delta
		if delta_time >= 0.145:
			delta_time = 0.0
			if sprite_texture != null:
				if sprite_texture.frame == sprite_texture.hframes - 1:
					sprite_texture.frame = 0
				else:
					sprite_texture.frame += 1
	var movement = speed
	if Input.is_key_pressed(KEY_SHIFT):
		movement *= 2
	if Input.is_key_pressed(KEY_W):
		# code for moving the player up
		position.y -= movement * delta * SECONDS_COUNT
	if Input.is_key_pressed(KEY_S):
		# code for moving the player down
		position.y += movement * delta * SECONDS_COUNT
	if Input.is_key_pressed(KEY_A):
		# code for moving the player left
		position.x -= movement * delta * SECONDS_COUNT
	if Input.is_key_pressed(KEY_D):
		# code for moving the player right
		position.x += movement * delta * SECONDS_COUNT