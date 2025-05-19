extends Node2D

enum TurnTypes {
	TURN_BASED,
	COOLDOWN_BASED_INSTANT,
	COOLDOWN_BASED_TRAVEL_TIME
}
@export var turn_type: TurnTypes = TurnTypes.TURN_BASED

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
				func (unit: Unit): return unit.team == team;
			)
			player_team = team

## For debugging:
func _draw():
	if selected_unit:
		var pos = to_local(selected_unit.global_position)
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
	return units.filter(func (unit: Unit): return unit.is_active)

func register_unit(unit: Unit) -> void:
	units.append(unit)
	# Bind deregister to the unit caputed signal
	unit.unit_captured.connect(deregister_unit.bind(unit))
	if unit.team == player_team:
		player_units.append(unit)
	
func deregister_unit(unit: Unit) -> void:
	units.erase(unit)
	player_units.erase(unit)
	
func execute_action(ai: ActionInstance) -> void:
	var unit: Unit = ai.unit
	match turn_type:
		TurnTypes.TURN_BASED:
			if turn_type == TurnTypes.TURN_BASED and current_team != unit.team:
				assert(false, "Error: move attempted on opponent's turn")
			if ai.definition.move_unit:
				unit.move_hex(ai.end_point)
			if ai.definition.capture_enemy:
				var enemy: Unit = Navigation.get_enemy_on_cell(unit, ai.end_point)
				if enemy:
					enemy.capture(current_team)
			_advance_turn()
		TurnTypes.COOLDOWN_BASED_INSTANT, TurnTypes.COOLDOWN_BASED_TRAVEL_TIME:
			pass
	selected_unit = null
	
	
func tmp_display_moves(unit: Unit):
	tmp_points_to_draw.clear()
	if unit:
		for action in unit.available_actions:
			var point_pos = Navigation.hex_to_world(action.end_point)
			if action.definition.require_enemy:
				tmp_points_to_draw.append({pos = point_pos, color = Color.DARK_RED})
			else:
				tmp_points_to_draw.append({pos = point_pos, color = Color.AQUA})
			
func _advance_turn() -> void:
	var cur_team_index = teams.find(current_team)
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
	# DEBUG:
	click_pos = pos
	queue_redraw()
	if clicked_unit:
		match turn_type:
			TurnTypes.TURN_BASED:
				if current_team == clicked_unit.team:
					selected_unit = clicked_unit
			TurnTypes.COOLDOWN_BASED_INSTANT, TurnTypes.COOLDOWN_BASED_TRAVEL_TIME:
				if clicked_unit.cooldown <= 0:
					selected_unit = clicked_unit
	elif selected_unit:
		var clicked_tile = Navigation.world_to_hex(pos)
		var ai_index = selected_unit.available_actions.find_custom(
			func(ai: ActionInstance): return ai.end_point == clicked_tile
		)
		if ai_index >= 0:
			execute_action(selected_unit.available_actions[ai_index])


func _unhandled_input(event: InputEvent) -> void:
	var local_event = make_input_local(event)
	if local_event is InputEventMouseMotion:
		pass
	elif local_event is InputEventMouseButton and local_event.pressed and local_event.button_index == MOUSE_BUTTON_LEFT:
		var click_event = local_event as InputEventMouseButton
		_process_left_click(click_event.position)
		
