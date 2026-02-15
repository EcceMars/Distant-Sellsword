## Seek food behavior - entity searches for food when hungry.
## TODO: Will eventually integrate with item/resource system.
@tool
class_name SeekFoodBehavior
extends Behavior

## Hunger ratio threshold below which seeking food becomes urgent (0.0 to 1.0)
@export_range(0.0, 1.0, 0.05) var hunger_threshold:float = 0.3

## Base priority when at threshold
@export_range(0.0, 2.0, 0.1) var base_priority:float = 0.6

## Search radius for food items (in pixels)
@export var search_radius:float = 200.0

func _init()->void:
	behavior_name = "Seek Food"
	description = "Searches for food when hungry"
	enabled = true

func priority(uid:int, REG:REGISTRY)->float:
	if not enabled:
		return 0.0
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG) as StatsComponent
	if not stats or not stats.is_alive or not stats.is_conscious:
		return 0.0
	
	var hunger_ratio:float = stats.hunger.ratio()
	
	# Priority increases as hunger drops below threshold
	if hunger_ratio < hunger_threshold:
		return base_priority - (hunger_ratio / hunger_threshold) * 0.2
	
	return 0.0

func act(uid:int, REG:REGISTRY)->void:
	var movement:MovementComponent = REG.get_component(uid, MOV_FLAG) as MovementComponent
	if not movement or not movement.movable:
		return
	
	# TODO:Once ItemComponent exists, search for food items
	# For now, move toward world center (placeholder behavior)
	var world_center:Vector2 = Vector2(REG.WIDTH * REG.SCALE, REG.HEIGHT * REG.SCALE) * 0.5
	var search_target:Vector2 = world_center.lerp(movement.position, 0.8)
	
	var mov_sys:MovementSystem = REG.get_system(MovementSystem)
	if mov_sys:
		mov_sys.force_move(uid, search_target, REG)

## Finds nearest food item within search radius
## Returns uid of food item, or -1 if none found
func _find_nearest_food(_uid:int, _REG:REGISTRY)->int:
	# TODO:Implement when ItemComponent exists
	# Pseudo-code:
	# 1. Get all entities with ItemComponent where item_type == FOOD
	# 2. Filter by distance < search_radius
	# 3. Return closest one
	return -1

## Attempts to consume a food item
func _consume_food(_uid:int, _food_uid:int, _REG:REGISTRY)->bool:
	# TODO:Implement when ItemComponent exists
	# Pseudo-code:
	# 1. Get ItemComponent from food_uid
	# 2. Apply food's nutrition to stats.hunger
	# 3. Destroy food item or reduce stack
	# 4. Return true if successful
	return false
