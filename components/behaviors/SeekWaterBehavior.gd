## Drives an entity toward the nearest water tile to recover thirst.
## Activates when thirst drops below a threshold, outbidding [WanderBehavior].
@tool
class_name SeekWaterBehavior
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

## World position of the current water target. Zero means unresolved.
var _water_pos:Vector2 = Vector2.ZERO

const DRINK_RADIUS:float = 24.0 ## So an GROUND entity may drink diagonally
const THIRST_THRESHOLD:float = 0.5
const DRINK_AMOUNT:float = 40.0
const DRINK_DURATION:float = 1.5

func _init()->void:
	behavior_name = "SeekWater"
	type = Type.SEEK_WATER
	priority = 0.0
	active = true

## Raises priority when thirst drops below [constant THIRST_THRESHOLD].
## Outbids [SeekFoodBehavior] slightly — thirst is more urgent than hunger.
func activate(uid:int)->void:
	var stats:StatsComponent = REG.get_component(uid, BaseComponent.Flag.STATS)
	if not stats or not stats.thirst:
		priority = 0.0
		return
	var ratio:float = stats.thirst.ratio()
	if ratio < THIRST_THRESHOLD:
		priority = lerp(0.22, 0.95, 1.0 - ratio / THIRST_THRESHOLD)
	else:
		priority = 0.0

func get_priority(_uid:int)->float:
	if not active: return 0.0
	return priority

## Moves toward the nearest water tile and drinks on arrival.
func act(uid:int)->void:
	if REG.ACT.is_waiting(uid): return

	var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
	if not mov: return

	## Resolve water position once, or re-resolve if it landed on a non-water tile.
	if _water_pos == -Vector2.ONE or not REG.TE_REG.is_water(_water_pos):
		_water_pos = REG.TE_REG.nearest_water(mov.position)

	if _water_pos == -Vector2.ONE:
		_do_search(uid)

	if mov.position.distance_to(_water_pos) <= DRINK_RADIUS:
		REG.ACT.drink(uid)
		return
	
	if mov.movable and not mov.movable.has_target:
		REG.ACT.move_closer(uid, _water_pos)

## Clears the cached target so this entity looks for a new one next tick.
func _do_search(uid:int)->void:
	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	_water_pos = -Vector2.ONE
	match _state:
		SearchState.START:
			_state = SearchState.LOOK_FIRST
		
		SearchState.LOOK_FIRST:
			var further_on:Vector2 = mov.position + ((Vector2.ONE * REG.SCALE * 2) * (-1 if mov.movable and not mov.movable.faces_right else 1))
			_water_pos = REG.TE_REG.nearest_water(further_on)
			REG.ACT.wait(uid, 1.0)
			_state = SearchState.WAIT_FIRST if _water_pos == -Vector2.ONE else SearchState.START
		
		SearchState.WAIT_FIRST:
			if not REG.ACT.is_waiting(uid):
				_water_pos = REG.TE_REG.nearest_water(mov.position)
				_state = SearchState.TURN if _water_pos == -Vector2.ONE else SearchState.START
		
		SearchState.TURN:
			REG.ACT.turn_around(uid)
			_state = SearchState.LOOK_SECOND
			
		SearchState.LOOK_SECOND:
			var further_on:Vector2 = mov.position + ((Vector2.ONE * REG.SCALE * 2) * (-1 if mov.movable and not mov.movable.faces_right else 1))
			_water_pos = REG.TE_REG.nearest_water(further_on)
			REG.ACT.wait(uid, 2.0)
			_state = SearchState.WAIT_SECOND
		
		SearchState.WAIT_SECOND:
			if not REG.ACT.is_waiting(uid):
				_water_pos = REG.TE_REG.nearest_water(mov.position)
				_state = SearchState.USE_MEMORY if (_water_pos == -Vector2.ONE) else SearchState.START
		
		SearchState.USE_MEMORY:
			# Not implemented
			#_target_uid = REG.TE_REG.nearest_water(mov.position)
			#if _target_uid != -1:
				#_state = SearchState.START
				#return
			_state = SearchState.WANDER_SEARCH
			
		SearchState.WANDER_SEARCH:
			if REG.ACT.is_waiting(uid): return
			
			if not mov: return
			if mov.movable and mov.movable.has_target: return  ## Still walking there
			## Picked a destination and arrived — restart the search cycle
			REG.ACT.move(uid, _random_nearby(mov.position))
			REG.ACT.wait(uid, 2.0)
			_state = SearchState.START
func on_enter()->void:
	_water_pos = Vector2.ZERO

func on_exit()->void:
	_water_pos = Vector2.ZERO
## Picks a random world position within a short radius to resume searching.
func _random_nearby(origin:Vector2)->Vector2:
	const RADIUS:int = 4
	var scale:int = REG.SCALE
	var dx:int = randi_range(-RADIUS, RADIUS) * scale
	var dy:int = randi_range(-RADIUS, RADIUS) * scale
	return (origin + Vector2(dx, dy)).clamp(
		Vector2.ZERO,
		Vector2(REG.WIDTH, REG.HEIGHT) * scale
	)
