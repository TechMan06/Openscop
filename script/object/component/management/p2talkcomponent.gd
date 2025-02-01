extends Node
class_name P2TalkComponent

const _P2TALK_WORD_OBJECT: PackedScene = preload("res://scene/object/instantiate/p2talkword.tscn")
const _P2TALK_SPEED: float = 1.0

@export var entity: Entity


func _create_word() -> void:
	var _word_instance: Label3D = _P2TALK_WORD_OBJECT.instantiate()
	
	_word_instance.text = get_p2talk_word(entity.p2talk_word)
	_word_instance.sound_id = entity.player_stats.character_id
	entity._p2talk_origin.add_child(_word_instance)
	
	#RESPONSIBLE FOR "CASCADE" EFFECT WHEN THERES MORE THAN 1 P2TALKWORD
	#ALSO RESPONSIBLE FOR ANIMATING THEM RISING
	for word in entity._p2talk_origin.get_children():
		if word.get_index() != 0:
			create_tween().tween_property(
					word, 
					"position", 
					Vector3(0, 1.0, 0), 
					_P2TALK_SPEED
				).set_trans(Tween.TRANS_LINEAR).as_relative()
			
			if word.get_index() == entity._p2talk_origin.get_child_count()-1:
				await get_tree().create_timer(_P2TALK_SPEED, false).timeout
				entity._can_submit = true


func get_p2talk_word(word: String) -> String:
	var _treated_word: String = word.rstrip(" ")
	var _numbers: Array = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var _final_word: String = ""

	if Global.p2talk_dict.find_key(_treated_word)!=null:
		if _treated_word=="OW K EY":
			return "OK"
		else:
			_final_word = Global.p2talk_dict.find_key(_treated_word)
			_final_word = _final_word.to_lower().capitalize()
			
			for number in _numbers:
				_final_word = _final_word.replace(number, "")
			
			return _final_word
	else:
		return "Not in Table"
