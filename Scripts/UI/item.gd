extends Node2D

@onready var IconRect_Path = $Icon

enum Type {DEFAULT, WEAPON, SHIELD, CONSUMABLE, HEADGEAR, CHESTPLATE, BOOTS, RING, AMULET, GLOVES}

var item_ID: int
var item_size = [[0,0], [0,1], [1, 1], [1, 0]]
var selected = false
var grid_anchor = null
var item_type :Type = Type.DEFAULT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		#global_position = get_global_mouse_position()
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func load_item(item_ID: int) -> void:
	#var icon_path = "item_path" #will need to be fixed
	var icon_path = "res://Images/Hub/Legendary.png"
	IconRect_Path.texture = load(icon_path)
	#for grid in Item_data.size_list

func _snap_to(destination: Vector2):
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	selected = false
