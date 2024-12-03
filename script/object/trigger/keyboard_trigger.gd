extends TriggerClass
class_name KeyboardTrigger

@export_category("Keyboard Properties")
@export var background: int = 0
@export var ask: bool = true
@export var has_fade: bool = true
@export var attach_to: Node
@export var enabled: bool = true

func _on_trigger() -> void:
	if enabled:
		HUD.create_keyboard(background, ask, has_fade, false, attach_to)
