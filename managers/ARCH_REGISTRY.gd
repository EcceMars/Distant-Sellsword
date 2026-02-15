## Central registry for entity archetypes.
## Provides lookup and spawning interface for all entity blueprints.
class_name ArchetypeRegistry
extends RefCounted

## WARNING: this should be updated with all types that are added to the project
var ARCHETYPES:Dictionary[String, Script] = {
	"actor": ActorType,
	"tree": TreeType,
	"villager": VillagerType
	}

## Registered archetypes by key name
var _archetypes: Dictionary[String, EntityArchetype] = {}

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

## Spawn entity from archetype key
## [param key] - Archetype identifier
## [param REG] - The ECS registry
## [param position] - Spawn position
## [param overrides] - Runtime property overrides
func spawn(key:String, REG:REGISTRY, position:Vector2 = Vector2.ZERO, overrides:Dictionary = {})->int:
	var archetype:EntityArchetype = get_archetype(key)
	if not archetype:
		return -1
	return archetype.spawn(REG, position, overrides)

## Check if archetype exists
func has_archetype(key:String)->bool:
	return _archetypes.has(key)

## Get all registered archetype keys
func get_all_keys()->Array[String]:
	var keys:Array[String] = []
	keys.assign(_archetypes.keys())
	return keys

## Load archetypes from resource files (for data-driven approach)
## [param directory] - Path to directory containing .tres archetype resources
func load_from_directory(directory:String)->void:
	var dir:DirAccess = DirAccess.open(directory)
	if not dir:
		push_warning("[ArchetypeRegistry] Cannot open directory: %s" % directory)
		return
	
	dir.list_dir_begin()
	var file_name:String = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource_path:String = directory.path_join(file_name)
			var archetype:EntityArchetype = load(resource_path) as EntityArchetype
			
			if archetype:
				var key:String = file_name.get_basename()
				register(key, archetype)
			else:
				push_warning("[ArchetypeRegistry] Failed to load: %s" % resource_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
