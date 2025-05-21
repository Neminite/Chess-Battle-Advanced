class_name UnguardedStatusEffect
extends StatusEffectBase

## This effect represents when a unit is unguarded after preforming a big move.
## For example a pawn is unguarded after a double-move and it can be en-passanted
## Currently amount doesn't have an effect for this status

func _init() -> void:
	duration_type = EffectDurationType.ENEMY_TURNS

func get_id() -> Constants.EffectId:
	return Constants.EffectId.UNGUARDED_STATUS
	
func compound_effect(compounding_effect: EffectBase) -> void:
	duration = max(self.duration, compounding_effect.duration)
	
