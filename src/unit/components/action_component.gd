class_name ActionComponenet
extends Node

## Note, this component is unit-specific
var unit: Unit
# Note: Set doesn't exist but Dictionary comes close
var subscribed_tiles: Dictionary[Vector2i, bool] = {}


func get_moves() -> Array[ActionInstance]:
	Navigation.unsubscibe_from_cells(unit, subscribed_tiles)
	subscribed_tiles.clear()
	var AIs: Array[ActionInstance]
	AIs.assign(unit.def.move_definitions.map(
		func (def: ActionDefinition) -> ActionInstance: return def.to_action_instance(unit) as ActionInstance)
		)
	if (AIs):
		return _filter_ais(AIs)
	return []

## This function should be called before deleting this node
func cleanup() -> void:
	Navigation.unsubscibe_from_cells(unit, subscribed_tiles)
	subscribed_tiles.clear()
	
func execute_action(ai: ActionInstance, turn_type: Constants.TurnType) -> void:
	var ai_unit: Unit = ai.unit
	match turn_type:
		Constants.TurnType.TURN_BASED:
			if ai.definition.move_unit:
				ai_unit.move_hex(ai.end_point)
			for effect: EffectBase in ai.definition.unit_effects:
				ai_unit.apply_effect(effect, ai_unit)
			for tile: Vector2i in ai.target_tiles:
				# TODO: Handle case with more than one enemy on tile
				var target: Unit = Navigation.get_enemy_on_cell(ai_unit, tile)
				if target and _validate_target(target, ai_unit, ai.definition.target_predicates):
					for effect: EffectBase in ai.definition.target_effects:
						target.apply_effect(effect, ai_unit)
		Constants.TurnType.COOLDOWN_BASED_INSTANT, Constants.TurnType.COOLDOWN_BASED_TRAVEL_TIME:
			pass
	unit.action_complete.emit()

func _validate_target(target: Unit, unit_targeting: Unit, target_predicates: Array[UnitPredicate]) -> bool:
	return target_predicates.all(func(pred: UnitPredicate) -> bool: return pred.test(target, unit_targeting))

func _filter_ais(ais: Array[ActionInstance]) -> Array[ActionInstance]:
	var valid: Array[ActionInstance] = []
	
	for ai in ais:	
		if not ai.validate_predicates():
			continue
		
		if  ai.definition.tile_block_mode == ActionDefinition.BlockMode.IGNORE and \
			ai.definition.ally_unit_block_mode == ActionDefinition.BlockMode.IGNORE and \
			ai.definition.enmemy_unit_block_mode == ActionDefinition.BlockMode.IGNORE:
				_process_unblocked(valid, ai)
				continue
		
		var block_result: Dictionary = Navigation.get_ai_block_point_and_reason(ai, subscribed_tiles)
		var block_reason: Navigation.BlockReason = block_result.block_reason
		var block: Vector2i = block_result.block_point
		
		# Get correct block mode
		var block_mode: ActionDefinition.BlockMode = ActionDefinition.BlockMode.CANCEL
		match block_reason:
			Navigation.BlockReason.TERRAIN:
				block_mode = ai.definition.tile_block_mode
			Navigation.BlockReason.ALLY_UNIT:
				block_mode = ai.definition.ally_unit_block_mode
			Navigation.BlockReason.ENEMY_UNIT:
				block_mode = ai.definition.enemy_unit_block_mode
			Navigation.BlockReason.MAP_EDGE:
				if ai.definition.tile_block_mode == ActionDefinition.BlockMode.CANCEL:
					block_mode = ActionDefinition.BlockMode.CANCEL
				else:
					block_mode = ActionDefinition.BlockMode.TRUNCATE_BEFORE
			Navigation.BlockReason.NONE: # Path was not blocked
				_process_unblocked(valid, ai)
				continue
		
		match block_mode:
			ActionDefinition.BlockMode.TRUNCATE_BEFORE:
				ai.end_point = block
				var idx := ai.full_path.find(ai.end_point)
				ai.path = ai.full_path.slice(0, idx)
				if ai.path.size() > 0:
					_process_unblocked(valid, ai)
				continue
			ActionDefinition.BlockMode.TRUNCATE_ON:
				var idx := ai.full_path.find(block)
				ai.path = ai.full_path.slice(0, idx + 1)
				ai.end_point = ai.path[ai.path.size() - 1]
				_process_unblocked(valid, ai)
			ActionDefinition.BlockMode.CANCEL:
				continue
			_:
				printerr("Error: Unnhandled blockMode in action_component")
	
	return valid

## This function will validate the endpoint of the AI, generate subpaths if necessary, 
## and append valid AIs to the input array
func _process_unblocked(valid_ais: Array[ActionInstance], ai: ActionInstance) -> void:
	if Navigation.is_ai_endpoint_tile_valid(ai, subscribed_tiles) and ai.validate_endpoint_predicates():
		valid_ais.append(ai)
	if ai.definition.generate_subpaths and ai.path.size() > 1:
		var ai_subpath := ai.duplicate()
		# Remove last tile of path
		ai_subpath.path = ai_subpath.path.slice(0, -1)
		ai_subpath.end_point = ai_subpath.path[ai_subpath.path.size() - 1]
		# Recursively generate and add subpaths
		_process_unblocked(valid_ais,ai_subpath)
