extends Control

@export var texture: Image
@export var background_image: Image

@onready var pixel_origin: Marker2D = $PixelOrigin
@onready var room_texture = $TextureOrigin/RoomTexture
@onready var bg_texture = $TextureOrigin/BGTexture
@onready var draw_sound: AudioStreamPlayer = $DrawSound


func _ready() -> void:
	HUD.play_nifty()
	room_texture.texture = ImageTexture.create_from_image(texture)
	
	get_tree().paused = true
	
	BGMusic.decrease_volume()

	if background_image == null:
		background_image = Image.create(
											int(str(texture.get_width() / 257.0)[0])  + 256, 
											int(str(texture.get_height() / 257.0)[0]) + 256, 
											false, 
											4
										)
		background_image.fill(Color.html("#FF00FF"))
		bg_texture.texture = ImageTexture.create_from_image(background_image)
	else:
		bg_texture.texture = ImageTexture.create_from_image(background_image)


func _process(_delta) -> void:
	if Input.is_action_pressed("pressed_start"):
		get_tree().paused = false
		Global.can_pause = true
		Global.is_game_paused = false
		EventBus.nifty_finished.emit(texture, background_image)
		HUD.play_nifty()
		BGMusic.increase_volume()
		queue_free()
	
	var x: float = Input.get_action_strength("pressed_right") - Input.get_action_strength("pressed_left")
	var y: float = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")
	
	var magnitude = sqrt(x*x + y*y)
	
	if magnitude > 1:
		x /= magnitude
		y /= magnitude

	pixel_origin.position.x += x
	pixel_origin.position.y += y
	
	pixel_origin.position = Vector2(
										round(clamp(pixel_origin.position.x,32,288)),
										round(clamp(pixel_origin.position.y,0,240))
									)
	
	if Input.is_action_pressed("pressed_action"):
		if !draw_sound.playing:
			draw_sound.play()
		
		if (pixel_origin.position.x < room_texture.texture.get_width() + 32) && (pixel_origin.position.y < room_texture.texture.get_height()):
			texture.set_pixel(pixel_origin.position.x-32, pixel_origin.position.y, Color.html("#FFCEE5"))
			room_texture.set_texture(ImageTexture.create_from_image(texture))
		else:
			background_image.set_pixel(pixel_origin.position.x-32, pixel_origin.position.y, Color.html("#FFCEE5"))
			bg_texture.texture = ImageTexture.create_from_image(background_image)
	else:
		draw_sound.stop()
