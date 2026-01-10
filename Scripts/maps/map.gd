extends Node2D

@onready var enemy_spawnpoints = $Enemy_SpawnPoints
@onready var player_spawnpoints = $Player_SpawnPoints
@onready var enemies = $Y_Sort/Enemies
@onready var position_relative = $Y_Sort

const SECONDS_COUNT = 60.0

var time = 0.0
var extraction_points: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(true)
	extraction_points = get_tree().get_nodes_in_group("Extraction_Points")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta / SECONDS_COUNT
	if time >= 14.0:
		time -= 5.0
		var extract_point = extraction_points[randi() % len(extraction_points)] as Node2D
		extraction_points.erase(extract_point)
		extract_point.animate.active = true
		extract_point.animate.play("Summon_Circle")
