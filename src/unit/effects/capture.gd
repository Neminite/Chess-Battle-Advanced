class_name CaptureEffect
extends EffectBase

## Capture the unit this effect is applied to

func get_id() -> Constants.EffectId:
	return Constants.EffectId.CAPTURE

func on_apply(unit: Unit, applier: Unit = null) -> void:
	super(unit, applier)
	var capturing_team := -1
	if (applier):
		capturing_team = applier.team
	unit.capture(capturing_team)
