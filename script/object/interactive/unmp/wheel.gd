extends Marker3D

var room: Level
var pet: PetResource
var can_interact: bool = true
var inside_wheel: bool = false
var rotation_tween: Tween

@export_category("Phone Properties")
@export var wheel_id: int
@export var turned: bool = false

@onready var wheel_rot: Marker3D = $WheelRot
@onready var interaction_symbol: Marker3D = $InteractionSymbol
@onready var pet_obj: Marker3D = $WheelRot/PetObj


func _ready() -> void:
	EventBus.place_pet.connect(pet_selected)
	EventBus.game_paused.connect(pause_anim)
	EventBus.game_unpaused.connect(unpause_anim)
	
	if get_tree().get_current_scene() is Level:
		room = get_tree().get_current_scene()
	
	if turned:
		SaveManager.get_data().wheel[str(wheel_id)][0] = [true, pet]
	
	if SaveManager.get_data().wheel.has(str(wheel_id)):
		if SaveManager.get_data().wheel[str(wheel_id)][0]:
			wheel_rot.rotation.y = deg_to_rad(180.)
	else:
		SaveManager.get_data().wheel[str(wheel_id)] = [false, pet]
	
	pet = SaveManager.get_data().wheel[str(wheel_id)][1]
	
	if pet != null:
		pet_obj.visible = true
		place_pet()

	
	interaction_symbol.in_area.connect(_in_wheel)
	interaction_symbol.triggered.connect(rotate_wheel)


func pause_anim() -> void:
	if rotation_tween != null:
		rotation_tween.pause()


func unpause_anim() -> void:
	if rotation_tween != null:
		if !rotation_tween.finished:
			rotation_tween.play()


func rotate_wheel() -> void:
	if room != null:
		if can_interact and !Global.reading_text:
			room.inside_wheel = false
			can_interact = false
			
			$TurnSound.play()
			
			if SaveManager.get_data().wheel.has(str(wheel_id)):
				SaveManager.get_data().wheel[str(wheel_id)][0] = [false, null]
			else:
				SaveManager.get_data().wheel[str(wheel_id)] = [true, null]
			
			rotation_tween = create_tween()
			rotation_tween.tween_property(
											wheel_rot, 
											"rotation:y", 
											deg_to_rad(-180.), 
											3.
										).as_relative()
			
			await rotation_tween.finished
			
			if pet != null:
				SaveManager.get_data().library_pet.append(pet.pet_id_name)
				pet_obj.get_child(0).queue_free()
				pet_obj.visible = false
				pet = null
			
			can_interact = true
			room.inside_wheel = true


func pet_selected(id: int, pet_resource: PetResource) -> void:
	await EventBus.game_unpaused
	pet_obj.visible = false
	
	if wheel_id == id:
		if pet != null:
			SaveManager.get_data().pet.append(pet.pet_id_name)
		
		if pet_obj.get_child_count() > 0:
			pet_obj.get_child(0).queue_free()

		pet = pet_resource
		
		SaveManager.get_data().pet.erase(pet.pet_id_name)
		SaveManager.get_data().wheel[str(wheel_id)][1] = pet
		
		place_pet()
	
	if pet.pet_string_name == "[color=#e4dc49]Care NLM[/color]":
		HUD.create_textbox(load("res://resource/textbox/dark.tres"), "library_wheel", ["[color=#e4dc49]Care\nNLM[/color]", pet.pet_string_name])
	else:
		HUD.create_textbox(load("res://resource/textbox/dark.tres"), "library_wheel", [pet.pet_string_name, pet.pet_string_name])
	
	await EventBus.text_finished
	
	$PlaceSound.play()
	pet_obj.visible = true


func place_pet() -> void:
	if pet != null:
		if pet.pet_scene != null:
			var pet_instance: Marker3D = pet.pet_scene.instantiate()
			
			if pet_instance is Pet:
				pet_instance.despawn = false
				pet_instance.disable_collection = true
			else:
				pet_instance.get_child(0).despawn = false
				pet_instance.get_child(0).disable_collection = true
			
			
			
			pet_obj.add_child(pet_instance)


func _in_wheel(value: bool) -> void:
	if value:
		if can_interact:
			room.inside_wheel = true
	else:
		room.inside_wheel = false
	
	inside_wheel = value
	room.wheel_id = wheel_id
