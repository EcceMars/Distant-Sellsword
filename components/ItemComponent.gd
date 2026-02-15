class_name ItemComponent
extends BaseComponent

const STATS_FLAG:BaseComponent.Flag = Flag.STATS

enum ItemType {
	FOOD,       ## Restores hunger
	WATER,      ## Restores thirst
	MATERIAL,   ## Crafting material (wood, stone, etc.)
	TOOL,       ## Equipment
	MISC        ## Other items
}

## Type of item
var item_type:ItemType = ItemType.MISC

## Display name
var item_name:String = "Item"

## How much hunger this restores (if food)
var nutrition:float = 0.0

## How much thirst this restores (if water)
var hydration:float = 0.0

## Stack size (how many in this stack)
var stack_size:int = 1

## Maximum stack size
var max_stack:int = 99

## Weight (for inventory systems, future)
var weight:float = 1.0

## Can this item be consumed?
var consumable:bool = false

## Is this item currently on the ground (vs. in inventory)?
var on_ground:bool = true

func _init(
	_item_type:ItemType = ItemType.MISC,
	_item_name:String = "Item",
	_nutrition:float = 0.0,
	_hydration:float = 0.0,
	_stack_size:int = 1,
	_consumable:bool = false
)->void:
	item_type = _item_type
	item_name = _item_name
	nutrition = _nutrition
	hydration = _hydration
	stack_size = _stack_size
	consumable = _consumable
	flag = Flag.ITEM

## Consumes this item and applies effects to entity
func consume(uid:int, REG:REGISTRY)->bool:
	if not consumable:
		return false
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG) as StatsComponent
	if not stats:
		return false
	
	# Apply effects
	if nutrition > 0.0:
		stats.hunger.recover(nutrition)
	if hydration > 0.0:
		stats.thirst.recover(hydration)
	
	# Reduce stack or destroy
	stack_size -= 1
	if stack_size <= 0:
		REG.destroy_entity(uid)  # Item consumed completely
	
	return true

## Adds to stack (returns overflow if any)
func add_to_stack(amount:int)->int:
	var can_add:int = min(amount, max_stack - stack_size)
	stack_size += can_add
	return amount - can_add  # Return overflow

func get_display_name()->String:
	if stack_size > 1:
		return "%s x%d" % [item_name, stack_size]
	return item_name
