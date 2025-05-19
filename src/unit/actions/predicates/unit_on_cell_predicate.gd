class_name UnitOnCellActionPredicate
extends ActionPredicate

@export var cell: Vector2i
## -1 = any team
@export var team: int = -1
## Overwrites team
@export var require_ally: bool = false
## Overwrites team
@export var require_enemy: bool = false
## Number of required units, 0 to require no matching units on cell, otherwise specifies a minumum
@export var required_unit_count: int = 1

func to_predicate_instance(unit: Unit = null) -> ActionPredicateInstance:
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
	
func to_endpoint_predicate_instance(endpoint: Vector2i, unit: Unit = null) -> ActionPredicateInstance:
	var instance: UnitOnCellPredicateInstance = to_predicate_instance(unit);
	instance.cell += endpoint
	return instance

class UnitOnCellPredicateInstance extends ActionPredicateInstance:
	var cell: Vector2i
	## -1 = any team
	var team: int
	## Number of required units, 0 to require no matching units on cell, otherwise specifies a minumum
	var required_unit_count: int
	var exclude_team := false
	
	func _init(cell_to_check: Vector2i, team_to_check: int, req_unit_count: int) -> void:
		cell = cell_to_check
		team = team_to_check
		required_unit_count = req_unit_count
	
	func evaluate() -> bool:
		var units = Navigation.get_units_on_cell(cell)
		if required_unit_count == 1: ## Slight optimization to use any in the case, probably unneeded
			if exclude_team:
				return units.any(_does_not_match_team)
			elif team != -1: # Filter for specific team
				return units.any(_does_match_team)
			#else
			return units.size() > 0
		elif required_unit_count == 0:
			if exclude_team:
				return not units.any(_does_not_match_team)
			elif team != -1: # Filter for specific team
				return not units.any(_does_match_team)
			#else
			return units.size() == 0
		else:
			if exclude_team:
				return units.filter(_does_not_match_team).size() >= required_unit_count
			elif team != -1: # Filter for specific team
				return units.filter(_does_match_team).size() >= required_unit_count
			#else
			return units.size() >= required_unit_count
			
	func _does_match_team(unit_on_tile): return unit_on_tile.team == team
	func _does_not_match_team(unit_on_tile): return unit_on_tile.team != team
