## Food item - restores hunger
class_name FoodItemType
extends ItemType

func _init() -> void:
	archetype = "Food"
	
	item_type = ItemComponent.ItemType.FOOD
	item_name = "Bread"
	nutrition = 30.0
	hydration = 0.0
	stack_size = 1
	max_stack = 10
	weight = 0.5
	consumable = true

	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "item_bread"  # TODO: Create these sprites
