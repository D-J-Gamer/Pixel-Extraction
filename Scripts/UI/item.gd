extends Node2D

@onready var IconRect_Path = $Control/Icon
@onready var container = $Control
@onready var txt = $Label
@onready var txt_background = $Label/ColorRect
# @export var size = Vector2(100, 100)

# @onready var container = $Container

# enum Type {DEFAULT, WEAPON, SHIELD, CONSUMABLE, HEADGEAR, CHESTPLATE, BOOTS, RING, AMULET, GLOVES}
const Type = Structures.Type
const slot_size = 100

var item_ID: int
var item_size = [[0,0], [0,1], [1, 1], [1, 0]]
var selected = false
var grid_anchor = null
var item_type :Type = Type.DEFAULT
# var position_fix = Vector2(-100, -100)
var description_follow = false

var imagePath = ""
# var name = ""
# var type :Type = Type.DEFAULT
var rarity = 0
var rating = 0
var modifiers = {} # Dictionary of Stats enum to modifier value
var weight = 0.0
var value = 0 # Monetary value
var description = ""
var replacement_damage = [0.0, 0.0, 0, Structures.Stats.Strength] # lower multipler, upper multiplier, base damage, stat used for damage calculation
var weapon_type: Structures.Weapons
var consumable_type: Structures.Consumables


# func _ready() -> void:
	# Allow clicks to pass through the container to the parent item
	# if container:
	# 	container.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		#global_position = get_global_mouse_position()
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	if description_follow:
		var target_pos = get_global_mouse_position() - txt.size / 2
		
		# Clamp position to keep text within camera view
		var camera = get_viewport().get_camera_2d()
		if camera:
			var viewport_size = get_viewport_rect().size
			var camera_zoom = camera.zoom
			var camera_pos = camera.global_position
			
			# Calculate camera's visible rect in world space
			var half_viewport = viewport_size / (2 * camera_zoom)
			var camera_rect_min = camera_pos - half_viewport
			var camera_rect_max = camera_pos + half_viewport
			
			target_pos.x = clamp(target_pos.x, camera_rect_min.x, camera_rect_max.x - txt.size.x / 2)
			target_pos.y = clamp(target_pos.y, camera_rect_min.y, camera_rect_max.y - txt.size.y / 2)
		
		txt.global_position = lerp(txt.global_position, target_pos, 25 * delta)

func load_item(item_deets: Structures.Item) -> void:

	#var icon_path = "item_path" #will need to be fixed
	# var icon_path = "res://Images/Hub/Legendary.png"
	item_size = item_deets.size
	var sizes = [0, 0, 0, 0] # x_min, y_min, x_max, y_max
	for slot in item_size:
		if slot[0] < sizes[0]:
			sizes[0] = slot[0]
		if slot[1] < sizes[1]:
			sizes[1] = slot[1]
		if slot[0] > sizes[2]:
			sizes[2] = slot[0]
		if slot[1] > sizes[3]:
			sizes[3] = slot[1]
	var rect_size = Vector2((sizes[2] - sizes[0] + 1) * slot_size, (sizes[3] - sizes[1] + 1) * slot_size)
	print("Rect size calculated: ", rect_size)
	imagePath = item_deets.imagePath
	IconRect_Path.texture = load(imagePath) as Texture2D
	var tex = IconRect_Path.texture
	# var texture_size = IconRect_Path.size
	var texture_size = Vector2(tex.get_width(), tex.get_height())
	IconRect_Path.size = texture_size
	container.size = rect_size
	container.set_anchors_preset(Control.PRESET_CENTER)
	print("Texture size: ", texture_size, " Rect size: ", rect_size)
	var texture_scale = Vector2(rect_size.x / texture_size.x, rect_size.y / texture_size.y)
	IconRect_Path.scale = texture_scale
	IconRect_Path.position = Vector2.ZERO

	# Offset container to account for negative coordinates in item_size
	# container.position = Vector2(sizes[0] * slot_size - slot_size, sizes[1] * slot_size - slot_size)
	# name = item_deets.name
	item_type = item_deets.type
	rarity = item_deets.rarity
	modifiers = item_deets.modifiers
	weight = item_deets.weight
	value = item_deets.value
	description = item_deets.description
	replacement_damage = item_deets.replacement_damage
	weapon_type = item_deets.weapon_type
	consumable_type = item_deets.consumable_type
	rating = item_deets.rating
	create_description()

func create_description() -> String:
	# enum values are integers; lookup their names from the enum dictionaries
	var type_name = Structures.Type.keys()[item_type]
	# var rarity_name = Structures.Rarity.keys()[rarity] if rarity < Structures.Rarity.size() else "Unknown"
	var rarity_name = ""
	match rarity:
		0: rarity_name = "Common"
		1: rarity_name = "Uncommon"
		2: rarity_name = "Rare"
		3: rarity_name = "Epic"
		4: rarity_name = "Legendary"
	# Format: "Common Chestplate" (first letter of rarity capped)
	var title = "%s %s" % [rarity_name.to_lower(), type_name.to_lower()]
	title[0] = title[0].to_upper()  # Capitalize only first letter

	var desc = "%s\nWeight: %.1f\nValue: %d" % [title, weight, value]

	if modifiers.size() > 0:
		for stat in modifiers.keys():
			if stat == Structures.Stats.Current_Weight:
				continue
			var mod_value = modifiers[stat]
			var stat_name = Structures.Stats.keys()[stat]
			
			# Special handling for replacement_damage (weapon damage)
			if stat == Structures.Stats.Replacement_Damage:
				# replacement_damage = [lower_multiplier, upper_multiplier, constant, stat_enum]
				var lower_mult = mod_value[0]
				var upper_mult = mod_value[1]
				var constant = mod_value[2]
				var damage_stat = mod_value[3]
				
				# Get the player's stat value
				var player_stats = MapDetails.player_base_stats
				var stat_keys = Structures.Stats.keys()
				var stat_name_lookup = stat_keys[damage_stat]
				var player_stat_value = player_stats.get(stat_name_lookup, 0)
				
				# Calculate damage range
				var lower_damage = int(lower_mult * player_stat_value + constant)
				var upper_damage = int(upper_mult * player_stat_value + constant)
				
				# Format based on whether range is same
				if lower_damage == upper_damage:
					desc += "\ndamage: %d" % lower_damage
				else:
					desc += "\ndamage: %d to %d" % [lower_damage, upper_damage]
			# Check if mod_value is an array [constant, percentile] or a single value
			elif typeof(mod_value) == TYPE_ARRAY:
				var parts = []
				if mod_value[0] != 0:
					var sign = "+" if mod_value[0] > 0 else ""
					# Format to 2 decimals, then strip trailing zeros
					var formatted = "%.2f" % mod_value[0]
					while formatted.ends_with("0"):
						formatted = formatted.substr(0, formatted.length() - 1)
					if formatted.ends_with("."):
						formatted = formatted.substr(0, formatted.length() - 1)
					parts.append("%s%s" % [sign, formatted])
				if mod_value[1] != 0:
					var sign = "x" if mod_value[1] > 0 else "x"
					parts.append("%s%.1f%%" % [sign, mod_value[1] * 100 + 100])
				if parts.size() > 0:
					desc += "\n%s: %s" % [stat_name.to_lower(), " ".join(parts)]
			else:
				var sign = "+" if mod_value > 0 else ""
				desc += "\n%s: %s%.1f" % [stat_name.to_lower(), sign, mod_value]

	# Add power rating based on item value
	var power_rating = rating
	desc += "\nPower Rating: %d" % power_rating

	txt.text = desc
	txt.size = txt.get_minimum_size()
	txt_background.size = txt.size
	return desc

func _snap_to(destination: Vector2):
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	selected = false


func _on_control_mouse_entered() -> void:
	if selected:
		return
	txt.visible = true
	description_follow = true



func _on_control_mouse_exited() -> void:
	txt.visible = false
	description_follow = false


# func _on_control_mouse_entered() -> void:
# 	pass # Replace with function body.
