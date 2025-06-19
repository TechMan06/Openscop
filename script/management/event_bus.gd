extends Node

## The EventBus Autoload Class, it is used for sending signals all across the game on a global scope.
## These signals are used to trigger certain objects or parts of the game to perform certain actions.

signal emit_transition(loading_preset: LoadingPreset) ## Triggers a loading screen on the [HUD] Class Autoload.
signal start_scene ## Emitted by the [Level] Class when the room starts.
signal crash_game ## Crashes the game by calling the [method Global.crash_game] function.

signal return_to_pause ## Re-enables the Pause Menu as you leave the options or The Book of Baby Names menu submenu.
signal return_to_options ## Re-enables the Options Menu as you leave the Sound Test Menu or the Controls Menu submenus.
signal return_to_sound_test ## Re-enables the Sound Test Menu as you leave the Secret Menu submenu.
signal return_to_secret ## Re-enables the Secret Menu as you leave the Recordings Menu submenu.
signal pause_leave_sfx  ## Plays the leaving the option selected sound you leave the Pause Menu.

signal text_started ## Triggered when a textbox starts typing it's text, right after spawning.
signal text_finished  ## Triggered when a textbox finishes it's text, right before being destroyed.

signal finished_typing(content: String, attached_node: Node) ## Emitted right after the textbox has finished typing a part of the dialog.
signal change_keyboard_bg(color: int) ## Changes the color of the on-screen keyboard if it's on-screen.

signal p2talk_key(word: String, buttons: String) ## Emits the current word typed and the button pressed when a button is pressed in P2 to Talk.
signal p2talk_type(word: String, buttons: String) ## Emits the current word typed and the button pressed when a button is pressed in P2 to Talk.

signal player_spawned(player_obj: Player) ## Emitted when the [Player] is spawned.
signal playback_player_spawned(playback_player_obj: PlaybackPlayer) ## Emitted when the [PlaybackPlayer] is spawned.

signal place_pet(wheel_id: int, pet: PetResource) ## Places a pet determined in the [PetResource] in [code]pet[/code] in the Child Library wheel with the specific [code]id[/code].

signal camera_spawned(camera: CameraMarker) ## Emitted when the [CameraMarker] is spawned.
signal camera_earthquake(value: bool) ## Triggers an earthquake on the [CameraMarker]
signal camera_shake_amount(value: float) ## Sets the intensity of the earthquake effect.
signal camera_zone_spawned(camera_zone: CameraZone) ## Emitted when the [CameraZone] is spawned.
signal camera_shake_speed(value: float)  ## Sets the speed of the earthquake effect.
signal camera_shake_transition_speed(value: float) ## Sets the speed of the earthquake transition effect.
signal camera_shake_stop ## Stops the earthquake effect abruptly.


signal open_bedroom ## Skips or finishes the Child Library earthquake and opens the bedroom.

signal unlock_nmp ## Unlocks the Newmaker Plane, triggered by the Pause Menu.
signal warp_spawned(warp: WarpClass) ## Emitted when a [WarpClass] Node is spawned.

signal nifty_upload(texture: Image) ## Emitted when the [NiftyMesh] sends it's texture to the [Level] Class for the Draw Mode.
signal nifty_finished(texture: Image, draw_layer_texture: Image, pixel_array: Array[Vector2i]) ## Sends the image drawn in Draw Mode to the [Level] Class.
signal nifty_set_pixels(array: Array[Vector2i]) ## Updates the textures in [NiftyMesh].


signal game_unpaused ## Emitted when the game is unpaused.
signal game_paused ## Emitted when the game is paused.
signal destroy_pause ## Brute-destroys the Pause Menu and forces the game to be unpaused.
signal destroy_hud ## Removes visibility from the HUD until it's triggered again.
signal create_face(
						id: int,
						expression: Array[int], 
						horizontal_offset: Array[int], 
						vertical_offset: Array[int]
					) ## Sends the Child Face drawn in the Child Library Face Canvas to a face in the overworld.

signal room_started(level: Level) ## Emitted when the [Level] Node is loaded.
signal gen_specific_object_spawned(settings: GenSpecific) ## Emitted when a [GenSpecific] object is spawned.
