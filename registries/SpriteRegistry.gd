class_name SpriteRegistry
extends BaseRegistry

## Animation categories mapped to directory paths
const CATEGORIES: Dictionary = {
	"actors": "res://assets/sprites/actors/",
	"vegetation": "res://assets/sprites/vegetation/",
	"structures": "res://assets/sprites/structures/",
	"items": "res://assets/sprites/items/",
	"effects": "res://assets/sprites/effects/"
	}

## Cache for loaded SpriteFrames
var _a_cache:Dictionary[String, SpriteFrames] = {}
## Cache for loaded Texture2D
var _t_cache:Dictionary[String, Texture2D] = {}
## Registry: key -> resource path
var _registry:Dictionary[String, String] = {}
## Reverse lookup: path -> key
var _path_to_key:Dictionary[String, String] = {}

func _init()->void:
	_scan_all_categories()

## Loads a [Texture2D], usually for [enum VisualComponent.SpriteType.STATIC]
func get_texture(key:String)->Texture2D:
	# Return cached if available
	if _t_cache.has(key):
		return _t_cache[key]
	
	# Check if key exists in registry
	if not _registry.has(key):
		push_error("[SpriteRegistry] No texture registered for key: '%s'" % key)
		return null
	
	# Load and cache
	var resource:Texture2D = load(_registry[key]) as Texture2D
	if resource:
		_t_cache[key] = resource
		return resource
	
	push_error("[SpriteRegistry] Failed to load texture: %s" % _registry[key])
	return null
## Gets SpriteFrames by key, loading and caching if needed
func get_frames(key:String)->SpriteFrames:
	# Return cached if available
	if _a_cache.has(key):
		return _a_cache[key]
	
	# Check if key exists in registry
	if not _registry.has(key):
		push_error("[SpriteRegistry] No animation registered for key: '%s'" % key)
		return null
	
	# Load and cache
	var resource:SpriteFrames = load(_registry[key]) as SpriteFrames
	if resource:
		_a_cache[key] = resource
		return resource
	
	push_error("[SpriteRegistry] Failed to load animation: %s" % _registry[key])
	return null
## Gets SpriteFrames without caching (useful for one-time loads)
func get_frames_no_cache(key:String) -> SpriteFrames:
	if not _registry.has(key):
		push_error("[SpriteRegistry] No animation registered for key: '%s'" % key)
		return null
	
	return load(_registry[key]) as SpriteFrames
## Scans all category directories for .tres
func _scan_all_categories()->void:
	for category:String in CATEGORIES:
		_scan_category(CATEGORIES[category])
## Scans a specific category directory
func _scan_category(dir_path:String)->void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if not dir:
		push_warning("[SpriteRegistry] Cannot access directory: %s" % dir_path)
		return
	
	dir.list_dir_begin()
	var file_name:String = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var key:String = file_name.get_basename()
			var full_path:String = dir_path.path_join(file_name)
			
			_registry[key] = full_path
			_path_to_key[full_path] = key
		
		file_name = dir.get_next()
	dir.list_dir_end()
## Gets all keys in a specific category
func get_keys_by_category(category: String) -> Array[String]:
	if not CATEGORIES.has(category):
		push_warning("[SpriteRegistry] Unknown category: %s" % category)
		return []
	
	var category_path: String = CATEGORIES[category]
	var keys: Array[String] = []
	
	for key: String in _registry:
		if _registry[key].begins_with(category_path):
			keys.append(key)
	
	return keys
func _to_string()->String:
	var message:String = "\n=== SpriteRegistry ==="
	for category:String in CATEGORIES:
		var keys:Array[String] = get_keys_by_category(category)
		if keys.size() > 0:
			message += "\n%s (%d):\n" % [category.capitalize(), keys.size()]
			for key:String in keys:
				var cached = " [cached]" if key in [_a_cache, _t_cache] else ""
				message += "  - %s%s\n" % [key, cached]
	message += "\nTotal: %d assets" % _registry.size()
	message += "\nCached: %d animations" % (_a_cache.size())
	message += "\nCached: %d textures" % (_t_cache.size())
	
	message += "\n=========================\n"
	return message
