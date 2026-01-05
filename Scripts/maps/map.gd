extends Node2D

@onready var enemy_spawnpoints = $Enemy_SpawnPoints
@onready var player_spawnpoints = $Player_SpawnPoints
@onready var enemies = $Y_Sort/Enemies
@onready var position_relative = $Y_Sort

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
