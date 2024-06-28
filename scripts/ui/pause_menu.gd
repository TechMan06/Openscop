extends Node2D

var screenshotted = false
var paused = false
@export var can_unpause = true

var fade = 0.0
const SCREEN_ANIM_TIME = 1.0
const BUTTON_ANIM_SPEED = 1
const MINI_SCREEN_SIZE = 0.5
var unpause_anim = false
var selected_option = 0
var active_menu = [false,false,false,false,false]
var spawned_menu = false
var inMenu = false
var piece_frame = 0
	

func selection_sound(variable):
	if variable%2!=0:
		if Global.gen!=6:
			$select_up.play()
		else:
			$select_down.play()
	else:
		if Global.gen!=6:
			$select_down.play()
		else:
			$select_up.play()

func _ready():
	$main_pausemenu/visible_group/Select.play()
	$main_pausemenu/visible_group/Resume.play()
	$main_pausemenu/buttons/quit_button.visible = !Record.replay

func _process(delta):
	piece_frame+=10.0*delta
	if piece_frame>19:
		piece_frame=0
	$main_pausemenu/visible_group/piece.frame_coords.x = round(piece_frame)
	if $current_menu.get_child_count()==0 && inMenu == true:
		create_tween().tween_property(self, "fade", 0.0,0.5)
		if fade<1.1:
			create_tween().tween_property($pink_fade,"color:a",0.0,0.25)
		await get_tree().create_timer(0.4).timeout
		inMenu = false
		active_menu = [false,false,false,false,false]
		
	if Input.is_action_just_pressed("pressed_start") && Global.control_mode!=1 && get_tree().get_first_node_in_group("HUD_pausemenu").can_unpause && Global.can_pause:
		if $current_menu.get_child_count()==0 && Global.gen>2:
			Global.game_paused=!Global.game_paused
	
	if Global.game_paused:
		#$"../../recording_header".disappear()
		#await $"../../recording_header".get_child(0).timeout
		$main_pausemenu/visible_group.visible=true
		$main_pausemenu/visible_group/piece_counter.text=str(Global.pieces_amount[Global.current_character]).pad_zeros(5)
		if $screen_sprite.scale.x>MINI_SCREEN_SIZE:
			can_unpause=false
			$screen_sprite.z_index=1
		else:
			can_unpause=true
			$screen_sprite.z_index=-1
			
		if !screenshotted:
			var random=randi_range(0,2)
			if random==0:
				$pause_sound.play()
			elif random==1:
				$pause_sound2.play()
			elif random==2:
				$pause_sound3.play()
			$main_pausemenu/background1.visible = true
			if $main_pausemenu/buttons_quit.get_child_count()==0 && !inMenu:
				$main_pausemenu/buttons.visible = true
			screenshotted = true
			create_tween().tween_property($screen_sprite,"scale",Vector2(MINI_SCREEN_SIZE,MINI_SCREEN_SIZE),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_SINE)
			$main_pausemenu/visible_group/Resume.frame=1
	else:
		if $screen_sprite.scale.x<1.:
			can_unpause=false
		else:
			selected_option=0
			for buttons in get_node("main_pausemenu/buttons").get_children():
				if get_node("main_pausemenu/buttons").get_child(0)!=buttons:
					buttons.frame_coords.x=0
					buttons.position.x=18
				else:
					buttons.frame_coords.x=1
					buttons.position.x=28
			
			can_unpause=true
			screenshotted=false
			$main_pausemenu/background1.visible = false
			$main_pausemenu/buttons.visible = false
			$screen_sprite.set_texture(null)
			$main_pausemenu/visible_group.visible=false
		if $screen_sprite.scale.x==MINI_SCREEN_SIZE:
			$screen_sprite.z_index=1
			var screen_scaler = create_tween()
			screen_scaler.tween_property($screen_sprite,"scale",Vector2(1.,1.),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_SINE)
			await screen_scaler.finished

	if can_unpause && Global.game_paused && $current_menu.get_child_count()==0 && $main_pausemenu/buttons.visible && !get_tree().get_first_node_in_group("Nifty").visible:
		if fade==0.0:
			if Input.is_action_just_pressed("pressed_up"):
				selected_option-=1
				
			if Input.is_action_just_pressed("pressed_down"):
				selected_option+=1
				
		if Input.is_action_just_pressed("pressed_down") && selected_option<=4-(int(Record.replay)):
			selection_sound(selected_option)
		if Input.is_action_just_pressed("pressed_up") && selected_option!=-1:
			selection_sound(selected_option)
		
		selected_option = clamp(selected_option,0,4-(int(Record.replay)))
		$overlay.set_modulate(Color(1,1,1,fade))
		
		if fade>1.0 && inMenu == false:
			create_tween().tween_property($pink_fade,"color:a",1.0,0.25)
			if $pink_fade.color.a>0.9 && active_menu[selected_option]==false:
				if selected_option==2:
					$current_menu.add_child(preload("res://scenes/objects/menu/pets.tscn").instantiate())
					active_menu[selected_option]=true
					inMenu = true
				if selected_option==3:
					$current_menu.add_child(preload("res://scenes/objects/menu/baby_book.tscn").instantiate())
					active_menu[selected_option]=true
					inMenu = true

		if Input.is_action_just_pressed("pressed_action") && !get_tree().get_first_node_in_group("Nifty").visible:
			if selected_option==4:
				#$selected.play()
				active_menu[selected_option]=true
				$current_menu.add_child(preload("res://scenes/objects/menu/quit_button.tscn").instantiate())
			elif selected_option!=0:
				if fade==0.0 && $current_menu.get_child_count()==0:
					$selected.play()
				$overlay.frame_coords.x=selected_option
				create_tween().tween_property(self,"fade",1.1,0.5)
			else:
				Global.game_paused=false
		
		for buttons in get_node("main_pausemenu/buttons").get_children():
			if get_node("main_pausemenu/buttons").get_child(selected_option)!=buttons:
				buttons.frame_coords.x=0
				if buttons.position.x>18:
					buttons.position.x-=BUTTON_ANIM_SPEED
			else:
				buttons.frame_coords.x=1
				if buttons.position.x<28:
					buttons.position.x+=BUTTON_ANIM_SPEED
