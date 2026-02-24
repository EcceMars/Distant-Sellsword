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
var focus_limit:int = 32

# Vision parameters
var vision_range:float = 5.0 * REG.SCALE		## How far it sees
var vision_width:float = 2.0 * REG.SCALE		## How wide it sees
var vision_back_ratio:float = 0.01				## Small offset back

## [member REG.tick] value of the last perception update for this entity.
var last_update_tick:int = 0
## How many ticks between perception updates.
## Set by [BehaviorSystem] based on the active behavior.
var update_interval:int = 10

var draw_vision:bool = false
var redraw:bool = true

func _init(
	_focus_limit:int   = focus_limit,
	_vision_range:float = vision_range,
	_vision_width:float = vision_width)->void:
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
## Forces the entity to scan its immediate surroundings and update memory
## with all visible entities. Returns array of newly discovered uids.
func look(owner_uid:int, current_tick:int) -> Array[int]:
	var updated_uids:Array[int] = []
	
	# Get owner's position and vision triangle
	var mov:MovementComponent = REG.get_component(owner_uid, BaseComponent.Flag.MOVEMENT)
	if not mov:
		return updated_uids
	
	var BEHAV_SYS:BehaviorSystem = REG.get_system(BehaviorSystem)
	if not BEHAV_SYS: 
		return []
	
	var vision_triangle:Triangle2D = build_vision_triangle(mov)
	if draw_vision and redraw:
		_debug_draw_vision_triangle(owner_uid, vision_triangle)
	# Get all entities with visual components (visible things)
	var visible_uids:Array[int] = REG.get_entities_by(BaseComponent.Flag.VISUAL)
	
	for target_uid:int in visible_uids:
		if target_uid == owner_uid:
			continue  # Skip self
			
		# Get target's position
		var target_mov:MovementComponent = REG.get_component(target_uid, BaseComponent.Flag.MOVEMENT)
		if not target_mov:
			continue
			
		# Check if target is within vision triangle
		if not vision_triangle.has_point(target_mov.position):
			continue

		# Determine relation to target
		var relation:Relation = BEHAV_SYS._classify(target_uid)
		
		# Remember what we saw
		remember(target_uid, relation, target_mov.position, current_tick)
		updated_uids.append(target_uid)
	
	last_update_tick = current_tick
	redraw = true
	return updated_uids
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
	var oldest_tick:int = 100_000_000_000
	for uid:int in entries:
		if entries[uid].last_tick < oldest_tick:
			oldest_tick = entries[uid].last_tick
			oldest_uid  = uid
	if oldest_uid != -1:
		entries.erase(oldest_uid)
## Internal debug: draws the vision triangle (green overlay) on the canvas.
## Auto-cleans after 1s so the scene stays clean.
func _debug_draw_vision_triangle(owner_uid:int, triangle:Triangle2D)->void:
	redraw = false
	var vis:VisualComponent = REG.get_component(owner_uid, BaseComponent.Flag.VISUAL)
	if not vis or not vis.sprite: return

	var poly:Polygon2D = Polygon2D.new()
	poly.name = "VisionDebug_%d" % owner_uid
	poly.color = Color(0.2, 1.0, 0.4, 0.22)
	## Vertices are already in world space — no offset needed
	poly.polygon = PackedVector2Array([triangle.a, triangle.b, triangle.c])

	REG.ENT_LAYER.add_child(poly)

	var t:SceneTreeTimer = vis.sprite.get_tree().create_timer(1.0)
	t.timeout.connect(poly.queue_free)
	t.timeout.connect(func()->void: redraw = true)
## Single perception record.
class MemoryEntry:
	## UID of the remembered entity or item.
	var uid:int = -1
	## How this entity relates to the owner.
	var relation:Relation = Relation.NEUTRAL
	## World position where it was last observed.
	var last_position:Vector2 = -Vector2.ONE
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
	func _to_string()->String:
		return "%d (%d) was last seen at " % [uid, relation] + str(last_position)
