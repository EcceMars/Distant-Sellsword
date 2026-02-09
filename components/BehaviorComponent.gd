class_name BehaviorComponent
extends BaseComponent

## Current active behavior
var active_behavior:Behavior = null
## List of all behaviors
var behaviors:Array[Behavior] = []

func _init()->void:
	behaviors = [
		FleeBehavior.new(),
		IdleBehavior.new(),
		RestBehavior.new(),
		SeekFoodBehavior.new(),
		WanderBehaviour.new()
	]
	active_behavior = behaviors[1]
func check_behavior(entity:Entity)->String:
	if not entity.get_component(BehaviorComponent): return str(entity.uid, " is mindless...")
	var status:String = "%d" % entity.uid
	match active_behavior.get_script():
		FleeBehavior:
			status += " flees!"
		IdleBehavior:
			status += " idles about..."
		RestBehavior:
			status += " is sound asleep..."
		SeekFoodBehavior:
			status += " hungers..."
		WanderBehaviour:
			status += " wanders about..."
	return status
## Base subclass for all behaviors
class Behavior:
	var name:String = "NONE"
	## Value to calculate inside [func priority]. It is always greater than 0
	var threshold:float = 1e-10:
		set(value):
			if value <= 0:
				return
			threshold = value
	## Evaluates the behavior priority
	func priority(_entity:Entity)->float: return 0.0
	## Executes behavior
	func act(_entity:Entity, _world:ECS_MANAGER)->void: pass
	func _to_string()->String: return name
## Flees when [health.blood] is crittical
## TODO: Should flee from equal or stronger entities (this has to wait for a [StatComponent] and [StatSystem] implementation)
class FleeBehavior extends Behavior:
	func _init(_threshold:float = 0.3)->void:
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
		
		var world_end:Vector2 = Vector2(world.WIDTH, world.HEIGHT)
		var flee_to_edge:Vector2 = [
			Vector2(0, randf_range(0, world_end.y)),
			Vector2(world_end.x, randf_range(0, world_end.y)),
			Vector2(randf_range(0, world_end.x), 0),
			Vector2(randf_range(0, world_end.x), world_end.y)
			].pick_random()
		var mov_sys:MovementSystem = world.get_system(MovementSystem)
		mov_sys.force_move(entity, flee_to_edge)
class RestBehavior extends Behavior:
	var regen_boost:float = 0.01
	
	func _init(_threshold:float = 0.2)->void:
		name = "REST"
		threshold = _threshold
	func priority(entity:Entity)->float:
		var health:HealthComponent = entity.get_component(HealthComponent)
		if not health or not health.is_conscious:
			return 1.0
		var energy_ratio:float = health.energy.ratio()
		if energy_ratio < threshold:
			return 0.8 - (energy_ratio / threshold) * 0.3
		return 0.0
	func act(entity:Entity, _world:ECS_MANAGER)->void:
		var movement:MovementComponent = entity.get_component(MovementComponent)
		var health:HealthComponent = entity.get_component(HealthComponent)
		if movement:
			movement.clear_path()
		if health:
			health.is_conscious = false
			health.energy.regen_factor += regen_boost
## TODO: As there is no resource/gather system/component for now, this serves only as a stub
class SeekFoodBehavior extends Behavior:
	func _init(_threshold:float = 0.3)->void:
		name = "SEEK_FOOD"
	func priority(entity:Entity)->float:
		var health:HealthComponent = entity.get_component(HealthComponent)
		if not health or not health.is_alive or not health.is_conscious:
			return 0.0
		var hunger_ratio:float = health.hunger.ratio()
		if hunger_ratio < threshold:
			return 0.6 - (hunger_ratio / threshold) * 0.2
		return 0.0
	func act(entity:Entity, world:ECS_MANAGER)->void:
		var mov_sys:MovementSystem = world.get_system(MovementSystem)
		if not mov_sys: return
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if not movement or not movement.movable:
			return
		
		var world_center:Vector2 = Vector2(world.WIDTH, world.HEIGHT) * 0.5
		var around_center:Vector2 = world_center.lerp(movement.position, 0.8)
		mov_sys.force_move(entity, around_center)
## Wanders about, using speed as range
class WanderBehaviour extends Behavior:
	var last_time_at:int = 0
	var interval:int = 60
	
	func _init()->void:
		name = "WANDER"
		last_time_at = randi() % interval
	func priority(entity:Entity)->float:
		var health:HealthComponent = entity.get_component(HealthComponent)
		if not health or not health.is_alive or not health.is_conscious:
			return 0.0
		return 0.2
	
	func act(entity:Entity, world:ECS_MANAGER)->void:
		var mov_sys:MovementSystem = world.get_system(MovementSystem)
		if not mov_sys: return
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if not movement or not movement.movable: return
		
		if movement.movable.target.size() > 4: return
		last_time_at += 1
		if last_time_at < interval: return
		
		last_time_at = 0
		interval = randi_range(30, 120)
		
		var distance:float = movement.movable.speed * randi_range(30, 60)
		var rand_angle:float = randf() * TAU
		var offset:Vector2 = Vector2(cos(rand_angle), sin(rand_angle)) * distance
		var target:Vector2 = movement.position + offset
		target = target.clamp(Vector2.ZERO, Vector2(world.WIDTH, world.HEIGHT))
		mov_sys.queue_move(entity, target)
## Fallback behavior
class IdleBehavior extends Behavior:
	func _init()->void:
		name = "IDLE"
	func priority(_entity:Entity)->float:
		return 0.1
	func act(entity:Entity, _world:ECS_MANAGER)->void:
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if movement:
			pass
