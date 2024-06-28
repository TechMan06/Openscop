extends Node2D
var loaded = false
var texture_data = null
var texture_image = null
var background_image = null


@onready var pencil = $pencil
@onready var nifty_sound = $nifty
@onready var level = get_tree().get_root().get_child(5).find_child("level_root")

func _ready():
	$pencil/sprite.offset.y=$pencil/sprite.texture.get_height()*-1

func _process(_delta):
	if visible:
		Global.allow_walking=false
		if !loaded:
			if level.find_child("visual_mesh"):
				texture_data = level.find_child("visual_mesh").get_child(0).get_surface_override_material(0).get_shader_parameter("albedoTex")
				texture_image = texture_data.get_image()
				$Texture.set_texture(ImageTexture.create_from_image(texture_image))
				background_image = $border/bg.texture.get_image()
				$nifty.play()
				loaded = true
		if Input.is_action_pressed("pressed_start"):
			pencil.position=Vector2i(32,240)
			$nifty.play()
			Global.can_pause=true
			Global.allow_walking=true
			for mesh_object in level.find_child("visual_mesh").get_children():
				if mesh_object.get_class() == "MeshInstance3D" && mesh_object.get_child_count()==0:
					mesh_object.get_surface_override_material(0).set_shader_parameter("albedoTex", ImageTexture.create_from_image(texture_image))
			$border/bg.texture = load("res://graphics/sprites/ui/nifty_background.png")
			visible = false
			loaded = false
			bg_music.resume()
		var x = Input.get_action_strength("pressed_right") - Input.get_action_strength("pressed_left")
		var y = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")
		var magnitude = sqrt(x*x + y*y)
		if magnitude > 1:
			x /= magnitude
			y /= magnitude

		pencil.position.x+= x
		pencil.position.y+= y
		
		pencil.position=Vector2(round(clamp(pencil.position.x,32,288)),round(clamp(pencil.position.y,0,240)))
		if Input.is_action_pressed("pressed_action"):
			if !$draw.playing:
				$draw.play()
			if (pencil.position.x<texture_image.get_width()+32) && (pencil.position.y<texture_image.get_height()):
				texture_image.set_pixel(pencil.position.x-32, pencil.position.y, Color.html("#FFCEE5"))
				$Texture.set_texture(ImageTexture.create_from_image(texture_image))
			else:
				background_image.set_pixel(pencil.position.x-32, pencil.position.y, Color.html("#FFCEE5"))
				$border/bg.texture = ImageTexture.create_from_image(background_image)
		else:
			$draw.stop()
