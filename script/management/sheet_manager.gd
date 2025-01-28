extends FileDialog


func _on_sheet_selected(path: String) -> void:
	var image: Image = Image.new()
	var image_texture: ImageTexture = ImageTexture.new()
	
	image.load(path)
	image_texture.set_image(image)
	
	GameManager.debug_settings.custom_sheet = path
	Global.custom_sheet = image_texture
	GameManager.update_sheet.emit()
