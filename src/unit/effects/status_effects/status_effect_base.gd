class_name StatusEffectBase
extends EffectBase

enum EffectDurationType {
	## Persistant effect, only needs on_apply and on_remove
	PERMANENT, 
	TICKS,
	## Note this will include the turn the effect is applied on
	UNIT_TURNS,
	GLOBAL_TURNS,
	ENEMY_TURNS,
	## Duration is number of global turns, but will be converted to Ticks if the TurnType is time based
	TICKS_OR_GLOBAL_TURNS
}

var unit: Unit

var duration_type: EffectDurationType

@export var duration: int = 1

func _init() -> void:
	self.duration_type = EffectDurationType.PERMANENT
	
func get_id() -> Constants.EffectId:
	return Constants.EffectId.BASE_EFFECT
	
func on_apply(this_unit: Unit, applier: Unit = null) -> void:
	super(this_unit, applier)
	unit = this_unit
	match duration_type:
		EffectDurationType.TICKS:
			pass
		EffectDurationType.UNIT_TURNS:
			unit.action_complete.connect(update)
		EffectDurationType.GLOBAL_TURNS:
			EventBus.unit_finished_turn.connect(update)
		EffectDurationType.ENEMY_TURNS:
			EventBus.unit_finished_turn.connect(_global_turn_update)
		EffectDurationType.TICKS_OR_GLOBAL_TURNS:
			pass
			
func update() -> void:
	reduce_duration()
	
func on_remove() -> void:
	match duration_type:
		EffectDurationType.UNIT_TURNS:
			unit.action_complete.disconnect(update)
		EffectDurationType.GLOBAL_TURNS:
			EventBus.unit_finished_turn.disconnect(update)
		EffectDurationType.ENEMY_TURNS:
			EventBus.unit_finished_turn.disconnect(_global_turn_update)
		EffectDurationType.TICKS_OR_GLOBAL_TURNS:
			pass
	
func compound_effect(_compounding_effect: EffectBase) -> void:
	pass
	
func reduce_duration(reduce_amount: int = 1) -> void:
	duration -= reduce_amount
	if duration <= 0:
		unit.remove_effect(self)

func _global_turn_update(turn_complete_unit: Unit) -> void:
	if duration_type == EffectDurationType.ENEMY_TURNS:
		if not unit.is_unit_ally(turn_complete_unit):
			update()
