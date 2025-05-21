extends Node2D


@export var turn_type: Constants.TurnType = Constants.TurnType.TURN_BASED

var units: Array[Unit]
var player_units: Array[Unit] # Sub-array of above
var current_team: int = 0 # team whos turn it is
var teams: Array[int] = [0]

var click_pos: Vector2
var tmp_points_to_draw: Array[Dictionary] # [{pos: Vector2, color: color},...] 

var selected_unit: Unit:
	set(unit):
		selected_unit = unit
		if unit:
			unit.update_move_paths()
		tmp_display_moves(unit)
		queue_redraw()

var player_team: int = 0:
	set(team):
		if team != player_team:
			player_units.clear()
			player_units = units.filter(
				func (unit: Unit) -> bool: return unit.team == team;
			)
			player_team = team

## For debugging:
func _draw() -> void:
	if selected_unit:
		var pos: Vector2i = to_local(selected_unit.global_position)
		draw_circle(pos, 2.0, Color.RED, false)
	if click_pos:
		draw_circle(click_pos, 2.0, Color.GREEN, false)
	for unit in player_units:
		draw_rect(unit.get_rect(), Color.BLUE_VIOLET, false)
	for point in tmp_points_to_draw:
		draw_circle(point.pos, 2.0, point.color, false)
	
	#var default_font = ThemeDB.fallback_font
	#for hex: Vector2i in Navigation.hexmap.keys():
		#var draw_pos = Navigation.hex_to_world(hex)
		#draw_string(default_font, draw_pos, str(hex), HORIZONTAL_ALIGNMENT_CENTER, -1, 4)
		#draw_pos.y += 5
		#draw_string(default_font, draw_pos, str(Navigation.oddq_from_axial(hex)), HORIZONTAL_ALIGNMENT_CENTER, -1, 4, Color.AQUA)
		
func _ready() -> void:
	for child in get_children():
		if child is Unit:
			register_unit(child)
	queue_redraw.call_deferred()

func get_active_units() -> Array[Unit]:
	return units.filter(func (unit: Unit) -> bool: return unit.is_active)

func register_unit(unit: Unit) -> void:
	units.append(unit)
	# Bind deregister to the unit caputed signal
	unit.unit_captured.connect(deregister_unit.bind(unit))
	if unit.team not in teams:
		teams.append(unit.team)
	## TEMPORARY TO PLAYTEST THINGS. TODO: REMOVE THIS
	if unit.team == player_team:
		pass
	player_units.append(unit)
	
func deregister_unit(unit: Unit) -> void:
	units.erase(unit)
	player_units.erase(unit)
	var active_teams: Dictionary[int, bool] = {}
	for u: Unit in units:
		active_teams.set(u.team, true)
	# Remove unit's team from teams if it was the last unit
	if not active_teams.get(unit.team, false):
		teams.erase(unit.team)
	
func tmp_display_moves(unit: Unit) -> void:
	tmp_points_to_draw.clear()
	if unit:
		for action in unit.available_actions:
			var point_pos: Vector2i = Navigation.hex_to_world(action.end_point)
			tmp_points_to_draw.append({pos = point_pos, color = Color.AQUA})
			
func _advance_turn() -> void:
	var cur_team_index: int = teams.find(current_team)
	cur_team_index += 1
	if cur_team_index >= teams.size():
		cur_team_index = 0
	current_team = teams[cur_team_index]
	
func _get_clicked_player_unit(global_pos: Vector2) -> Unit:
	for unit in player_units:
		if unit.get_rect().has_point(to_local(global_pos)):
			return unit
	return null

func _process_left_click(pos: Vector2) -> void:
	var clicked_unit: Unit = _get_clicked_player_unit(pos)
	var selected_new_unit: bool = false
	# DEBUG:
	click_pos = pos
	queue_redraw()
	if clicked_unit:
		match turn_type:
			Constants.TurnType.TURN_BASED:
				if current_team == clicked_unit.team:
					selected_unit = clicked_unit
					selected_new_unit = true
			Constants.TurnType.COOLDOWN_BASED_INSTANT, Constants.TurnType.COOLDOWN_BASED_TRAVEL_TIME:
				if clicked_unit.cooldown <= 0:
					selected_unit = clicked_unit
					selected_new_unit = true
	if selected_unit and not selected_new_unit:
		var clicked_tile: Vector2i = Navigation.world_to_hex(pos)
		## TODO: Look into moving this code elsewhere
		var ai_index: int = selected_unit.available_actions.find_custom(
			func(ai: ActionInstance) -> bool: return ai.end_point == clicked_tile
		)
		if ai_index >= 0:
			selected_unit.execute_action(selected_unit.available_actions[ai_index], turn_type)
			# Deselect unit
			EventBus.unit_finished_turn.emit(selected_unit)
			selected_unit = null
			if turn_type == Constants.TurnType.TURN_BASED:
				_advance_turn()


func _unhandled_input(event: InputEvent) -> void:
	var local_event: InputEvent = make_input_local(event)
	if local_event is InputEventMouseMotion:
		pass
	elif local_event is InputEventMouseButton and local_event.pressed and local_event.button_index == MOUSE_BUTTON_LEFT:
		var click_event := local_event as InputEventMouseButton
		_process_left_click(click_event.position)
		
