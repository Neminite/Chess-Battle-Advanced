class_name EffectBase
extends Resource

@export var duration_type: EffectDurationType = EffectDurationType.PERMANENT
@export var duration: int = 1
@export var amount: int = 1

enum EffectDurationType {
	## Non-persistant one time effect, only needs on_apply
	INSTANT, 
	## Persistant effect, only needs on_apply and on_remove
	PERMANENT, 
	TICKS,
	UNIT_TURNS,
	GLOBAL_TURNS,
	## Duration is number of global turns, but will be converted to Ticks if the TurnType is time based
	TICKS_OR_GLOBAL_TURNS
}

var unit: Unit

func on_apply():
	match duration_type:
		EffectDurationType.PERMANENT:
			pass
		EffectDurationType.TICKS:
			pass
		EffectDurationType.UNIT_TURNS:
			unit.action_complete.connect(on_update)
		EffectDurationType.GLOBAL_TURNS:
			pass
		EffectDurationType.TICKS_OR_GLOBAL_TURNS:
			pass
	
func on_update():
	reduce_duration()
	
func on_remove():
	pass
	
func compound_effect(compounding_effect: EffectBase):
	pass
	
func reduce_duration(amount: int = 1):
	duration -= amount
	if duration <= 0:
		unit.remove_effect(self)
		
func get_id() -> String:
	return "BaseEffect"
