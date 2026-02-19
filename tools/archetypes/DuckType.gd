## Concrete archetype for trees and vegetation
## Demonstrates static entities that could become movable at runtime
class_name DuckType
extends EntityArchetype

func _init()->void:
	label = "Duck"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "duck"
	data.moves = true
	data.move_type = MovementComponent.Movable.Flag.AMPHIBIAN
	data.has_stats = true
	data.behavior_keys = [
		#BaseBehavior.Type.FLEE,
		#BaseBehavior.Type.REST,
		BaseBehavior.Type.SEEK_WATER,
		BaseBehavior.Type.SEEK_FOOD,
		BaseBehavior.Type.WANDER,
		BaseBehavior.Type.IDLE
	]
	data.has_animations = true
	data.has_information = true
	data.has_memory = true

func _prepare()->void:
	data.char_name = "Wild Duck" #REG.DATA.duck_names.pick_random()
