## Central registry for entity archetypes.
## Provides lookup and spawning interface for all entity blueprints.
class_name ArchetypeRegistry
extends BaseRegistry

## WARNING: this should be updated with all types that are added to the project
var ARCHETYPES:Dictionary[String, Script] = {
	## Actors
	"actor": ActorType,
	"villager": VillagerType,
	"duck": DuckType,
	#
	## Items
	"berries": BerriesItemType,
	#"water": WaterItemType,
	#"wood": WoodItemType,
	#"stone": StoneItemType,
	#
	# Objects
	"tree": TreeType,
	}

## Registered archetypes by key name
var _archetypes:Dictionary[String, EntityArchetype] = {}

func _init()->void:
	_register_default_archetypes()

## Register all built-in archetypes
func _register_default_archetypes()->void:
	for type:String in ARCHETYPES:
		register(type, ARCHETYPES[type].new())
## Register a custom archetype
## [param key] - Lookup key for spawning
## [param archetype] - The archetype instance or resource
func register(key:String, archetype:EntityArchetype)->void:
	if _archetypes.has(key):
		push_warning("[ArchetypeRegistry] Overwriting archetype '%s'" % key)
	_archetypes[key] = archetype

## Get archetype by key
func get_archetype(key:String)->EntityArchetype:
	if not _archetypes.has(key):
		push_error("[ArchetypeRegistry] No archetype found for key: %s" % key)
		return null
	return _archetypes[key]

## [param key] - Archetype identifier
## [param overrides] - Runtime property overrides
func register_entity(key:String, overrides:Dictionary = {})->int:
	var archetype:EntityArchetype = get_archetype(key)
	if not archetype:
		return -1
	return archetype.create(overrides)
func random_position()->Vector2:
	return Vector2(
		randi() % REG.WIDTH * REG.SCALE,
		randi() % REG.HEIGHT * REG.SCALE
	)
