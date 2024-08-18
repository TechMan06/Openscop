@tool
extends Node3D
@export_subgroup("Warp_properties")
@export var all_directions = false
@export var diagonal_entrance = false
@export var directions = Vector2i.ZERO
@export var warp_direction=0
@export_subgroup("Warp_to")
@export_file("*.tscn") var scene
@export var loading_preset = "nmp_noload"
@export var coordinate_and_direction = Vector4.ZERO

@onready var sprite = $visual
@onready var warp_area = $warp_area/warp
@onready var backup = $backup_warp

func _ready():
	if !Engine.is_editor_hint():
		if all_directions:
			var sphere = SphereShape3D.new()
			sphere.radius = 0.5
			warp_area.set_shape(sphere)
		if Global.gen==1:
			queue_free()
		if all_directions:
			backup.queue_free()

func _process(_delta):
	
	if Engine.is_editor_hint():
		sprite.visible=true
	else:
		sprite.visible=Global.debug

	if !all_directions:
		sprite.frame_coords.x=clamp(warp_direction,0,3)
	if all_directions:
		sprite.frame_coords.x=4
	
	if !all_directions:
		if warp_direction==0 || warp_direction==3:
			warp_area.get_shape().size = Vector3(2.,2.,0.)
			if warp_direction==3:
				backup.rotation.y=deg_to_rad(180)
			else:
				backup.rotation.y=0.0
		elif warp_direction==1 || warp_direction==2:
			warp_area.get_shape().size = Vector3(0.,2.,2.)
			if warp_direction==2:
				backup.rotation.y=deg_to_rad(-90)
			else:
				backup.rotation.y=deg_to_rad(90)
		
	
	warp_direction=clamp(warp_direction,0,3)

func _on_warp_area_body_entered(body):
	
	if body==get_tree().get_first_node_in_group("Player"):
		if get_tree().get_first_node_in_group("Player_sprite").hframes==5:
			if diagonal_entrance:
				if get_tree().get_first_node_in_group("Player").animation_direction==directions.x || get_tree().get_first_node_in_group("Player").animation_direction==directions.y:
					Global.warp_to(scene,loading_preset)
					Global.player_array=coordinate_and_direction
			else:
				if get_tree().get_first_node_in_group("Player").animation_direction==warp_direction || all_directions:
					Global.warp_to(scene,loading_preset)
					Global.player_array=coordinate_and_direction
		else:
			Global.warp_to(scene,loading_preset)
			Global.player_array=coordinate_and_direction
			
	if body==get_tree().get_first_node_in_group("Playback_player"):
		get_tree().get_first_node_in_group("Playback_player").queue_free()
