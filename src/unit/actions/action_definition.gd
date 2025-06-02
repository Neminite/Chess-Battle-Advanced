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
## Currently optional, helpful to keep things organized
@export var name: String
### Action Path exports
@export_group("Path")
## All values relative to the origin at (0, 0)
@export var path: Array[Vector2i] = []
## All values relative to the origin at (0, 0). If left as max, will be set to last tile on path
@export var end_point: Vector2i = Vector2i.MAX
@export var tile_block_mode: BlockMode
@export var ally_unit_block_mode: BlockMode
@export var enemy_unit_block_mode: BlockMode
## All tile types that block this action's path
@export var blocking_tile_types: Array[Constants.TileType] = \
	[Constants.TileType.MOUNTAIN, 
	 Constants.TileType.PIT]
## All unit types that block this action's path
@export var blocking_unit_category: Array[Constants.UnitCategory] = \
	[Constants.UnitCategory.NORMAL]
## All tile types that block this action's endpoint TODO: Replace this with a predicate
@export var invalid_end_tile_types: Array[Constants.TileType] = \
	[Constants.TileType.MOUNTAIN, 
	 Constants.TileType.PIT]
## List of predicates to evaluate at endpoint
@export var endpoint_predicates: Array[ActionPredicate] = []
## List of required predicates to validate
@export var predicates: Array[ActionPredicate] = []
## Whether to duplicate path based on range
@export var affected_by_range: bool = false
## If this is true, moves will be generated for each tile in the path only rechecking the end tile
@export var generate_subpaths: bool = false
## If the unit that executes this action will move
@export_group("Unit Effects")
@export var move_unit: bool = true
## Effects to apply to self after move
@export var unit_effects: Array[EffectBase] = [preload("res://src/unit/effects/default/default_cooldown_effect.tres")]
#### These variables define the target and target effects:
@export_group("Target")
## List of tiles to target with this ability, this is expressed in offset from endpoint
@export var target_tiles: Array[Vector2i] = [Vector2i(0,0)]
## Predicates to only target certain units (Ex: Enemies only)
@export var target_predicates: Array[UnitPredicate] = [preload("res://src/unit/predicates/default/is_enemy_predicate.tres")]
## Effects to apply to the target
@export var target_effects: Array[EffectBase] = [preload("res://src/unit/effects/default/capture_effect.tres")]

func to_action_instance(unit: Unit) -> ActionInstance:
	var current_cell: Vector2i = unit.cell
	var current_rot: int = unit.move_rotation
	var ai := ActionInstance.new(self, unit)
	# Calculate how range affects the ability
	var constructed_path: Array[Vector2i] = path.duplicate()
	var constructed_end_point: Vector2i = end_point
	if constructed_end_point == Vector2i.MAX:
		constructed_end_point = path[-1]
	var init_end_point: Vector2i = constructed_end_point
	if affected_by_range:
		for n in unit.base_range:
			var last_cell: Vector2i = constructed_path[-1]
			constructed_end_point += init_end_point
			for cell in path:
				constructed_path.append(cell + last_cell)
			
	
	# WORKAROUND, fix if https://github.com/godotengine/godot/pull/71336 is merged
	var instanced_path: Array[Vector2i]
	instanced_path.assign(constructed_path.map(
		func (cell: Vector2i) -> Vector2i:
			return Navigation.localize_hex(cell, current_cell, current_rot)
	))
	ai.path = instanced_path
	var instanced_ep: Vector2i = Navigation.localize_hex(constructed_end_point, current_cell, current_rot)
	ai.end_point = instanced_ep
	ai.target_tiles_offset = target_tiles
	return ai
	
