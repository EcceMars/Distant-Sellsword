class_name MemoryComponent
extends BaseComponent

enum Type {	
	CURIOSITY,		## Any type of non-classified memory (somewhat of a fallback)
	
	FOOD,			## Last few positions where food was found
	FRIEND,			## Last few positions where an alligned entity was seen
	HOME,			## Usually, the only nest position (can be more than one)
	PREY,			## Antagonistic entity that can be hunted
	RESOURCE,		## List of last seen resource positions
	THREAT,			## Will flee from this position
	WATER			## Last fresh water source found
	}

const Behavior = BehaviorComponent.Type
const Materia = MateriaComponent.Materia
const Species = HealthComponent.Species

@export var memory_capacity:int = 32
## Area of the vision triangle
@export var vision_range:Dictionary[String, float] = {
	'length': 14.0,			## Furthest point of the triangle
	'width': 6.0,			## How wide is the base of the triangle
	'back_ratio': 0.1		## Offset back the triangle, so the entity isn't too oblivious about its surroundings
	}
@export var vision_rate:float = 1.5
@export var focus_limit:int = 8		## How many catches can the entity make per [method look], i.e. its attention span.
@export var debug:bool = true		## Debugs the vision of the entity.

var _entries:Dictionary[Type, Dictionary] = {}
var _entry_n:int = 0

var _vision_frame:float = vision_rate

func _ready()->void:
	super()
	for type:Type in Type.values():
		_entries[type] = {}
	var home:Entry = Entry.new(Type.HOME, entity.get_ent_in_grid())
	_entries[Type.HOME] = { home.position: home }
	_entry_n += 1

func process()->void:
	_vision_frame += DIR.delta
	if _vision_frame >= vision_rate:
		look()
		_vision_frame = 0.0
	if _entry_n >= memory_capacity:
		_free_memory()
func look()->Array[Entry]:
	var triangle_vision:Triangle2D = _draw_vision_triangle()
	if debug: _debug_vision(triangle_vision)
	
	var tri_points:Array[Vector2i] = triangle_vision.get_tri_area_points()
	
	var detected:Array[Entry] = []
	detected += _detect_entities(tri_points)
	detected += [_detect_water(tri_points)]
	
	var clean_detected:Array[Entry] = []
	for item:Entry in detected:
		if item == null: continue
		if not item is Entry: continue
		
		clean_detected.append(item)
	var clamped_entries:Array[Entry] = _clamp_to_attention(clean_detected)
	for entry:Entry in clamped_entries:
		record(entry.type, entry)
	return clamped_entries
## Catches a temporary [Entry].
func catch(type:Type, what:Variant)->Entry:
	var has_mat:MateriaComponent = DIR.get_material(what)
	if not (type == Type.WATER or type == Type.HOME) and not has_mat:
		return null
	var new_entry:Entry = null
	match(type):
		Type.RESOURCE:
			var entry:Entry = _catch_resource_site(what)
			if not entry:
				return null
			return entry
		Type.WATER:
			var entry:Entry = _catch_water_source(what)
			if not entry:
				return null
			return entry
		_:
			new_entry = Entry.new(type, what.get_component(MovementComponent).position)
	return new_entry
## Will attempt to append or update a [Entry] to the memory arrays.
func record(type:Type, what:Variant)->Entry:
	var which:Array = _entries[type].values()

	var new_entry:Entry = Entry.new(type, what.position)
	for entry:Entry in which.duplicate():
		if what is Entity:
			if entry.same_entity(what):
				entry.update_memory(new_entry)
				return entry
	_entries[type] = { new_entry.position: new_entry }
	_entry_n += 1
	return _entries[type].values().back()
## Queries the memory lists for its entries using [Type].
func remember(type:Type, res_type:Materia = Materia.NONE)->Array:
	var found:Array[Entry] = []
	if res_type != Materia.NONE:
		for entry:Entry in _entries[Type.RESOURCE]:
			var mat:MateriaComponent = entry._entity.get_component(MateriaComponent)
			if not mat: continue
			if mat.materials.has(res_type):
				found.append(entry)
		return found
	return _entries[type].values()
func remember_closer(type:Type, res_type:Materia = Materia.NONE)->Entry:
	#print(Type.keys()[type], " ", res_type)
	var which:Array = remember(type, res_type)
	if not which: return null
	
	var mov:MovementComponent = entity.get_component(MovementComponent)
	var MIN:float = INF
	var closest:Entry = which.front()
	for entry:Entry in which:
		var dist:float = mov.position.distance_to(entry.position)
		if dist < MIN:
			MIN = dist
			closest = entry
			
	return closest
func forget(entry:Entry)->void:
	var which:Array[Entry] = remember(entry.type)
	which.erase(entry)
func _clamp_to_attention(entries:Array[Entry])->Array[Entry]:
	if entries.size() <= focus_limit:
		return entries
	
	var center:Vector2 = entity.get_ent_position()
	entries.sort_custom(func(a:Entry, b:Entry)->bool: 
		return a.position.distance_squared_to(center) < b.position.distance_squared_to(center)
		)
	for n:int in entries.size():
		_try_forget(entries[n])
		
	return entries.slice(0, focus_limit)
func _try_forget(entry:Entry)->void:
	if entry.type != Type.HOME: return
	forget(entry)
	
func _catch_resource_site(what:Variant)->Entry:
	if not what is Entity: return null
	var materials:Array[Materia] = what.get_material().materials
	var resource_type:Materia = Materia.STONE if Materia.STONE in materials else Materia.WOOD if Materia.WOOD in materials else Materia.NONE
	if resource_type == Materia.NONE: return null
	
	return Entry.new(Type.RESOURCE, what.get_ent_in_grid(), { 'resource_type': resource_type })
func _catch_water_source(what:Variant)->Entry:
	if not what is Vector2i: return null
	var mov:MovementComponent = entity.get_component(MovementComponent)
	
	var mid_point:Vector2 = mov.position.move_toward(what, 0.5)
	var closest_water:Vector2 = DIR.get_system(TerrainSystem).nearest_water(mid_point)
	if closest_water == DIR.NULL_POS:
		return null
	
	return Entry.new(Type.WATER, closest_water)
func _free_memory()->void:
	for type:Type in _entries:
		if type == Type.HOME: continue
		_entries[type].values().pop_back()
## Call this if the perception of the entity is altered (e.g. night, etc.)
func _draw_vision_triangle()->Triangle2D:
	var mov:MovementComponent = entity.get_component(MovementComponent)
	if not mov: return null
	return Triangle2D.from_facing(
		mov.position,
		mov.faces_right,
		vision_range,
		DIR.SCALE
	)
func _debug_vision(vision_triangle:Triangle2D)->void:
	if not vision_triangle: return
	var points:Array[Vector2i] = vision_triangle.get_tri_area_points()
	DIR.DEBUG.draw_tiles(points, Color.SKY_BLUE, 0.5)
#region Detection and classification
func _detect_entities(tri_points:Array[Vector2i])->Array[Entry]:
	var new_memories:Array[Entry] = []
	for point:Vector2i in tri_points:
		if new_memories.size() >= focus_limit * 2:
			break
		
		var others:Array = DIR.get_entities_at(point)
		for other:Entity in others:
			if other and other == entity: continue
			if debug: DIR.DEBUG.draw_tiles([other.get_ent_in_grid()], Color.RED, 1.0)

			var type:Type = _classify_entity(other)
			var entry:Entry = catch(type, other)
			new_memories.append(entry)
	return new_memories
func _detect_water(tri_points:Array[Vector2i])->Entry:
	var mov:MovementComponent = entity.get_component(MovementComponent)
	var nearest_water:Vector2i = DIR.NULL_POS
	var TER_SYS:TerrainSystem = DIR.get_system(TerrainSystem)
	
	for point:Vector2i in tri_points:
		if TER_SYS.is_water(point):
			var mid_point:Vector2 = mov.position.move_toward(Vector2(point), 0.5)
			nearest_water = MovementComponent.world_to_grid(TER_SYS.nearest_water(mid_point))
			if nearest_water != Vector2i(DIR.NULL_POS):
				break
	if nearest_water == DIR.NULL_GRID: return null

	return Entry.new(Type.WATER, nearest_water)
func _classify_entity(other:Entity)->Type:
	var self_behavior:BehaviorComponent = entity.get_component(BehaviorComponent)
	var other_mat:MateriaComponent = other.get_component(MateriaComponent)
	var self_health:HealthComponent = entity.get_component(HealthComponent)
	var other_health:HealthComponent = other.get_component(HealthComponent)
	
	
	match(self_behavior.type):
		Behavior.PREDATOR:
			# Is of the same specie
			if other_health.specie == self_health.specie:
				return Type.FRIEND
			# Has the ANIMAL material and can be eaten or hunted
			if Materia.ANIMAL in other_mat.materials:
				if other_health.specie == Species.ITEM:
					return Type.FOOD
				# Is a living entity and can be hunted
				return Type.PREY
		Behavior.PREY:
			# Preying plants could trick preys
			if Materia.PLANT in other_mat.materials:
				return Type.FOOD
			if other_health.specie == self_health.specie:
				return Type.FRIEND
			if other_health.specie != self_health.specie:
				return Type.THREAT
	return Type.CURIOSITY
	
#endregion
#region Update memories
func _update_typed(entry:Entry)->void:
	var which:Array[Entry] = remember(entry.type)
	which.erase(entry)
	which.append(entry)
## Memory entry data. Carries the [enum Type], the last seen [Vector2] position of the memory,
## and, if needed, a [Dictionary] data member, for context.
## TODO: an entity member should be added to make smarter AIs identify if an entity moved from
## its last seem position, forgeting the old memory.
class Entry:
	var _entity:Entity = null
	var type:Type = Type.CURIOSITY
	var position:Vector2 = DIR.NULL_POS
	var data:Dictionary = {}
	
	func _init(_type:Type, _position:Vector2, _description:Dictionary = {})->void:
		type = _type
		position = _position
		data = _description
	func same_entity(who:Entity)->bool:
		return _entity == who
	func _to_string()->String:
		return "%s at %s" % [Type.keys()[type], position]
