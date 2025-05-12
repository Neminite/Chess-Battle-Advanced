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
## All tile types that block this action's endpoint
@export var invalid_end_tile_types: Array[Constants.TileTypes] = \
	[Constants.TileTypes.MOUNTAIN, 
	 Constants.TileTypes.PIT]
## If this is true, moves will be generated for each tile in the path only rechecking the end tile
@export var generate_subpaths: bool = false
## If this move requires an enemy at the end point
@export var require_enemy: bool = false
## If the unit that executes this action will move
@export var move_unit: bool = true
## If the enemy at the endpoint will be captured when executing this move
@export var capture_enemy = true


var full_path: Array:
	get:
		return path + [end_point]

func to_action_instance(unit: Unit) -> ActionInstance:
	var current_cell: Vector2i = unit.cell
	var ac = ActionInstance.new(self, unit)
	
	# WORKAROUND, fix if https://github.com/godotengine/godot/pull/71336 is merged
	var instanced_path: Array[Vector2i]
	instanced_path.assign(path.map(
		func (cell):
			return cell + current_cell
	))
	ac.path = instanced_path
	ac.end_point = end_point + current_cell
	return ac
