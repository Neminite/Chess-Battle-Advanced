class_name EnergyActionPredicate
extends ActionPredicate

@export var required_energy: int

func to_predicate_instance(unit: Unit = null) -> ActionPredicateInstance:
	assert(unit != null, "EnergyPredicateInstance requires unit in instantiation")
	return EnergyPredicateInstance.new(unit, required_energy)

class EnergyPredicateInstance extends ActionPredicateInstance:
	var required_energy: int
	var unit: Unit
	
	func _init(unit_to_check: Unit, unit_required_energy: int) -> void:
		unit = unit_to_check
		required_energy = unit_required_energy
	
	func evaluate() -> bool:
		return unit.energy >= required_energy
