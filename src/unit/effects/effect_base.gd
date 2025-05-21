class_name EffectBase
extends Resource

## Effects handle both status effects, and instant effects of an attack 
## such as damaging or capturing a unit

@export var amount: int = 0

func get_id() -> Constants.EffectId:
	return Constants.EffectId.BASE_EFFECT

## applier can be null, as effects can be applied by sources other than a unit
func on_apply(unit: Unit, _applier: Unit = null) -> void:
	assert(unit != null, "Effects require a unit")
	
