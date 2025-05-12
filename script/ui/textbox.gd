extends Panel
#TEXTBOX OBJECT

#TYPEWRITER SPEEDS
const _DEFAULT_WAIT: float = 0.025
const _PUNCTUATION_WAIT: float = 0.150
const _TYPING_SOUND_FADE: float = 0.25
const _TYPING_SOUND_VOLUME: float = 5.0

var preset: TextboxResource
var text: Array = ["No Text"]
var placeholder_strings: Array = []
var clean_text: Array = []
#AMOUNT OF CHARS ON DISPLAY, PAGE OF TEXTBOX.
var _chars: int = 0
var _textbox: int = 0
#CHARACTERS THAT MAKE TYPEWRITER SLOWER
var _slowchars: String ="!.?,;"
var _disabled: bool = false

@onready var _textbox_label: RichTextLabel = %TextboxLabel
@onready var _typing_sound: AudioStreamPlayer = $TypingSound
@onready var _change_sound: AudioStreamPlayer = $ChangeSound
@onready var _closing_sound: AudioStreamPlayer = $ClosingSound
@onready var _arrow_timer: Timer = $ArrowTimer
@onready var _type_speed: Timer = $TypeSpeed
@onready var _arrow: TextureRect = %Arrow


func _ready() -> void:
	EventBus.destroy_hud.connect(queue_free)
	EventBus.text_started.emit()
	Global.reading_text = true
	
	theme = preset.background
	position = preset.position
	size = preset.size
	
	var textbox_iterator: int = 0
	
	if placeholder_strings != []:
		for textbox in text:
			text[textbox_iterator] = textbox.format(placeholder_strings)
			textbox_iterator += 1
	
	for textbox in text:
		clean_text.append(Global.strip_bbcode(textbox))
	
	_textbox_label.visible_characters = 0
	
	visible = false
	_arrow.modulate = preset.arrow_color
	_arrow.visible = false

	#WAITS UNTIL HALF THE TIME HAS BEEN COMPLETED TO SHOW THE TEXTBOX BACKGROUND.
	_type_speed.start()
	
	await get_tree().create_timer(0.25, process_mode == Node.PROCESS_MODE_ALWAYS).timeout
	
	visible = true
	
	if Global.global_data.gen > 2 && !preset.mute:
		_change_sound.play()
		create_tween().tween_property(
										_typing_sound, 
										"volume_db", 
										_TYPING_SOUND_VOLUME, 
										_TYPING_SOUND_FADE
									)
	
		await get_tree().process_frame
	
	_textbox_label.text = text[_textbox]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#IF DIDN'T FINISH TYPING EVERYTHING, KEEP TYPING, IF IT DID, STOP PLAYING TYPING SOUND
	if _textbox_label.text != "":
		if _textbox_label.visible_characters < clean_text[_textbox].length() && Global.global_data.gen > 2:
			_textbox_label.visible_characters = _chars
			
			if Input.is_action_just_pressed("pressed_action"):
				_finish_writing()
		
		else:
			_finish_writing()
			
			if Input.is_action_just_pressed("pressed_action") && !_disabled:
				if _textbox < text.size()-1:
					_textbox += 1
					
					if Global.global_data.gen > 2:
						_chars = 0
					
					_arrow_timer.stop()
					_arrow.visible = false
					
					if Global.global_data.gen > 2:
						_textbox_label.visible_characters = 0
					
					if _textbox < text.size() && Global.global_data.gen > 2 && !preset.mute:
						_change_sound.play()
					
					_type_speed.start()
					_textbox_label.text = text[_textbox]
				else:
					_disabled = true
					EventBus.text_finished.emit()
					
					if  Global.global_data.gen > 2 && !preset.mute:
						visible = false
						_closing_sound.play()
						await _closing_sound.finished
					
					Global.reading_text = false
					queue_free()

	if preset.destructible && Input.is_action_just_pressed("pressed_triangle"):
		EventBus.text_finished.emit()
		queue_free()


func _finish_writing() -> void:
	_type_speed.stop()
	_chars = _textbox_label.text.length()
	_textbox_label.visible_characters = _chars
	
	if _arrow_timer.is_stopped() && Global.global_data.gen > 2:
		_arrow_timer.start()
	
	_typing_sound.playing = false


func _on_arrow_timer_timeout() -> void:
	_arrow.visible = !_arrow.visible


func _on_type_speed_timeout() -> void:
	if _textbox <= text.size() - 1:
		if _chars < text[_textbox].length():
			_chars += 1
			_check_character()
			_type_speed.start()


func _check_character() -> void:
	_type_speed.stop()
	
	#CHECKS IF CHARACATER IS NORMAL OR SPECIAL CHARACTER, WHICH IS TYPED SLOWER ON PETSCOP
	if _slowchars.find(clean_text[_textbox][_textbox_label.visible_characters -1]) == -1:
		_type_speed.wait_time = _DEFAULT_WAIT
		
		if !_typing_sound.playing && Global.global_data.gen > 2 && !preset.mute:
			_typing_sound.play()
			create_tween().tween_property(
											_typing_sound, 
											"volume_db", 
											_TYPING_SOUND_VOLUME, 
											_TYPING_SOUND_FADE
										)
									
	else:
		_type_speed.wait_time = _PUNCTUATION_WAIT
		_typing_sound.playing = false
		_typing_sound.volume_db = -80.
