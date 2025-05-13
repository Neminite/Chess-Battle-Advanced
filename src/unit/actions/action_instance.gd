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

var full_path: Array:
	get:
		return path + [end_point]

var unit: Unit

var predicate_instances: Array[ActionPredicateInstance]
var endpoint_predicates: Array[ActionPredicate]

func _init(def: ActionDefinition, src_unit: Unit, pred_instances: Array[ActionPredicateInstance], end_pred: Array[ActionPredicate]) -> void:
	definition = def
	unit = src_unit
	predicate_instances = pred_instances
	endpoint_predicates = end_pred

func duplicate() -> ActionInstance:
	var new_obj = ActionInstance.new(definition, unit, predicate_instances, endpoint_predicates)
	# Note this is a shallow copy, change this if the 
	# vectors need to be modified later
	new_obj.path = path.duplicate()
	new_obj.end_point = end_point
	return new_obj
