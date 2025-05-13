class_name ActionPredicate
extends Resource

func to_predicate_instance(unit: Unit = null) -> ActionPredicateInstance:
	return null

func to_endpoint_predicate_instance(endpoint: Vector2i, unit: Unit = null) -> ActionPredicateInstance:
	return to_predicate_instance(unit)
