class_name ActionInstance
extends RefCounted

var definition: ActionDefinition

var path: Array[Vector2i] = []
## Endpoint is where to click to execute the move. 
## If the unit moves it will always initially be to the endpoint
## Often but not always the last element of path
## Should always be the same if generate_sub_paths
## is true on the definition

var end_point: Vector2i
var target_tiles_offset: Array[Vector2i]
var target_tiles: Array[Vector2i]

var full_path: Array:
	get:
		return path + [end_point]

var unit: Unit

func _init(def: ActionDefinition, src_unit: Unit) -> void:
	definition = def
	unit = src_unit

func duplicate() -> ActionInstance:
	var new_obj := ActionInstance.new(definition, unit)
	# Note this is a shallow copy, change this if the vectors need to be modified later
	new_obj.path = path.duplicate()
	new_obj.end_point = end_point
	new_obj.target_tiles_offset = target_tiles_offset
	return new_obj

## This function will evaluate all endpoint predicates and return true if they all pass
func validate_endpoint_predicates() -> bool:
	return definition.endpoint_predicates.all(func(pred: ActionPredicate) -> bool: return pred.test_endpoint(end_point, unit))
	
## This function will evaluate all non-endpoint predicates and return true if they all pass
func validate_predicates() -> bool:
	return definition.predicates.all(func(pred: ActionPredicate) -> bool: return pred.test(unit))
	
	
