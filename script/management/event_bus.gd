extends Node


signal emit_transition(loading_preset: LoadingPreset)
signal start_scene

signal return_to_pause
signal text_finished

signal finished_typing(content: String, attached_node: Node)
signal change_keyboard_bg(color: int)

signal p2talk_key(word: String, buttons: String)
signal p2talk_type(word: String, buttons: String)

signal player_spawned(player_obj: Player)
signal playback_player_spawned(playback_player_obj: PlaybackPlayer)
signal camera_spawned(camera: CameraMarker)
signal camera_zone_spawned(camera_zone: CameraZone)

signal piece_spawned(id: int)
signal piece_collected(id: int)

signal nifty_upload(texture: Image)
signal nifty_finished(texture: Image, background_texture: Image)

signal destroy_pause
signal destroy_hud