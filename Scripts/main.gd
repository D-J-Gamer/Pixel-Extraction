


extends Node2D

var main_menu := true

var mapping := {
		"StartGame": "Start_Game",
		"LoadGame": "Load_Game",
		"Settings": "Settings",
		"Exit": "Exit_Game",
	}

# This script is a placeholder for the main menu logic.
# GDScript doesn't allow executable statements (like `while`) in the class body.
# Put runtime logic inside functions such as `_ready()` or `_process(delta)`.

func _ready() -> void:
	print("Main.gd ready — main_menu=%s" % str(main_menu))
	# Show your UI, connect button signals, etc. Do not block here with long loops.
	# Connect button `pressed` signals to handler methods if the nodes exist in the scene.
	
	

	# Ensure processing is enabled so `_process` will be called every frame
	set_process(true)

func show_main_menu() -> void:
	# Implement UI creation or scene switching here.
	pass

func _process(_delta: float) -> void:
	# Use _process for per-frame checks instead of a blocking `while` loop.
	if main_menu:
		# Lightweight debug accumulator to print once per second so output isn't spammy.
		if not has_meta("_process_debug_acc"):
			set_meta("_process_debug_acc", 0.0)
		var acc = get_meta("_process_debug_acc")
		acc += _delta
		if acc >= 1.0:
			# print("_process called (1s tick) — main_menu=%s" % str(main_menu))
			acc = 0.0
		set_meta("_process_debug_acc", acc)
		
		for node_name in mapping.keys():
			# print("Checking for node: %s" % node_name)
			var button_parent = get_node_or_null("Tree")
			var button = button_parent.get_node_or_null(node_name)
			# print(button_parent.get_node(node_name))
			# if has_node(button):
			# if button == null:
				# print("Node %s not found in scene." % node_name)
			# print("Connecting button signal for node: %s" % node_name)
			# var node := get_node(node_name)
			if button and button.has_signal("pressed"):
				# Use `Callable` so name changes still connect correctly
				button.connect("pressed", Callable(self, mapping[node_name]))


func Start_Game() -> void:
	# Called when the StartGame button is pressed
	print("Start_Game(): Start button pressed")
	# TODO: change to your gameplay scene, e.g.:
	# get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func Load_Game() -> void:
	# Called when the LoadGame button is pressed
	print("Load_Game(): Load button pressed")
	# TODO: implement load-game logic


func Settings() -> void:
	# Called when the Settings button is pressed
	print("Settings(): Settings button pressed")
	# TODO: open settings UI or scene


func Exit_Game() -> void:
	# Called when the Exit button is pressed
	print("Exit_Game(): Exit button pressed — quitting")
	get_tree().quit()
