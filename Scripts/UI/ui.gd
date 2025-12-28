extends Control

@onready var slot_scene = preload("res://Scenes/UI/Slot.tscn")
@onready var margin_container = $Inventory/MarginContainer
@onready var grid_container = $Inventory/MarginContainer/VBoxContainer/ScrollContainer2/GridContainer
@onready var item_scene = preload("res://Scenes/UI/Item.tscn")
@onready var scroll_container = $Inventory/MarginContainer/VBoxContainer/ScrollContainer2
@onready var col_count = grid_container.columns
@onready var inventory = $Inventory
# @onready var equipment_slots = [
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/GridContainer/Slot,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/GridContainer/Slot4,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/GridContainer/Slot5,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/GridContainer2/Slot,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer2/GridContainer/Slot,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer2/GridContainer/Slot2,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/GridContainer2/Slot2,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/GridContainer2/Slot3,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/GridContainer3/Slot2,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Slot,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Slot2,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Slot3,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Slot4,
# 	$Inventory/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer2/Slot5
# ]

var grid_array: Array = []
var item_held = null
var current_slot = null
var can_place = false
var icon_anchor : Vector2
# var inventory_open = false
var inventory_open = true # temp code

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(80): #Will change to right amount
		create_slot()
	for slot in get_tree().get_nodes_in_group("equipment_slots"):
		slot.slot_entered.connect(_on_slot_mouse_entered)
		slot.slot_exited.connect(_on_slot_mouse_exited)
		# slot.type = slot.Type(equipment_slots.find(slot) ) # Will need to be fixed to proper types

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if inventory_open:
			$Inventory.hide()
			inventory_open = false
		else:
			$Inventory.show()
			inventory_open = true
	if inventory_open:
		if item_held:
			if Input.is_action_just_pressed("mouse_leftclick"):
				if margin_container.get_global_rect().has_point(get_global_mouse_position()):
					place_item()
		else: 
			if Input.is_action_just_pressed("mouse_leftclick"):
				if margin_container.get_global_rect().has_point(get_global_mouse_position()):
					pickup_item()
			

func create_slot():
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	grid_container.add_child(new_slot)
	grid_array.push_back(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)
	new_slot.type = new_slot.Type.DEFAULT
	
func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000, 10000)
	#print("cool_stuff")
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	#a_Slot.set_color(a_Slot.States.TAKEN)

func _on_slot_mouse_exited(a_Slot):
	#a_Slot.set_color(a_Slot.States.DEFAULT)
	clear_grid()
	
func spawn_item() -> void:
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(0)
	new_item.selected = true
	item_held = new_item
	

func _on_button_button_up() -> void:
	spawn_item()
	pass

func check_slot_availability(a_slot) -> void:
	if a_slot.type != a_slot.Type.DEFAULT:
		if a_slot.type == item_held.item_type and a_slot.item_stored == null:
			can_place = true
		else:
			can_place = false
		return
	
	for grid_pos in item_held.item_size:
		var grid_to_check = a_slot.slot_ID + grid_pos[0] + grid_pos[1] * col_count
		var line_switch_check = a_slot.slot_ID % col_count + grid_pos[0]
		if line_switch_check < 0  or line_switch_check >= col_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
	can_place = true
	
func set_grids(a_slot) -> void:
	if a_slot.type != a_slot.Type.DEFAULT:
		icon_anchor = Vector2(0,0)
		if can_place:
			a_slot.set_color(a_slot.States.FREE)
		else:
			a_slot.set_color(a_slot.States.TAKEN)
		return
	for grid_pos in item_held.item_size:
		var grid_to_check = a_slot.slot_ID + grid_pos[0] + grid_pos[1] * col_count
		var line_switch_check = a_slot.slot_ID % col_count + grid_pos[0]
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if line_switch_check < 0 or line_switch_check >= col_count:
			continue
		
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			
			if grid_pos[0] < icon_anchor.x: icon_anchor.x = grid_pos[0]
			if grid_pos[1] < icon_anchor.y: icon_anchor.y = grid_pos[1]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)
			
func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)
	for slot in get_tree().get_nodes_in_group("equipment_slots"):
		slot.set_color(slot.States.DEFAULT)

func place_item():
	if not can_place or not current_slot:
		return
	if current_slot.type == current_slot.Type.DEFAULT:
		var calculated_grid_id = current_slot.slot_ID + icon_anchor.x + icon_anchor.y * col_count
		
		var target_slot = grid_array[calculated_grid_id]
		var slot_center = target_slot.global_position + target_slot.size / 2.0
		
		item_held.get_parent().remove_child(item_held)
		grid_container.add_child(item_held)
		item_held.global_position = get_global_mouse_position()
		# item_held._snap_to(grid_array[calculated_grid_id].global_position)
		# item_held._snap_to(slot_center)
		item_held.global_position = slot_center
		item_held.selected = false
		
		item_held.grid_anchor = current_slot
		for grid in item_held.item_size:
			var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * col_count
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
			grid_array[grid_to_check].item_stored = item_held
	else:
		item_held.get_parent().remove_child(item_held)
		current_slot.add_child(item_held)
		
		# Use local position relative to the slot (center of the slot)
		var slot_center_local = current_slot.size / 2.0
		item_held.position = slot_center_local
		item_held.selected = false
		
		item_held.grid_anchor = current_slot
		current_slot.state = current_slot.States.TAKEN
		current_slot.item_stored = item_held
	
	item_held = null
	clear_grid()

func pickup_item():
	if not current_slot or not current_slot.item_stored:
		return
		
	item_held = current_slot.item_stored
	item_held.selected = true
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	if current_slot.type != current_slot.Type.DEFAULT:
		current_slot.state = current_slot.States.FREE
		current_slot.item_stored = null
	else:
		for grid_pos in item_held.item_size:
			var grid_to_check = item_held.grid_anchor.slot_ID + grid_pos[0] + grid_pos[1] * col_count
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
			grid_array[grid_to_check].item_stored = null
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
