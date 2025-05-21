extends Camera2D

var mouse_down: bool = false
var last_mouse_pos: Vector2

func _process(delta: float) -> void:
	
	if Input.is_action_just_released("mouse_wheel_up"):
		var zoom_amount := Vector2.ONE / 10
		zoom = (zoom + zoom_amount).min(Vector2.ONE * 3)

	if Input.is_action_just_released("mouse_wheel_down"):
		var zoom_amount := Vector2.ONE / 10
		zoom = (zoom - zoom_amount).max(Vector2.ONE * .3)

	if Input.is_action_just_pressed("mouse_middle"):
		mouse_down = true
		last_mouse_pos = get_global_mouse_position()
	if Input.is_action_just_released("mouse_middle"):
		mouse_down = false
	if mouse_down:
		camera_movement(delta)

func camera_movement(_delta: float) -> void:
	var offs := last_mouse_pos - get_global_mouse_position()
	offset += offs
	last_mouse_pos = get_global_mouse_position()
