extends Control

@onready var credits_text: RichTextLabel = %CreditsText
@onready var debug_toggle = %DebugToggle
@onready var autorec_toggle = %AutoRecToggle


func _ready() -> void:
	BGMusic.stop()
	credits_text.scroll_to_line(1)
	debug_toggle.button_pressed = GameManager.debug_settings.debug
	autorec_toggle.button_pressed = GameManager.debug_settings.auto_record


func _on_debug_toggle_toggled(button_pressed):
	match button_pressed:
		debug_toggle:
			GameManager.debug_settings.debug = debug_toggle.button_pressed
		
		autorec_toggle:
			GameManager.debug_settings.auto_record = autorec_toggle.button_pressed
