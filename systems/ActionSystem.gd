## Manager of all actions between behaviors, systems, registries and component needed.
## A reference to it may be found in [member REG.ACT]
class_name ActionSystem
extends BaseSystem

## Wait timer associated to entities.
## If an action must override the wait time, it just needs to reuse the position at uid.
var _wait_timers:Dictionary[int, float] = {}

## World position of the current water target. Zero means unresolved.
var _water_pos:Vector2 = -Vector2.ONE

# TODO! Move these to the item description
## How much energy is restored on eating.
const EAT_ENERGY:float = 30.0
## How much hunger is restored on eating.
const EAT_HUNGER:float = 40.0
## How much thirst is restored on eating.
const EAT_THIRST:float = 10.0

const DRINK_AMOUNT:float = 40.0
const DRINK_DURATION:float = 1.5

func process()->void:
	for uid:int in _wait_timers.keys():
		_wait_timers[uid] -= REG.DELTA
		if _wait_timers[uid] <= 0.0:
			_wait_timers.erase(uid)

## Prevents the entity from issuing new move commands for [param duration] seconds.
func wait(uid:int, duration:float = 1.0)->void:
	_wait_timers[uid] = duration
## Returns true if [param uid] is currently in a wait state.
func is_waiting(uid:int)->bool:
	return _wait_timers.has(uid)
## Requests the entity to move to [param target]
func move(uid:int, target:Vector2)->bool:
	if is_waiting(uid): return false

	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if not mov or not mov.movable: return false

	if not REG.TE_REG.can_spawn(target, mov.movable.mov_type):
		return false

	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	if not MOV_SYS: return false
	
	return MOV_SYS.add_move(uid, target)
func move_closer(uid:int, target:Vector2)->bool:
	if is_waiting(uid): return false
	
	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if not mov or not mov.movable: return false
	
	var origin:Vector2 = mov.position
	var distance:float = origin.distance_to(target)
	if distance < REG.SCALE: return false
	
	var direction:Vector2 = (target - origin).normalized()
	var steps:int = int(distance / REG.SCALE)
	var last_valid:Vector2 = origin
	
	for i:int in range(1, steps + 1):
		var candidate:Vector2 = origin + direction * (i * REG.SCALE)
		if not REG.TE_REG.can_spawn(candidate, mov.movable.mov_type):
			break
		last_valid = candidate
	
	if last_valid == origin: return false
	
	return move(uid, last_valid)
## Scans the entity's vision triangle and updates its [MemoryComponent].
func look(uid:int)->Array[int]:
	if is_waiting(uid): return []
	var mem:MemoryComponent = REG.get_component(uid, MEM_FLAG)
	if not mem:
		return []

	var found:Array[int] = mem.look(uid, REG.tick)
	return found
## Flips the entity's horizontal facing direction.
func turn_around(uid:int)->void:
	if is_waiting(uid): return
	
	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if not mov or not mov.movable: return
	
	mov.movable.faces_right = !mov.movable.faces_right
## Consumes [param food_uid] for [param eater_uid].
## Recovers stats, cleans memory, triggers visual effects and queues destruction.
func eat(eater_uid:int, food_uid:int)->void:
	if is_waiting(eater_uid): return

	## Data first — registry and stats
	REG.IT_REG.unregister_item(food_uid)

	var stats:StatsComponent = REG.get_component(eater_uid, BaseComponent.Flag.STATS)
	if stats:
		if stats.energy: stats.energy.recover(EAT_ENERGY)
		if stats.hunger: stats.hunger.recover(EAT_HUNGER)
		if stats.thirst: stats.thirst.recover(EAT_THIRST)

	var mem:MemoryComponent = REG.get_component(eater_uid, BaseComponent.Flag.MEMORY)
	if mem: mem.forget(food_uid)

	## Visual last — cosmetic only, entity is already logically gone
	var food_vis:VisualComponent = REG.get_component(food_uid, REG.C_FLAGS.VISUAL)
	if food_vis: _consume_food(food_vis)
## Recovers thirst and issues a wait to simulate drinking time.
func drink(uid:int)->void:
	var stats:StatsComponent = REG.get_component(uid, BaseComponent.Flag.STATS)
	if not stats or not stats.thirst: return
	
	stats.thirst.recover(DRINK_AMOUNT)
	REG.ACT.wait(uid, DRINK_DURATION)
	_water_pos = -Vector2.ONE  ## Clear so it re-evaluates next time
## Internal helper for visual consumption of food.
func _consume_food(food_vis:VisualComponent)->void:
	var ANI_SYS:AnimationSystem = REG.SYSTEMS.get("AnimationSystem")
	if ANI_SYS:
		ANI_SYS.shake_sprite(food_vis.sprite)
		ANI_SYS.burst_particles(food_vis.sprite)

	food_vis.destroy_time = 0.5
	food_vis.queue_destroy = true
## Request the entity to die
func die(uid:int)->void:
	var vis:VisualComponent = REG.get_component(uid, REG.C_FLAGS.VISUAL)
	if vis:
		var ANI_SYS:AnimationSystem = REG.SYSTEMS.get("AnimationSystem")
		if ANI_SYS:
			ANI_SYS.play_death(vis.sprite)
		vis.queue_destroy = true
		vis.destroy_time = 3.0  ## Let VisualSystem handle the fade and cleanup
		return
	REG.destroy_entity(uid)
