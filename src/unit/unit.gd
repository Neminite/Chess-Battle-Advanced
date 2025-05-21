class_name  Unit
extends Node2D

signal movement_complete
signal unit_captured
signal action_complete

@export var def: UnitDefinition
@export var team: int
@export var energy: int
## Defines the rotation , 0 = Not rotated, 3 = 180deg
@export var move_rotation: int = 0
@export var base_range: int = 1
@export var move_speed_per_cell: float = 0.15

@onready var action_componet: ActionComponenet = %action_component
@onready var effect_componet: EffectComponenet = %effect_component
@onready var sprite: Sprite2D = %sprite

# TODO: Look into best way to set this up, and best unit to calculate in. Ticks? Ms?
var cooldown: int = 0
var is_active := true
var available_actions: Array[ActionInstance] = []
var _skip_move_update := false

var cell: Vector2i:
	get:
		return Navigation.world_to_hex(global_position)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_componet.unit = self
	effect_componet.unit = self
	_init_def()
	_snap_pos.call_deferred()

func is_unit_ally(unit: Unit) -> bool:
	return unit.team == team
	
func update_move_paths() -> void:
	if not _skip_move_update:
		available_actions = action_componet.get_moves()
	
func get_rect() -> Rect2:
	var local_rect := sprite.get_rect()
	var global_pos := to_global(local_rect.position)
	var global_size := local_rect.size * scale
	return Rect2(global_pos, global_size)
	
func execute_action(ai: ActionInstance, turn_type: Constants.TurnType) -> void:
	action_componet.execute_action(ai, turn_type)
	
func move_hex(hex_pos: Vector2i) -> void:
	var old_cell := cell
	global_position = Navigation.hex_to_world(hex_pos)
	Navigation.remove_unit_from_cell(self, old_cell)
	Navigation.add_unit_to_cell(self, cell)
	# Avoid updating paths twice
	_skip_move_update = true
	Navigation.update_tiles([cell, old_cell])
	_skip_move_update = false
	update_move_paths()
	
## If reason for capture is not a unit, team will be -1
func capture(capturing_team: int) -> void:
	is_active = false
	print("Unit captured by team #", capturing_team)
	Navigation.remove_unit_from_cell(self, cell)
	action_componet.cleanup()
	unit_captured.emit()
	Navigation.update_tiles([cell])
	sprite.hide()
	queue_free()
	
func apply_effect(effect: EffectBase, applier: Unit = null) -> void:
	effect_componet.apply_effect(effect, applier)
	
func remove_effect(effect: EffectBase) -> void:
	effect_componet.remove_effect(effect)
	
func has_effect(effect: EffectBase) -> bool:
	return effect_componet.has_effect(effect)
	
func has_effect_id(effect_id: Constants.EffectId) -> bool:
	return effect_componet.has_effect_id(effect_id)

# TODO: Decide how moves will work. Real time or turn based? If real time, are units capturable while moving? Blockable?
# Current thoughts, real time, but instant moves? In this case click unit click destination best control path
#func move_along_path(path: Array[Vector2i]) -> void:
	#var move_tween = create_tween()
	#move_tween.set_ease(Tween.EASE_OUT)
	#move_tween.set_trans(Tween.TRANS_CUBIC)
	#move_tween
	#for pcell in path:
		#move_tween.tween_property(
			#self,
			#'global_position',
			#Navigation.hex_to_world(pcell),
			#move_speed_per_cell
		#)
		#if pcell.x < cell.x:
			#sprite.flip_h = true
		#elif pcell.x > cell.x:
			#sprite.flip_h = false
	#await move_tween.finished
	#movement_complete.emit()
	

func _init_def() -> void:
	sprite.texture = def.sprite
	base_range = def.base_range
	energy = def.starting_energy
	#sprite.sprite_frames = def.frames
	#sprite.play()
	
	#for component in def.type_components:
		#var comp = component.instantiate() as UnitTypeComponent
		#add_child(comp)
		#comp.unit = self

func _snap_pos() -> void:
	global_position = Navigation.snap_to_tile(global_position)
	Navigation.add_unit_to_cell(self, cell)
	
