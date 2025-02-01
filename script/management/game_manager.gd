extends Control

signal update_sheet

const DEBUG_FILE: String = "user://debug_settings.tres"

var fullscreen: bool = false
var debug_settings: DebugSettingsResource = load("res://resource/management/debug_settings.tres")

@onready var file_dialog: FileDialog = $FileDialog


func _ready() -> void:
	if ResourceLoader.exists(DEBUG_FILE):
		debug_settings = load(DEBUG_FILE)
	else:
		save_debug_settings()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("screenshot"):
		var viewport_feed: Viewport =  get_tree().root.get_viewport()
		var screen_texture: Texture2D = viewport_feed.get_texture()
		var screen_image: Image = screen_texture.get_image()
		screen_image.save_png(
								"user://screenshots/screenshot" +
								str((DirAccess.open("user://screenshots").get_files()).size()) + 
								".png"
							)
	
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	
	if Input.is_action_just_pressed("screenshot_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://screenshots"),true)

	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode(
										DisplayServer.WINDOW_MODE_FULLSCREEN 
										if fullscreen 
										else 
											DisplayServer.WINDOW_MODE_WINDOWED
										)
	
	if Input.is_action_just_pressed("sheet_hotkey"):
		file_dialog.visible = !file_dialog.visible
	
	if Input.is_action_just_pressed("console"):
		Console.visible = !Console.visible
		
	if Input.is_action_just_pressed("reset_sheet"):
		Global.custom_sheet = null
		GameManager.debug_settings.custom_sheet = ""
		update_sheet.emit()


func reset_game() -> void:
	GameManager.save_debug_settings()
	Global.current_controller = 0
	Global.can_pause = true
	Global.can_unpause = false
	Global.is_game_paused = false
	
	Global.warp_to(
						"res://scene/title/title.tscn", 
						load("res://resource/loading_preset/ec_noload.tres")
					)
	
	await get_tree().create_timer(HUD.FADE_SPEED, true).timeout
	
	HUD.show_label(false, "", 0)
	EventBus.destroy_hud.emit()


func hard_reset_game() -> void:
	GameManager.save_debug_settings()
	Global.current_controller = 0
	Global.can_pause = true
	Global.can_unpause = false
	Global.is_game_paused = false
	
	HUD.show_label(false, "", 0)
	EventBus.destroy_hud.emit()
	Global.save_global()
	get_tree().change_scene_to_file("res://scene/title/garalina.tscn")


func save_debug_settings() -> void:
	ResourceSaver.save(debug_settings, DEBUG_FILE)


#SYSTEM NOTIF CLASS IS UNKNOWN
func _notification(system_notif) -> void:
	if system_notif == NOTIFICATION_WM_CLOSE_REQUEST:
		save_debug_settings()
		get_tree().quit() # default behavior
