## Central animation registry with auto-discovery and lazy loading.
## Scans animation directories at startup and provides clean access patterns.
class_name AnimationRegistry
extends RefCounted

## Animation categories mapped to directory paths
const CATEGORIES: Dictionary = {
	"actors": "res://assets/sprites/actors/",
	"vegetation": "res://assets/sprites/vegetation/",
	"structures": "res://assets/sprites/structures/",
	"items": "res://assets/sprites/items/",
	"effects": "res://assets/sprites/effects/"
}

## Cache for loaded SpriteFrames
var _cache:Dictionary[String, SpriteFrames] = {}
## Registry: key -> resource path
var _registry:Dictionary[String, String] = {}
## Reverse lookup: path -> key
var _path_to_key:Dictionary[String, String] = {}

func _ready() -> void:
	_scan_all_categories()
	print("[AnimationRegistry] Registered %d animations" % _registry.size())

## Scans all category directories for .tres animation files
func _scan_all_categories() -> void:
	for category: String in CATEGORIES:
		_scan_category(CATEGORIES[category])

## Scans a specific category directory
func _scan_category(dir_path:String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if not dir:
		push_warning("[AnimationRegistry] Cannot access directory: %s" % dir_path)
		return
	
	dir.list_dir_begin()
	var file_name:String = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var key: String = file_name.get_basename()
			var full_path: String = dir_path.path_join(file_name)
			
			_registry[key] = full_path
			_path_to_key[full_path] = key
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

## Gets SpriteFrames by key, loading and caching if needed
func get_frames(key:String)->SpriteFrames:
	# Return cached if available
	if _cache.has(key):
		return _cache[key]
	
	# Check if key exists in registry
	if not _registry.has(key):
		push_error("[AnimationRegistry] No animation registered for key: '%s'" % key)
		return null
	
	# Load and cache
	var resource:SpriteFrames = load(_registry[key]) as SpriteFrames
	if resource:
		_cache[key] = resource
		return resource
	
	push_error("[AnimationRegistry] Failed to load animation: %s" % _registry[key])
	return null

## Gets SpriteFrames without caching (useful for one-time loads)
func get_frames_no_cache(key: String) -> SpriteFrames:
	if not _registry.has(key):
		push_error("[AnimationRegistry] No animation registered for key: '%s'" % key)
		return null
	
	return load(_registry[key]) as SpriteFrames

## Checks if animation key exists
func has_animation(key: String) -> bool:
	return _registry.has(key)

## Gets all registered animation keys
func get_all_keys() -> Array[String]:
	var keys: Array[String] = []
	keys.assign(_registry.keys())
	return keys

## Gets all keys in a specific category
func get_keys_by_category(category: String) -> Array[String]:
	if not CATEGORIES.has(category):
		push_warning("[AnimationRegistry] Unknown category: %s" % category)
		return []
	
	var category_path: String = CATEGORIES[category]
	var keys: Array[String] = []
	
	for key: String in _registry:
		if _registry[key].begins_with(category_path):
			keys.append(key)
	
	return keys

## Gets animation path for a key
func get_anim_path(key:String)->String:
	return _registry.get(key, "")

## Clears the cache (frees memory)
func clear_cache() -> void:
	_cache.clear()

## Preloads specific animations into cache
func preload_animations(keys: Array[String]) -> void:
	for key: String in keys:
		if not _cache.has(key):
			get_frames(key)

## Preloads entire category into cache
func preload_category(category: String) -> void:
	var keys:Array[String] = get_keys_by_category(category)
	preload_animations(keys)

## Debug: Print all registered animations
func print_registry() -> void:
	print("\n=== Animation Registry ===")
	for category: String in CATEGORIES:
		var keys: Array[String] = get_keys_by_category(category)
		if keys.size() > 0:
			print("\n%s (%d):" % [category.capitalize(), keys.size()])
			for key: String in keys:
				var cached: String = " [cached]" if _cache.has(key) else ""
				print("  - %s%s" % [key, cached])
	print("\nTotal: %d animations" % _registry.size())
	print("Cached: %d animations" % _cache.size())
	print("=========================\n")
