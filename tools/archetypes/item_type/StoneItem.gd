## Stone resource - crafting material
class_name StoneItemType
extends ItemType

func _init() -> void:
	archetype = "Stone"
	
	item_type = ItemComponent.ItemType.MATERIAL
	item_name = "Stone"
	nutrition = 0.0
	hydration = 0.0
	stack_size = 1
	max_stack = 99
	weight = 5.0
	consumable = false
	
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "item_stone"
