extends Marker2D

var player: Entity

@onready var player_sprite = $PlayerSprite


func _ready() -> void:
	GameManager.update_sheet.connect(update_sheet)
	update_sheet()


func _process(_delta) -> void:
	if player != null:
		if (
				player._sprite.frame_coords.x 
				!= player_sprite.frame_coords.x
				and player._sprite.frame_coords.x != 1
				and player._sprite.frame_coords.x != 2
				):
			player_sprite.frame_coords.x =  player._sprite.frame_coords.x
		
		if player._sprite.frame_coords.y != player_sprite.frame_coords.y:
			player_sprite.frame_coords.y = player._sprite.frame_coords.y


func update_sheet() -> void:
	player_sprite.texture = player._sprite.texture
	player_sprite.vframes = player._sprite.vframes
	player_sprite.hframes = player._sprite.hframes
	player_sprite.get_material().set_shader_parameter("albedoTex", player_sprite.texture)
