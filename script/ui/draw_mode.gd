extends Control

var draw_offset: Vector2i = Vector2i.ZERO
var x: float = 0.0
var y: float = 0.0
var pixel_array: Array[Vector2i]

@export var texture: Image
@export var draw_layer_image: Image

@onready var pixel_origin: Marker2D = $PixelOrigin
@onready var texture_origin = %TextureOrigin
@onready var room_texture: TextureRect = %RoomTexture
@onready var draw_canvas: SubViewport = %DrawSubViewport
@onready var draw_texture: TextureRect = %DrawLayer
@onready var draw_sound: AudioStreamPlayer = $DrawSound


func _ready() -> void:
	EventBus.nifty_set_pixels.connect(nifty_set_pixels)
	HUD.play_nifty()
	room_texture.texture = ImageTexture.create_from_image(texture)
	
	get_tree().paused = true
	
	BGMusic.decrease_volume()

	if draw_layer_image == null:
		# TO-DO: REPLACE ARGUMENT 4 WITH PROPER ENUM
		draw_layer_image = Image.create(
											int(str(texture.get_width() / 257.0)[0])  + 512, 
											int(str(texture.get_height() / 257.0)[0]) + 512, 
											false, 
											4
										)
		
		draw_layer_image.fill(Color.html("#FF00FF"))
		draw_layer_image.detect_alpha()
		draw_texture.texture = ImageTexture.create_from_image(draw_layer_image)
	else:
		draw_texture.texture = ImageTexture.create_from_image(draw_layer_image)
	
	draw_canvas.size = Vector2(texture.get_width(), texture.get_height())
	
	EventBus.crash_game.connect(crash_draw_mode)


func _process(_delta) -> void:
	if Input.is_action_pressed("pressed_start"):
		get_tree().paused = false
		Global.can_pause = true
		Global.is_game_paused = false
		EventBus.nifty_finished.emit(draw_canvas.get_texture().get_image(), draw_layer_image, pixel_array)
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
		x = 0.0
		y = 0.0
		draw_sound.stop()
		
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
			
			var pixel_position: Vector2i = Vector2i(
														pixel_origin.position.x - 32 - draw_offset.x,
														pixel_origin.position.y - draw_offset.y
													)
			
			draw_layer_image.set_pixel(
										pixel_position.x, 
										pixel_position.y, 
										Color.html("#FFCEE5FF")
									)
			
			if pixel_array.find(Vector2i(pixel_position.x, pixel_position.y)) == -1:
				pixel_array.push_back(pixel_position)
			
			draw_texture.texture = ImageTexture.create_from_image(draw_layer_image)
		else:
			draw_sound.stop()


func crash_draw_mode() -> void:
	draw_sound.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	self.set_process_mode(Node.PROCESS_MODE_DISABLED)


func nifty_set_pixels(pixel_array: Array[Vector2i]) -> void:
	for pixel in pixel_array:
		draw_layer_image.set_pixel(
									clamp(
											pixel.x,
											0,
											draw_layer_image.get_width()
										), 
									clamp(
											pixel.y,
											0,
											draw_layer_image.get_height()
										), 
									Color.html("#FFCEE5FF")
								)
	
	draw_texture.texture = ImageTexture.create_from_image(draw_layer_image)
