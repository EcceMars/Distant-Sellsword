class_name BehaviorComponent
extends BaseComponent

enum State { IDLE, WANDER, FLEE, REST, SEEK_FOOD }
var current:State = State.IDLE
var dying:float = 0.3
var hungry:float = 0.3
var tired:float = 0.2

## Base subclass for all behaviors
class Behavior:
	var name:String = "NONE"
	## Evaluates the behavior priority
	func priority(_entity:Entity)->float: return 0.0
	## Executes behavior
	func act(_entity:Entity, _world:ECS_MANAGER)->void: pass
	func _to_string()->String: return name
## Flees when health.blood is crittical
class FleeBehavior extends Behavior:
	var threshold:float = 0.3
	func _init(_threshold:float = threshold)->void:
		name = "FLEE"
		threshold = _threshold
		while not threshold: threshold += 1e-10
	func priority(entity:Entity)->float:
		var health:HealthComponent = entity.get_component(HealthComponent)
		if not health or not health.is_alive or not health.is_conscious: return 0.0
		
		var blood_ratio:float = health.blood.ratio()
		if blood_ratio < threshold:
			return 1.0 - (blood_ratio / threshold)
		return 0.0
	func act(entity:Entity, world:ECS_MANAGER)->void:
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if not movement or not movement.movable: return
		
		print("%d flees!" % entity.uid)
		
		
