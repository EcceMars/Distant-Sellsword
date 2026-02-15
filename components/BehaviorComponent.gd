class_name BehaviorComponent
extends BaseComponent

## Current active behavior
var active_behavior:Behavior = null
## List of all behaviors
var behaviors:Array[Behavior] = []

func _init(_behavior_keys:Array = [])->void:
	behaviors = [
		FleeBehavior.new(),
		IdleBehavior.new(),
		RestBehavior.new(),
		SeekFoodBehavior.new(),
		WanderBehaviour.new()
	]
	active_behavior = behaviors[1]
	flag = Flag.BEHAVIOR
func check_behavior(uid:int, REG:REGISTRY)->String:
	if not REG.get_component(uid, Flag.BEHAVIOR): return str(uid, " is mindless...")
	var status:String = "%d" % uid
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
	const MOV_FLAG:BaseComponent.Flag = BaseComponent.Flag.MOVEMENT
	const STATS_FLAG:BaseComponent.Flag = BaseComponent.Flag.STATS
	var name:String = "NONE"
	## Value to calculate inside [func priority]. It is always greater than 0
	var threshold:float = 1e-10:
		set(value):
			if value <= 0:
				return
			threshold = value
	## Evaluates the behavior priority
	func priority(_uid:int, _REG:REGISTRY)->float: return 0.0
	## Executes behavior
	func act(_uid:int, _REG:REGISTRY)->void: pass
	func _to_string()->String: return name
## Flees when [health.blood] is crittical
## TODO: Should flee from equal or stronger entities (this has to wait for a [StatsComponent] and [StatSystem] implementation)
class FleeBehavior extends Behavior:
	func _init(_threshold:float = 0.3)->void:
		name = "FLEE"
		threshold = _threshold
		while not threshold: threshold += 1e-10
	func priority(uid:int, REG:REGISTRY)->float:
		var stat:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if not stat or not stat.is_alive or not stat.is_conscious: return 0.0
		
		var blood_ratio:float = stat.blood.ratio()
		if blood_ratio < threshold:
			return 1.0 - (blood_ratio / threshold)
		return 0.0
	func act(uid:int, REG:REGISTRY)->void:
		var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not movement or not movement.movable: return
		
		var world_end:Vector2 = Vector2(REG.WIDTH, REG.HEIGHT)
		var flee_to_edge:Vector2 = [
			Vector2(0, randf_range(0, world_end.y)),
			Vector2(world_end.x, randf_range(0, world_end.y)),
			Vector2(randf_range(0, world_end.x), 0),
			Vector2(randf_range(0, world_end.x), world_end.y)
			].pick_random()
		var mov_sys:MovementSystem = REG.get_system(MovementSystem)
		mov_sys.force_move(uid, flee_to_edge, REG)
class RestBehavior extends Behavior:
	var regen_boost:float = 0.01
	
	func _init(_threshold:float = 0.2)->void:
		name = "REST"
		threshold = _threshold
	func priority(uid:int, REG:REGISTRY)->float:
		var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if not stats or not stats.is_conscious:
			return 1.0
		var energy_ratio:float = stats.energy.ratio()
		if energy_ratio < threshold:
			return 0.8 - (energy_ratio / threshold) * 0.3
		return 0.0
	func act(uid:int, REG:REGISTRY)->void:
		var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
		var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if movement.movable:
			movement.movable.clear()
		if stats:
			stats.energy.regen_factor += regen_boost
## TODO: As there is no resource/gather system/component for now, this serves only as a stub
class SeekFoodBehavior extends Behavior:
	func _init(_threshold:float = 0.3)->void:
		name = "SEEK_FOOD"
	func priority(uid:int, REG:REGISTRY)->float:
		var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if not stats or not stats.is_alive or not stats.is_conscious:
			return 0.0
		var hunger_ratio:float = stats.hunger.ratio()
		if hunger_ratio < threshold:
			return 0.6 - (hunger_ratio / threshold) * 0.2
		return 0.0
	func act(uid:int, REG:REGISTRY)->void:
		var mov_sys:MovementSystem = REG.get_system(MovementSystem)
		if not mov_sys: return
		var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not movement or not movement.movable:
			return
		
		var world_center:Vector2 = Vector2(REG.WIDTH, REG.HEIGHT) * 0.5
		var around_center:Vector2 = world_center.lerp(movement.position, 0.8)
		mov_sys.force_move(uid, around_center, REG)
## Wanders about, using speed as range
class WanderBehaviour extends Behavior:
	var last_time_at:int = 0
	var interval:int = 60
	
	func _init()->void:
		name = "WANDER"
		last_time_at = randi() % interval
	func priority(uid:int, REG:REGISTRY)->float:
		var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if not stats or not stats.is_alive or not stats.is_conscious:
			return 0.0
		return 0.2
	
	func act(uid:int, REG:REGISTRY)->void:
		var mov_sys:MovementSystem = REG.get_system(MovementSystem)
		if not mov_sys: return
		var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not movement or not movement.movable: return
		
		if movement.movable.path.size() > 4: return
		last_time_at += 1
		if last_time_at < interval: return
		
		last_time_at = 0
		interval = randi_range(30, 120)
		
		var distance:float = movement.movable.speed * randi_range(30, 60)
		var rand_angle:float = randf() * TAU
		var offset:Vector2 = Vector2(cos(rand_angle), sin(rand_angle)) * distance
		var target:Vector2 = movement.position + offset
		target = target.clamp(Vector2.ZERO, Vector2(REG.WIDTH, REG.HEIGHT))
		mov_sys.queue_move(uid, target, REG)
## Fallback behavior
class IdleBehavior extends Behavior:
	func _init()->void:
		name = "IDLE"
	func priority(_uid:int, _REG:REGISTRY)->float:
		return 0.1
	func act(_uid:int, _REG:REGISTRY)->void: pass
