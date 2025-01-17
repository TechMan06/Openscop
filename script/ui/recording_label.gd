extends Label


func _process(_delta: float) -> void:
	if visible:
		var viewport_feed: Viewport =  get_tree().root.get_viewport().get_viewport()
		var screen_texture: Texture2D = viewport_feed.get_texture()
		var screen_image: Image = screen_texture.get_image()
		
		if screen_image.get_pixel(20,17).get_luminance() > 0.5:
			self.label_settings.set_font_color(Color(0.0,0.0,0.0,1.0))
		else:
			self.label_settings.set_font_color(Color(1.0,1.0,1.0,1.0))
