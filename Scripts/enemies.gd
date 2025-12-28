extends CharacterBody2D

class_name EnemyCharacter

var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var walking_colision: CollisionShape2D = null
var hit_box: CollisionShape2D = null
var attack_area: Area2D = null

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

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	walking_colision = get_node_or_null("Walking Collision") as CollisionShape2D
	var hit_box_node = get_node_or_null("Area2D")
	hit_box = hit_box_node.get_node_or_null("Hit Box") as CollisionShape2D
	attack_area = get_node_or_null("AttackBoxes") as Area2D
	# attack_area = %AttackBoxes as Area2D
	attack_area.character_owner = "Enemy"

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
	attack_area.damage = damage
	speed = enemy_stats["Speed"]
	resistences["Poison"] = enemy_stats["Poison_Resist"]
	resistences["Magic"] = enemy_stats["Magic_Resist"]
	resistences["Fire"] = enemy_stats["Fire_Resist"]
	resistences["Cold"] = enemy_stats["Cold_Resist"]
	resistences["Lightning"] = enemy_stats["Lightning_Resist"]

func take_damage(dmg: int) -> void:
	current_health -= max(dmg - defence, 0)
	if current_health <= 0:
		current_health = 0
		die()

func die() -> void:
	animation_player.play("Death")
	# $Walking Collision.disabled = true
	walking_colision.set_deferred("disabled", true)
	$Area2D.set_deferred("monitoring", false)
	hit_box.set_deferred("disabled", true)
	# yield(animation_player, "animation_finished")
	# queue_free()
