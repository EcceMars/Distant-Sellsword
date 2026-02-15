## Water item - restores thirst
class_name WaterItemType
extends ItemType

func _init() -> void:
	archetype = "Water"
	
	item_type = ItemComponent.ItemType.WATER
	item_name = "Water Bottle"
	nutrition = 0.0
	hydration = 40.0
	stack_size = 1
	max_stack = 5
	weight = 1.0
	consumable = true
	
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "item_water"
