class_name ActorType
extends Entity

func _init()->void:
	label = "Actor"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "m_knight"
	data.moves = true
	data.move_speed = 4.0
	data.is_solid = true
	data.has_stats = true
	data.behavior_keys = [
		BaseBehavior.Type.INPUT
	]
	data.has_animations = true
	data.has_information = true

func _prepare()->void:
	data.char_name = "Iphrit"
