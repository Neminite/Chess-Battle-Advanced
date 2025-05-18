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

var unit_predicate_instances: Array[UnitOnCellPredicateInstance]
var unit_endpoint_predicates: Array[UnitOnCellPredicate]

func _init(def: ActionDefinition, src_unit: Unit, pred_instances: Array[UnitOnCellPredicateInstance], end_pred: Array[UnitOnCellPredicate]) -> void:
	definition = def
	unit = src_unit
	unit_predicate_instances = pred_instances
	unit_endpoint_predicates = end_pred

func duplicate() -> ActionInstance:
	var new_obj = ActionInstance.new(definition, unit, unit_predicate_instances, unit_endpoint_predicates)
	# Note this is a shallow copy, change this if the 
	# vectors need to be modified later
	new_obj.path = path.duplicate()
	new_obj.end_point = end_point
	return new_obj
