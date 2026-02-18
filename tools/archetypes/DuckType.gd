## Concrete archetype for trees and vegetation
## Demonstrates static entities that could become movable at runtime
class_name DuckType
extends EntityArchetype

func _init()->void:
	label = "Duck"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "duck"
	data.moves = true
	data.has_stats = true
	data.behavior_keys = [
		BaseBehavior.Type.FLEE,
		BaseBehavior.Type.REST,
		BaseBehavior.Type.WANDER,
		BaseBehavior.Type.IDLE
	]
	data.has_animations = true
	data.has_information = true

func _prepare()->void:
	data.char_name = "Wild Duck" #REG.DATA.duck_names.pick_random()
