class_name UnitOnCellActionPredicate
extends ActionPredicate

## Cell position offset from unit or endpoint
@export var cell_offset: Vector2i
## Predicates to validate the units found against
@export var unit_predicate_list: Array[UnitPredicate]
## Number of required units, 0 to require no matching units on cell, otherwise specifies a minumum
@export var required_unit_count: int = 1

func test(unit: Unit = null) -> bool:
	assert(unit != null, "UnitOnCellPredicate requires unit")
	var current_cell: Vector2i = unit.cell
	var current_rot: int = unit.move_rotation
	var pred_cell: Vector2i = Navigation.localize_hex(cell_offset, current_cell, current_rot)
	
	return _evaluate(unit, pred_cell)

	
func test_endpoint(endpoint: Vector2i, unit: Unit = null) -> bool:
	assert(unit != null, "UnitOnCellPredicate requires unit")
	var current_rot: int = unit.move_rotation
	var pred_cell: Vector2i = Navigation.localize_hex(cell_offset, endpoint, current_rot)
	return _evaluate(unit, pred_cell)

func _evaluate(unit: Unit, cell: Vector2i) -> bool:
	# If a unit is looking at a cell, we want to update the unit when that cell changes
	Navigation.subscribe_unit_to_cell(unit, cell)
	
	var units = Navigation.get_units_on_cell(cell)
	if required_unit_count == 1: ## Slight optimization to use any in this case, probably unneeded
			return units.any(func(unit_on_cell): return _does_match_predicate(unit_on_cell, unit))
	elif required_unit_count == 0:
		return not units.any(func(unit_on_cell): return _does_match_predicate(unit_on_cell, unit))
	else:
		return units.filter(func(unit_on_cell): return _does_match_predicate(unit_on_cell, unit)).size() >= required_unit_count

## Iterate through predicates and return false if any are false
func _does_match_predicate(unit_on_tile: Unit, testing_unit: Unit) -> bool: 
	return unit_predicate_list.all(func(pred): return pred.test(unit_on_tile, testing_unit) )
