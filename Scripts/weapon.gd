extends Area2D

class_name Weapon

# const PlayerCharacter = preload("res://Scripts/player.gd")
# const EnemyCharacter = preload("res://Scripts/enemies.gd")
var character_owner: String = ""
var damage = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", deal_damage)
	pass # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
# 	pass

func deal_damage(area: Area2D) -> void:
	# Get the CharacterBody2D parent of the hit box Area2D
	if area is Weapon:
		return
	var body = area.get_parent()
	if body == null:
		return
	
	if character_owner == "Player" and body is EnemyCharacter:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Dealt ", damage, " damage to enemy.")
	elif character_owner == "Enemy" and body is PlayerCharacter:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Dealt ", damage, " damage to player.")