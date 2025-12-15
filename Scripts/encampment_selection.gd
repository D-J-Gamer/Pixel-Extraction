extends Node2D

const HUB_NAMING_SCENE := preload("res://Scenes/encampment_selection.tscn")

var main: Control = null
var encampment_name: LineEdit = null
var save_reminder: Label = null

static func create_instance() -> Node2D:
	var instance = HUB_NAMING_SCENE.instantiate()
	instance.set_script(load("res://Scripts/encampment_selection.gd"))
	return instance

func _ready() -> void:
	encampment_name = get_node("EncampmentName")
	if encampment_name:
		encampment_name.grab_focus()
		encampment_name.connect("text_submitted", Callable(self, "_on_encampment_name_submitted"))

func _on_encampment_name_submitted(new_text: String) -> void:
	print("Encampment name entered: ", new_text)
	if main.encampment_selection_to_encampment(new_text):
		save_reminder = get_node("SaveExistsReminder")
		save_reminder.label_settings.font_color[3] = 1.0
		set_process(true)

	# Add any additional logic here for what happens after pressing Enter
	
func _process(delta: float) -> void:
	if save_reminder != null:
		save_reminder.label_settings.font_color[3] = max(save_reminder.label_settings.font_color[3] - delta, 0.0)
		if save_reminder.label_settings.font_color[3] <= 0.0:
			set_process(false)
			save_reminder = null
	# Add any additional logic here for what happens during the game loop
