## Archetype for berries items
class_name BerriesItemType
extends Entity

func _init()->void:
	label = "RedBerries"
	data.sprite_type = VisualComponent.SpriteType.STATIC
	data.is_item = true
	data.item_type = "FOOD"

func _prepare() -> void:
	data.sprite_key = ["red_berries", "blue_berries"].pick_random()
