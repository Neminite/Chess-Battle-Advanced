class_name TeamUnitPredicate
extends UnitPredicate

## Require unit to be on a specific team. Will not throw error if testing_unit is null. Priority 1
@export var team: int = -1
## Require the unit to be an ally of the testing unit. (Throws error if testing unit is null). Priority 2
@export var require_ally: bool = false
## Require the unit to not be an ally of the testing unit. (Throws error if testing unit is null). Priority 3
@export var require_enemy: bool = false

func test(unit_to_test: Unit, testing_unit: Unit = null) -> bool:
	if team != -1:
		return unit_to_test.team == team
	assert(testing_unit != null, "testing_unit cannot be null when checking ally status")
	var is_ally = testing_unit.is_unit_ally(unit_to_test)
	if require_ally:
		return is_ally
	if require_enemy:
		return not is_ally
	printerr("ERROR: TeamUnitPredicate has no filters set")
	return false
