extends Node

# Tile types
# Note, these match the tile_type custom data layer.
enum TileType {
	NORMAL,
	MOUNTAIN,
	PIT
}

enum UnitCategory {
	NORMAL,
	FLYING
}

enum TurnType {
	TURN_BASED,
	COOLDOWN_BASED_INSTANT,
	COOLDOWN_BASED_TRAVEL_TIME
}

enum EffectId {
	BASE_EFFECT,
	UNGUARDED_STATUS,
	REDUCE_ENERGY,
	CAPTURE,
	SET_COOLDOWN
}

## Number of time steps in a normal move on time based modes
const GLOBAL_TURN_DURATION_TICKS = 20
