extends Control

var draw_offset: Vector2i = Vector2i.ZERO
var x: float = 0.0
var y: float = 0.0

@export var texture: Image
@export var background_image: Image

@onready var pixel_origin: Marker2D = $PixelOrigin
@onready var texture_origin = %TextureOrigin
@onready var room_texture: TextureRect = $TextureOrigin/RoomTexture
@onready var bg_texture: TextureRect = $TextureOrigin/BGTexture
@onready var draw_sound: AudioStreamPlayer = $DrawSound


func _ready() -> void:
	HUD.play_nifty()
	room_texture.texture = ImageTexture.create_from_image(texture)
	
	get_tree().paused = true
	
	BGMusic.decrease_volume()

	if background_image == null:
		# TO-DO: REPLACE ARGUMENT 4 WITH PROPER ENUM
		background_image = Image.create(
											int(str(texture.get_width() / 257.0)[0])  + 512, 
											int(str(texture.get_height() / 257.0)[0]) + 512, 
											false, 
											4
										)
		background_image.fill(Color.html("#FF00FF"))
		bg_texture.texture = ImageTexture.create_from_image(background_image)
	else:
		bg_texture.texture = ImageTexture.create_from_image(background_image)
	
	EventBus.crash_game.connect(crash_draw_mode)

func _process(_delta) -> void:
	if Input.is_action_pressed("pressed_start"):
		get_tree().paused = false
		Global.can_pause = true
		Global.is_game_paused = false
		EventBus.nifty_finished.emit(texture, background_image)
		HUD.play_nifty()
		BGMusic.increase_volume()
		Global.draw_mode = false
	
	if !Global.draw_mode:
		queue_free()
	
	pixel_origin.position.x += x
	pixel_origin.position.y += y
	
	pixel_origin.position = Vector2(
										round(clamp(pixel_origin.position.x, 32, 288)),
										round(clamp(pixel_origin.position.y, 0, 240))
									)
	
	texture_origin.position = Vector2(draw_offset.x + 32, draw_offset.y)
	
	if Input.is_action_pressed("pressed_triangle"):
		if (
				Input.is_action_just_pressed("pressed_right") and 
				abs(draw_offset.x - 32) < room_texture.texture.get_width()
			) :
			draw_offset.x -= 32
		
		if Input.is_action_just_pressed("pressed_left") and draw_offset.x < 0:
			draw_offset.x += 32
		
		if (
				Input.is_action_just_pressed("pressed_down") and 
				abs(draw_offset.y - 32) < room_texture.texture.get_height()
			):
			draw_offset.y -= 32
		
		if Input.is_action_just_pressed("pressed_up") and draw_offset.y < 0:
			draw_offset.y += 32
	else:
		x = Input.get_action_strength("pressed_right") - Input.get_action_strength("pressed_left")
		y = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")

		
		if Input.is_action_pressed("pressed_action"):
			if !draw_sound.playing:
				draw_sound.play()
			
			if (
					(pixel_origin.position.x < room_texture.texture.get_width() + 32 + draw_offset.x) 
					and (pixel_origin.position.y < room_texture.texture.get_height() + draw_offset.y)
				):
				texture.set_pixel(
										pixel_origin.position.x - 32 - draw_offset.x, 
										pixel_origin.position.y - draw_offset.y, 
										Color.html("#FFCEE5")
									)
				
				room_texture.set_texture(ImageTexture.create_from_image(texture))
			else:
				background_image.set_pixel(
												pixel_origin.position.x  - 32 - draw_offset.x, 
												pixel_origin.position.y - draw_offset.y, 
												Color.html("#FFCEE5")
											)
				
				bg_texture.texture = ImageTexture.create_from_image(background_image)
		else:
			draw_sound.stop()


func crash_draw_mode() -> void:
	draw_sound.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)
