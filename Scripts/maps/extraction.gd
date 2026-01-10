extends Node2D

@onready var animate = $AnimationPlayer

enum states {SUMMONING, START, RUNNING}
var state: int = states.SUMMONING

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#animate.play("Summon_Circle")




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == states.SUMMONING:
		state = states.START
		animate.play("Start")
	elif state == states.START:
		state = states.RUNNING
		animate.play("Running")
