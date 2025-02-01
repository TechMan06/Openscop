extends Control

signal transition_middle
signal transition_end

const PAUSE_SCENE: PackedScene = preload("res://scene/ui/pause_menu/pause_menu.tscn")
const TEXTBOX_SCENE: PackedScene = preload("res://scene/ui/textbox.tscn")
const KEYBOARD_SCENE: PackedScene = preload("res://scene/ui/keyboard.tscn")
const DEFAULT_TEXTBOX: TextboxResource = preload("res://resource/textbox/default.tres")
const FADE_SPEED: float = 0.5

@onready var fade: ColorRect = %Fade
@onready var loading_image: TextureRect = %LoadingImage
@onready var dialogue_boxes: Node = $DialogueBoxes
@onready var demo_card: AnimatedSprite2D = %DemoCard
@onready var counter: Label = %Counter
@onready var piece_counter: TextureRect = %PieceCounter


func _ready() -> void:
	EventBus.emit_transition.connect(_on_scene_transition)
	EventBus.destroy_hud.connect(_on_hud_destruction)
	loading_image.visible = false
	
	return


func create_textbox(preset: TextboxResource = DEFAULT_TEXTBOX, text: String = "No Text.", process_always: bool = false) -> void:
	var _textbox_instance: Panel = TEXTBOX_SCENE.instantiate()
	_textbox_instance.preset = preset
	
	if process_always:
		_textbox_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if Global.dialogue_dict.get(text) != null:
		_textbox_instance.text = Global.dialogue_dict.get(text)
	else:
		_textbox_instance.text = [text]
	
	if Global.is_game_paused:
		add_child(_textbox_instance)
		_textbox_instance.z_index = 1
	elif dialogue_boxes.get_child_count() == 0:
		dialogue_boxes.add_child(_textbox_instance)
	
	return


func show_label(show_label: bool, recording: String, gen: int) -> void:
	$RecordingLabel.visible = show_label
	
	if show:
		$RecordingLabel.text = "Name: " + recording + "\nGen: " + str(gen)
	
	return


func show_counter() -> void:
	piece_counter.show_counter()
	
	return


func update_counter() -> void:
	piece_counter.update_counter()
	
	return


func fade_animation(fade_color: Color) -> void:
	var _fade_tween: Tween = create_tween()
	
	fade.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	_fade_tween.tween_property(fade, "color:a", 1.0, FADE_SPEED)
	
	await _fade_tween.finished
	
	transition_middle.emit()
	
	create_tween().tween_property(fade, "color:a", 0.0, FADE_SPEED)


func _on_scene_transition(preset: LoadingPreset) -> void:
	Global.can_pause = true
	fade.color = Color(preset.fade_color.r, preset.fade_color.g, preset.fade_color.b, 0.0)
	
	var _fade_tween: Tween = create_tween()
	
	_fade_tween.tween_property(fade, "color:a", 1.0, FADE_SPEED)
	
	await _fade_tween.finished
	
	Global.can_pause = false
	get_tree().paused = true
	
	if preset.loading_image != null:
		piece_counter._on_destruction()
		loading_image.texture = preset.loading_image
		loading_image.visible = true
		BGMusic.stop()
		
		await get_tree().create_timer(
										preset.loading_timer 
										+ randf_range(
														0., 
														preset.loading_timer 
														/ 4
													), 
										true 
									).timeout
	
	EventBus.start_scene.emit()
	
	loading_image.visible = false
	get_tree().paused = false
	Global.can_pause = true
	
	var _fade_out_tween: Tween = create_tween()
	
	_fade_out_tween.tween_property(fade, "color:a", 0.0, FADE_SPEED)
	
	await _fade_out_tween.finished
	
	transition_end.emit()


func create_keyboard(background: int = 0, ask: bool = true, use_fade: bool = true, file_select: bool = false, attach_to: Node = null) -> void:
	var keyboard_instance: CanvasLayer = KEYBOARD_SCENE.instantiate()
	
	keyboard_instance.background = background
	keyboard_instance.ask = ask
	keyboard_instance.has_fade = use_fade
	keyboard_instance.file_select = file_select
	keyboard_instance.attach_to = attach_to
	
	add_child(keyboard_instance)
	
	Global.can_pause=false


func play_nifty() -> void:
	$Nifty.play()


func _on_hud_destruction() -> void:
	demo_card.play(&"default")
