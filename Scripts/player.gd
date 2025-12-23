extends CharacterBody2D

# var texturePath: String = ""
# var sprite: Node2D = null
var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var delta_time: float = 0.0
const SECONDS_COUNT: int = 60
# var speed: float = 2.5
# var stats: Dictionary = {}
#Stats:
var level = 0
var exp = 0
var constitution = 0
var strength = 0
var dexterity = 0
var intelligence = 0
var wisdom = 0
var charisma = 0

var health: int = 0
var mana: int = 0
var stamina: int = 40
var defense: int = 0
var damage: int = 0
var weight_capacity: int = 0
var soft_capacity: float = 0.0
var hard_capacity: float = 0.0
var base_speed: float = 0.0
var weight_ignore: float = 0.0
var speed: float = 0.0
var resistences: Dictionary = {
	"Poison_Resist": 0.0,
	"Magic_Resist": 0.0,
	"Fire_Resist": 0.0,
	"Cold_Resist": 0.0,
	"Lightning_Resist": 0.0
}

var inventory: Array = []
var equippedItems: Dictionary = {}

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func set_player(player: Structures.Player):
	level = player.level
	exp = player.exp
	constitution = player.constitution
	strength = player.strength
	dexterity = player.dexterity
	intelligence = player.intelligence
	wisdom = player.wisdom
	charisma = player.charisma

	health = constitution * 10 + constitution * 5 * level
	mana = intelligence * 10 + intelligence * 5 * level
	stamina = 40 + constitution * level
	defense = int(dexterity * 0.5 * level + constitution * 0.2 * level)
	damage = strength * 1.5 + strength * 0.5 * level
	weight_ignore = strength * 1.5
	weight_capacity = strength * 15
	soft_capacity = strength * 7.5 - weight_ignore
	hard_capacity = weight_capacity - weight_ignore
	base_speed = 1 + dexterity * 0.1 + dexterity * 0.01 * level
	speed = base_speed
	resistences["Poison_Resist"] = constitution / (constitution + 50)
	resistences["Magic_Resist"] = wisdom / (wisdom + 50)
	resistences["Fire_Resist"] = constitution / (constitution + 50)
	resistences["Cold_Resist"] = constitution / (constitution + 50)
	resistences["Lightning_Resist"] = constitution / (constitution + 50)

	inventory = player.inventory
	equippedItems = player.equippedItems
	set_item_modifiers()
	set_process(true)


func _process(delta: float):
	var movement = speed
	var movement_change = Vector2.ZERO
	if Input.is_key_pressed(KEY_SHIFT):
		movement *= 2
	if Input.is_key_pressed(KEY_W):
		# code for moving the player up
		movement_change.y -= 1
	if Input.is_key_pressed(KEY_S):
		# code for moving the player down
		movement_change.y += 1
	if Input.is_key_pressed(KEY_A):
		# code for moving the player left
		movement_change.x -= 1
	if Input.is_key_pressed(KEY_D):
		# code for moving the player right
		movement_change.x += 1
	
	# Use move_and_collide to handle collision detection
	if movement_change != Vector2.ZERO:
		movement_change = movement_change.normalized() * movement * delta * SECONDS_COUNT
		var collision = move_and_collide(movement_change) as KinematicCollision2D
		if collision:
			if movement_change.x != 0:
				move_and_collide(Vector2(collision.get_remainder().x, 0))
			if movement_change.y != 0:
				move_and_collide(Vector2(0, collision.get_remainder().y))
		if Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Run":
			animation_player.play("Run")
		elif not Input.is_key_pressed(KEY_SHIFT) and animation_player.current_animation != "Walk":
			animation_player.play("Walk")
	
	if movement_change.x != 0 or movement_change.y != 0:
		if sprite_texture and movement_change.x > 0:
			sprite_texture.flip_h = false
		elif sprite_texture and movement_change.x < 0:
			sprite_texture.flip_h = true
	else:
		if animation_player.current_animation != "Idle":
			animation_player.play("Idle")

func set_item_modifiers():
	pass

func apply_buff(item):
	pass

func remove_buff(item):
	pass