## Central registry for entity archetypes.
## Access via [member REGISTRY.AR_REG].
class_name ArchetypeRegistry
extends BaseRegistry

## Maps each [enum Type] to its [EntityType] script. Add new archetypes here.
const TYPES = REG.DATA.ARCHETYPES.TYPES

## Cached archetype instances, keyed by [enum Type].
var _instances:Dictionary[TYPES, EntityType] = {}

## Returns the [EntityType] instance for [param type].
## Logs an error and returns null if not found.
func get_archetype(type:TYPES, specific:String)->EntityType:
	if not type in TYPES.values():
		push_error("[ArchetypeRegistry] No archetype for: %s" % TYPES.find_key(type), " using ", type)
		return null
	_instances[type] = REG.DATA.ARCHETYPES.get_type(type, specific)
	return _instances[type]

## Spawns an entity from the archetype matching [param type].
## Returns the new entity UID, or -1 on failure.
func spawn(type:TYPES, specific:String = "", spawn_position:Vector2 = -Vector2.ONE)->int:
	var archetype:EntityType = get_archetype(type, specific)
	if not archetype:
		return -1
	return archetype._build(spawn_position)
