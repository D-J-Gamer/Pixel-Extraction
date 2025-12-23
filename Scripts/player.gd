extends CharacterBody2D

# var texturePath: String = ""
# var sprite: Node2D = null
var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var delta_time: float = 0.0
const SECONDS_COUNT: int = 60
var speed: float = 2.5
var stats: Dictionary = {}
var inventory: Array = []
var equippedItems: Dictionary = {}

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func set_player(player: Structures.Player):
	stats = player.stats
	inventory = player.inventory
	equippedItems = player.equippedItems
	set_process(true)


func _process(delta: float):
	# if sprite != null:
	# 	delta_time += delta
	# 	if delta_time >= 0.145:
	# 		delta_time = 0.0
	# 		if sprite_texture != null:
	# 			if sprite_texture.frame == sprite_texture.hframes - 1:
	# 				sprite_texture.frame = 0
	# 			else:
	# 				sprite_texture.frame += 1
	var movement = speed
	var movement_change = Vector2.ZERO
	if Input.is_key_pressed(KEY_SHIFT):
		movement *= 2
	if Input.is_key_pressed(KEY_W):
		# code for moving the player up
		position.y -= movement * delta * SECONDS_COUNT
		movement_change.y -= movement * delta * SECONDS_COUNT
		# move_and_slide()
	if Input.is_key_pressed(KEY_S):
		# code for moving the player down
		position.y += movement * delta * SECONDS_COUNT
		movement_change.y += movement * delta * SECONDS_COUNT
	if Input.is_key_pressed(KEY_A):
		# code for moving the player left
		position.x -= movement * delta * SECONDS_COUNT
		movement_change.x -= movement * delta * SECONDS_COUNT
	if Input.is_key_pressed(KEY_D):
		# code for moving the player right
		position.x += movement * delta * SECONDS_COUNT
		movement_change.x += movement * delta * SECONDS_COUNT
	if movement_change.x != 0 or movement_change.y != 0:
		if Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Run":
			animation_player.play("Run")
		elif not Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Walk":
			animation_player.play("Walk")
		if sprite_texture and movement_change.x > 0:
			sprite_texture.flip_h = false
		elif sprite_texture and movement_change.x < 0:
			sprite_texture.flip_h = true
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")
