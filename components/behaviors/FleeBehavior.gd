## Flee behavior - entity runs away when health is critical.
## Priority increases as health decreases below threshold.
@tool
class_name FleeBehavior
extends Behavior

## Blood ratio threshold below which fleeing becomes urgent (0.0 to 1.0)
@export_range(0.0, 1.0, 0.05) var blood_threshold:float = 0.3

## Base priority when at threshold
@export_range(0.0, 2.0, 0.1) var base_priority:float = 1.0

func _init()->void:
	behavior_name = "Flee"
	description = "Flees to map edge when health is critical"
	enabled = true

func priority(uid:int, REG:REGISTRY)->float:
	if not enabled:return 0.0
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if not stats or not stats.is_alive or not stats.is_conscious:return 0.0
	
	var blood_ratio:float = stats.blood.ratio()
	
	# Priority increases as health drops below threshold
	if blood_ratio < blood_threshold:return base_priority - (blood_ratio / blood_threshold) * 0.5
	
	return 0.0

func act(uid:int, REG:REGISTRY) -> void:
	var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if not movement or not movement.movable:
		return
	
	# Flee to nearest map edge
	var world_end:Vector2 = Vector2(REG.WIDTH * REG.SCALE, REG.HEIGHT * REG.SCALE)
	var edges:Array[Vector2] = [
		Vector2(0, randf_range(0, world_end.y)),                    # Left edge
		Vector2(world_end.x, randf_range(0, world_end.y)),         # Right edge
		Vector2(randf_range(0, world_end.x), 0),                   # Top edge
		Vector2(randf_range(0, world_end.x), world_end.y)          # Bottom edge
	]
	
	# Pick closest edge
	var closest_edge:Vector2 = edges[0]
	var closest_dist:float = movement.position.distance_to(closest_edge)
	
	for edge in edges:
		var dist:float = movement.position.distance_to(edge)
		if dist < closest_dist:
			closest_dist = dist
			closest_edge = edge
	
	var mov_sys:MovementSystem = REG.get_system(MovementSystem)
	if mov_sys:
		mov_sys.force_move(uid, closest_edge, REG)
