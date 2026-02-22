@tool
class_name SeekFoodBehavior
extends BaseBehavior

enum SearchState {
	START,			## Not searching
	LOOK_FIRST,		## First look in current direction
	WAIT_FIRST,		## Waiting after first look
	TURN,			## Turning around
	LOOK_SECOND,	## Second look in opposite direction
	WAIT_SECOND,	## Waiting after second look
	USE_MEMORY,		## Fall back to last known position
	WANDER_SEARCH   ## If no item is found either in the new or the older memory entries
	}

var _state:SearchState = SearchState.START

const EAT_RADIUS:float = 4.0
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
	if hunger_ratio < 0.5:
		priority = lerp(0.21, 0.9, 1.0 - hunger_ratio / 0.6)
	else:
		priority = 0.0
## Called every BehaviorSystem tick while this behavior is selected.
## Moves toward the nearest known food, eats it on arrival.
func act(uid:int)->void:
	var mem:MemoryComponent = REG.get_component(uid, BaseComponent.Flag.MEMORY)
	if not mem: return

	if not _is_valid_target(_target_uid):
		_target_uid = _nearest_food_uid(uid, mem)

	if _target_uid == -1:
		_do_search(uid)
		return

	_state = SearchState.START  ## Reset search when target is found

	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov: return

	var food_pos:Vector2 = _food_position(_target_uid, mem)
	if mov.position.distance_to(food_pos) <= EAT_RADIUS:
		REG.ACT.eat(uid, _target_uid)
		_target_uid = -1
		return

	if mov.movable and not mov.movable.has_target:
		REG.ACT.move(uid, food_pos)
## Clears the cached target so this entity looks for a new one next tick.
func _do_search(uid:int)->void:
	match _state:
		SearchState.START:
			_state = SearchState.LOOK_FIRST
		
		SearchState.LOOK_FIRST:
			var found:Array[int] = REG.ACT.look(uid)
			REG.ACT.wait(uid, 1.0)
			_state = SearchState.WAIT_FIRST if found.is_empty() else SearchState.START
		
		SearchState.WAIT_FIRST:
			if not REG.ACT.is_waiting(uid):
				_target_uid = _nearest_food_uid(uid, REG.get_component(uid, BaseComponent.Flag.MEMORY))
				_state = SearchState.TURN if _target_uid == -1 else SearchState.START
		
		SearchState.TURN:
			REG.ACT.turn_around(uid)
			_state = SearchState.LOOK_SECOND
			
		SearchState.LOOK_SECOND:
			REG.ACT.look(uid)
			REG.ACT.wait(uid, 2.0)
			_state = SearchState.WAIT_SECOND
		
		SearchState.WAIT_SECOND:
			if not REG.ACT.is_waiting(uid):
				_target_uid = _nearest_food_uid(uid, REG.get_component(uid, BaseComponent.Flag.MEMORY))
				_state = SearchState.USE_MEMORY if (_target_uid == -1) else SearchState.START
		
		SearchState.USE_MEMORY:
			_target_uid = _nearest_food_uid(uid, REG.get_component(uid, BaseComponent.Flag.MEMORY))
			if _target_uid != -1:
				_state = SearchState.START
				return
			_state = SearchState.WANDER_SEARCH
			
		SearchState.WANDER_SEARCH:
			if REG.ACT.is_waiting(uid): return
			var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
			if not mov: return
			if mov.movable and mov.movable.has_target: return  ## Still walking there
			## Picked a destination and arrived — restart the search cycle
			REG.ACT.move(uid, _random_nearby(mov.position))
			REG.ACT.wait(uid, 2.0)
			_state = SearchState.START
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
	return -Vector2.ONE

## Returns true if [param food_uid] still refers to a living item entity.
func _is_valid_target(food_uid:int)->bool:
	if food_uid == -1: return false
	return REG.IT_REG.get_item(food_uid) != null
## Picks a random world position within a short radius to resume searching.
func _random_nearby(origin:Vector2)->Vector2:
	var RADIUS:int = REG.DATA.ACTIONS.SEEK_WANDER
	var scale:int = REG.SCALE
	var dx:int = randi_range(-RADIUS, RADIUS) * scale
	var dy:int = randi_range(-RADIUS, RADIUS) * scale
	return (origin + Vector2(dx, dy)).clamp(
		Vector2.ZERO,
		Vector2(REG.WIDTH, REG.HEIGHT) * scale
	)
