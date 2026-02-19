## Drives an entity toward the nearest water tile to recover thirst.
## Activates when thirst drops below a threshold, outbidding [WanderBehavior].
@tool
class_name SeekWaterBehavior
extends BaseBehavior

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
	if _water_pos == Vector2.ZERO or not REG.TE_REG.is_water(_water_pos):
		_water_pos = REG.TE_REG.nearest_water(mov.position)

	if _water_pos == Vector2.ZERO: return  ## No water found in world

	if mov.position.distance_to(_water_pos) <= DRINK_RADIUS:
		REG.ACT.drink(uid)
		return
	
	if mov.movable and not mov.movable.has_target:
		REG.ACT.move_closer(uid, _water_pos)

func on_enter()->void:
	_water_pos = Vector2.ZERO

func on_exit()->void:
	_water_pos = Vector2.ZERO
