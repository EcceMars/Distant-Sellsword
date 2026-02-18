## Stores what an entity has perceived and remembers about the world.
## Updated by [BehaviorSystem] at a frequency determined by the active behavior.
## Entries are evicted by age (lowest [member MemoryEntry.last_tick]) when
## [member focus_limit] is reached.
class_name MemoryComponent
extends BaseComponent

## Relation an entity holds toward another uid or item.
enum Relation {
	NEUTRAL,	## Default — perceived but not yet classified
	FRIEND,		## Ally; will not flee from, may assist
	ENEMY,		## Threat; triggers flee or combat
	FOOD,		## Consumable item or prey
	THREAT		## Environmental hazard (reserved for later)
	}

## All currently remembered entities, keyed by their uid.
var entries:Dictionary[int, MemoryEntry] = {}
var focus_limit:int = 8

# Vision parameters
var vision_range:float = 5.0 * REG.SCALE		## How far it sees
var vision_width:float = 2.0 * REG.SCALE		## How wide it sees
var vision_back_ratio:float = 0.2				## Small offset back

## [member REG.tick] value of the last perception update for this entity.
var last_update_tick:int = 0
## How many ticks between perception updates.
## Set by [BehaviorSystem] based on the active behavior.
var update_interval:int = 10

func _init(
	_focus_limit:int   = 8,
	_vision_range:float = 5.0 * 16.0,
	_vision_width:float = 2.0 * 16.0)->void:
	focus_limit  = _focus_limit
	vision_range = _vision_range
	vision_width = _vision_width
	flag         = Flag.MEMORY	## Added to BaseComponent.Flag

## Adds or refreshes an entry for [param uid].
## Evicts the oldest entry if [member focus_limit] is reached.
func remember(
	uid:int,
	relation:Relation,
	position:Vector2,
	tick:int)->void:

	if entries.has(uid):
		## Refresh existing
		entries[uid].last_position = position
		entries[uid].last_tick     = tick
		entries[uid].relation      = relation
		return

	if entries.size() >= focus_limit:
		_evict_oldest()

	entries[uid] = MemoryEntry.new(uid, relation, position, tick)
## Builds the vision [Triangle2D] for this entity based on its [MovementComponent].
func build_vision_triangle(mov:MovementComponent)->Triangle2D:
	var faces_right:bool = true
	if mov.movable:
		faces_right = mov.movable.faces_right
	return Triangle2D.from_facing(
		mov.position,
		faces_right,
		vision_range,
		vision_width,
		vision_back_ratio)
## Returns all entries matching [param relation], sorted newest-first.
func get_by_relation(relation:Relation)->Array[MemoryEntry]:
	var result:Array[MemoryEntry] = []
	for entry:MemoryEntry in entries.values():
		if entry.relation == relation:
			result.append(entry)
	result.sort_custom(func(x:MemoryEntry, y:MemoryEntry)->bool:
		return x.last_tick > y.last_tick)
	return result

## Returns true if [param uid] is currently remembered.
func knows(uid:int)->bool:
	return entries.has(uid)
## Removes the entry for [param uid], if it exists.
func forget(uid:int)->void:
	entries.erase(uid)
## Evicts the entry with the lowest [member MemoryEntry.last_tick].
func _evict_oldest()->void:
	var oldest_uid:int  = -1
	var oldest_tick:int = 10_000
	for uid:int in entries:
		if entries[uid].last_tick < oldest_tick:
			oldest_tick = entries[uid].last_tick
			oldest_uid  = uid
	if oldest_uid != -1:
		entries.erase(oldest_uid)
## Single perception record.
class MemoryEntry:
	## UID of the remembered entity or item.
	var uid:int = -1
	## How this entity relates to the owner.
	var relation:Relation = Relation.NEUTRAL
	## World position where it was last observed.
	var last_position:Vector2 = Vector2.ZERO
	## [member REGISTRY.tick] value when this entry was last refreshed.
	var last_tick:int = 0

	func _init(
		_uid:int,
		_relation:Relation,
		_position:Vector2,
		_tick:int)->void:
			
		uid				= _uid
		relation		= _relation
		last_position	= _position
		last_tick		= _tick
