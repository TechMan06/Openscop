extends Node

signal emit_transition(loading_preset: LoadingPreset)
signal start_scene
signal crash_game

signal return_to_pause
signal return_to_options
signal return_to_sound_test
signal return_to_secret

signal text_finished
signal text_started

signal finished_typing(content: String, attached_node: Node)
signal change_keyboard_bg(color: int)

signal p2talk_key(word: String, buttons: String)
signal p2talk_type(word: String, buttons: String)

signal player_spawned(player_obj: Player)
signal playback_player_spawned(playback_player_obj: PlaybackPlayer)

signal camera_spawned(camera: CameraMarker)
signal camera_earthquake(value: bool)
signal camera_shake_amount(value: float)
signal camera_zone_spawned(camera_zone: CameraZone)
signal camera_shake_speed(value: float)

signal unlock_nmp
signal warp_spawned(warp: WarpClass)

signal nifty_upload(texture: Image)
signal nifty_finished(texture: Image, draw_layer_texture: Image, pixel_array: Array[Vector2i])
signal nifty_set_pixels(array: Array[Vector2i])

signal destroy_pause
signal destroy_hud

signal room_started(level: Level)
signal gen_specific_object_spawned(settings: GenSpecific)
