## Central registry for AI behavior resources.
## Loads and caches behavior instances.
class_name BehaviorRegistry
extends BaseRegistry

const BEHAV_CFLAG:BaseComponent.Flag = BaseComponent.Flag.BEHAVIOR

var BEHAVIORS:Dictionary[BaseBehavior.Type, GDScript] = {
	BaseBehavior.Type.FLEE:		FleeBehavior,
	BaseBehavior.Type.IDLE:		IdleBehavior,
	BaseBehavior.Type.INPUT:	InputBehavior,
	BaseBehavior.Type.REST:		RestBehavior,
	BaseBehavior.Type.WANDER:	WanderBehavior,
}

## Cache for behavior instances
var _cache:Dictionary[BaseBehavior.Type, BaseBehavior] = {}
func get_behavior(uid:int, name:String)->BaseBehavior:
	if not REG.get_component(uid, REG.C_FLAGS.BEHAV): return null
	return REG.get_component(uid, REG.C_FLAGS.BEHAV).get_behavior(name)
func has_behavior(uid:int, key:BaseBehavior.Type)->bool:
	var behav_component:BehaviorComponent = REG.get_component(uid, BEHAV_CFLAG)
	if not behav_component: return false
	return not behav_component.behaviors.get(key, true)
## Gets a behavior instance by key, creating and loading it to [_cache] if needed.
func load_behavior(key:BaseBehavior.Type)->BaseBehavior:
	if _cache.has(key): return _cache[key]
	if not BEHAVIORS.has(key):
		push_warning("[BehaviorRegistry] No behavior registered for key:'%s'" % key)
		return null
	
	var behavior:BaseBehavior = BEHAVIORS[key].new()
	_cache[key] = behavior
	return behavior
## Gets behaviors from a list of keys
func load_behaviors(keys:Array[BaseBehavior.Type])->Array[BaseBehavior]:
	var behaviors:Array[BaseBehavior] = []
	
	for key:BaseBehavior.Type in keys:
		var behavior:BaseBehavior = load_behavior(key)
		if behavior:
			behaviors.append(behavior)
	
	return behaviors
## Clears the cache
func clear_cache() -> void:
	_cache.clear()
## Print registry info
func _to_string()->String:
	var message:String = "\n=== Behavior Registry ===\nBehavior Types (%d):" % BEHAVIORS.size()
	for key in BEHAVIORS:
		var cached:String = " [cached]" if _cache.has(key) else ""
		message += "\n  - %s%s" % [key, cached]
	message += "\n=========================\n"
	return message
