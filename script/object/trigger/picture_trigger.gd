extends TriggerClass
class_name PictureTrigger

const image_scene: PackedScene = preload("res://scene/ui/display_image.tscn")

@export_category("Picture Properties")
@export var image_0: CompressedTexture2D
@export var image_1: CompressedTexture2D


func _on_trigger() -> void:
	var image: Control = image_scene.instantiate()
	
	image.layer0 = image_0
	image.layer1 = image_1
	add_child(image)
