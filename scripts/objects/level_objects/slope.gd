@tool
extends Node3D

@export_subgroup("Slope Settings:")
@export var slope_length = 0.
@export var slope_width = 1.
@export var slope_direction = 0
@export var slope_up = true
@export var change_brightness = false
@export var has_platform_on_end = true
#func _ready():
func _ready():
	if slope_direction==0 || slope_direction==3:
		if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x-slope_width/2 && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x+slope_width/2:
			if slope_direction==0:
				if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
					if change_brightness:
						Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.z-$slope_start.global_position.z)-0.25),0.0,1.0)
					slope_processing_z()
			
			if slope_direction==3:
				if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
					if change_brightness:
						Global.player_brightness= clamp(1.0-(($slope_start.global_position.z-get_tree().get_first_node_in_group("Player").global_position.z)-0.25),0.0,1.0)
					slope_processing_z()
	elif slope_direction==1 || slope_direction==2:
		if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z-slope_width/2 && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z+slope_width/2:
			if slope_direction==1:
				if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
					if change_brightness:
							Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.x-$slope_start.global_position.x)-0.25),0.0,1.0)
					slope_processing_x()
			if slope_direction==2:
				if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
					if change_brightness:
							Global.player_brightness= clamp(1.0-(($slope_start.global_position.x-get_tree().get_first_node_in_group("Player").global_position.x)-0.25),0.0,1.0)
					slope_processing_x()
	if !Engine.is_editor_hint():
		if !Global.debug:
			$slope_start/visual.visible = false
			$slope_end/visual2.visible = false
	
	if get_tree().get_first_node_in_group("Playback_player")!=null:
		if slope_direction==0 || slope_direction==3:
			if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_start.global_position.x-slope_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_start.global_position.x+slope_width/2:
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_end.global_position.z:
						if change_brightness:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.z-$slope_start.global_position.z)-0.25),0.0,1.0)
						playback_slope_processing_z()
				
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_end.global_position.z:
						if change_brightness:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-(($slope_start.global_position.z-get_tree().get_first_node_in_group("Playback_player").global_position.z)-0.25),0.0,1.0)
						playback_slope_processing_z()
		elif slope_direction==1 || slope_direction==2:
			if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_start.global_position.z-slope_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_start.global_position.z+slope_width/2:
				if slope_direction==1:
					if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_end.global_position.x:
						if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.x-$slope_start.global_position.x)-0.25),0.0,1.0)
						playback_slope_processing_x()
				if slope_direction==2:
					if get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_end.global_position.x:
						if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-(($slope_start.global_position.x-get_tree().get_first_node_in_group("Playback_player").global_position.x)-0.25),0.0,1.0)
						playback_slope_processing_x()
func _process(_delta):
	if Engine.is_editor_hint():
		if slope_direction==0:
			$slope_end.position.z=slope_length
			$slope_end.position.x=0.0
		if slope_direction==3:
			$slope_end.position.z=slope_length*-1
			$slope_end.position.x=0.0
		if slope_direction==1:
			$slope_end.position.x=slope_length
			$slope_end.position.z=0.0
		if slope_direction==2:
			$slope_end.position.x=slope_length*-1
			$slope_end.position.z=0.0
			
	if !Engine.is_editor_hint():
		if slope_direction==0:
			$slope_end.position.z=slope_length
			$slope_end.position.x=0.0
		if slope_direction==3:
			$slope_end.position.z=slope_length*-1
			$slope_end.position.x=0.0
		if slope_direction==1:
			$slope_end.position.x=slope_length
			$slope_end.position.z=0.0
		if slope_direction==2:
			$slope_end.position.x=slope_length*-1
			$slope_end.position.z=0.0
			
		
		if slope_direction==0 || slope_direction==3:
			
			if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x-slope_width/2 && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x+slope_width/2:
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
						if change_brightness:
							Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.z-$slope_start.global_position.z)-0.25),0.0,1.0)
						slope_processing_z()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
								gravity()
						else:
							gravity()
				
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
						if change_brightness:
							Global.player_brightness= clamp(1.0-(($slope_start.global_position.z-get_tree().get_first_node_in_group("Player").global_position.z)-0.25),0.0,1.0)
						slope_processing_z()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
								gravity()
						else:
							gravity()
			else:
				if slope_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z<=$slope_end.global_position.z:
						gravity()
				if slope_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_end.global_position.z:
						gravity()
		elif slope_direction==1 || slope_direction==2:
			
			if get_tree().get_first_node_in_group("Player").global_position.z>=$slope_start.global_position.z-slope_width/2 && get_tree().get_first_node_in_group("Player").global_position.z<=$slope_start.global_position.z+slope_width/2:
				if slope_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
						if change_brightness:
							Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.x-$slope_start.global_position.x)-0.25),0.0,1.0)
						slope_processing_x()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
								gravity()
						else:
							gravity()
				
				if slope_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
						if change_brightness:
							Global.player_brightness= clamp(1.0-(($slope_start.global_position.x-get_tree().get_first_node_in_group("Player").global_position.x)-0.25),0.0,1.0)
						slope_processing_x()
					else:
						if has_platform_on_end:
							if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
								gravity()
						else:
							gravity()
			else:
				if slope_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x<=$slope_end.global_position.x:
						gravity()
						
				if slope_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x>=$slope_end.global_position.x:
						gravity()
			
		
		if get_tree().get_first_node_in_group("Playback_player")!=null:
			if slope_direction==0 || slope_direction==3:
				
				if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_start.global_position.x-slope_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_start.global_position.x+slope_width/2:
					if slope_direction==0:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_start.global_position.z && get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_end.global_position.z:
							if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.z-$slope_start.global_position.z)-0.25),0.0,1.0)
							playback_slope_processing_z()
						else:
							if has_platform_on_end:
								if get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_end.global_position.z:
									playback_gravity()
							else:
								playback_gravity()
					
					if slope_direction==3:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_start.global_position.z && get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_end.global_position.z:
							if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-(($slope_start.global_position.z-get_tree().get_first_node_in_group("Playback_player").global_position.z)-0.25),0.0,1.0)
							playback_slope_processing_z()
						else:
							if has_platform_on_end:
								if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_end.global_position.z:
									playback_gravity()
							else:
								playback_gravity()
				else:
					if slope_direction==0:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_end.global_position.z:
							playback_gravity()
					if slope_direction==3:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_end.global_position.z:
							playback_gravity()
			elif slope_direction==1 || slope_direction==2:
				
				if get_tree().get_first_node_in_group("Playback_player").global_position.z>=$slope_start.global_position.z-slope_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.z<=$slope_start.global_position.z+slope_width/2:
					if slope_direction==1:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_start.global_position.x && get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_end.global_position.x:
							if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.x-$slope_start.global_position.x)-0.25),0.0,1.0)
							playback_slope_processing_x()
						else:
							if has_platform_on_end:
								if get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_end.global_position.x:
									playback_gravity()
							else:
								playback_gravity()
					
					if slope_direction==2:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_start.global_position.x && get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_end.global_position.x:
							if change_brightness:
								get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-(($slope_start.global_position.x-get_tree().get_first_node_in_group("Playback_player").global_position.x)-0.25),0.0,1.0)
							playback_slope_processing_x()
						else:
							if has_platform_on_end:
								if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_end.global_position.x:
									playback_gravity()
							else:
								playback_gravity()
				else:
					if slope_direction==1:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x<=$slope_end.global_position.x:
							playback_gravity()
							
					if slope_direction==2:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x>=$slope_end.global_position.x:
							playback_gravity()
		
		
		
func slope_processing_z():
	if slope_up:
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z)
	else:
		get_tree().get_first_node_in_group("Player_sprite").position.y=(abs(abs(get_tree().get_first_node_in_group("Player").global_position.z)-$slope_start.global_position.z))*-1
	

func slope_processing_x():
	if slope_up:
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)
	else:
		get_tree().get_first_node_in_group("Player_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Player").global_position.x)-$slope_start.global_position.x)*-1

func gravity():
	if Global.player_brightness>0.0:
		Global.player_brightness=1.0
	if get_tree().get_first_node_in_group("Player_sprite").position.y<=0.:
		get_tree().get_first_node_in_group("Player_sprite").position.y=0.
	if get_tree().get_first_node_in_group("Player_sprite").position.y>=0.:
		if get_tree().get_first_node_in_group("Player_sprite").position.y>=0.5:
			get_tree().get_first_node_in_group("Player_sprite").position.y-=0.5
		else:
			get_tree().get_first_node_in_group("Player_sprite").position.y=0.


func playback_slope_processing_z():
	if slope_up:
		get_tree().get_first_node_in_group("Playback_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Playback_player").global_position.z)-$slope_start.global_position.z)
	else:
		get_tree().get_first_node_in_group("Playback_sprite").position.y=(abs(abs(get_tree().get_first_node_in_group("Playback_player").global_position.z)-$slope_start.global_position.z))*-1
	

func playback_slope_processing_x():
	if slope_up:
		get_tree().get_first_node_in_group("Playback_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Playback_player").global_position.x)-$slope_start.global_position.x)
	else:
		get_tree().get_first_node_in_group("Playback_sprite").position.y=abs(abs(get_tree().get_first_node_in_group("Playback_player").global_position.x)-$slope_start.global_position.x)*-1

func playback_gravity():
	if get_tree().get_first_node_in_group("Playback_player").brightness>0.0:
		get_tree().get_first_node_in_group("Playback_player").brightness=1.0
	if get_tree().get_first_node_in_group("Playback_sprite").position.y<=0.:
		get_tree().get_first_node_in_group("Playback_sprite").position.y=0.
	if get_tree().get_first_node_in_group("Playback_sprite").position.y>=0.:
		if get_tree().get_first_node_in_group("Playback_sprite").position.y>=0.5:
			get_tree().get_first_node_in_group("Playback_sprite").position.y-=0.5
		else:
			get_tree().get_first_node_in_group("Playback_sprite").position.y=0.
