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

## UID of the food item currently being pursued. -1 means none.
var _target_uid:int = -1

func _init()->void:
	behavior_name = "SeekFood"
	type = Type.SEEK_FOOD
	priority = 0.0			# Computed dynamically in get_priority()
## Raises priority when the entity is hungry; returns 0 when inactive or well-fed.
## Outbids [WanderBehavior] (0.2) once hunger drops below 60 %.
func get_priority() -> float:
	if not active:
		return 0.0

	# We need a uid to inspect — BehaviorSystem passes none here, so we scan.
	# Priority is computed entity-agnostically: caller is expected to have called
	# activate(uid) before the selection round. See [method activate].
	return priority
## Called by BehaviorSystem before _select_behavior to let the behavior
## inspect its own entity and set a meaningful priority.
## [param uid] Owner entity UID.
func activate(uid:int)->void:
	var stats:StatsComponent = REG.get_component(uid, BaseComponent.Flag.STATS)
	if not stats:
		priority = 0.0
		return

	# Hunger ratio: 1.0 = full, 0.0 = starving.
	# Kick in below 60 %, outbid Wander (0.2) below 40 %.
	var hunger_ratio:float = stats.hunger.ratio()
	if hunger_ratio < 0.6:
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
		return		# No food visible; stay put until memory updates

	var mov: MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return

	var food_pos: Vector2 = _food_position(_target_uid, mem)
	var distance: float   = mov.position.distance_to(food_pos)

	if distance <= EAT_RADIUS:
		_eat(uid, _target_uid)
		_target_uid = -1
		return

	# Issue movement only when not already heading there
	if mov.movable and not mov.movable.has_target:
		var mov_sys: MovementSystem = REG.SYSTEMS.get("MovementSystem")
		if mov_sys:
			mov_sys.add_move(uid, food_pos)

## Clears the cached target so this entity looks for a new one next tick.
func on_exit() -> void:
	_target_uid = -1
## Returns the UID of the closest FOOD memory entry, or -1 if none exist.
func _nearest_food_uid(uid: int, mem: MemoryComponent) -> int:
	var food_entries: Array[MemoryComponent.MemoryEntry] = \
		mem.get_by_relation(MemoryComponent.Relation.FOOD)
	if food_entries.is_empty():
		return -1

	var mov: MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return food_entries[0].uid

	var best_uid: int    = -1
	var best_dist: float = INF

	for entry: MemoryComponent.MemoryEntry in food_entries:
		if not _is_valid_target(entry.uid):
			continue
		var dist: float = mov.position.distance_to(entry.last_position)
		if dist < best_dist:
			best_dist = dist
			best_uid  = entry.uid

	return best_uid

## Returns the best known world position for [param food_uid]:
## the live entity position if available, otherwise the last-seen memory position.
func _food_position(food_uid: int, mem: MemoryComponent) -> Vector2:
	var live_pos: Vector2 = REG.get_ent_position(food_uid)
	if live_pos != -Vector2.ONE:
		return live_pos
	var entry: MemoryComponent.MemoryEntry = mem.entries.get(food_uid)
	if entry:
		return entry.last_position
	return Vector2.ZERO

## Returns true if [param food_uid] still refers to a living item entity.
func _is_valid_target(food_uid: int) -> bool:
	if food_uid == -1:
		return false
	return REG.has_components(food_uid, BaseComponent.Flag.ITEM)

## Restores stats and destroys the food entity.
func _eat(eater_uid:int, food_uid:int) -> void:
	var stats: StatsComponent = REG.get_component(eater_uid, BaseComponent.Flag.STATS)
	if stats:
		if stats.energy: stats.energy.recover(EAT_ENERGY)
		if stats.hunger: stats.hunger.recover(EAT_HUNGER)
		if stats.thirst: stats.thirst.recover(EAT_THIRST)
	# Forget the entry so memory stays consistent
	var mem: MemoryComponent = REG.get_component(eater_uid, BaseComponent.Flag.MEMORY)
	if mem:
		mem.forget(food_uid)

	REG.destroy_entity(food_uid)
	print(food_uid, " is being consumed...")
