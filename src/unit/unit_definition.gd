class_name UnitDefinition
extends Resource

enum Type {
	Pawn,
	Knight,
	Bishop,
	Rook,
	Queen,
	King
}

@export var category: Constants.UnitCategory
@export var type: Type
@export var name: String
@export var frames: SpriteFrames # Unused
@export var sprite: Texture2D
@export var type_components: Array[PackedScene] = []
@export var move_definitions: Array[ActionDefinition]
@export var base_range: int = 1
@export var starting_energy: int = 1
