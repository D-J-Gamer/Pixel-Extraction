extends Node2D

const HUB_SCENE := preload("res://Scenes/encampment_selection.tscn")

var main: Control = null

static func create_instance() -> Node2D:
	var instance = HUB_SCENE.instantiate()
	instance.set_script(load("res://Scripts/encampment_selection.gd"))
	return instance

func _ready() -> void:
	var encampment_name = get_node("EncampmentName")
	if encampment_name:
		encampment_name.grab_focus()
		encampment_name.connect("text_submitted", Callable(self, "_on_encampment_name_submitted"))

func _on_encampment_name_submitted(new_text: String) -> void:
	print("Encampment name entered: ", new_text)
	# Add any additional logic here for what happens after pressing Enter
	
