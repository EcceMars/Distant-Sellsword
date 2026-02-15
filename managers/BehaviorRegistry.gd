## Central registry for AI behavior resources.
## Loads and caches behavior instances.
class_name BehaviorRegistry
extends RefCounted

## Behavior presets - common behavior configurations
const PRESETS:Dictionary = {
	"villager": ["flee", "rest", "seek_food", "wander", "idle"],
	"guard": ["flee", "rest", "patrol", "idle"],
	"merchant": ["rest", "idle"],
	"animal": ["flee", "seek_food", "wander", "idle"],
	"peaceful": ["wander", "idle"],
}

## Cache for behavior instances
var _cache:Dictionary[String, Behavior] = {}

## Available behavior scripts
var _behavior_scripts:Dictionary[String, Script] = {
	"flee": FleeBehavior,
	"rest": RestBehavior,
	"seek_food": SeekFoodBehavior,
	"wander": WanderBehavior,
	"idle": IdleBehavior,
}

func _ready() -> void:
	print("[BehaviorRegistry] Initialized with %d behavior types" % _behavior_scripts.size())

## Gets a behavior instance by key, creating if needed
func get_behavior(key:String) -> Behavior:
	# Return cached if available
	if _cache.has(key):
		return _cache[key]
	
	# Check if script exists
	if not _behavior_scripts.has(key):
		push_error("[BehaviorRegistry] No behavior registered for key:'%s'" % key)
		return null
	
	# Create new instance
	var behavior:Behavior = _behavior_scripts[key].new()
	_cache[key] = behavior
	return behavior

## Gets behaviors for a preset configuration
func get_preset(preset_key:String) -> Array[Behavior]:
	if not PRESETS.has(preset_key):
		push_warning("[BehaviorRegistry] Unknown preset:%s" % preset_key)
		return []
	
	var behavior_keys:Array = PRESETS[preset_key]
	var behaviors:Array[Behavior] = []
	
	for key:String in behavior_keys:
		var behavior:Behavior = get_behavior(key)
		if behavior:
			behaviors.append(behavior)
	
	return behaviors

## Gets behaviors from a list of keys
func get_behaviors(keys:Array[String]) -> Array[Behavior]:
	var behaviors:Array[Behavior] = []
	
	for key:String in keys:
		var behavior:Behavior = get_behavior(key)
		if behavior:
			behaviors.append(behavior)
	
	return behaviors

## Registers a custom behavior script
func register_behavior(key:String, script:Script) -> void:
	if _behavior_scripts.has(key):
		push_warning("[BehaviorRegistry] Overwriting behavior '%s'" % key)
	_behavior_scripts[key] = script
	# Clear cache for this key if it exists
	_cache.erase(key)

## Checks if behavior key exists
func has_behavior(key:String) -> bool:
	return _behavior_scripts.has(key)

## Gets all registered behavior keys
func get_all_keys() -> Array[String]:
	var keys:Array[String] = []
	keys.assign(_behavior_scripts.keys())
	return keys

## Gets all preset keys
func get_preset_keys() -> Array[String]:
	var keys:Array[String] = []
	keys.assign(PRESETS.keys())
	return keys

## Clears the cache
func clear_cache() -> void:
	_cache.clear()

## Debug:Print registry info
func print_registry() -> void:
	print("\n=== Behavior Registry ===")
	print("\nBehavior Types (%d):" % _behavior_scripts.size())
	for key in _behavior_scripts:
		var cached:String = " [cached]" if _cache.has(key) else ""
		print("  - %s%s" % [key, cached])
	
	print("\nPresets (%d):" % PRESETS.size())
	for preset_key in PRESETS:
		print("  - %s:%s" % [preset_key, PRESETS[preset_key]])
	
	print("=========================\n")
