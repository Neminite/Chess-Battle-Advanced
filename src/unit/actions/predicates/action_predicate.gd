class_name ActionPredicate
extends Resource

func test(unit: Unit = null) -> bool:
	return false

func test_endpoint(endpoint: Vector2i, unit: Unit = null) -> bool:
	return test(unit)
