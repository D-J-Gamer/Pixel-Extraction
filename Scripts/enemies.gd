extends CharacterBody2D

class_name EnemyCharacter

var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var walking_colision: CollisionShape2D = null
var hit_box: CollisionShape2D = null
var attack_area: Area2D = null
var inventory_area: Area2D = null
var player_character: PlayerCharacter = null

var death_exp: int = 0
var health: int = 0
var current_health: int = 0
var mana: int = 0
var current_mana: int = 0
var mana_regen: float = 0.0
var defence: int = 0
var damage: int = 0
var speed: float = 0.0
var resistences: Dictionary = {
	"Poison": 0.0,
	"Magic": 0.0,
	"Fire": 0.0,
	"Cold": 0.0,
	"Lightning": 0.0
}
var inventory: Array = [] # To be filled with Structures.Item instances
enum EnemyState {IDLE, WALKING, ATTACKING, DEAD}
var current_state: EnemyState = EnemyState.IDLE
var can_open_inventory: bool = false

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	walking_colision = get_node_or_null("Walking Collision") as CollisionShape2D
	var hit_box_node = get_node_or_null("Area2D")
	hit_box = hit_box_node.get_node_or_null("Hit Box") as CollisionShape2D
	attack_area = get_node_or_null("AttackBoxes") as Area2D
	inventory_area = hit_box_node.get_node_or_null("GrabInventory") as Area2D
	inventory_area.set_deferred("monitoring", false)
	# attack_area = %AttackBoxes as Area2D
	attack_area.character_owner = "Enemy"
	set_process_unhandled_input(true)

func set_enemy(enemy_stats: Dictionary): 
	#{"Exp": 2, "Health": 20, "Mana": 0, "Mana_Regen": 0.0, "Defence": 1, "Damage": 4, "Speed": 1.5, "Poison_Resist": 0.5, "Magic_Resist": 0.2, "Fire_Resist": 0.2, "Cold_Resist": 0.2, "Lightning_Resist": 0.2}
	death_exp = enemy_stats["Exp"]
	health = enemy_stats["Health"]
	current_health = health
	mana = enemy_stats["Mana"]
	current_mana = mana
	mana_regen = enemy_stats["Mana_Regen"]
	defence = enemy_stats["Defence"]
	damage = enemy_stats["Damage"]
	attack_area.min_damage = damage
	attack_area.max_damage = damage
	speed = enemy_stats["Speed"]
	resistences["Poison"] = enemy_stats["Poison_Resist"]
	resistences["Magic"] = enemy_stats["Magic_Resist"]
	resistences["Fire"] = enemy_stats["Fire_Resist"]
	resistences["Cold"] = enemy_stats["Cold_Resist"]
	resistences["Lightning"] = enemy_stats["Lightning_Resist"]

func take_damage(dmg: int) -> void:
	if current_state == EnemyState.DEAD:
		return
	current_health -= max(dmg - defence, 0)
	if current_health <= 0:
		current_health = 0
		die()

func die() -> void:
	animation_player.play("Death")
	# $Walking Collision.disabled = true
	walking_colision.set_deferred("disabled", true)
	# $Area2D.set_deferred("monitoring", false)
	# hit_box.set_deferred("disabled", true)
	inventory_area.set_deferred("monitoring", true)
	current_state = EnemyState.DEAD
	# yield(animation_player, "animation_finished")
	# queue_free()


func _on_inventory_area_entered(area: Area2D) -> void:
	if area.get_parent() is PlayerCharacter and area is not Weapon:
		if sprite_texture:
			sprite_texture.modulate = Color(0.65, 0.75, 1.2, 1.0) # blue tint when player is in range
		player_character = area.get_parent() as PlayerCharacter
		can_open_inventory = true

func _on_inventory_area_exited(area: Area2D) -> void:
	if area.get_parent() is PlayerCharacter and area is not Weapon:
		if sprite_texture:
			sprite_texture.modulate = Color(1, 1, 1, 1) # clear tint when leaving
		var temp_inventory = []
		inventory += player_character.ui.free_enemy_inventory()
		player_character = null
		can_open_inventory = false

func _unhandled_input(event: InputEvent) -> void:
	if can_open_inventory and event.is_action_pressed("interact"):
		player_character.ui.enemy_inventory.show()
		player_character.ui.enemy_inventory_open = true
		player_character.ui.inventory.show()
		player_character.ui.inventory_open = true
		for item in inventory:
			player_character.ui.add_item(item)
		inventory.clear()
