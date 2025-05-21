class_name ReduceEnergyEffect
extends EffectBase

## Reduces unit's energy by amount (to a min of zero)

func get_id() -> Constants.EffectId:
	return Constants.EffectId.REDUCE_ENERGY

func on_apply(unit: Unit, applier: Unit = null) -> void:
	super(unit, applier)
	unit.energy = max(unit.energy - amount, 0)
