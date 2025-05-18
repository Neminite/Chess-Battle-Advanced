class_name UnitOnCellPredicateInstance 
extends Resource

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
