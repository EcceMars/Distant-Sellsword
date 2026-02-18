## Central registry for entity archetypes.
## Access via [member REGISTRY.AR_REG].
class_name ArchetypeRegistry
extends BaseRegistry

## Hardcoded archetype identifiers. Update when adding new types.
enum Type {
	ACTOR,
	BERRY,
	DUCK,
	TREE,
	VILLAGER
	}

## Maps each [enum Type] to its [EntityArchetype] script. Add new archetypes here.
var TYPES:Dictionary = {
	Type.ACTOR:		ActorType,
	Type.BERRY:		BerriesItemType,
	Type.DUCK:		DuckType,
	Type.TREE:		TreeType,
	Type.VILLAGER:	VillagerType,
	}

## Cached archetype instances, keyed by [enum Type].
var _instances:Dictionary[Type, EntityArchetype] = {}

func _init()->void:
	for type:Type in TYPES:
		_instances[type] = TYPES[type].new()

## Returns the [EntityArchetype] instance for [param type].
## Logs an error and returns null if not found.
func get_archetype(type:Type)->EntityArchetype:
	if not _instances.has(type):
		push_error("[ArchetypeRegistry] No archetype for: %s" % Type.find_key(type))
		return null
	return _instances[type]

## Spawns an entity from the archetype matching [param type].
## Returns the new entity UID, or -1 on failure.
func spawn(type:Type)->int:
	var archetype:EntityArchetype = get_archetype(type)
	if not archetype:
		return -1
	return archetype._build()
