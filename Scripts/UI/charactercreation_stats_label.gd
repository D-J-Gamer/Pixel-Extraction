extends Control

@onready var points_remaining_label = $"Points Remaining"
@onready var strength_label = $Strength/Label
@onready var dexterity_label = $Dexterity/Label
@onready var constitution_label = $Constitution/Label
@onready var inteligence_label = $Inteligence/Label
@onready var wisdom_label = $Wisdom/Label

var points_remaining: int
var strength: int
var dexterity: int
var constitution: int
var inteligence: int
var wisdom: int

func update_labels(pnts_remaining: int, stre: int, dex: int, con: int, intl: int, wis: int) -> void:
	points_remaining_label.text = "Points Remaining: " + str(pnts_remaining)
	strength_label.text = "Strength: " + str(stre)
	dexterity_label.text = "Dexterity: " + str(dex)
	constitution_label.text = "Constitution: " + str(con)
	inteligence_label.text = "Inteligence: " + str(intl)
	wisdom_label.text = "Wisdom: " + str(wis)
	points_remaining = pnts_remaining
	strength = stre
	dexterity = dex
	constitution = con
	inteligence = intl
	wisdom = wis



func _minus_str_button_up() -> void:
	if strength > 8:
		strength -= 1
		points_remaining += 1
		strength_label.text = "Strength: " + str(strength)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)



func _plus_str_button_up() -> void:
	if points_remaining > 0:
		strength += 1
		points_remaining -= 1
		strength_label.text = "Strength: " + str(strength)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _minus_dex_button_up() -> void:
	if dexterity > 8:
		dexterity -= 1
		points_remaining += 1
		dexterity_label.text = "Dexterity: " + str(dexterity)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _on_plus_button_up() -> void:
	if points_remaining > 0:
		dexterity += 1
		points_remaining -= 1
		dexterity_label.text = "Dexterity: " + str(dexterity)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _minus_con_button_up() -> void:
	if constitution > 8:
		constitution -= 1
		points_remaining += 1
		constitution_label.text = "Constitution: " + str(constitution)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _plus_con_button_up() -> void:
	if points_remaining > 0:
		constitution += 1
		points_remaining -= 1
		constitution_label.text = "Constitution: " + str(constitution)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _minus_int_button_up() -> void:
	if inteligence > 8:
		inteligence -= 1
		points_remaining += 1
		inteligence_label.text = "Inteligence: " + str(inteligence)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _plus_int_button_up() -> void:
	if points_remaining > 0:
		inteligence += 1
		points_remaining -= 1
		inteligence_label.text = "Inteligence: " + str(inteligence)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _minus_wis_button_up() -> void:
	if wisdom > 8:
		wisdom -= 1
		points_remaining += 1
		wisdom_label.text = "Wisdom: " + str(wisdom)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)


func _plus_wis_button_up() -> void:
	if points_remaining > 0:
		wisdom += 1
		points_remaining -= 1
		wisdom_label.text = "Wisdom: " + str(wisdom)
		points_remaining_label.text = "Points Remaining: " + str(points_remaining)
