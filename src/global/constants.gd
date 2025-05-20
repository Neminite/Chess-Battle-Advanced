extends Node

# Tile types
# Note, these match the tile_type custom data layer.
enum TileTypes {
	NORMAL,
	MOUNTAIN,
	PIT
}

enum UnitCategory {
	NORMAL,
	FLYING
}

enum TurnTypes {
	TURN_BASED,
	COOLDOWN_BASED_INSTANT,
	COOLDOWN_BASED_TRAVEL_TIME
}

## Number of time steps in a normal move on time based modes
const GLOBAL_TURN_DURATION_TICKS = 20
