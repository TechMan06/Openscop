extends TriggerClass
class_name DialogueTrigger

@export_category("Dialogue Properties")
@export var textbox_preset: TextboxResource
@export_multiline var textbox_text: String
@export var placeholder_strings_dict: String
@export var placeholder_strings_array: Array[String]


func _on_trigger() -> void:
	if textbox_preset != null:
		HUD.create_textbox(textbox_preset, textbox_text)
	else:
		printerr("No TextboxResource found on \"Textbox Preset\"! Create a new one or load one from \"res://resource/textbox\"")

