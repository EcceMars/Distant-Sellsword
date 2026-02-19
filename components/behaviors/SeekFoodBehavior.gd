@tool
class_name SeekFoodBehavior
extends BaseBehavior

const EAT_RADIUS:float = 4.0
## How much energy is restored on eating.
const EAT_ENERGY:float = 30.0
## How much hunger is restored on eating.
const EAT_HUNGER:float = 40.0
## How much thirst is restored on eating.
const EAT_THIRST:float = 10.0

const LOOK_AROUND_INTERVAL:float = 0.5
var look_latency:float = 0.0

## UID of the food item currently being pursued. -1 means none.
var _target_uid:int = -1

func _init()->void:
	behavior_name = "SeekFood"
	type = Type.SEEK_FOOD
	priority = 0.0			# Computed dynamically in get_priority()
	active = true
## Raises priority when the entity is hungry; returns 0 when inactive or well-fed.
## Outbids [WanderBehavior] (0.3) once hunger drops below 30 %.
func get_priority(_uid:int)->float:
	if not active:
		return 0.0
	#var stats:StatsComponent = REG.get_component(uid, REG.C_FLAGS.STATS)
	#if not stats or not stats.hunger: return 0.0
	#priority = 1.0 - stats.hunger.ratio()
	
	return priority
## Called by BehaviorSystem before _select_behavior to let the behavior
## inspect its own entity and set a meaningful priority.
## [param uid] Owner entity UID.
func activate(uid:int)->void:
	var stats:StatsComponent = REG.get_component(uid, BaseComponent.Flag.STATS)
	if not stats:
		priority = 0.0
		return

	var hunger_ratio:float = stats.hunger.ratio()
	if hunger_ratio < 0.2:
		priority = lerp(0.21, 0.9, 1.0 - hunger_ratio / 0.6)
	else:
		priority = 0.0
## Called every BehaviorSystem tick while this behavior is selected.
## Moves toward the nearest known food, eats it on arrival.
func act(uid:int)->void:
	activate(uid)		# Keep priority fresh each tick
	_tire(uid)
	var mem:MemoryComponent = REG.get_component(uid, BaseComponent.Flag.MEMORY)
	if not mem:
		return
	
	# Validate or refresh target
	if not _is_valid_target(_target_uid):
		_target_uid = _nearest_food_uid(uid, mem)
	
	if _target_uid == -1:
		if not REG.ACT.look(uid):
			REG.ACT.turn_around(uid)
			REG.ACT.look(uid)
		#return		# No food visible; stay put until memory updates
		_target_uid = _nearest_food_uid(uid, mem)

	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return

	var food_pos:Vector2 = _food_position(_target_uid, mem)
	var distance:float   = mov.position.distance_to(food_pos)

	if distance <= EAT_RADIUS:
		_eat(uid, _target_uid)
		_target_uid = -1
		return

	# Issue movement only when not already heading there
	if mov.movable and not mov.movable.has_target:
		REG.ACT.move(uid, food_pos)
## Clears the cached target so this entity looks for a new one next tick.
func on_exit() -> void:
	_target_uid = -1
## Returns the UID of the closest FOOD memory entry, or -1 if none exist.
func _nearest_food_uid(uid:int, mem:MemoryComponent) -> int:
	var food_entries:Array[MemoryComponent.MemoryEntry] = \
		mem.get_by_relation(MemoryComponent.Relation.FOOD)

	if food_entries.is_empty():
		return -1

	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return food_entries[0].uid

	var best_uid:int = -1
	var best_dist:float = INF

	for entry:MemoryComponent.MemoryEntry in food_entries:
		if not _is_valid_target(entry.uid):
			continue
		var dist:float = mov.position.distance_to(entry.last_position)
		if dist < best_dist:
			best_dist = dist
			best_uid = entry.uid

	return best_uid
## Returns the best known world position for [param food_uid]:
## the live entity position if available, otherwise the last-seen memory position.
func _food_position(food_uid:int, mem:MemoryComponent) -> Vector2:
	var live_pos: Vector2 = REG.get_ent_position(food_uid)
	if live_pos != -Vector2.ONE:
		return live_pos
	var entry: MemoryComponent.MemoryEntry = mem.entries.get(food_uid)
	if entry:
		return entry.last_position
	return Vector2.ZERO

## Returns true if [param food_uid] still refers to a living item entity.
func _is_valid_target(food_uid:int)->bool:
	if food_uid == -1:
		return false
	var item:ItemComponent = REG.get_component(food_uid, BaseComponent.Flag.ITEM)
	return item != null

## Restores stats and destroys the food entity.
func _eat(eater_uid:int, food_uid:int) -> void:
	var stats:StatsComponent = REG.get_component(eater_uid, BaseComponent.Flag.STATS)
	if stats:
		if stats.energy: stats.energy.recover(EAT_ENERGY)
		if stats.hunger: stats.hunger.recover(EAT_HUNGER)
		if stats.thirst: stats.thirst.recover(EAT_THIRST)
	# Forget the entry so memory stays consistent
	var mem:MemoryComponent = REG.get_component(eater_uid, BaseComponent.Flag.MEMORY)
	if mem:
		mem.forget(food_uid)
	var food_vis:VisualComponent = REG.get_component(food_uid, REG.C_FLAGS.VISUAL)
	if food_vis:
		var ANI_SYS:AnimationSystem = REG.SYSTEMS.get("AnimationSystem")
		if ANI_SYS:
			_consume_food(food_vis, ANI_SYS)
func _consume_food(food_vis:VisualComponent, ANI_SYS:AnimationSystem)->void:
	ANI_SYS._shake_sprite(food_vis.sprite)
	ANI_SYS.burst_particles(food_vis.sprite)
	
	food_vis.destroy_time = 0.5
	food_vis.queue_destroy = true
