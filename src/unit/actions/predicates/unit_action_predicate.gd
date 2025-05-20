class_name UnitActionPredicate
extends ActionPredicate

## Note: This only supports unit predicates that only require one unit
@export var unit_predicate: UnitPredicate

func test(unit: Unit = null) -> bool:
	assert(unit != null, "UnitPredicate requires a unit")
	return unit_predicate.test(unit)
