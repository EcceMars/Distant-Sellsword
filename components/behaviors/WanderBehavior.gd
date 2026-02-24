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
	
	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return
	
	var destination:Vector2 = REG.ACT.wander_about(mov.position, WANDER_RADIUS)
	REG.ACT.move(uid, destination)
## Returns a random unblocked grid position within [constant WANDER_RADIUS] tiles.
