class_name UnitOnCellPredicate
extends Resource

@export var cell: Vector2i
## -1 = any team
@export var team: int = -1
## Overwrites team
@export var require_ally: bool = false
## Overwrites team
@export var require_enemy: bool = false
## Number of required units, 0 to require no matching units on cell, otherwise specifies a minumum
@export var required_unit_count: int = 1

func to_predicate_instance(unit: Unit = null) -> UnitOnCellPredicateInstance:
	assert(unit != null, "UnitOnCellPredicate requires unit in instantiation")
	var current_cell: Vector2i = unit.cell
	var current_rot: int = unit.move_rotation
	var pred_cell: Vector2i = Navigation.localize_hex(cell, current_cell, current_rot)
	var pred = UnitOnCellPredicateInstance.new(
		pred_cell,
		team,
		required_unit_count)
	if require_ally or require_enemy:
		pred.team = unit.team
		if require_ally and require_enemy:
			assert(false, "Error, only one of require_ally and require_enemy should be set")
	if require_enemy:
		pred.exclude_team = true
	
	# If a unit is looking at a cell, we want to update the unit when that cell changes
	Navigation.subscribe_unit_to_cell(unit, pred_cell)
	
	return pred
	
func to_endpoint_predicate_instance(endpoint: Vector2i, unit: Unit = null) -> UnitOnCellPredicateInstance:
	var instance: UnitOnCellPredicateInstance = to_predicate_instance(unit);
	instance.cell += endpoint
	return instance
