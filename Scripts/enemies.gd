extends CharacterBody2D

var animation_player: AnimationPlayer = null
var sprite_texture: AnimatedSprite2D = null
var walking_colision: CollisionShape2D = null
var hit_box: CollisionShape2D = null

func _ready() -> void:
	animation_player = get_node_or_null("Animations") as AnimationPlayer
	animation_player.play("Idle")
	sprite_texture = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	walking_colision = get_node_or_null("Walking Collision") as CollisionShape2D
	var hit_box_node = get_node_or_null("Area2D")
	hit_box = hit_box_node.get_node_or_null("Hit Box") as CollisionShape2D

func set_enemy(enemy_stats: Dictionary):
	pass