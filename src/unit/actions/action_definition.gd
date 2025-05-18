class_name ActionDefinition
extends Resource

enum ActionType {
	Move,
	Ability
}

enum BlockMode {
	CANCEL,
	TRUNCATE_BEFORE,
	TRUNCATE_ON,
	IGNORE
}

# TODO: Add filter on unique action endpoints when constructing instance list

@export var tile_block_mode: BlockMode
@export var ally_unit_block_mode: BlockMode
@export var enemy_unit_block_mode: BlockMode
## All tile types that block this action's path
@export var blocking_tile_types: Array[Constants.TileTypes] = \
	[Constants.TileTypes.MOUNTAIN, 
	 Constants.TileTypes.PIT]
## All unit types that block this action's path
@export var blocking_unit_category: Array[Constants.UnitCategory] = \
	[Constants.UnitCategory.NORMAL]
## All values relative to the origin at (0, 0)
@export var path: Array[Vector2i] = []
## All values relative to the origin at (0, 0)
@export var end_point: Vector2i
## All tile types that block this action's endpoint TODO: Replace this with a predicate
@export var invalid_end_tile_types: Array[Constants.TileTypes] = \
	[Constants.TileTypes.MOUNTAIN, 
	 Constants.TileTypes.PIT]
## If this move requires an enemy at the end point TODO: Replace this with a predicate
@export var require_enemy: bool = false
## If this is true, moves will be generated for each tile in the path only rechecking the end tile
@export var generate_subpaths: bool = false
## If the unit that executes this action will move
@export var move_unit: bool = true
## If the enemy at the endpoint will be captured when executing this move
@export var capture_enemy = true
## List of required predicates to validate
@export var predicates: Array[ActionPredicate] = []
## List of predicates to evaluate at endpoint
@export var endpoint_predicates: Array[ActionPredicate] = []
## Whether to duplicate path based on range
@export var affected_by_range: bool = false

var full_path: Array:
	get:
		return path + [end_point]

func to_action_instance(unit: Unit) -> ActionInstance:
	var current_cell: Vector2i = unit.cell
	var current_rot: int = unit.move_rotation
	var predicate_instances: Array[ActionPredicateInstance] 
	predicate_instances.assign(predicates.map(func(pred): return pred.to_predicate_instance(unit)))
	var ac = ActionInstance.new(self, unit, predicate_instances, endpoint_predicates)
	
	# Calculate how range affects the ability
	var constructed_path: Array[Vector2i] = path.duplicate()
	var constructed_end_point: Vector2i = end_point
	if affected_by_range:
		for n in unit.range:
			var last_cell: Vector2i = constructed_path[-1]
			constructed_end_point += end_point
			for cell in path:
				constructed_path.append(cell + last_cell)
			
	
	# WORKAROUND, fix if https://github.com/godotengine/godot/pull/71336 is merged
	var instanced_path: Array[Vector2i]
	instanced_path.assign(constructed_path.map(
		func (cell):
			return Navigation.localize_hex(cell, current_cell, current_rot)
	))
	ac.path = instanced_path
	ac.end_point = Navigation.localize_hex(constructed_end_point, current_cell, current_rot)
	return ac
	
