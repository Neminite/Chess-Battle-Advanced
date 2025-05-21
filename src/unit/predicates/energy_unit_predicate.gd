class_name UnitEnergyPredicate
extends UnitPredicate

@export var required_energy: int

func test(unit_to_test: Unit, _testing_unit: Unit = null) -> bool:
	return unit_to_test.energy >= required_energy
