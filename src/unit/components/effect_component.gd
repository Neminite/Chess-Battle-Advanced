class_name EffectComponenet
extends Node

## Note, this component is unit-specific
var unit: Unit

## Dictionary of EffectId to the effect. Effects will handle stacking internally
var active_effects: Dictionary[Constants.EffectId, StatusEffectBase] = {}

func apply_effect(effect: EffectBase, applier: Unit = null) -> void:
	assert(unit != null, "Unit must be set in effect_component")
	if effect is StatusEffectBase:
		_apply_status_effect(effect, applier)
	else:
		effect.on_apply(unit, applier)
		
func _apply_status_effect(effect: StatusEffectBase, applier: Unit = null) -> void:
	var effect_id := effect.get_id()
	var existing_effect: StatusEffectBase = active_effects.get(effect_id)
	if existing_effect:
		existing_effect.compound_effect(effect)
	else:
		var new_effect: StatusEffectBase = effect.duplicate() as StatusEffectBase
		active_effects.set(effect_id, new_effect)
		new_effect.on_apply(unit, applier)
	
func remove_effect(effect: EffectBase) -> void:
	if has_effect(effect):
		active_effects.erase(effect.get_id())
	
func has_effect(effect: EffectBase) -> bool:
	return active_effects.has(effect.get_id())
	
func has_effect_id(effect_id: Constants.EffectId) -> bool:
	return active_effects.has(effect_id)
