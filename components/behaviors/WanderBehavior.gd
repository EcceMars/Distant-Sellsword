@tool
class_name WanderBehavior
extends BaseBehavior

const WANDER_INTERVAL:float = 3.0
const WANDER_RADIUS:int = 4

var _latency:float = 0.0

func _init()->void:
	behavior_name = "Wander"
	type = Type.WANDER
	priority = 0.2

func get_priority()->float:
	if not active: return 0.0
	return priority
func act(uid:int)->void:
	var mov_sys: MovementSystem = REG.SYSTEMS.get("MovementSystem")
	if not mov_sys:
		return
	_latency -= REG.DELTA
	if _latency > 0.0:
		return
	_latency = WANDER_INTERVAL
	
	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return
	
	var destination:Vector2 = _pick_destination(mov.position, mov_sys)
	mov_sys.add_move(uid, destination)
## Returns a random unblocked grid position within [constant WANDER_RADIUS] tiles.
func _pick_destination(origin: Vector2, mov_sys: MovementSystem) -> Vector2:
	var scale: int = REG.SCALE
	var attempts: int = 8

	while attempts > 0:
		var dx: int = randi_range(-WANDER_RADIUS, WANDER_RADIUS) * scale
		var dy: int = randi_range(-WANDER_RADIUS, WANDER_RADIUS) * scale
		var candidate: Vector2 = origin + Vector2(dx, dy)

		# Keep within world bounds
		candidate = candidate.clamp(
			Vector2.ZERO,
			Vector2(REG.WIDTH, REG.HEIGHT) * scale
		)

		var grid_candidate: Vector2i = Vector2i(candidate.snapped(Vector2(scale, scale)))
		if not mov_sys.blocked_positions.has(grid_candidate):
			return candidate

		attempts -= 1

	return origin
