## Wander behavior - entity moves to random nearby locations.
## Provides ambient life to the world.
@tool
class_name WanderBehavior
extends Behavior

## Base priority (constant)
@export_range(0.0, 1.0, 0.05) var base_priority:float = 0.2

## Minimum time between wander moves (in frames)
@export_range(10, 300, 10) var interval_min:int = 30

## Maximum time between wander moves (in frames)
@export_range(10, 300, 10) var interval_max:int = 120

## Minimum wander distance multiplier (speed * frames * multiplier)
@export_range(1.0, 100.0, 5.0) var distance_min:float = 30.0

## Maximum wander distance multiplier
@export_range(1.0, 100.0, 5.0) var distance_max:float = 60.0

## Internal:Frame counter for timing
var _last_wander_frame:int = 0
var _next_wander_interval:int = 60

func _init()->void:
	behavior_name = "Wander"
	description = "Moves to random nearby locations"
	enabled = true
	_randomize_interval()

func priority(uid:int, REG:REGISTRY)->float:
	if not enabled:
		return 0.0
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if not stats or not stats.is_alive or not stats.is_conscious:
		return 0.0
	
	return base_priority

func act(uid:int, REG:REGISTRY)->void:
	var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if not movement or not movement.movable:
		return
	
	# Don't interrupt long movement queues
	if movement.movable.path.size() > 4:
		return
	
	# Wait for interval
	_last_wander_frame += 1
	if _last_wander_frame < _next_wander_interval:
		return
	
	# Time to wander!
	_last_wander_frame = 0
	_randomize_interval()
	
	# Pick random direction and distance
	var distance:float = movement.movable.speed * randf_range(distance_min, distance_max)
	var angle:float = randf() * TAU
	var offset:Vector2 = Vector2(cos(angle), sin(angle)) * distance
	
	# Calculate target, clamped to world bounds
	var target:Vector2 = movement.position + offset
	var world_size:Vector2 = Vector2(REG.WIDTH * REG.SCALE, REG.HEIGHT * REG.SCALE)
	target = target.clamp(Vector2.ZERO, world_size)
	
	# Queue movement
	var mov_sys:MovementSystem = REG.get_system(MovementSystem)
	if mov_sys:
		mov_sys.queue_move(uid, target, REG)

func on_enter(_uid:int, _REG:REGISTRY)->void:
	# Reset timing when behavior becomes active
	_last_wander_frame = 0
	_randomize_interval()

func _randomize_interval()->void:
	_next_wander_interval = randi_range(interval_min, interval_max)
