class_name EffectComponenet
extends Node

## Note, this component is unit-specific
var unit: Unit

## Dictionary of EffectId to the effect. Effects will handle stacking internally
var active_effects: Dictionary[String, EffectBase]

func apply_effect(effect: EffectBase):
	var effect_id = effect.get_id()
	var existing_effect: EffectBase = active_effects.get(effect_id)
	if existing_effect:
		existing_effect.compound_effect(effect)
	else:
		active_effects.set(effect_id, effect)
		effect.unit = unit
		effect.on_apply()
	
func remove_effect(effect: EffectBase):
	if has_effect(effect):
		active_effects.erase(effect.get_id())
	
func has_effect(effect: EffectBase) -> bool:
	return active_effects.has(effect.get_id())
	
func has_effect_id(effect_id: String) -> bool:
	return active_effects.has(effect_id)
