## Archetype for berries items
class_name BerriesItemType
extends EntityArchetype

func _init()->void:
	label = "RedBerries"
	data.sprite_type = VisualComponent.SpriteType.STATIC
	data.sprite_key = ["red_berries", "blue_berries"].pick_random()
