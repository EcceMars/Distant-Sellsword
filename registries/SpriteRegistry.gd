class_name SpriteRegistry
extends BaseRegistry

const CATEGORIES:Dictionary[String, String] = REG.DATA.SPRITES.CATEGORIES

## Cache for loaded SpriteFrames
var _cache:Dictionary[String, SpriteFrames] = {}
## Registry: key -> resource path
var _registry:Dictionary[String, String] = {}
## Reverse lookup: path -> key
var _path_to_key:Dictionary[String, String] = {}

func _init()->void:
	_scan_all_categories()

## Gets SpriteFrames by key, loading and caching if needed
func get_frames(key:String)->SpriteFrames:
	# Return cached if available
	if _cache.has(key):
		return _cache[key]
	
	# Check if key exists in registry
	if not _registry.has(key):
		push_error("[SpriteRegistry] No animation registered for key: '%s'" % key)
		return null
	
	# Load and cache
	var resource:SpriteFrames = load(_registry[key])
	if resource:
		_cache[key] = resource
		return resource
	
	push_error("[SpriteRegistry] Failed to load animation: %s" % _registry[key])
	return null
## Gets SpriteFrames without caching (one-time loads)
func get_frames_no_cache(key:String)->SpriteFrames:
	if not _registry.has(key):
		push_error("[SpriteRegistry] No frames registered for key: '%s'" % key)
		return null
	
	return load(_registry[key])
func get_default_anim_name(sprite_frames:SpriteFrames)->String:
	var keys:PackedStringArray = sprite_frames.get_animation_names()
	if not keys: return ""
	if "idle" in keys:
		return "idle"
	if "static" in keys:
		return "static"
	if "default" in keys:
		return "default"
	return keys[0]
## Returns the texture of a [SpriteFrames]
func get_texture(sprite_frames:SpriteFrames, key:String = "", at:int = 0)->Texture2D:
	if not sprite_frames: return null
		
	var keys:Array[String] = sprite_frames.get_animation_names()
	if not keys: return null
	
	if keys.has(key):
		if sprite_frames.get_frame_count(key) < at -1:
			return sprite_frames.get_frame_texture(key, 0)
		return sprite_frames.get_frame_texture(key, at)
	return null
## Scans all category directories for .tres (assumed SpriteFrames)
func _scan_all_categories()->void:
	for category:String in CATEGORIES:
		_scan_category(CATEGORIES.get(category))
## Scans a specific category directory
func _scan_category(dir_path:String)->void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if not dir:
		push_warning("[SpriteRegistry] Cannot access directory: %s" % dir_path)
		return
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var key: String = file_name.get_basename()
			var full_path: String = dir_path.path_join(file_name)
			
			_registry[key] = full_path
			_path_to_key[full_path] = key
		
		file_name = dir.get_next()
	dir.list_dir_end()
## Gets all keys in a specific category
func get_keys_by_category(category: String) -> Array[String]:
	if not CATEGORIES.has(category):
		push_warning("[SpriteRegistry] Unknown category: %s" % category)
		return []
	
	var category_path:String = CATEGORIES[category]
	var keys: Array[String] = []
	
	for key: String in _registry:
		if _registry[key].begins_with(category_path):
			keys.append(key)
	
	return keys
func _to_string() -> String:
	var message:String = "\n=== SpriteRegistry ==="
	for category:String in CATEGORIES:
		var keys:Array[String] = get_keys_by_category(category)
		if keys.size() > 0:
			message += "\n%s (%d):\n" % [category.capitalize(), keys.size()]
			for key: String in keys:
				var cached = " [cached]" if _cache.has(key) else ""
				message += "  - %s%s\n" % [key, cached]
	message += "\nTotal: %d assets" % _registry.size()
	message += "\nCached: %d frames" % _cache.size()
	message += "\n=========================\n"
	return message
