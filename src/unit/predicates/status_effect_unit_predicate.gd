class_name UnitStatusEffectPredicate
extends UnitPredicate

@export var required_status_effect: Constants.EffectId = Constants.EffectId.BASE_EFFECT

func test(unit_to_test: Unit, _testing_unit: Unit = null) -> bool:
	return unit_to_test.has_effect_id(required_status_effect)
