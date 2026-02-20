## Concrete archetype for trees and vegetation
## Demonstrates static entities that could become movable at runtime
class_name TreeType
extends Entity

func _init()->void:
	label = "PineTree"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "pines"
	data.is_solid = true
