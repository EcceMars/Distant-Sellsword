## Wood resource - crafting material
class_name WoodItemType
extends ItemType

func _init() -> void:
	archetype = "Wood"
	
	item_type = ItemComponent.ItemType.MATERIAL
	item_name = "Wood"
	nutrition = 0.0
	hydration = 0.0
	stack_size = 1
	max_stack = 99
	weight = 2.0
	consumable = false
	
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "item_wood"
