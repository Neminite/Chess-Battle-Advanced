class_name SetCooldownEffect
extends EffectBase
## Sets a unit's cooldown to amount if amount is greater than the current cooldown
## If amount is 0, sets amount to the Global standard cooldown

func get_id() -> Constants.EffectId:
	return Constants.EffectId.SET_COOLDOWN

func on_apply(unit: Unit, applier: Unit = null) -> void:
	super(unit, applier)
	if amount == 0:
		amount = Constants.GLOBAL_TURN_DURATION_TICKS
	unit.cooldown = max(unit.cooldown, amount)
