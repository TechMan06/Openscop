extends CanvasLayer

const ANIM_SPEED: float = 0.125
const APPEAR_ANIM_SPEED: float = 0.5

@export var background: int = 0
@export var ask: bool = true
@export var has_fade: bool = true
@export var file_select: bool = false
@export var attach_to: Node

var cursor_pos: Vector2i = Vector2i(0, 0)
		
var offsets: Vector2i = Vector2i(1,2)
var loaded: bool = false
var disabled: bool = true
var characters: Array[Array] = [
		[["A"],["B"],["C"],["D"],["E"],["F"],["G"],["H"],["I"],["J"],["K"],["L"],["M"]],
		[["N"],["O"],["P"],["Q"],["R"],["S"],["T"],["U"],["V"],["W"],["X"],["Y"],["Z"]],
		[["a"],["b"],["c"],["d"],["e"],["f"],["g"],["h"],["i"],["j"],["k"],["l"],["m"]],
		[["n"],["o"],["p"],["q"],["r"],["s"],["t"],["u"],["v"],["w"],["x"],["y"],["z"]],
		[["0"],["1"],["2"],["3"],["4"],["5"],["6"],["7"],["8"],["9"],[" "],["."],["!"]],
		[["?"],[","],[";"],[":"],['"'],["'"],["("],[")"],["/"],["-"],["+"],[""],[" "]],
	]
var _offset_letters_1: Array[int] = [1, 2, 5, 7, 10]
var _theme_color: Color = (Color.BLACK if background == 3 else Color.WHITE)
var _inverted_theme_color: Color = (Color.WHITE if background == 3 else Color.BLACK)

@onready var cursor: ColorRect = %Cursor
@onready var input_field: Label = %InputField
@onready var keyboard: Sprite2D = $Keyboard
@onready var fade: ColorRect = $Fade
@onready var select_sound: AudioStreamPlayer = $SelectSound
@onready var whoosh_sound: AudioStreamPlayer = $WhooshSound
@onready var keyboard_letters: Marker2D = %KeyboardLetters
@onready var keyboard_arrow: TextureRect = %KeyboardArrow



func _ready() -> void:
	EventBus.destroy_hud.connect(queue_free)
	EventBus.change_keyboard_bg.connect(_change_background)
	EventBus.crash_game.connect(crash_keyboard)
	
	var _keyboard_row: int = 0
	
	for row in characters:
		for letter in row:
			
			var _letter_glyph: Label = Label.new()
			_letter_glyph.add_theme_font_override("font", load("res://asset/2d/font/ttf/PetscopWide.ttf"))
			
			if background != 3:
				if _keyboard_row == 0 && row.find(letter) == 0:
					_letter_glyph.add_theme_color_override("font_color", _inverted_theme_color)
				else:
					_letter_glyph.add_theme_color_override("font_color", _theme_color)
				
			else:
				if _keyboard_row == 0 && row.find(letter) == 0:
					_letter_glyph.add_theme_color_override("font_color", _theme_color)
				else:
					_letter_glyph.add_theme_color_override("font_color", _inverted_theme_color)
				
			if _keyboard_row < 2:
				_letter_glyph.position = Vector2(16 * row.find(letter), 20 * _keyboard_row)
			else:
				if _keyboard_row == 2:
					if _offset_letters_1.find(row.find(letter)) != -1:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 2, 
															(20 * _keyboard_row) - 2
														)
					elif row.find(letter) == 11:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 3, 
															(20 * _keyboard_row) - 2
														)
					elif row.find(letter) == 8 || row.find(letter) == 9:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 4, 
															(20 * _keyboard_row) - 2
														)
					else:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 1, 
															(20 * _keyboard_row) - 2
														)
				elif _keyboard_row == 3:
					if row.find(letter) < 7:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 2, 
															(20 * _keyboard_row) - 2
														)
					else:
						_letter_glyph.position = Vector2(
															(16 * row.find(letter)) + 1, 
															(20 * _keyboard_row) - 2
														)
				elif _keyboard_row == 4:
					if row.find(letter) == 11:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 3, 
															20 * _keyboard_row
														)
					elif row.find(letter) == 12:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 2, 
															20 * _keyboard_row
														)
					else:
						_letter_glyph.position = Vector2(
															16 * row.find(letter), 
															20 * _keyboard_row
														)
				elif _keyboard_row == 5:
					if row.find(letter) == 0 || row.find(letter) == 6 || row.find(letter) == 7:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 2, 
															20 * _keyboard_row
														)
					elif  row.find(letter) == 4:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 1, 
															20 * _keyboard_row + 1
														)
					elif  row.find(letter) == 5:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 3, 
															20 * _keyboard_row + 1
														)
					elif row.find(letter) == 1 || row.find(letter) == 2 || row.find(letter) == 3:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 3, 
															20 * _keyboard_row
														)
					else:
						_letter_glyph.position = Vector2(
															16 * row.find(letter) + 1, 
															20 * _keyboard_row
														)
			
			_letter_glyph.text = letter[0]
			
			keyboard_letters.add_child(_letter_glyph)
		
		_keyboard_row += 1
		
	Global.can_pause = false 
	keyboard.frame_coords.x = background
	
	cursor.color = (_theme_color if background != 3 else _inverted_theme_color)
	keyboard_arrow.modulate = (_theme_color if background != 3 else _inverted_theme_color)
	
	if background != 3:
		input_field.get_label_settings().set_font_color(_theme_color)
	else:
		input_field.get_label_settings().set_font_color(_inverted_theme_color)
	
	if file_select:
		ask = false
		keyboard.position.y = -278
		input_field.text = "Name file: "

	
	if has_fade:
		var fade_in = create_tween()
		
		fade_in.tween_property(fade, "color:a", 1.0, APPEAR_ANIM_SPEED)
		
		await fade_in.finished
	
	disabled = false
	
	if !file_select:
		get_tree().paused = true
		
		create_tween().tween_property(
											keyboard, 
											"position:y", 
											38.0, 
											APPEAR_ANIM_SPEED
										).set_trans(Tween.TRANS_SINE)
	else:
		await get_tree().create_timer(0.75, true).timeout
		whoosh_sound.play() 
		create_tween().tween_property(
											keyboard, 
											"position:y", 
											23.0, 
											APPEAR_ANIM_SPEED
										).set_trans(Tween.TRANS_SINE)
	
	if ask:
		input_field.text="Ask: ?"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var new_cursor_pos = cursor_pos
	
	if !disabled:
		if file_select:
			if (
					Input.is_action_just_pressed("pressed_up")
					or Input.is_action_just_pressed("pressed_down")
					or Input.is_action_just_pressed("pressed_left")
					or Input.is_action_just_pressed("pressed_right")
				):
				select_sound.play()
		
		if Input.is_action_just_pressed("pressed_up"):
			new_cursor_pos.y -= 1
		
		if Input.is_action_just_pressed("pressed_down"):
			new_cursor_pos.y += 1

		if Input.is_action_just_pressed("pressed_left"):
			new_cursor_pos.x -= 1

		if Input.is_action_just_pressed("pressed_right"):
			new_cursor_pos.x += 1

		if Input.is_action_just_pressed("pressed_action") && new_cursor_pos.x < 13 && new_cursor_pos.y < 6:
			if new_cursor_pos != Vector2i(11, 5):
				if input_field.text.length() <= 27:
					if ask:
						input_field.text = input_field.text.left(-1)
						input_field.text += characters[new_cursor_pos.y][new_cursor_pos.x][0]
						input_field.text += "?"
					else:
						if !file_select:
							input_field.text += characters[new_cursor_pos.y][new_cursor_pos.x][0]
						else:
							if input_field.text.length() < 18:
								input_field.text += characters[new_cursor_pos.y][new_cursor_pos.x][0]
			else:
				if ask:
					if input_field.text.length() > 6:
						input_field.text = input_field.text.left(-2)
						input_field.text += "?"
				else:
					if file_select:
						if input_field.text.length() > 5:
							input_field.text = input_field.text.left(-1)
					else:
						if input_field.text.length() > 0:
							input_field.text = input_field.text.left(-1)

		if Input.is_action_just_pressed("pressed_start"):
			if !ask:
				if file_select && input_field.text.length() > 11:
					if input_field.text.right(-11).rstrip(" ") != " ":
						EventBus.finished_typing.emit(input_field.text.right(-11), attach_to)
				elif !file_select && input_field.text.length() > 0:
					EventBus.finished_typing.emit(input_field.text, attach_to)
			elif input_field.text.length() > 6 :
				if input_field.text.right(-5).rstrip(" ") != " ":
					EventBus.finished_typing.emit(input_field.text.right(-5).left(-1), attach_to)
			
			create_tween().tween_property(fade, "color:a", 0.0, APPEAR_ANIM_SPEED)
			
			get_tree().paused = false
			
			if !file_select:
				var disappear = create_tween()
				
				disappear.tween_property(
											keyboard, 
											"position:y", 
											278.0, 
											APPEAR_ANIM_SPEED
										).set_trans(Tween.TRANS_SINE)
				
				await disappear.finished
			else:
				whoosh_sound.play()
				
				var disappear = create_tween()
				
				disappear.tween_property(
											keyboard, 
											"position:y", 
											-278.0, 
											APPEAR_ANIM_SPEED
										).set_trans(Tween.TRANS_SINE)
				
				await disappear.finished
			
			Global.can_pause = true
			queue_free()
	
	if Input.is_action_just_pressed("pressed_triangle") && file_select:
		whoosh_sound.play()
		
		var _disappear: Tween = create_tween()
		
		_disappear.tween_property(
									keyboard, 
									"position:y", 
									-278.0, 
									APPEAR_ANIM_SPEED
								).set_trans(Tween.TRANS_SINE)
		
		await _disappear.finished
		
		EventBus.finished_typing.emit("", attach_to)
		
		queue_free()
	
	
	if new_cursor_pos.x > 12:
		if new_cursor_pos.y != 5:
			new_cursor_pos.x = 0
			new_cursor_pos.y += 1
		else:
			new_cursor_pos.y = 0
			new_cursor_pos.x = 0
		cursor.position = Vector2i(0, 8 + (new_cursor_pos.y * 19) + new_cursor_pos.y)
		
	if new_cursor_pos.x < 0:
		if new_cursor_pos.y != 0:
			new_cursor_pos.x = 12
			new_cursor_pos.y -= 1
		else:
			new_cursor_pos.y = 5
			new_cursor_pos.x = 12
		cursor.position = Vector2i(210, 8 + (new_cursor_pos.y * 19) + new_cursor_pos.y)
			
	if new_cursor_pos.y < 0:
		cursor.position = Vector2i(cursor.position.x, 117)
		new_cursor_pos.y = 5
	
	if new_cursor_pos.y > 5:
		cursor.position = Vector2i(cursor.position.x, 0)
		new_cursor_pos.y = 0
	
	if cursor_pos != new_cursor_pos:
		cursor_pos = new_cursor_pos
		
		#9 + (self.Position.X * 15) + (self.OFFSET.X * self.Position.X),
		#8 + (self.Position.Y * 19) + (self.OFFSET.Y * self.Position.Y)
				
		create_tween().tween_property(
										cursor, 
										"position", 
										Vector2(
													9 + (cursor_pos.x * 15) + cursor_pos.x,
													8 + (cursor_pos.y * 19) + cursor_pos.y
												), 
										ANIM_SPEED
									).set_trans(Tween.TRANS_SINE)
	
		for letter in keyboard_letters.get_children():
			if letter.get_index() == ((cursor_pos.y * 13) + cursor_pos.x):
				create_tween().tween_method(
											func (color:Color) -> void:
												letter.add_theme_color_override("font_color", color), 
											letter.get_theme_color("font_color"), 
											(Color.WHITE if background == 3 else Color.BLACK), 
											ANIM_SPEED
										)
			else:
				create_tween().tween_method(
											func (color:Color) -> void:
												letter.add_theme_color_override("font_color", color), 
											letter.get_theme_color("font_color"), 
											(Color.BLACK if background == 3 else Color.WHITE), 
											ANIM_SPEED
										)
		
		if cursor_pos.y == 5 && cursor_pos.x == 11:
			create_tween().tween_property(
											keyboard_arrow, 
											"modulate", 
											(Color.WHITE if background == 3 else Color.BLACK), 
											ANIM_SPEED
										)
		else:
			create_tween().tween_property(
											keyboard_arrow, 
											"modulate", 
											(Color.BLACK if background == 3 else Color.WHITE), 
											ANIM_SPEED
										)


func _change_background(color_id: int) -> void:
	keyboard.frame_coords.x = color_id

	for letter in keyboard_letters.get_children():
		if letter.get_index() == ((cursor_pos.y * 13) + cursor_pos.x):
			letter.add_theme_color_override("font_color", _inverted_theme_color)
		else:
			letter.add_theme_color_override("font_color", _theme_color)


func crash_keyboard() -> void:
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)
