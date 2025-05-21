extends Node

var hexmap: Dictionary[Vector2i, Dictionary] = {}
var unit_lookup: Callable
var tilemap: TileMapLayer

enum HexProperties {
	TERRAIN, # Enum (int)
	SUBSCRIBED_UNITS, # Dict[Unit, true]
	UNITS_ON_TILE # Array[Unit]
}

func init_level(tilemap_ref: TileMapLayer, unit_lookup_callable: Callable) -> void:
	# Returns Array[Unit]
	unit_lookup = unit_lookup_callable
	tilemap = tilemap_ref
	
	# Note, cell is a Vector2i
	for cell_pos in tilemap.get_used_cells():
		var hex := {}
		hex[HexProperties.TERRAIN] = tilemap.get_cell_tile_data(cell_pos).get_custom_data('tile_type')
		var subscribed_units: Dictionary[Unit, bool] = {}
		hex[HexProperties.SUBSCRIBED_UNITS] = subscribed_units
		var units_on_tile: Array[Unit] = []
		hex[HexProperties.UNITS_ON_TILE] = units_on_tile
		var hex_pos := oddq_to_axial(cell_pos)
		hexmap[hex_pos] = hex
	
		
# TODO: Add functions to process updating tiles (tile or moved unit) and notifying units of the update
func update_tiles(axial_pos_ary: Array[Vector2i]) -> void:
	var units_to_update: Dictionary[Unit, bool] = {}
	for pos in axial_pos_ary:
		var hex := hexmap[pos]
		if hex:
			var units: Dictionary[Unit, bool] = hex[HexProperties.SUBSCRIBED_UNITS]
			for unit: Unit in units.keys():
				units_to_update[unit] = true
	for unit: Unit in units_to_update.keys():
		unit.update_move_paths()
		# Call update unit to recalculate paths	

func snap_to_tile(pos: Vector2) -> Vector2:	
	return tilemap.to_global(tilemap.map_to_local(
		tilemap.local_to_map(tilemap.to_local(pos))))

func world_to_hex(pos: Vector2) -> Vector2i:
	return oddq_to_axial(tilemap.local_to_map(tilemap.to_local(pos)))

func hex_to_world(pos: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(oddq_from_axial(pos)))

# Even columns shoved down
func oddq_from_axial(pos: Vector2i) -> Vector2i:
	# pos.x = q, pos.y = r, s = -q -r
	var col := pos.x
	@warning_ignore("integer_division")
	var row := pos.y + ((pos.x - (pos.x & 1)) / 2)
	return Vector2(col, row)

func oddq_to_axial(pos: Vector2i) -> Vector2i:
	# pos.x = col, pos.y = row
	var q := pos.x
	@warning_ignore("integer_division")
	var r := pos.y - ((pos.x - (pos.x & 1)) / 2)
	# var s = -q - r;
	return Vector2(q, r)
	
func rotate_hex_around_origin(pos: Vector2i, hex_rotation: int) -> Vector2i:
	# Rotation 0-5, 3 = 180deg. Rotations are clockwise
	match hex_rotation:
		0: # Note pos.x + pos.y = -s = -(-q-r)
			return pos
		1:
			return Vector2i(-pos.y, pos.x + pos.y)
		2:
			return Vector2i(-pos.x -pos.y, pos.x)
		3:
			return Vector2i(-pos.x, -pos.y)
		4:
			return Vector2i(pos.y, -pos.x - pos.y)
		5:
			return Vector2i(pos.x + pos.y, -pos.x)
		_:
			assert(false, "hex_rotation must be in the range of 0-5")
			return Vector2i(0, 0)
			
## Rotate hex by the local rotation, then offset it by the local pos
func localize_hex(global_hex: Vector2i, local_pos: Vector2i, local_rot: int) -> Vector2i:
	return rotate_hex_around_origin(global_hex, local_rot) + local_pos

enum BlockReason {
	NONE,
	TERRAIN,
	ALLY_UNIT,
	ENEMY_UNIT,
	MAP_EDGE
}

## Resonse format: {block_point: Vector2i, block_reason: BlockReason}
func get_ai_block_point_and_reason(ai: ActionInstance, subscribed_tiles := {}) -> Dictionary:
	var ai_def := ai.definition
	var ally_unit_blocking_cells: Array[Vector2i] = []
	var enemy_unit_blocking_cells: Array[Vector2i] = []
	# Get what categories can block the ai to avoid extra work
	var can_terrain_block := ai_def.tile_block_mode != ActionDefinition.BlockMode.IGNORE
	var can_ally_units_block := ai_def.ally_unit_block_mode != ActionDefinition.BlockMode.IGNORE
	var can_enemy_units_block := ai_def.enemy_unit_block_mode != ActionDefinition.BlockMode.IGNORE
	
	# Get blocking cells with units
	if can_ally_units_block or can_enemy_units_block:
		var units: Array[Unit] = unit_lookup.call()
		units = units.filter(
			func (unit: Unit) -> bool:
				return \
					unit != ai.unit and \
					unit.def.category in ai_def.blocking_unit_category
		)
		if can_ally_units_block:
			var ally_units: Array[Unit] = units.filter(
				func (unit: Unit) -> bool: return unit.is_unit_ally(ai.unit);
			)
			ally_unit_blocking_cells.append_array(ally_units.map(
				func (unit: Unit) -> Vector2i: return unit.cell
			))
		if can_enemy_units_block:
			var enemy_units: Array[Unit] = units.filter(
				func (unit: Unit) -> bool: return not unit.is_unit_ally(ai.unit);
			)
			enemy_unit_blocking_cells.append_array(enemy_units.map(
				func (unit: Unit) -> Vector2i: return unit.cell
			))
	
	# Calculate blocking cell
	for i in range(ai.full_path.size()):
		var cell: Vector2i = ai.full_path[i]
		# Dictionary or nil
		var cell_properties: Dictionary = hexmap.get(cell, {})
		if cell_properties.is_empty():
			# Cell not in cell map
			return {block_point = cell, block_reason = BlockReason.MAP_EDGE}
		# If cell is a part of the map, subscribe the unit to updates on the cell
		_subscribe_unit_to_cell(ai.unit, cell, cell_properties, subscribed_tiles)
		if can_terrain_block:
			var cell_type: Constants.TileType = cell_properties[HexProperties.TERRAIN]
			if cell_type in ai_def.blocking_tile_types:
				return {block_point = cell, block_reason = BlockReason.TERRAIN}
		if can_ally_units_block and cell in ally_unit_blocking_cells:
			return {block_point = cell, block_reason = BlockReason.ALLY_UNIT}
		if can_enemy_units_block and cell in enemy_unit_blocking_cells:
			return {block_point = cell, block_reason = BlockReason.ENEMY_UNIT}
	
	return {block_point = Vector2i.MAX, block_reason = BlockReason.NONE}

func is_ai_endpoint_tile_valid(ai: ActionInstance, subscribed_tiles := {}) -> bool:
	var cell := ai.end_point
	var cell_properties: Dictionary = hexmap.get(cell)
	# Update cell subscriptions, dictionary is pass by reference
	_subscribe_unit_to_cell(ai.unit, cell, cell_properties, subscribed_tiles)
	
	if not cell_properties:
		# Cell not in cell map
		return false
	var cell_type: Constants.TileType = cell_properties[HexProperties.TERRAIN]
	if cell_type in ai.definition.invalid_end_tile_types:
		return false
	return true
	
func get_units_on_cell(cell: Vector2i) -> Array[Unit]:
	var cell_properties: Dictionary = hexmap.get(cell)
	if not cell_properties:
		# Cell not in cell map
		return []
	return cell_properties[HexProperties.UNITS_ON_TILE]
	
func get_enemy_on_cell(unit: Unit, cell: Vector2i) -> Unit:
	var units_on_tile: Array[Unit] = get_units_on_cell(cell)
	var enemy_index := units_on_tile.find_custom(
		func(unit_on_tile: Unit) -> bool: return not unit_on_tile.is_unit_ally(unit)
		)
	if enemy_index >= 0:
		return units_on_tile[enemy_index]
	return null

func subscribe_unit_to_cell(unit: Unit, cell: Vector2i) -> void:
	var cell_properties: Dictionary = hexmap.get(cell)
	_subscribe_unit_to_cell(unit, cell, cell_properties, unit.action_componet.subscribed_tiles)
	return

func unsubscibe_from_cells(unit: Unit, cells: Dictionary[Vector2i, bool]) -> void:
	for cell: Vector2i in cells.keys():
		var cell_properties: Dictionary = hexmap.get(cell)
		cell_properties[HexProperties.SUBSCRIBED_UNITS].erase(unit)
		
func add_unit_to_cell(unit: Unit, cell: Vector2i) -> void:
	hexmap[cell][HexProperties.UNITS_ON_TILE].append(unit)
	
func remove_unit_from_cell(unit: Unit, cell: Vector2i) -> void:
	hexmap[cell][HexProperties.UNITS_ON_TILE].erase(unit)

func _subscribe_unit_to_cell(unit: Unit, cell: Vector2i, cell_properties: Dictionary, subscribed_tiles: Dictionary[Vector2i, bool]) -> void:
	cell_properties[HexProperties.SUBSCRIBED_UNITS][unit] = true
	subscribed_tiles[cell] = true
	return
