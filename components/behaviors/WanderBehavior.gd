@tool
class_name WanderBehavior
extends BaseBehavior

const WANDER_INTERVAL:float = 3.0
var WANDER_RADIUS:int = REG.DATA.ACTIONS.IDLE_WANDER

var _latency:float = 0.0

func _init()->void:
	behavior_name = "Wander"
	type = Type.WANDER
	priority = 0.2
	active = true

func get_priority(_uid:int)->float:
	if not active: return 0.0
	return priority
func act(uid:int)->void:
	_latency -= REG.DELTA
	if _latency > 0.0:
		return
	_latency = WANDER_INTERVAL
	
	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return
	
	var destination:Vector2 = _pick_destination(mov.position, MOV_SYS)
	REG.ACT.move(uid, destination)
## Returns a random unblocked grid position within [constant WANDER_RADIUS] tiles.
func _pick_destination(origin: Vector2, mov_sys: MovementSystem) -> Vector2:
	var attempts: int = 8

	while attempts > 0:
		var dx: int = randi_range(-WANDER_RADIUS, WANDER_RADIUS) * REG.SCALE
		var dy: int = randi_range(-WANDER_RADIUS, WANDER_RADIUS) * REG.SCALE
		var candidate: Vector2 = origin + Vector2(dx, dy)

		# Keep within world bounds
		candidate = candidate.clamp(
			Vector2.ZERO,
			Vector2(REG.WIDTH -1, REG.HEIGHT -1) * REG.SCALE
		)

		var grid_candidate:Vector2i = Vector2i(candidate.snapped(Vector2(REG.SCALE, REG.SCALE)))
		if not mov_sys or not mov_sys.blocked_positions.has(grid_candidate):
			return candidate

		attempts -= 1

	return origin
