extends Marker3D

const SHAKE_AMOUNT: float = 0.05
const SHAKE_SPEED: float = 0.1

var triggered: bool = false
var shake_tween: Tween

@export_category("Phone Properties")
@export var phone_id: int
@export_category("Dialogue Properties")
@export var textbox_preset: TextboxResource
@export_multiline var textbox_text: String
@export_category("General Properties")
@export var destroy_after_interaction: bool = false
@export_category("Symbol Properties")
@export var height_offset: float = 0.0
@export var min_distance: float = 1.5

@onready var phone_sprite = $PhoneSprite
@onready var phone_ring = $PhoneRing
@onready var ring_visibility = $PhoneRing/RingVisibility
@onready var idle_visibility = $PhoneRing/IdleVisibility
@onready var phone_sound = $PhoneSound
@onready var ring_animation = $RingAnimation
@onready var dialogue_trigger = $DialogueTrigger



func _ready() -> void:
	EventBus.text_started.connect(_animate_phone)
	EventBus.text_finished.connect(_reset_phone)
	dialogue_trigger.textbox_preset = textbox_preset
	dialogue_trigger.textbox_text = textbox_text
	dialogue_trigger.destroy_after_interaction = destroy_after_interaction
	dialogue_trigger.height_offset = height_offset
	dialogue_trigger.min_distance = min_distance
	
	var shake_tween: Tween = create_tween().set_loops()
		
	shake_tween.tween_property(
									ring_visibility, 
									"position:x", 
									SHAKE_AMOUNT, 
									SHAKE_SPEED
								).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(
									ring_visibility, 
									"position:x", 
									-SHAKE_AMOUNT, 
									SHAKE_SPEED
								).set_trans(Tween.TRANS_SINE)
	
	if SaveManager.get_data().anna_phone.find(phone_id) == -1:
		phone_sound.play()
		ring_animation.play(&"Ring")
	else:
		phone_ring.visible = false
		phone_sprite.visible = true


func _on_dialogue_triggered() -> void:
	phone_ring.visible = false
	phone_sprite.visible = true

	phone_sound.stop()
	triggered = true
	
	if phone_id > -1:
		SaveManager.get_data().anna_phone.append(phone_id)


func _animate_phone() -> void:
	await get_tree().process_frame
	
	if triggered:
		phone_sprite.play(&"listen")


func _reset_phone() -> void:
	if triggered:
		phone_sprite.play(&"idle")
		triggered = false
