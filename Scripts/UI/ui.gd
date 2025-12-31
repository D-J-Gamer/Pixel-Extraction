extends Control

@onready var slot_scene = preload("res://Scenes/UI/Slot.tscn")
@onready var margin_container = $Inventory/MarginContainer
@onready var grid_container = $Inventory/MarginContainer/VBoxContainer/ScrollContainer2/GridContainer
@onready var enemy_grid_container = $"Enemy Inventory/MarginContainer/VBoxContainer/ScrollContainer2/GridContainer"
@onready var item_scene = preload("res://Scenes/UI/Item.tscn")
@onready var grid_containers = [grid_container, enemy_grid_container]
@onready var scroll_container = $Inventory/MarginContainer/VBoxContainer/ScrollContainer2
@onready var col_count = grid_container.columns
@onready var inventory = $Inventory
@onready var enemy_inventory = $"Enemy Inventory"
@onready var enemy_margin_container = $"Enemy Inventory/MarginContainer"
@onready var current_weight_label = $Inventory/MarginContainer/VBoxContainer/Footer/Control/Label


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
var enemy_grid_array: Array = []
var grid_arrays = [grid_array, enemy_grid_array]
var item_held = null
var current_slot = null
var can_place = false
var icon_anchor : Vector2
var inventory_open = false
var enemy_inventory_open = false
var last_slot = null
var player_character: PlayerCharacter = null
# var inventory_open = true # temp code

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(80): #Will change to right amount
		create_slot(0)
		create_slot(1)
	for slot in get_tree().get_nodes_in_group("equipment_slots"):
		slot.slot_entered.connect(_on_slot_mouse_entered)
		slot.slot_exited.connect(_on_slot_mouse_exited)
		# slot.type = slot.Type(equipment_slots.find(slot) ) # Will need to be fixed to proper types

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if inventory_open:
			inventory.hide()
			inventory_open = false
			enemy_inventory.hide()
			enemy_inventory_open = false
			if item_held:
				current_slot = last_slot
				can_place = true
				place_item()
		else:
			inventory.show()
			inventory_open = true
			update_current_weight_label()
			can_place = false
			# enemy_inventory.show()
			# enemy_inventory_open = true
	if inventory_open:
		if item_held:
			if Input.is_action_just_pressed("mouse_leftclick"):
				var in_player_inv = margin_container.get_global_rect().has_point(get_global_mouse_position())
				var in_enemy_inv = enemy_margin_container.get_global_rect().has_point(get_global_mouse_position())
				if in_player_inv or in_enemy_inv:
					place_item()
		else: 
			if Input.is_action_just_pressed("mouse_leftclick"):
				var in_player_inv2 = margin_container.get_global_rect().has_point(get_global_mouse_position())
				var in_enemy_inv2 = enemy_margin_container.get_global_rect().has_point(get_global_mouse_position())
				if in_player_inv2 or in_enemy_inv2:
					pickup_item()
			

func create_slot(container_index: int) -> void:
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_arrays[container_index].size()
	grid_containers[container_index].add_child(new_slot)
	grid_arrays[container_index].push_back(new_slot)
	# Mark which inventory owns this slot
	if container_index == 0:
		new_slot.inventory_owner = new_slot.Owner.PLAYER
	else:
		new_slot.inventory_owner = new_slot.Owner.ENEMY
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
	var owner_index = a_slot.inventory_owner
	var cols = grid_containers[owner_index].columns
	for grid_pos in item_held.item_size:
		var grid_to_check = a_slot.slot_ID + grid_pos[0] + grid_pos[1] * cols
		var line_switch_check = a_slot.slot_ID % cols + grid_pos[0]
		if line_switch_check < 0  or line_switch_check >= cols:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_arrays[owner_index].size():
			can_place = false
			return
		if grid_arrays[owner_index][grid_to_check].state == grid_arrays[owner_index][grid_to_check].States.TAKEN:
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
	var owner_index = a_slot.inventory_owner
	var cols2 = grid_containers[owner_index].columns
	for grid_pos in item_held.item_size:
		var grid_to_check = a_slot.slot_ID + grid_pos[0] + grid_pos[1] * cols2
		var line_switch_check = a_slot.slot_ID % cols2 + grid_pos[0]
		if grid_to_check < 0 or grid_to_check >= grid_arrays[owner_index].size():
			continue
		if line_switch_check < 0 or line_switch_check >= cols2:
			continue
		
		if can_place:
			grid_arrays[owner_index][grid_to_check].set_color(grid_arrays[owner_index][grid_to_check].States.FREE)
			
			if grid_pos[0] < icon_anchor.x: icon_anchor.x = grid_pos[0]
			if grid_pos[1] < icon_anchor.y: icon_anchor.y = grid_pos[1]
		else:
			grid_arrays[owner_index][grid_to_check].set_color(grid_arrays[owner_index][grid_to_check].States.TAKEN)
			
func clear_grid():
	for grid_arr in grid_arrays:
		for grid in grid_arr:
			grid.set_color(grid.States.DEFAULT)
	for slot in get_tree().get_nodes_in_group("equipment_slots"):
		slot.set_color(slot.States.DEFAULT)

func place_item(modify_weight: bool = true) -> void:
	if not can_place or not current_slot:
		return
	var owner_index = current_slot.inventory_owner
	if current_slot.type == current_slot.Type.DEFAULT:
		var cols3 = grid_containers[owner_index].columns
		var calculated_grid_id = current_slot.slot_ID + icon_anchor.x + icon_anchor.y * cols3
		
		var target_slot = grid_arrays[owner_index][calculated_grid_id]
		var slot_center = target_slot.global_position + target_slot.size / 4.0
		
		item_held.get_parent().remove_child(item_held)
		grid_containers[owner_index].add_child(item_held)
		# item_held.global_position = get_global_mouse_position()
		# item_held._snap_to(grid_array[calculated_grid_id].global_position)
		# item_held._snap_to(slot_center)
		item_held.global_position = slot_center
		item_held.selected = false
		
		item_held.grid_anchor = current_slot
		for grid in item_held.item_size:
			var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * col_count
			grid_arrays[owner_index][grid_to_check].state = grid_arrays[owner_index][grid_to_check].States.TAKEN
			grid_arrays[owner_index][grid_to_check].item_stored = item_held
	else: # Will need to revisit to handle equipment slots properly in position
		item_held.get_parent().remove_child(item_held)
		current_slot.add_child(item_held)
		player_character.apply_item_buff(item_held)
		# update_current_weight_label()
		# Center the item in equipment slot
		# Container uses PRESET_CENTER, so it centers itself on the Node2D position
		# Position Node2D at slot center - the preset handles centering for all sizes
		var slot_center_local = current_slot.size / 2.0
		var container_ratio_x = item_held.container.size.x / 100.0
		var container_ratio_y = item_held.container.size.y / 100.0
		item_held.position = slot_center_local
		if container_ratio_x >= (current_slot.size.x / 100.0):
			item_held.position.x = slot_center_local.x / container_ratio_x
		else: item_held.position.x = slot_center_local.x / container_ratio_x
		if container_ratio_y >= (current_slot.size.y / 100.0):
			item_held.position.y = slot_center_local.y / container_ratio_y
		else: item_held.position.y = slot_center_local.y / container_ratio_y * slot_center_local.y / 100.0
		# item_held.position = Vector2(0, 0) # Adjustment for centering issues
		# item_held.position = slot_center_local - Vector2(100, 100)
		# item_held.position = slot_center_local - item_held.container.size / 2.0
		item_held.selected = false
		
		item_held.grid_anchor = current_slot
		current_slot.state = current_slot.States.TAKEN
		current_slot.item_stored = item_held
	
	if owner_index == current_slot.Owner.ENEMY and modify_weight:
		player_character.remove_weight(item_held.weight)
	update_current_weight_label()

	item_held = null
	clear_grid()

func pickup_item():
	if not current_slot or not current_slot.item_stored:
		return
	var owner_index = current_slot.inventory_owner
	item_held = current_slot.item_stored
	item_held.selected = true
	last_slot = current_slot
	
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	if current_slot.type != current_slot.Type.DEFAULT:
		current_slot.state = current_slot.States.FREE
		current_slot.item_stored = null
		player_character.remove_item_buff(item_held)
		# update_current_weight_label()
	else:
		for grid_pos in item_held.item_size:
			var grid_to_check = item_held.grid_anchor.slot_ID + grid_pos[0] + grid_pos[1] * col_count
			grid_arrays[owner_index][grid_to_check].state = grid_arrays[owner_index][grid_to_check].States.FREE
			grid_arrays[owner_index][grid_to_check].item_stored = null
	if owner_index == current_slot.Owner.ENEMY:
		player_character.add_weight(item_held.weight)
	update_current_weight_label()
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)

func add_item(item_deets: Structures.Item) -> bool:
	# Create the item and load it with the provided details
	var item = item_scene.instantiate()
	add_child(item)
	item.load_item(item_deets)
	# item.selected = true
	# item_held = item
	# Add an already-created item to the enemy inventory at the top-left most available position
	var enemy_inventory_index = 1
	var enemy_grid = grid_arrays[enemy_inventory_index]
	var enemy_container = grid_containers[enemy_inventory_index]
	var cols = enemy_container.columns
	
	# Find the first available position from top-left
	for slot_id in range(enemy_grid.size()):
		var test_slot = enemy_grid[slot_id]
		
		# Check if this slot can fit the item
		var can_fit = true
		for grid_pos in item.item_size:
			var grid_to_check = slot_id + grid_pos[0] + grid_pos[1] * cols
			var line_switch_check = slot_id % cols + grid_pos[0]
			
			# Check bounds
			if line_switch_check < 0 or line_switch_check >= cols:
				can_fit = false
				break
			if grid_to_check < 0 or grid_to_check >= enemy_grid.size():
				can_fit = false
				break
			
			# Check if slot is taken
			if enemy_grid[grid_to_check].state == enemy_grid[grid_to_check].States.TAKEN:
				can_fit = false
				break
		
		# If we found a valid position, use place_item() to handle the placement
		if can_fit:
			# # Add item to container
			# if item.get_parent():
			# 	item.get_parent().remove_child(item)
			# enemy_container.add_child(item)
			# var slot_center = test_slot.global_position + test_slot.size / 2.0
			# item.global_position = slot_center
			# item.selected = false
			# item.grid_anchor = test_slot
			# Set up pre-requisites for place_item()
			item_held = item
			current_slot = test_slot
			can_place = true
			icon_anchor = Vector2(0, 0)
			# Calculate icon_anchor (minimum coordinates in item_size)
			for grid_pos in item.item_size:
				# var grid_to_check = slot_id + grid_pos[0] + grid_pos[1] * cols
				# enemy_grid[grid_to_check].state = enemy_grid[grid_to_check].States.TAKEN
				# enemy_grid[grid_to_check].item_stored = item
				if grid_pos[0] < icon_anchor.x: 
					icon_anchor.x = grid_pos[0]
				if grid_pos[1] < icon_anchor.y: 
					icon_anchor.y = grid_pos[1]
			
			# Call place_item() to handle the actual placement
			place_item(false)
			return true
	
	# No space found - clean up the item
	item.queue_free()
	return false

func free_enemy_inventory() -> Array:
	var free_items = []
	var processed_items: Array = []
	for slot in enemy_grid_array:
		if not slot.item_stored:
			continue
		var item_ref = slot.item_stored
		# Skip if we've already freed this multi-slot item
		if processed_items.has(item_ref):
			continue
		processed_items.append(item_ref)
		var item_details: Structures.Item = item_ref.return_item_details()
		free_items.append(item_details)
		# Clear all slots occupied by this item
		for s in enemy_grid_array:
			if s.item_stored == item_ref:
				s.state = s.States.FREE
				s.item_stored = null
		item_ref.queue_free()
	for slot in get_tree().get_nodes_in_group("equipment_slots"):
		if not slot.item_stored:
			continue
		if slot.item_stored == null or slot.inventory_owner != slot.Owner.ENEMY:
			continue
		free_items.append(slot.item_stored.return_item_details())
		slot.item_stored.queue_free()
		slot.item_stored = null
	if item_held and last_slot.inventory_owner == last_slot.Owner.ENEMY:
		free_items.append(item_held.return_item_details())
		player_character.remove_weight(item_held.weight)
		update_current_weight_label()
		item_held.queue_free()
		item_held = null
	enemy_inventory.hide()
	enemy_inventory_open = false
	return free_items

func _on_enemy_button_down() -> void:
	# var item = item_scene.instantiate()
	# item.load_item(0)
	# add_item(item)
	pass

func update_current_weight_label() -> void:
	var current_weight = player_character.get_current_weight()
	var weight_capacity = player_character.weight_capacity
	current_weight_label.text = "Weight: " + str(current_weight) + " / " + str(weight_capacity)
