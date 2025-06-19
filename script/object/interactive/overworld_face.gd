extends Marker3D

@export_category("Overworld Face Settings")
@export var load_from_file: bool = false
@export var id: int = 0
@export var use_custom_expression: bool = false
@export var update_on_signal: bool = true
@export var expression: Array[int]
@export var vertical_offsets: Array[int]
@export var horizontal_offsets: Array[int]
@export_category("Room Loading and Canvas Settings")
@export var wall: CollisionShape3D
@export var special_faces: Array[FaceResource]
@export var textbox_preset: TextboxResource
@export var do_earthquake: bool = false
@export var earthquake_sound: AudioStreamPlayer
@export var wait_time: float =  600.0

@onready var face: ChildFace = %Face
@onready var earthquake_timer: Timer = $EarthquakeTimer


func _ready() -> void:
	EventBus.create_face.connect(check_face)
	EventBus.open_bedroom.connect(open_bedroom)
	
	face.id = id
	earthquake_timer.wait_time = wait_time
	earthquake_timer.timeout.connect(open_bedroom)
	
	if use_custom_expression:
		face.visible = true
		face.expression = expression
		face.horizontal_offsets = horizontal_offsets
		face.vertical_offsets = vertical_offsets
		face.update()
	
	if load_from_file:
		face.visible = true
		use_custom_expression == true
		
		if SaveManager.get_data().library_face != null:
			face.expression = SaveManager.get_data().library_face.expression
			face.horizontal_offsets = SaveManager.get_data().library_face.horizontal_offsets
			face.vertical_offsets = SaveManager.get_data().library_face.vertical_offsets
		
		face.update()
	
	toggle_wall(true)


func check_face(
						new_id: int,
						new_expression: Array[int], 
						new_horizontal_offset: Array[int], 
						new_vertical_offset: Array[int]
					) -> void:
	for _face in special_faces:
		if (  
				_face != null and
				textbox_preset != null and
				id == new_id and
				_face.textbox != "" and
				_face.expression == new_expression and
				_face.horizontal_offsets == new_horizontal_offset and
				_face.vertical_offsets == new_vertical_offset
			):
			HUD.create_textbox(textbox_preset, _face.textbox)
	
	SaveManager.get_data().library_face = FaceResource.new()
	SaveManager.get_data().library_face.expression = new_expression
	SaveManager.get_data().library_face.horizontal_offsets = new_horizontal_offset
	SaveManager.get_data().library_face.vertical_offsets = new_vertical_offset
	
	if !do_earthquake:
		EventBus.camera_shake_transition_speed.emit(2.0)
		EventBus.camera_shake_amount.emit(0.05)
		EventBus.camera_shake_speed.emit(0.45)
		EventBus.camera_earthquake.emit(true)
		
		if earthquake_sound != null and !earthquake_sound.playing:
			earthquake_sound.play()
		
		earthquake_timer.start()
		toggle_wall(true)


func open_bedroom():
	if earthquake_sound != null:
		earthquake_sound.stop()
	
	toggle_wall(false)


func toggle_wall(value: bool) -> void:
	if wall != null:
		wall.disabled = !value
