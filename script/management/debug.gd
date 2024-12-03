extends Control

@onready var credits_text = %CreditsText


func _ready() -> void:
	BGMusic.stop()
	credits_text.scroll_to_line(1)
