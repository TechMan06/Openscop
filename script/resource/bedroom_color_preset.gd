extends Resource
class_name BedroomColorPreset

@export var color: Color = Color.WHITE ## Main color used on the bedroom.
@export var secondary_color: Color = Color.WHITE ## Secondary color used for the details on the walls and floor and part of the furniture.
@export var child: CompressedTexture2D ## [CompressedTexture2D] for the child sitting on the bed.
@export var primary_color_on_all_furniture: bool = true ## Whether all furniture will use the [member PredefinedBedroomPreset.color].
