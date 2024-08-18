@tool
extends Node3D

@export_subgroup("Darkener Settings:")
@export var darkener_width = 1.
@export var darkener_direction = 0
#func _ready():
func _ready():
	if !Engine.is_editor_hint():
		if darkener_direction==0 || darkener_direction==3:
			if get_tree().get_first_node_in_group("Player").global_position.x>=self.global_position.x-darkener_width/2 && get_tree().get_first_node_in_group("Player").global_position.x<=self.global_position.x+darkener_width/2:
				if darkener_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z>=self.global_position.z:
						Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.z-self.global_position.z)-0.25),0.0,1.0)

				
				if darkener_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z<=self.global_position.z:
						Global.player_brightness= clamp(1.0-((self.global_position.z-get_tree().get_first_node_in_group("Player").global_position.z)-0.25),0.0,1.0)

		elif darkener_direction==1 || darkener_direction==2:
			if get_tree().get_first_node_in_group("Player").global_position.z>=self.global_position.z-darkener_width/2:
				if darkener_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x>=self.global_position.x:
						Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.x-self.global_position.x)-0.25),0.0,1.0)

				if darkener_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x<=self.global_position.x:
						Global.player_brightness= clamp(1.0-((self.global_position.x-get_tree().get_first_node_in_group("Player").global_position.x)-0.25),0.0,1.0)
						
	if !Engine.is_editor_hint():
		if !Global.debug:
			$visual.visible = false
			
		if get_tree().get_first_node_in_group("Playback_player")!=null:
			if darkener_direction==0 || darkener_direction==3:
				if get_tree().get_first_node_in_group("Playback_player").global_position.x>=self.global_position.x-darkener_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.x<=self.global_position.x+darkener_width/2:
					if darkener_direction==0:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z>=self.global_position.z:
							Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.z-self.global_position.z)-0.25),0.0,1.0)

					
					if darkener_direction==3:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z<=self.global_position.z:
							Global.player_brightness= clamp(1.0-((self.global_position.z-get_tree().get_first_node_in_group("Playback_player").global_position.z)-0.25),0.0,1.0)

			elif darkener_direction==1 || darkener_direction==2:
				if get_tree().get_first_node_in_group("Playback_player").global_position.z>=self.global_position.z-darkener_width/2:
					if darkener_direction==1:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x>=self.global_position.x:
							Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.x-self.global_position.x)-0.25),0.0,1.0)

					if darkener_direction==2:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x<=self.global_position.x:
							Global.player_brightness= clamp(1.0-((self.global_position.x-get_tree().get_first_node_in_group("Playback_player").global_position.x)-0.25),0.0,1.0)
							
func _process(_delta):
	$visual.frame_coords.x=clamp(darkener_direction,0,3)
	if !Engine.is_editor_hint():
		if darkener_direction==0 || darkener_direction==3:
			if get_tree().get_first_node_in_group("Player").global_position.x>=self.global_position.x-darkener_width/2 && get_tree().get_first_node_in_group("Player").global_position.x<=self.global_position.x+darkener_width/2:
				if darkener_direction==0:
					if get_tree().get_first_node_in_group("Player").global_position.z>=self.global_position.z:
						Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.z-self.global_position.z)-0.25),0.0,1.0)
				
				if darkener_direction==3:
					if get_tree().get_first_node_in_group("Player").global_position.z<=self.global_position.z:
						Global.player_brightness= clamp(1.0-((self.global_position.z-get_tree().get_first_node_in_group("Player").global_position.z)-0.25),0.0,1.0)

		elif darkener_direction==1 || darkener_direction==2:
			
			if get_tree().get_first_node_in_group("Player").global_position.z>=self.global_position.z-darkener_width/2 && get_tree().get_first_node_in_group("Player").global_position.z<=self.global_position.z+darkener_width/2:
				if darkener_direction==1:
					if get_tree().get_first_node_in_group("Player").global_position.x>=self.global_position.x:
						Global.player_brightness= clamp(1.0-((get_tree().get_first_node_in_group("Player").global_position.x-self.global_position.x)-0.25),0.0,1.0)

				
				if darkener_direction==2:
					if get_tree().get_first_node_in_group("Player").global_position.x<=self.global_position.x:
						Global.player_brightness= clamp(1.0-((self.global_position.x-get_tree().get_first_node_in_group("Player").global_position.x)-0.25),0.0,1.0)
						
	
		if get_tree().get_first_node_in_group("Playback_player")!=null:
			if darkener_direction==0 || darkener_direction==3:
				if get_tree().get_first_node_in_group("Playback_player").global_position.x>=self.global_position.x-darkener_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.x<=self.global_position.x+darkener_width/2:
					if darkener_direction==0:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z>=self.global_position.z:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.z-self.global_position.z)-0.25),0.0,1.0)
					
					if darkener_direction==3:
						if get_tree().get_first_node_in_group("Playback_player").global_position.z<=self.global_position.z:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((self.global_position.z-get_tree().get_first_node_in_group("Playback_player").global_position.z)-0.25),0.0,1.0)

			elif darkener_direction==1 || darkener_direction==2:
				
				if get_tree().get_first_node_in_group("Playback_player").global_position.z>=self.global_position.z-darkener_width/2 && get_tree().get_first_node_in_group("Playback_player").global_position.z<=self.global_position.z+darkener_width/2:
					if darkener_direction==1:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x>=self.global_position.x:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((get_tree().get_first_node_in_group("Playback_player").global_position.x-self.global_position.x)-0.25),0.0,1.0)

					
					if darkener_direction==2:
						if get_tree().get_first_node_in_group("Playback_player").global_position.x<=self.global_position.x:
							get_tree().get_first_node_in_group("Playback_player").brightness= clamp(1.0-((self.global_position.x-get_tree().get_first_node_in_group("Playback_player").global_position.x)-0.25),0.0,1.0)
