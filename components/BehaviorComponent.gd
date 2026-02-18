class_name BehaviorComponent
extends BaseComponent

const TYPES = BaseBehavior.Type

## Current behavior
var active_behavior:BaseBehavior = null
## List of all behaviors this entity has
var behaviors:Dictionary[BaseBehavior.Type, BaseBehavior] = {}

func _init(behavior_keys:Array[BaseBehavior.Type])->void:
	flag = Flag.BEHAVIOR
	if behavior_keys.is_empty():
		push_warning("Empty behavior_keys. Pushing IDLE as fallback.")
	
	for key:BaseBehavior.Type in behavior_keys:
		var behavior:BaseBehavior = REG.BE_REG.load_behavior(key)
		behaviors[key] = behavior
	if not TYPES.IDLE in behavior_keys: active_behavior = REG.BE_REG.load_behavior(behavior_keys.front())
	if not active_behavior: active_behavior = REG.BE_REG.load_behavior(TYPES.IDLE)
func add_behavior(behavior:BaseBehavior, override:bool = false)->BaseBehavior:
	if not override and behavior.get(behavior.behavior_name): return null
	behaviors[behavior.flag] = behavior
	return behaviors[behavior.flag]
func get_behavior(name:String)->BaseBehavior:
	return behaviors.get(name)
func has_behavior(name:String)->bool:
	return behaviors.has(name)
func _to_string()->String:
	var message:String = get_script().get_global_name()
	var list:String = ": { "
	for behavior in behaviors.keys():
		list += str(behavior) + " "
	list += "} -> Act: " + str(active_behavior.get_script())
	return message + list
