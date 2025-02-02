extends Control

@onready var credits_text: RichTextLabel = %CreditsText
@onready var debug_toggle = %DebugToggle
@onready var autorec_toggle = %AutoRecToggle
@onready var boot_screen_toggle = %BootScreenToggle



func _ready() -> void:
	BGMusic.stop()
	credits_text.scroll_to_line(1)
	debug_toggle.button_pressed = GameManager.debug_settings.debug
	autorec_toggle.button_pressed = GameManager.debug_settings.auto_record
	boot_screen_toggle.button_pressed = GameManager.debug_settings.boot_screen


func _on_debug_toggle_toggled(button_pressed):
	match button_pressed:
		debug_toggle:
			GameManager.debug_settings.debug = debug_toggle.button_pressed
		
		autorec_toggle:
			GameManager.debug_settings.auto_record = autorec_toggle.button_pressed
		boot_screen_toggle:
			GameManager.debug_settings.boot_screen = boot_screen_toggle.button_pressed
