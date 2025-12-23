extends MenuButton

const MAP_PATHS: Array = [
    "res://Maps/Dungeon.png"
    #"res://Maps/Dungeon2.png"
]
var map_path: String = MAP_PATHS[0]



func _ready() -> void:
    # var button_icon = load("res://Images/Hub/DungeonMapIconTemp.PNG")
    # icon = button_icon

    var popup = get_popup()
    popup.connect("id_pressed", Callable(self, "_on_popup_id_pressed"))

    var max_icon_width = 139
    for i in range(popup.get_item_count()):
        popup.set_item_icon_max_width(i, max_icon_width)
    # popup.set_item_icon_max_width(0, max_icon_width)

func _on_popup_id_pressed(id: int) -> void:
    var popup = get_popup()
    icon = popup.get_item_icon(id)
    map_path = MAP_PATHS[id]