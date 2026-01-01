extends Control

@onready var stat_labels = $ColorRect/VBoxContainer/HBoxContainer/Stat_Labels
@onready var left_button = $ColorRect/VBoxContainer/HBoxContainer/Left/Button
@onready var right_button = $ColorRect/VBoxContainer/HBoxContainer/Right/Button
@onready var class_label = $ColorRect/VBoxContainer/HBoxContainer/VBoxContainer2/Class

var classes = Structures.BEGINNER_CLASSES
var class_labels = ["Warrior", "Mage", "Rogue", "Cleric"]
var selected_class_index: int = 0
var points_remaining: int = 0
var encampment = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_label_stats()

func update_label_stats():
	stat_labels.update_labels(points_remaining,
		classes[selected_class_index]["Strength"],
		classes[selected_class_index]["Dexterity"],
		classes[selected_class_index]["Constitution"],
		classes[selected_class_index]["Intelligence"],
		classes[selected_class_index]["Wisdom"]
	)
	class_label.text = class_labels[selected_class_index]
	if selected_class_index == 0:
		left_button.disabled = true
	else:
		left_button.disabled = false


func _on_left_button_up() -> void:
	if selected_class_index == classes.size() - 1:
		right_button.disabled = false
	if selected_class_index > 0:
		selected_class_index -= 1
		update_label_stats()
	if selected_class_index == 0:
		left_button.disabled = true

func _on_right_button_up() -> void:
	if selected_class_index == 0:
		left_button.disabled = false
	if selected_class_index < classes.size() - 1:
		selected_class_index += 1
		update_label_stats()
	if selected_class_index == classes.size() - 1:
		right_button.disabled = true


func _character_create_button_up() -> void:
	var player = Structures.Player.new()
	player.name = "NewHero"
	player.stats = {
		"Level": 1,
		"Exp": 0,
		"Strength": stat_labels.strength,
		"Dexterity": stat_labels.dexterity,
		"Constitution": stat_labels.constitution,
		"Intelligence": stat_labels.inteligence,
		"Wisdom": stat_labels.wisdom,
		# "Charisma": 0
	}
	player.scenePath = "res://Scenes/Characters/Players/skeleton.tscn"
	encampment.create_player(player)
	visible = false


func _on_x_button_up() -> void:
	visible = false
