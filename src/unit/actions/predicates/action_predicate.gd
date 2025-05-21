class_name ActionPredicate
extends Resource

func test(_unit: Unit = null) -> bool:
	return false

func test_endpoint(_endpoint: Vector2i, unit: Unit = null) -> bool:
	return test(unit)
