extends Resource
class_name PredefinedBedroomPreset

## Script for the [Resource] used for pre-defined Child Library bedrooms.
## The tile selected on this preset is the number of the tile according to a left to right and top to bottom order within 32x32 grid.
## The tiles can be found on the file [code]res://asset/3d/room/child_library/bedroom_tiles.png[/code].

@export var disable_gray_face: bool = false ## Displays the [OverworldFace] object color as black.
@export var higher_fog: bool = false ## Room fog size is slightly bigger.
@export var assigned_face: FaceResource ## [FaceResource] the bedroom is assigned to.
@export var table_object_left: int = 0 ## The sprite frame for the object that should be placed on the left side of the table in the bedroom.
@export var table_object_left_offset: Vector3 = Vector3.ZERO ## Offset for the position of the object placed on the left side of the table in the bedroom.
@export var table_object_right: int = 0 ## The sprite frame for the object that should be placed on the right side of the table in the bedroom.
@export var table_object_right_offset: Vector3 = Vector3.ZERO ## Offset for the position of the object placed on the right side of the table in the bedroom.
@export var child: int = 0 ## Child sprite frame.
@export var valid_pets: Array[PackedScene] ## Pets that can be placed in the bedroom if it was placed in the wheel at the entrance of the Child Library, none if empty.
@export var use_default_colors: bool = false ## Use the default bedroom colors, default value is [code]false[/code].
@export var color_id: int = 0 ## ID of the default bedroom color to use.
@export var color: Color = Color.WHITE ## Custom bedroom color used if [member PredefinedBedroomPreset.use_default_color] is [code]false[/code].
@export var note: String = "" ## Bedroom note, none if blank.
@export var floor_tile_1_id: int = 0 ## Tile used for the first floor tile.
@export_range(0.0, 270, 90.0) var floor_tile_1_rotation: float = 0.0 ## Rotation of the first floor tile, only multiples of 90º.
@export var floor_tile_2_id: int = 0 ## Tile used for the second floor tile.
@export_range(0.0, 270, 90.0) var floor_tile_2_rotation: float = 0.0 ## Rotation of the second floor tile, only multiples of 90º.
@export var floor_tile_3_id: int = 0 ## Tile used for the third floor tile.
@export_range(0.0, 270, 90.0) var floor_tile_3_rotation: float = 0.0 ## Rotation of the third floor tile, only multiples of 90º.
@export var floor_tile_4_id: int = 0 ## Tile used for the fourth floor tile.
@export_range(0.0, 270, 90.0) var floor_tile_4_rotation: float = 0.0 ## Rotation of the fourth floor tile, only multiples of 90º.
@export var wall_tile_1_id: int = 0 ## Tile used for the first wall tile.
@export_range(0.0, 270, 90.0) var wall_tile_1_rotation: float = 0.0 ## Rotation of the first wall tile, only multiples of 90º.
@export var wall_tile_2_id: int = 0 ## Tile used for the second wall tile.
@export_range(0.0, 270, 90.0) var wall_tile_2_rotation: float = 0.0 ## Rotation of the second wall tile, only multiples of 90º.
@export var wall_tile_3_id: int = 0 ## Tile used for the third wall tile.
@export_range(0.0, 270, 90.0) var wall_tile_3_rotation: float = 0.0 ## Rotation of the third wall tile, only multiples of 90º.
@export var wall_tile_4_id: int = 0 ## Tile used for the fourth wall tile.
@export_range(0.0, 270, 90.0) var wall_tile_4_rotation: float = 0.0 ## Rotation of the fourth wall tile, only multiples of 90º.
