extends MenuButton

var difficulty: int = 0

func _ready() -> void:
	# Set the button's icon
	var button_icon = load("res://Images/Hub/Easy.png")  # Change to your image path
	icon = button_icon
	
	# Get the popup menu and add items with the same icon
	var popup = get_popup()
	
	# Connect to selection
	popup.connect("id_pressed", Callable(self, "_on_item_selected"))

func _on_item_selected(id: int) -> void:
	var popup = get_popup()
	# Update button icon to match selected item
	icon = popup.get_item_icon(id)
	difficulty = id
	print("Selected: ", popup.get_item_text(id))
