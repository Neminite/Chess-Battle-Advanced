extends TileMapLayer

@onready var unit_controller = %UnitController

func _ready() -> void:
	Navigation.init_level(self, unit_controller.get_active_units)

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#print("Left button was clicked at ", event.position)
			#var clicked_cell_pos = local_to_map(get_local_mouse_position())
			##var clicked_cell = get_cell_tile_data(clicked_cell_pos)
			#print("Cell: ", clicked_cell_pos)
	#elif event is InputEventMouseMotion:
		#var cell_pos = local_to_map(get_local_mouse_position())
		#
